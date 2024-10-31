
use v5.40;
use experimental qw[ class ];

class Allium::MOP::CodeValue :isa(Allium::MOP::Value) {
    field $optree :param = undef;
    field $glob   :param = undef;

    field $pad :reader;

    ADJUST {
        $pad = Allium::MOP::Pad->new;
    }

    method has_glob   { defined $glob   }
    method has_optree { defined $optree }

    method glob   :lvalue { $glob   }
    method optree :lvalue { $optree }

    method to_string {
        sprintf '&CV[%d](*%s)' => $self->OID, (defined $glob ? $glob->name : '__ANON__');
    }
}
