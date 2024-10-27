#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use YAML qw[ Dump ];

use A;
use Allium::Optree::Dumper;

sub foo {
    say 10, 20, 30, 40;
}

class Allium::Optree::B::Loader {
    use B::Generate;

    field %built;

    sub __empty_sub_to_clone {}

    method load ($raw) {
        # create all the ops first ...
        my %op_index;
        my @ops = map { $op_index{ $_->{addr} } = $self->build_op( $_, +{ %op_index } ) }
                  # 2. construct the op from raw and replace it in the index
                  #    (NOTE: we make a copy of %op_index for build_op to ensure it does
                  #     not overwrite outside of build_op while it is reading inside)
                  map { $op_index{ $_->{addr} } = $_ }
                  # 1. create the initial index of ops from serialized addrs
                  $raw->{ops}->@*;
                  # ^^ read from bottom up

        # 3. Everything should be connected via first,last,other
        #    now we need to restore the next & sibling pointers
        foreach my ($i, $op) (indexed @ops) {
            my $raw_op = $raw->{ops}->[$i];
            $op->next    ( $op_index{ $raw_op->{next}    } ) if $raw_op->{next};
            $op->sibling ( $op_index{ $raw_op->{sibling} } ) if $raw_op->{sibling};
        }

        # now extract the root & start from the index ...
        my $root  = $op_index{ $raw->{root}  } // die "Could not find(root) addr=".$raw->{root};
        my $start = $op_index{ $raw->{start} } // die "Could not find(start) addr=".$raw->{start};

        my $sub = B::svref_2object(\&__empty_sub_to_clone)->NEW_with_start (
            $root,
            $start
        )->object_2svref;

        return $sub;
    }

    method build_op ($raw, $index) {
        return $built{ $raw->{addr} } if exists $built{ $raw->{addr} };

        my $opclass = 'B::'.$raw->{type};
        my $op_num  = B::opnumber($raw->{name});

        my @args;
        if ($opclass eq 'B::COP') {
            @args = ( $raw->{public_flags}->{bits}, $op_num, undef );
        }
        else {
            #say "op($opclass) -> Found ".B::opnumber($raw->{name})." for ".$raw->{name};

            @args = ( $op_num, $raw->{public_flags}->{bits} );

            if ($opclass eq 'B::UNOP') {
                push @args => ( $self->build_op( $index->{ $raw->{first} }, $index ) );
            }
            elsif ($opclass eq 'B::BINOP' || $opclass eq 'B::LISTOP') {
                push @args => (
                    $self->build_op( $index->{ $raw->{first} }, $index ),
                    $self->build_op( $index->{ $raw->{last} }, $index )
                );
            }
            elsif ($opclass eq 'B::LOGOP') {
                push @args => (
                    $self->build_op( $index->{ $raw->{first} }, $index ),
                    $self->build_op( $index->{ $raw->{other} }, $index )
                );
            }
            elsif ($opclass eq 'B::SVOP' && $raw->{name} eq 'const') {
                push @args => ( int(rand(10)) );
            }
        }

        my $op = $opclass->new( @args );
        $op->private( $raw->{private_flags}->{bits} );

        $built{ $raw->{addr} } = $op;
        #say join ', ' => $op->type, $op->name, ${ $op }, $op;

        return $op;
    }
}

sub pprint ($op) { say($op->addr,('  ' x $op->depth),join ':' => $op->type, $op->name) }

CHECK {

    my $orig = A->new->disassemble(\&foo);
    my $dump = Allium::Optree::Dumper->new->dump($orig);
    #say Dump $dump;
    $orig->walk(top_down => \&pprint);

    my $foo2 = Allium::Optree::B::Loader->new->load($dump);

    *main::foo2 = $foo2;

}

#{
#    my $orig = A->new->disassemble(\&foo2);
#    my $dump = Allium::Optree::Dumper->new->dump($orig);
#    say Dump $dump;
#    $orig->walk(top_down => \&pprint);
#}

say "... foo";
foo();
say "... foo2";
foo2();
say "... ";

done_testing;
