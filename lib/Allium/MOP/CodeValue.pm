
use v5.40;
use experimental qw[ class ];

use Allium::MOP::Value::Type;

class Allium::MOP::CodeValue :isa(Allium::MOP::Value) {
    field $root  :param = undef;
    field $start :param = undef;
    field $glob  :param = undef;

    field $pad :reader;

    ADJUST {
        $pad = Allium::MOP::Pad->new;

        $self->set_type(Allium::MOP::Value::Type::Code->new);
    }

    method has_glob  { defined $glob  }
    method has_root  { defined $root  }
    method has_start { defined $start }

    method glob  :lvalue { $glob  }
    method root  :lvalue { $root  }
    method start :lvalue { $start }

    method to_string {
        sprintf '&CV[%d](*%s)' => $self->OID, (defined $glob ? $glob->name : '__ANON__');
    }
}
