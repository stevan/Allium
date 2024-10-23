
use v5.40;
use experimental qw[ class ];

class Allium::Operation::LOGOP :isa(Allium::Operation::UNOP) {
    field $other;
    method     other :lvalue { $other }
    method has_other { defined $other }
}
