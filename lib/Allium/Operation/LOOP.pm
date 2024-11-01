
use v5.40;
use experimental qw[ class ];

class Allium::Operation::LOOP :isa(Allium::Operation::LISTOP) {
    field $redo_op;
    field $next_op;
    field $last_op;

    method redo_op :lvalue { $redo_op }
    method next_op :lvalue { $next_op }
    method last_op :lvalue { $last_op }
}
