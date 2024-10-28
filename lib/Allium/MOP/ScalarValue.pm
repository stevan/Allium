
use v5.40;
use experimental qw[ class ];

use Allium::MOP::Value::Type;

class Allium::MOP::ScalarValue :isa(Allium::MOP::Value) {
    field $value_type :param :reader = undef;

    ADJUST {
        $self->set_type(Allium::MOP::Value::Type::Scalar->new);

        $value_type //= Allium::MOP::Value::Type::Null->new;
    }

    method is_string    { $value_type isa Allium::MOP::Value::Type::Str   }
    method is_numeric   { $value_type isa Allium::MOP::Value::Type::Int ||
                          $value_type isa Allium::MOP::Value::Type::Num   }
    method is_ref       { $value_type isa Allium::MOP::Value::Type::Ref   }
    method is_false     { $value_type isa Allium::MOP::Value::Type::False }
    method is_true      { $value_type isa Allium::MOP::Value::Type::True  }
    method is_undefined { $value_type isa Allium::MOP::Value::Type::Null  }
    method is_defined   { ! $self->is_undefined }

    method to_string {
        sprintf '$SV[%d]<%s>' => $self->OID, $value_type->name;
    }
}
