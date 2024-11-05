
use v5.40;
use experimental qw[ class ];

use Allium::Environment;
use Allium::Optree;
use Allium::Operations;

class Allium::Optree::Loader {

    method load ($raw) {

        my $pad = $self->build_pad($raw);

        my @ops;
        my %op_index;
        foreach my $raw_op ( $raw->{ops}->@* ) {
            my $op = Allium::Operations->build(
                $raw_op->{type}, (
                    name          => $raw_op->{name},
                    addr          => $raw_op->{addr},
                    is_nullified  => !!($raw_op->{is_nullified}),
                    is_optimized  => !!($raw_op->{is_optimized}),
                    pad_target    => $raw_op->{pad_target},
                    public_flags  => $self->build_public_flags($raw_op->{public_flags}),
                    private_flags => $self->build_private_flags($raw_op->{private_flags}),
                )
            );
            push @ops => $op;
            $op_index{ $op->addr } = $op;
        }

        foreach my ($i, $op) (indexed @ops) {
            my $raw_op = $raw->{ops}->[$i];
            $op->next    = $op_index{ $raw_op->{next}    } if exists $raw_op->{next};
            $op->sibling = $op_index{ $raw_op->{sibling} } if exists $raw_op->{sibling};
            $op->parent  = $op_index{ $raw_op->{parent}  } if exists $raw_op->{parent};
            $op->first   = $op_index{ $raw_op->{first}   } if exists $raw_op->{first};
            $op->last    = $op_index{ $raw_op->{last}    } if exists $raw_op->{last};
            $op->other   = $op_index{ $raw_op->{other}   } if exists $raw_op->{other};

            $self->build_op_specific_data($raw_op, $op, \%op_index, $pad);
        }

        my $root  = $op_index{ $raw->{root}  } // die "Could not find(root) addr=".$raw->{root};
        my $start = $op_index{ $raw->{start} } // die "Could not find(start) addr=".$raw->{start};

        return Allium::Optree->new( root => $root, start => $start, pad => $pad );
    }

    method build_pad ($raw) {
        my $pad = Allium::Pad->new;
        foreach my $entry ($raw->{pad}->@*) {
            $pad->add_entry(
                Allium::Pad::Entry->new(
                    name      => $entry->{name},
                    stash     => $entry->{stash},
                    flags     => $self->build_pad_flags( $entry->{flags} ),
                    cop_range => [ $entry->{cop_range}->@* ]
                )
            );
        }
        return $pad;
    }

    method build_op_specific_data ($raw, $op, $op_index, $pad) {
        if ($op isa Allium::Operation::LISTOP) {
            $op->num_children = $raw->{num_children};
        }

        if ($op isa Allium::Operation::LOOP) {
            $op->redo_op = $op_index->{ $raw->{redo_op} } if exists $raw->{redo_op};
            $op->next_op = $op_index->{ $raw->{next_op} } if exists $raw->{next_op};
            $op->last_op = $op_index->{ $raw->{last_op} } if exists $raw->{last_op};
        }

        if ($op isa Allium::Operation::PVOP) {
            $op->pv = $raw->{pv};
        }

        if ($op isa Allium::Operation::COP) {
            $op->label      = $raw->{label};
            $op->stash      = $raw->{stash};
            $op->file       = $raw->{file};
            $op->cop_seq    = $raw->{cop_seq};
            $op->line       = $raw->{line};
            $op->warnings   = $raw->{warnings};
            $op->hints      = $raw->{hints};
            $op->hints_hash = $raw->{hints_hash};
            # XXX: $op->io is IGNORED for now
        }

        if ($op isa Allium::Operation::PADOP) {
            $op->pad_index = $raw->{pad_index};
        }

        if ($op isa Allium::Operation::SVOP) {
            ; # no-op for now
        }

        if ($op isa Allium::Operation::UNOP_AUX) {
            $op->aux_list = $raw->{aux_list};
        }

    }

    method build_pad_flags ($flags) {
        Allium::Flags::Pad::Flags->new( %$flags );
    }

    method build_public_flags ($flags) {
        Allium::Flags::Operation::PublicFlags->new( %$flags );
    }

    method build_private_flags ($flags) {
        Allium::Flags::Operation::PrivateFlags->new( %$flags );
    }

}
