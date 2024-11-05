
use v5.40;
use experimental qw[ class ];

class Allium::MOP::ArrayValue :isa(Allium::MOP::Abstract::Value) {
    method to_string {
        return sprintf '@AV[%d]:=%s' => $self->oid, $self->get_binding->value
            if $self->has_binding;
        return sprintf '@AV[%d]' => $self->oid
    }
}
