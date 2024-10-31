
use v5.40;
use experimental qw[ class ];

class Allium::Type {
    use overload '""' => 'to_string';

    field $name :reader;
    ADJUST { $name = (split '::' => __CLASS__)[-1] }

    method to_string { __CLASS__ }
}
