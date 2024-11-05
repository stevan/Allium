
use v5.40;
use experimental qw[ class ];

class Allium::MOP::HashValue :isa(Allium::MOP::Abstract::Value) {
    method to_string {
        return sprintf '%%HV[%d]:=%s' => $self->oid, $self->get_binding->value
            if $self->has_binding;
        return sprintf '%%HV[%d]' => $self->oid
    }
}
