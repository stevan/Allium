
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
            root  => $optree->root->addr,
            start => $optree->start->addr,
            ops   => \@ops,
        };
    }

    method dump_op ($op) {
        my %op;

        $op{name} = $op->name;
        $op{addr} = $op->addr;
        $op{type} = $op->type;

        $op{is_nullified}  = $op->is_nullified;

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

        return \%op;
    }

    method dump_flags ($flags) {
        $flags->dump_flags;
    }

    method dump_connection ($connection_type, $op) {
        return 0 unless $op;
        return $op->addr;
    }
}
