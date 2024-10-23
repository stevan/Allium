
use v5.40;
use experimental qw[ class ];

class A::OP {
    field $name    :param :reader;
    field $desc    :param :reader;
    field $addr    :param :reader;
    field $type    :param :reader;

    field $is_null         :param :reader;
    field $has_descendents :param :reader;

    field $next;
    field $sibling;
    field $parent;

    method next    :lvalue { $next    }
    method sibling :lvalue { $sibling }
    method parent  :lvalue { $parent  }

    method has_next    { defined $next    }
    method has_sibling { defined $sibling }
    method has_parent  { defined $parent  }

    method depth {
        return 0 unless $parent;
        return 1 + $parent->depth;
    }
}

class A::SVOP   :isa(A::OP) {}
class A::PADOP  :isa(A::OP) {}
class A::PVOP   :isa(A::OP) {}
class A::COP    :isa(A::OP) {}
class A::METHOP :isa(A::OP) {}

class A::UNOP :isa(A::OP) {
    field $first;
    method     first :lvalue { $first }
    method has_first { defined $first }
}

class A::UNOP_AUX :isa(A::UNOP) {}

class A::LOGOP :isa(A::UNOP) {
    field $other;
    method     other :lvalue { $other }
    method has_other { defined $other }
}

class A::BINOP :isa(A::UNOP) {
    field $last;

    method     last :lvalue { $last }
    method has_last { defined $last }
}

class A::LISTOP :isa(A::BINOP) {}

class A::PMOP :isa(A::LISTOP) {}
class A::LOOP :isa(A::LISTOP) {}
