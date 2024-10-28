
use v5.40;
use experimental qw[ class ];

use Allium::MOP::Stash;
use Allium::MOP::Value::Type;

class Allium::MOP::GlobValue :isa(Allium::MOP::Value) {
    field $name   :param :reader;

    field $scalar :param = undef;
    field $array  :param = undef;
    field $hash   :param = undef;
    field $code   :param = undef;

    field $stash;

    ADJUST {
        $self->set_type(Allium::MOP::Value::Type::Glob->new);
    }

    method is_namespace { !! ($name =~ /\:\:$/) }
    method has_stash    { !! ($self->stash) }

    method stash {
        return unless $self->is_namespace;
        return $stash //= Allium::MOP::Stash->new;
    }

    method has_scalar { defined $scalar }
    method has_array  { defined $array  }
    method has_hash   { defined $hash   }
    method has_code   { defined $code   }

    method scalar :lvalue { $scalar }
    method array  :lvalue { $array  }
    method hash   :lvalue { $hash   }
    method code   :lvalue { $code   }

    method to_string {
        return sprintf '*STASH[%d](%s)={%s}' => $self->OID, $name,
            (join ', ' => map { '*'.$_ } $self->stash->all_names)
            if $self->is_namespace;
        return sprintf '*GV[%d](%s)=[%s]' => $self->OID, $name,
            (join ', ' => (
                ($scalar ? $scalar->to_string : ()),
                ($array  ? $array ->to_string : ()),
                ($hash   ? $hash  ->to_string : ()),
                ($code   ? $code  ->to_string : ()),
            ));
    }
}
