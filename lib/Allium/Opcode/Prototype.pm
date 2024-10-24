
use v5.40;
use experimental qw[ class ];

class Allium::Opcode::Prototype {
    field $arguments :param :reader;
}

class Allium::Opcode::Argument {
    field $type     :param :reader;
    field $optional :param :reader;
}

