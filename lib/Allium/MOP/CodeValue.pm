
use v5.40;
use experimental qw[ class ];

class Allium::MOP::CodeValue :isa(Allium::MOP::Abstract::Bindable) {
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
        my $name = defined $glob ? $glob->name : '__ANON__';
        return sprintf '&CV[%d](*%s):=%s' => $self->oid, $name, $self->get_binding->value
            if $self->has_binding;
        return sprintf '&CV[%d](*%s)' => $self->oid, $name;
    }
}
