
use v5.40;
use experimental qw[ class ];

class Allium::Operation::SVOP :isa(Allium::Operation::OP) {
    field $sv;
    field $gv;

    method has_sv { defined $sv }
    method has_gv { defined $gv }

    method sv :lvalue { $sv }
    method gv :lvalue { $gv }
}
