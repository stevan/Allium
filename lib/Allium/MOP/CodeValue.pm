
use v5.40;
use experimental qw[ class ];

class Allium::MOP::CodeValue :isa(Allium::MOP::Abstract::Bindable) {
    field $glob :param :reader = undef;

    method to_string {
        my $name = defined $glob ? $glob->name : '__ANON__';
        return sprintf '&CV[%d](*%s):=%s' => $self->oid, $name, $self->get_binding->value
            if $self->has_binding;
        return sprintf '&CV[%d](*%s)' => $self->oid, $name;
    }
}
