
use v5.40;
use experimental qw[ class ];

class Allium::Operation::METHOP :isa(Allium::Operation::OP) {
    field $first;
    field $method_sv;

    method     first :lvalue { $first }
    method has_first { defined $first }

    method method_sv :lvalue { $method_sv }
}
