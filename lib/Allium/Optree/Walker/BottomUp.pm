
use v5.40;
use experimental qw[ class ];

class Allium::Optree::Walker::BottomUp :isa(Allium::Optree::Walker) {
    field $f :param :reader;

    method walk_listop ($op) {
        #say "walk_listop with $op";
        for (my $child = $op->first; $child; $child = $child->sibling) {
            $self->walk($child);
        }
        $f->($op);
    }

    method walk_binop ($op) {
        #say "walk_binop with $op";
        $self->walk($op->first) if $op->has_first;
        $self->walk($op->last)  if $op->has_last;
        $f->($op);
    }

    method walk_logop ($op) {
        #say "walk_logop with $op";
        for (my $child = $op->first; $child; $child = $child->sibling) {
            $self->walk($child);
        }
        $f->($op);
    }

    method walk_unop ($op) {
        #say "walk_unop with $op";
        $self->walk($op->first) if $op->has_first;
        $f->($op);
    }

    method walk_op ($op) {
        #say "walk_op with $op";
        $self->walk($op->sibling)
            if $op->has_descendents
            && $op->has_sibling;
        $f->($op);
    }
}
