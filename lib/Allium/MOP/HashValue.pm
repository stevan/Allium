
use v5.40;
use experimental qw[ class ];

use Allium::MOP::Value::Type;

class Allium::MOP::HashValue :isa(Allium::MOP::Value) {

    ADJUST {
        $self->set_type(Allium::MOP::Value::Type::Hash->new);
    }

    method to_string { sprintf '%%HV[%d]' => $self->OID }
}
