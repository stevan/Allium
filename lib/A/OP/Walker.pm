
use v5.40;
use experimental qw[ class ];

use A::OP;

class A::OP::Walker {
    method walk ($op) {
        return $self->walk_listop($op) if $op isa A::LISTOP;
        return $self->walk_binop($op)  if $op isa A::BINOP;
        return $self->walk_logop($op)  if $op isa A::LOGOP;
        return $self->walk_unop($op)   if $op isa A::UNOP;
        return $self->walk_op($op)     if $op isa A::OP;
        #say "walk?? with $op";
        return;
    }

    method walk_listop  ($op) { ... }
    method walk_binop   ($op) { ... }
    method walk_logop   ($op) { ... }
    method walk_unop    ($op) { ... }
    method walk_op      ($op) { ... }
}
