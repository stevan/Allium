
use v5.40;
use experimental qw[ class ];

class Allium::MOP::ArrayValue :isa(Allium::MOP::Value) {
    method to_string { sprintf '@AV[%d]' => $self->OID }
}
