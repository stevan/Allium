
use v5.40;
use experimental qw[ class ];

# TODO: Move back to MOP namespace

class Allium::Abstract::Bindable {
    field $binding :param = undef;
    method has_binding      { defined $binding }
    method get_binding      {         $binding }
    method add_binding ($b) {         $binding = $b; $self }
}
