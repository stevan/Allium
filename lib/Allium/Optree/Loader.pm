
use v5.40;
use experimental qw[ class ];

use Allium::Optree;
use Allium::Operations;

class Allium::Optree::Loader {

    method load ($raw) {

        my @ops;
        my %op_index;
        foreach my $raw_op ( $raw->{ops}->@* ) {
            my $op = Allium::Operations->build(
                $raw_op->{type}, (
                    name          => $raw_op->{name},
                    addr          => $raw_op->{addr},
                    is_nullified  => !!($raw_op->{is_nullified}),
                    public_flags  => $self->build_public_flags($raw_op->{public_flags}),
                    private_flags => $self->build_private_flags($raw_op->{private_flags}),
                )
            );
            push @ops => $op;
            $op_index{ $op->addr } = $op;
        }

        foreach my ($i, $op) (indexed @ops) {
            my $raw_op = $raw->{ops}->[$i];
            $op->next    = $op_index{ $raw_op->{next}    } if $raw_op->{next};
            $op->sibling = $op_index{ $raw_op->{sibling} } if $raw_op->{sibling};
            $op->parent  = $op_index{ $raw_op->{parent}  } if $raw_op->{parent};
            $op->first   = $op_index{ $raw_op->{first}   } if $raw_op->{first};
            $op->last    = $op_index{ $raw_op->{last}    } if $raw_op->{last};
            $op->other   = $op_index{ $raw_op->{other}   } if $raw_op->{other};
        }

        my $root  = $op_index{ $raw->{root}  } // die "Could not find(root) addr=".$raw->{root};
        my $start = $op_index{ $raw->{start} } // die "Could not find(start) addr=".$raw->{start};

        return Allium::Optree->new( root => $root, start => $start );
    }

    method build_public_flags ($flags) {
        Allium::Flags::Operation::PublicFlags->new( %$flags );
    }

    method build_private_flags ($flags) {
        Allium::Flags::Operation::PrivateFlags->new( %$flags );
    }

}
