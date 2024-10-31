
use v5.40;
use experimental qw[ class ];

class Allium::Environment::Value {}

class Allium::Environment::Value::Literal :isa(Allium::Environment::Value) {
    field $literal :param :reader;
}

class Allium::Environment::Value::Optree :isa(Allium::Environment::Value) {
    field $optree :param :reader;
}
