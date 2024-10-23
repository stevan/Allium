
use v5.40;
use experimental qw[ class ];

class Allium::Opcode::Arg {
    field $type     :param :reader;
    field $optional :param :reader;
}
