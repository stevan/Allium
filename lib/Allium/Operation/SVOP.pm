
use v5.40;
use experimental qw[ class ];

class Allium::Operation::SVOP :isa(Allium::Operation::OP) {
    field $binding;

    method has_binding { defined $binding }
    method binding :lvalue {     $binding }
}
