#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;

=pod

# Value types
SvNULL  - undef
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

=cut

class Type::Value {}

class Type::Value::Null :isa(Type::Value) {}
class Type::Value::Int  :isa(Type::Value) {}
class Type::Value::Num  :isa(Type::Value) {}
class Type::Value::Str  :isa(Type::Value) {}
class Type::Value::Ref  :isa(Type::Value) {}

class Type::Container {}

class Type::Container::Scalar  :isa(Type::Container) {}
class Type::Container::Array   :isa(Type::Container) {}
class Type::Container::Hash    :isa(Type::Container) {}
class Type::Container::Glob    :isa(Type::Container) {}
class Type::Container::Code    :isa(Type::Container) {}

class Type {}

class Type::Any             :isa(Type)          {}
    class Type::Void        :isa(Type::Any)     {}
    class Type::Scalar      :isa(Type::Any)     {}
        class Type::Bool    :isa(Type::Scalar)  {}
        class Type::String  :isa(Type::Scalar)  {}
        class Type::Ref     :isa(Type::Scalar)  {}
        class Type::Numeric :isa(Type::Scalar)  {}
            class Type::Int :isa(Type::Numeric) {}
    class Type::Array       :isa(Type::List)    {}
    class Type::Hash        :isa(Type::Any)     {}
    class Type::Code        :isa(Type::Any)     {}
    class Type::Glob        :isa(Type::Any)     {}





done_testing;
