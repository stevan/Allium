
use v5.40;
use experimental qw[ class ];

use Allium::Opcode::Arg;
use Allium::Opcode::ArgType;
use Allium::Opcode::Flags;

class Allium::Opcode {
    field $name    :param :reader;
    field $opclass :param :reader;
    field $args    :param :reader;
    field $flags   :param :reader;
}


