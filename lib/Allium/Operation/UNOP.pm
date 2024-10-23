
use v5.40;
use experimental qw[ class ];

class Allium::Operation::UNOP :isa(Allium::Operation::OP) {
    field $first;
    method     first :lvalue { $first }
    method has_first { defined $first }
}
