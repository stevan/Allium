
use v5.40;
use experimental qw[ class ];

use Allium::Optree::Walker::TopDown;

class Allium::Optree::Dumper {

    method dump ($optree) {
        my @ops;

        Allium::Optree::Walker::TopDown->new(
            f => sub ($op) { push @ops => $self->dump_op($op) }
        )->walk($optree->root);

        return +{
            root   => $optree->root->addr,
            start  => $optree->start->addr,
            pad    => $self->dump_pad( $optree->pad ),
            ops    => \@ops,
            op_seq => $self->dump_sequence( $optree->op_seq ),
            st_seq => $self->dump_sequence( $optree->st_seq ),
        };
    }

    method dump_sequence ($seq) {
        return +{
            type    => $seq->type,
            start   => $seq->start,
            step    => $seq->step,
            current => $seq->current,
        }
    }

    method dump_pad ($pad) {
        my @pad;
        foreach my $entry ($pad->entries) {
            push @pad => $self->dump_pad_entry($entry);
        }
        return \@pad;
    }

    method dump_pad_entry ($entry) {
        my %entry = (
            type      => $entry->type,
            name      => $entry->name,
            flags     => $self->dump_flags($entry->flags),
            cop_range => {
                type  => $entry->cop_range->type,
                start => $entry->cop_range->start,
                end   => $entry->cop_range->end,
            }
        );

        if ($entry->flags->is_our) {
            $entry{stash_name} = $entry->stash_name;
        }
        elsif ($entry->flags->is_outer) {
            $entry{parent_pad_index} = $entry->parent_pad_index;
            $entry{parent_lex_flags} = $self->dump_flags($entry->parent_lex_flags);
        }

        return \%entry;
    }

    method dump_op ($op) {
        my %op;

        $op{name} = $op->name;
        $op{addr} = $op->addr;
        $op{type} = $op->type;

        $op{is_nullified}  = $op->is_nullified;
        $op{is_optimized}  = $op->is_optimized;

        $op{pad_target}    = $op->pad_target;
        $op{public_flags}  = $self->dump_flags($op->public_flags);
        $op{private_flags} = $self->dump_flags($op->private_flags);

        $op{next}    = $self->dump_connection(next    => $op->next);
        $op{sibling} = $self->dump_connection(sibling => $op->sibling);
        $op{parent}  = $self->dump_connection(parent  => $op->parent);

        $op{first} = $self->dump_connection(first => $op->first)
            if $op isa Allium::Operation::UNOP;

        $op{last} = $self->dump_connection(last => $op->last)
            if $op isa Allium::Operation::BINOP;

        $op{other} = $self->dump_connection(other => $op->other)
            if $op isa Allium::Operation::LOGOP;

        $op{is_nullified}  = $op->is_nullified;

        $self->dump_op_specific_data(\%op, $op);

        return \%op;
    }

    method dump_op_specific_data ($raw, $op) {
        if ($op isa Allium::Operation::LISTOP) {
            $raw->{num_children} = $op->num_children;
        }

        if ($op isa Allium::Operation::LOOP) {
            $raw->{redo_op} = $self->dump_connection( redo_op => $op->redo_op );
            $raw->{next_op} = $self->dump_connection( next_op => $op->next_op );
            $raw->{last_op} = $self->dump_connection( last_op => $op->last_op );
        }

        if ($op isa Allium::Operation::PVOP) {
            $raw->{pv} = $op->pv;
        }

        if ($op isa Allium::Operation::COP) {
            $raw->{label}      = $op->label;
            $raw->{stash}      = $op->stash;
            $raw->{file}       = $op->file;
            $raw->{cop_seq}    = $op->cop_seq;
            $raw->{line}       = $op->line;
            $raw->{warnings}   = $op->warnings;
            $raw->{io}         = $op->io;
            $raw->{hints}      = $op->hints;
            $raw->{hints_hash} = $op->hints_hash;
        }

        if ($op isa Allium::Operation::SVOP) {
            #$raw->{binding} = $op->get_binding->uid if $op->has_binding;
        }

        if ($op isa Allium::Operation::UNOP_AUX) {
            $raw->{aux_list} = $op->aux_list;
        }

    }

    method dump_flags ($flags) {
        $flags->dump_flags;
    }

    method dump_connection ($connection_type, $op) {
        return 0 unless $op;
        return $op->addr;
    }
}
