
use v5.40;
use experimental qw[ class ];

package Allium::Datatypes {

    class Allium::Datatype::Container {}

    class Allium::Datatype::Container::Scalar  :isa(Allium::Datatype::Container) {}
    class Allium::Datatype::Container::Array   :isa(Allium::Datatype::Container) {}
    class Allium::Datatype::Container::Hash    :isa(Allium::Datatype::Container) {}
    class Allium::Datatype::Container::Glob    :isa(Allium::Datatype::Container) {}
    class Allium::Datatype::Container::Code    :isa(Allium::Datatype::Container) {}

    class Allium::Datatype::Value {}

    class Allium::Datatype::Value::Any         :isa(Allium::Datatyp::Value) {}
    class Allium::Datatype::Value::Void        :isa(Allium::Datatyp::Value::Any) {}

    class Allium::Datatype::Value::Scalar      :isa(Allium::Datatyp::Value::Any) {}
    class Allium::Datatype::Value::Bool        :isa(Allium::Datatyp::Value::Scalar) {}
    class Allium::Datatype::Value::String      :isa(Allium::Datatyp::Value::Scalar) {}
    class Allium::Datatype::Value::Ref         :isa(Allium::Datatyp::Value::Scalar) {}
    class Allium::Datatype::Value::Numeric     :isa(Allium::Datatyp::Value::Scalar) {}
    class Allium::Datatype::Value::Int         :isa(Allium::Datatyp::Value::Numeric) {}

    class Allium::Datatype::Value::Array       :isa(Allium::Datatyp::Value::Any) {}
    class Allium::Datatype::Value::Hash        :isa(Allium::Datatyp::Value::Any) {}
    class Allium::Datatype::Value::Glob        :isa(Allium::Datatyp::Value::Any) {}

}
