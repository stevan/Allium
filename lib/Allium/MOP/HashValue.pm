
use v5.40;
use experimental qw[ class ];

class Allium::MOP::HashValue :isa(Allium::MOP::Value) {
    method to_string { sprintf '%%HV[%d]' => $self->OID }
}
