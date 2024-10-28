
use v5.40;
use experimental qw[ class ];

class Allium::MOP::Value {
    use overload '""' => 'to_string';

    field $__oid  :param :reader(OID);
    field $__type        :reader(TYPE);

    method set_type ($t) {
        defined $__type && die 'You can only set the type once';
        $__type = $t;
    }

    method to_string { ... }
}
