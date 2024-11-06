
use v5.40;
use experimental qw[ class ];

class Allium::Sequence {
    use overload '""' => 'to_string';
    field $type :reader;
    field $next;

    ADJUST {
        $type = (split '::' => __CLASS__)[-1];
        $next = $self->start;
    }

    method start { 0 }
    method step  { 1 }

    method current { $next }
    method next    { $next += $self->step }

    method get_range ($start, $end) {
        ($start < $next && $end <= $next)
            || die "Could not create range($start, $end) it is not a valid range ($next)";
        Allium::Sequence::Range->new(
            type  => $type,
            start => $start,
            end   => $end,
        )
    }

    method to_string {
        sprintf 'SEQ[%s](%d, %d)' => $type, $self->start, $next
    }
}

class Allium::Sequence::Range {
    field $type  :param :reader;
    field $start :param :reader;
    field $end   :param :reader;
}

class Allium::Sequence::Translation {
    field $sequence :param :reader;
    field %map;
    method translate ($other) { $map{ $other } //= $sequence->next }

    method translate_range($start, $end) {
        $sequence->get_range( $map{ $start } // 0, $map{ $end } // 0 );
    }
}

class Allium::Sequence::OpAddress :isa(Allium::Sequence) {}
class Allium::Sequence::Statement :isa(Allium::Sequence) {}

