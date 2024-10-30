
use v5.40;
use experimental qw[ class ];

class Allium::MOP::Value::Type {
    use overload '""' => 'to_string';

    field $name :reader;
    ADJUST { $name = (split '::' => __CLASS__)[-1] }

    method is_core_type { ! $self->is_scalar_value_type }

    method is_scalar_value_type {
        __CLASS__ ne 'Allium::MOP::Value::Type::Scalar'
            && $self isa Allium::MOP::Value::Type::Scalar
    }

    method to_string { __CLASS__ }
}

class Allium::MOP::Value::Type::Scalar  :isa(Allium::MOP::Value::Type) {} # SV
class Allium::MOP::Value::Type::Array   :isa(Allium::MOP::Value::Type) {} # AV
class Allium::MOP::Value::Type::Hash    :isa(Allium::MOP::Value::Type) {} # HV
class Allium::MOP::Value::Type::Code    :isa(Allium::MOP::Value::Type) {} # CV
class Allium::MOP::Value::Type::Glob    :isa(Allium::MOP::Value::Type) {} # GV

class Allium::MOP::Value::Type::Null  :isa(Allium::MOP::Value::Type::Scalar) {} # sv_undef
class Allium::MOP::Value::Type::True  :isa(Allium::MOP::Value::Type::Scalar) {} # sv_yes
class Allium::MOP::Value::Type::False :isa(Allium::MOP::Value::Type::Scalar) {} # sv_no
class Allium::MOP::Value::Type::Int   :isa(Allium::MOP::Value::Type::Scalar) {} # IV
class Allium::MOP::Value::Type::Num   :isa(Allium::MOP::Value::Type::Scalar) {} # NV
class Allium::MOP::Value::Type::Str   :isa(Allium::MOP::Value::Type::Scalar) {} # PV
class Allium::MOP::Value::Type::Ref   :isa(Allium::MOP::Value::Type::Scalar) {} # RV

class Allium::MOP::Value::Type::Ref::Scalar :isa(Allium::MOP::Value::Type::Ref) {} # RV<SV>
class Allium::MOP::Value::Type::Ref::Array  :isa(Allium::MOP::Value::Type::Ref) {} # RV<AV>
class Allium::MOP::Value::Type::Ref::Hash   :isa(Allium::MOP::Value::Type::Ref) {} # RV<HV>
class Allium::MOP::Value::Type::Ref::Code   :isa(Allium::MOP::Value::Type::Ref) {} # RV<CV>
class Allium::MOP::Value::Type::Ref::Glob   :isa(Allium::MOP::Value::Type::Ref) {} # RV<GV>

