
use v5.40;
use experimental qw[ class ];

class Allium::Operation::LISTOP :isa(Allium::Operation::BINOP) {
    field $num_children;

    method num_children :lvalue { $num_children }
}
