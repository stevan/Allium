
use v5.40;
use experimental qw[ class ];

use Allium::MOP::Value::Type;

class Allium::MOP::ArrayValue :isa(Allium::MOP::Value) {

    ADJUST {
        $self->set_type(Allium::MOP::Value::Type::Array->new);
    }

    method to_string { sprintf '@AV[%d]' => $self->OID }
}
