
use v5.40;
use experimental qw[ class ];

class Allium::Operation::PVOP :isa(Allium::Operation::OP) {
    field $pv;

    method has_pv { defined $pv }
    method pv :lvalue { $pv }
}
