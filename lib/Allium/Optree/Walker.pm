
use v5.40;
use experimental qw[ class ];

class Allium::Optree::Walker {
    method walk ($op) {
        return $self->walk_listop($op) if $op isa Allium::Operation::LISTOP;
        return $self->walk_binop($op)  if $op isa Allium::Operation::BINOP;
        return $self->walk_logop($op)  if $op isa Allium::Operation::LOGOP;
        return $self->walk_unop($op)   if $op isa Allium::Operation::UNOP;
        return $self->walk_cop($op)    if $op isa Allium::Operation::COP;
        return $self->walk_svop($op)   if $op isa Allium::Operation::SVOP;
        return $self->walk_op($op)     if $op isa Allium::Operation::OP;
        #say "walk?? with $op";
        return;
    }

    method walk_listop  ($op) { ... }
    method walk_binop   ($op) { ... }
    method walk_logop   ($op) { ... }
    method walk_unop    ($op) { ... }
    method walk_cop     ($op) { ... }
    method walk_svop    ($op) { ... }
    method walk_op      ($op) { ... }
}
