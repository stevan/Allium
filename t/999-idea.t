#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

## -------------------------------------------------------------------------------------------------

class Allium::ObjectSpace::Type {
    field $name    :reader;
    field @lineage :reader;

    ADJUST {
        $name    = (split '::' => __CLASS__)[-1];
        @lineage = mro::get_linear_isa(__CLASS__)->@*;
        shift @lineage; # shift this class off
    }
}

class Allium::ObjectSpace::Type::Any   :isa(Allium::ObjectSpace::Type) {}
class Allium::ObjectSpace::Type::Null  :isa(Allium::ObjectSpace::Type::Any) {}
class Allium::ObjectSpace::Type::Bool  :isa(Allium::ObjectSpace::Type::Any) {}
class Allium::ObjectSpace::Type::Str   :isa(Allium::ObjectSpace::Type::Any) {}
class Allium::ObjectSpace::Type::Num   :isa(Allium::ObjectSpace::Type::Any) {}
class Allium::ObjectSpace::Type::Int   :isa(Allium::ObjectSpace::Type::Num) {}
class Allium::ObjectSpace::Type::Ref   :isa(Allium::ObjectSpace::Type::Any) {}
class Allium::ObjectSpace::Type::Array :isa(Allium::ObjectSpace::Type::Any) {}
class Allium::ObjectSpace::Type::Hash  :isa(Allium::ObjectSpace::Type::Any) {}
class Allium::ObjectSpace::Type::Code  :isa(Allium::ObjectSpace::Type::Any) {}
class Allium::ObjectSpace::Type::Glob  :isa(Allium::ObjectSpace::Type::Any) {}

class Allium::ObjectSpace::TypeVar {
    use overload '""' => 'to_string';

    field $type :param :reader;

    field $__tid :reader(TID);
    our $TID_SEQ = 0;
    ADJUST {
        $__tid = ++$TID_SEQ;
    }

    method to_string {
        sprintf '`T[%d](%s)' => $__tid, $type->name;
    }
}

class Allium::ObjectSpace::TypeSpace {
    field %types;
    field %vars;

    method get_type ($name) {
        $types{ $name } //= ('Allium::ObjectSpace::Type::'.$name)->new;
    }

    method new_type_var ($name) {
        my $tv = Allium::ObjectSpace::TypeVar->new( type => $self->get_type( $name ) );
        $vars{ $tv->TID } = $tv;
        return $tv;
    }
}

## -------------------------------------------------------------------------------------------------

class Allium::ObjectSpace::Value {
    use overload '""' => 'to_string';

    field $__oid :reader(OID);
    our $OID_SEQ = 0;
    ADJUST {
        $__oid = ++$OID_SEQ;
    }

    method to_string { ... }
}

## -------------------------------------------------------------------------------------------------

class Allium::ObjectSpace::ScalarValue :isa(Allium::ObjectSpace::Value) {
    field $type_var :param :reader;

    method to_string {
        sprintf 'SV[%d]<%s>' => $self->OID, $type_var->type->name;
    }
}

class Allium::ObjectSpace::ArrayValue :isa(Allium::ObjectSpace::Value) {}
class Allium::ObjectSpace::HashValue :isa(Allium::ObjectSpace::Value) {}
class Allium::ObjectSpace::GlobValue :isa(Allium::ObjectSpace::Value) {}
class Allium::ObjectSpace::CodeValue :isa(Allium::ObjectSpace::Value) {}

## -------------------------------------------------------------------------------------------------

class Allium::ObjectSpace {
    field %arena;

    field $root_stash;
    field $type_space;

    ADJUST {
        $type_space = Allium::ObjectSpace::TypeSpace->new;
    }

    ## ....

    my sub is_valid_scalar_type ($type_name) { $type_name =~ /Null|Bool|Str|Num|Int|Ref/ }

    ## ....

    method new_scalar_value ($type_name) {
        is_valid_scalar_type($type_name)
            || die "Could not create new Scalar Value of type($type_name) is not a valid Scalar type";
        my $tv = $type_space->new_type_var( $type_name );
        my $sv = Allium::ObjectSpace::ScalarValue->new( type_var => $tv );
        $arena{ $sv->OID } = $sv;
        return $sv;
    }
}

my $os = Allium::ObjectSpace->new;


my @svs = map { $os->new_scalar_value($_) } qw(
    Null
    Bool
    Str
    Num
    Int
    Ref
);

say join "\n" => @svs;

## -------------------------------------------------------------------------------------------------

# sv_undef  => ::Type::Null
# sv_yes    => ::Type::Boolean
# sv_no     => ::Type::Boolean
# IV        => ::Type::Integer
# NV        => ::Type::Numeric
# PV        => ::Type::String
# RV        => ::Type::Reference
# AV        => ::Type::Array
# HV        => ::Type::Hash
# GV        => ::Type::Glob
# CV        => ::Type::Null

## -------------------------------------------------------------------------------------------------

done_testing;
