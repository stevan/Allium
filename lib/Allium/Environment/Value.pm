
use v5.40;
use experimental qw[ class ];

class Allium::Environment::Value {
    use overload '""' => 'to_string';
    method to_string { ... }
}

class Allium::Environment::Value::Literal :isa(Allium::Environment::Value) {
    field $literal :param :reader;
    method to_string { quotemeta("".$literal) }
}

class Allium::Environment::Value::Optree :isa(Allium::Environment::Value) {
    field $optree :param :reader;
    method to_string { '&!OPTREE['.(refaddr $optree).']' }
}
