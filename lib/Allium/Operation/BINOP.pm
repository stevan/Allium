
use v5.40;
use experimental qw[ class ];

class Allium::Operation::BINOP :isa(Allium::Operation::UNOP) {
    field $last;

    method     last :lvalue { $last }
    method has_last { defined $last }
}
