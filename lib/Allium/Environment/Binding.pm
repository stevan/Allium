
use v5.40;
use experimental qw[ class ];

class Allium::Environment::Binding {
    field $symbol :param :reader = undef;
    field $value  :param :reader = undef;
    field $uid    :param :reader = undef;

    ADJUST {
        $uid //= refaddr $self;
    }

    method has_symbol { defined $symbol }
    method has_value  { defined $value  }

    method is_unnamed    { ! defined $symbol }
    method is_unresolved { ! defined $value  }

    method copy (%args) {
        $args{symbol} //= $symbol;
        $args{value}  //= $value;
        return Allium::Environment::Binding->new( %args )
    }
}
