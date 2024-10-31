
use v5.40;
use experimental qw[ class ];

class Allium::MOP::Abstract::Value {
    use overload '""' => 'to_string';

    field $oid :param :reader;

    method to_string { ... }
}
