
use v5.40;
use experimental qw[ class ];

package Allium::Types {

    ## ---------------------------------------------------------------------------------------------
    ## Types
    ## ---------------------------------------------------------------------------------------------

    # Types do not match to values, because types are attached to containers
    # and not values. This aims to represent all the various types in a perl
    # program, more (or less) may be needed later.

    class Allium::Type {}

    class Allium::Type::Any         :isa(Allium::Type) {}
    class Allium::Type::Undef       :isa(Allium::Type::Any) {}
    class Allium::Type::Void        :isa(Allium::Type::Any) {}

    class Allium::Type::Scalar      :isa(Allium::Type::Any) {}
    class Allium::Type::Bool        :isa(Allium::Type::Scalar) {}
    class Allium::Type::String      :isa(Allium::Type::Scalar) {}
    class Allium::Type::Ref         :isa(Allium::Type::Scalar) {}
    class Allium::Type::Binary      :isa(Allium::Type::Scalar) {}
    class Allium::Type::Numeric     :isa(Allium::Type::Scalar) {}
    class Allium::Type::Int         :isa(Allium::Type::Numeric) {}

    class Allium::Type::List        :isa(Allium::Type::Any) {}
    class Allium::Type::Array       :isa(Allium::Type::List) {}
    class Allium::Type::Hash        :isa(Allium::Type::List) {}
    class Allium::Type::Glob        :isa(Allium::Type::Any) {}
    class Allium::Type::Code        :isa(Allium::Type::Any) {}

    # NOTE: the Code type is not the same as the signature. It is only here to be
    # input to a reference type (or possibly for map/grep signature)/
}



