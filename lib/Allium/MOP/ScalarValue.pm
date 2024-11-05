
use v5.40;
use experimental qw[ class ];

use Allium::Type::ValueType;

class Allium::MOP::ScalarValue :isa(Allium::MOP::Abstract::Value) {
    field $value_type :param :reader = undef;

    ADJUST {
        $value_type //= Allium::Type::ValueType::Null->new;
    }

    method is_string    { $value_type isa Allium::Type::ValueType::Str   }
    method is_int       { $value_type isa Allium::Type::ValueType::Int   }
    method is_numeric   { $value_type isa Allium::Type::ValueType::Num   }
    method is_ref       { $value_type isa Allium::Type::ValueType::Ref   }
    method is_false     { $value_type isa Allium::Type::ValueType::False }
    method is_true      { $value_type isa Allium::Type::ValueType::True  }
    method is_undefined { $value_type isa Allium::Type::ValueType::Null  }
    method is_defined   { ! $self->is_undefined }

    method to_string {
        return sprintf '$SV[%d]<%s>:=%s' => $self->oid, $value_type->name, $self->get_binding->value
            if $self->has_binding;
        return sprintf '$SV[%d]<%s>' => $self->oid, $value_type->name;
    }
}
