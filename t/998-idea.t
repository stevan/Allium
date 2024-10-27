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

    method load ($optree) {
        # build all the ops ...
        my @ops;
        $optree->walk(top_down => sub ($op) {
            push @ops => $op, $self->build_or_get_op( $op )
        });

        # connect the next/sibling pointers ...
        foreach my ($old, $new) (@ops) {
            $new->next    ( $self->build_or_get_op( $old->next    )) if $old->has_next;
            $new->sibling ( $self->build_or_get_op( $old->sibling )) if $old->has_sibling;
        }

        # now extract the root & start
        my $root  = $self->build_or_get_op( $optree->root  );
        my $start = $self->build_or_get_op( $optree->start );

        my $sub = B::svref_2object(\&__empty_sub_to_clone)->NEW_with_start (
            $root,
            $start
        )->object_2svref;

        return $sub;
    }

    method build_or_get_op ($op) {
        return $built{ $op->addr } if exists $built{ $op->addr };

        my $opclass = 'B::'.$op->type;
        my $op_num  = B::opnumber($op->name);

        my @args;
        if ($opclass eq 'B::COP') {
            @args = ( $op->public_flags->bits, $op_num, undef );
        }
        else {
            #say "op($opclass) -> Found ".B::opnumber($op->{name})." for ".$op->{name};

            @args = ( $op_num, $op->public_flags->bits );

            if ($opclass eq 'B::UNOP') {
                push @args => ( $self->build_op( $op->first ) );
            }
            elsif ($opclass eq 'B::BINOP' || $opclass eq 'B::LISTOP') {
                push @args => (
                    $self->build_op( $op->first ),
                    $self->build_op( $op->last )
                );
            }
            elsif ($opclass eq 'B::LOGOP') {
                push @args => (
                    $self->build_op( $op->first ),
                    $self->build_op( $op->other )
                );
            }
            elsif ($opclass eq 'B::SVOP' && $op->name eq 'const') {
                push @args => ( int(rand(10)) );
            }
        }

        my $b_op = $opclass->new( @args );
        $b_op->private( $op->private_flags->bits );

        $built{ $op->addr } = $b_op;
        #say join ', ' => $op->type, $op->name, ${ $op }, $op;

        return $b_op;
    }
}

sub pprint ($op) { say($op->addr,('  ' x $op->depth),join ':' => $op->type, $op->name) }

CHECK {

    my $orig = A->new->disassemble(\&foo);
    #my $dump = Allium::Optree::Dumper->new->dump($orig);
    #say Dump $dump;
    $orig->walk(top_down => \&pprint);

    my $foo2 = Allium::Optree::B::Loader->new->load($orig);

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
