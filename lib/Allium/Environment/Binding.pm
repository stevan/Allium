
use v5.40;
use experimental qw[ class ];

class Allium::Environment::Binding {
    field $symbol :param :reader;
    field $value  :param :reader;
}
