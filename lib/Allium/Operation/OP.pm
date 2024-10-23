
use v5.40;
use experimental qw[ class ];

class Allium::Operation::OP {
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
