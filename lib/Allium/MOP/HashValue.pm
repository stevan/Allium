
use v5.40;
use experimental qw[ class ];

class Allium::MOP::HashValue :isa(Allium::MOP::Abstract::Bindable) {
    method to_string { sprintf '%%HV[%d]' => $self->oid }
}
