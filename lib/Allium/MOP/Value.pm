
use v5.40;
use experimental qw[ class ];

class Allium::MOP::Value {
    use overload '""' => 'to_string';

    field $__oid  :param :reader(OID);

    method to_string { ... }
}
