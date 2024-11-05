
use v5.40;
use experimental qw[ class ];

class Allium::MOP::Abstract::Bindable :isa(Allium::MOP::Abstract::Value) {
    field $binding :param = undef;
    method has_binding      { defined $binding }
    method get_binding      {         $binding }
    method add_binding ($b) {         $binding = $b; $self }
}
