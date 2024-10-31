
use v5.40;
use experimental qw[ class ];

class Allium::MOP::ArrayValue :isa(Allium::MOP::Abstract::Bindable) {
    method to_string { sprintf '@AV[%d]' => $self->oid }
}
