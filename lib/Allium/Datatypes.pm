
use v5.40;
use experimental qw[ class ];

package Allium::Datatypes {

    ## ---------------------------------------------------------------------------------------------
    ## Containers
    ## ---------------------------------------------------------------------------------------------

    # Containers are what variables hold, they can
    # contain a Value, and have a Type associated

    class Allium::Datatype::Container {}

    class Allium::Datatype::Container::Scalar  :isa(Allium::Datatype::Container) {}
    class Allium::Datatype::Container::Array   :isa(Allium::Datatype::Container) {}
    class Allium::Datatype::Container::Hash    :isa(Allium::Datatype::Container) {}
    class Allium::Datatype::Container::Glob    :isa(Allium::Datatype::Container) {}

    # NOTE: Code is left out here, because you cannot change the
    # contents of Code, so it doesn't really fit. And it is not
    # made from SVs like all the others.

    ## ---------------------------------------------------------------------------------------------
    ## Values
    ## ---------------------------------------------------------------------------------------------

    # Values are actual things that can be stored in a container, and can
    # be mapped back to some kind of literal value

    class Allium::Datatype::Value {}
    class Allium::Datatype::Value::Undef    :isa(Allium::Datatype::Value) {}
    class Allium::Datatype::Value::Bool     :isa(Allium::Datatype::Value) {}
    class Allium::Datatype::Value::String   :isa(Allium::Datatype::Value) {}
    class Allium::Datatype::Value::Numeric  :isa(Allium::Datatype::Value) {}
    class Allium::Datatype::Value::Int      :isa(Allium::Datatype::Value) {}
    class Allium::Datatype::Value::Ref      :isa(Allium::Datatype::Value) {}

}

__END__

Perl SV types

# Value types
SvNULL  - Undef
SvIV    - Integer
SvNV    - Number
SvPV    - String
SvRV    - Reference

# Compound Value types
SvPVIV  - String or Integer
SvPVNV  - String, Float or Integer

# container type (+ SV itself)
SvPVAV  - Array
SvPVHV  - Hash
SvPVCV  - Code
SvPVGV  - Glob

# Ignore
SvPVMG  - Magical values
