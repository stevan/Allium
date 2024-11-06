
use v5.40;
use experimental qw[ class ];

class Allium::Sequence {
    use overload '""' => 'to_string';
    field $start   :param :reader = 0;
    field $step    :param :reader = 1;
    field $current :param :reader = 0;

    field $type :reader;

    ADJUST {
        $type = (split '::' => __CLASS__)[-1];
    }

    method next { $current += $step }

    method get_range ($s, $e) {
        ($s < $current && $e <= $current)
            || die "Could not create range($s, $e) it is not a valid range ($current)";
        Allium::Sequence::Range->new(
            type  => $type,
            start => $s,
            end   => $e,
        )
    }

    method to_string {
        sprintf 'SEQ[%s](%d, %d)' => $type, $start, $current
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

