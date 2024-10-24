
use v5.40;
use experimental qw[ class ];

use Allium::Opcode::Arg;
use Allium::Opcode::ArgType;
use Allium::Opcode::Flags;

class Allium::Opcode {
    field $category    :param :reader;
    field $name        :param :reader;
    field $description :param :reader;
    field $operation   :param :reader;
    field $signature   :param :reader;
    field $flags       :param :reader;
    field $private     :param :reader;
}
