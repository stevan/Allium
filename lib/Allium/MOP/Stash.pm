
use v5.40;
use experimental qw[ class ];

class Allium::MOP::Stash {
    field %namespace :reader;

    method all_names { keys %namespace }

    method get_all            { values %namespace }
    method get_all_globs      { grep !$_->is_namespace, values %namespace }
    method get_all_namespaces { grep  $_->is_namespace, values %namespace }

    method has ($name) { exists $namespace{ $name } }
    method get ($name) { $namespace{ $name } }

    method set ($glob) { $namespace{ $glob->name } = $glob }
}