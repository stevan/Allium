
use v5.40;
use experimental qw[ class ];

class Allium::Operation::OP {
    field $name :param :reader;
    field $addr :param :reader;

    field $is_nullified  :param :reader;
    field $public_flags  :param :reader;
    field $private_flags :param :reader;

    field $next;
    field $sibling;
    field $parent;

    field $type :reader;

    ADJUST {
        $type = (split '::' => __CLASS__)[-1];
    }

    method parent  :lvalue { $parent  }
    method next    :lvalue { $next    }
    method sibling :lvalue { $sibling }

    method has_parent  { defined $parent  }
    method has_next    { defined $next    }
    method has_sibling { defined $sibling }

    method has_descendents { $public_flags->has_descendents }

    method depth {
        return 0 unless $parent;
        return 1 + $parent->depth;
    }

    method accept ($v) {
        my @children;
        if ($self->has_descendents) {
            for (my $child = $self->first; $child; $child = $child->sibling) {
                push @children => $child->accept($v);
            }
        }
        $v->visit($self, @children);
    }
}
