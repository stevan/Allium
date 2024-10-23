
use v5.40;
use experimental qw[ class ];

class A::OP::Walker::TopDown :isa(A::OP::Walker) {
    field $f :param :reader;

    method walk_listop ($op) {
        #say "walk_listop with $op";
        $f->($op);
        for (my $child = $op->first; $child; $child = $child->sibling) {
            $self->walk($child);
        }
    }

    method walk_binop ($op) {
        #say "walk_binop with $op";
        $f->($op);
        $self->walk($op->first) if $op->has_first;
        $self->walk($op->last)  if $op->has_last;
    }

    method walk_logop ($op) {
        #say "walk_logop with $op";
        $f->($op);
        for (my $child = $op->first; $child; $child = $child->sibling) {
            $self->walk($child);
        }
    }

    method walk_unop ($op) {
        #say "walk_unop with $op";
        $f->($op);
        $self->walk($op->first) if $op->has_first;
    }

    method walk_op ($op) {
        #say "walk_op with $op";
        $f->($op);
        $self->walk($op->sibling)
            if $op->has_descendents
            && $op->has_sibling;
    }
}
