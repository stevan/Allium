
use v5.40;
use experimental qw[ class ];

class Allium::MOP::Value {
    use overload '""' => 'to_string';

    field $__oid  :reader(OID);
    field $__type :reader(TYPE);

    our $OID_SEQ = 0;
    ADJUST { $__oid = ++$OID_SEQ }

    method set_type ($t) {
        defined $__type && die 'You can only set the type once';
        $__type = $t;
    }

    method to_string { ... }
}
