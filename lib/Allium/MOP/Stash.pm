
use v5.40;
use experimental qw[ class ];

class Allium::MOP::Stash :isa(Allium::MOP::HashValue) {
    field %namespace :reader;

    method all_names { keys %namespace }

    method get_all            { values %namespace }
    method get_all_globs      { grep !$_->is_namespace, values %namespace }
    method get_all_namespaces { grep  $_->is_namespace, values %namespace }

    method has ($name) { exists $namespace{ $name } }
    method get ($name) { $namespace{ $name } }

    method set ($glob) { $namespace{ $glob->name } = $glob }

    method to_string {
        sprintf '^STASH[%d]::{%d}' => $self->oid, (scalar keys %namespace);
    }

    # YUK: override the Bindable methods from HashValue
    method has_binding     { die 'Stashes do not support bindings' }
    method get_binding     { die 'Stashes do not support bindings' }
    method add_binding ($) { die 'Stashes do not support bindings' }
}
