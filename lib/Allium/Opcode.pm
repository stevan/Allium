
use v5.40;
use experimental qw[ class ];

use Allium::Opcode::Prototype;
use Allium::Opcode::Flags;

class Allium::Opcode {
    field $category    :param :reader;
    field $name        :param :reader;
    field $description :param :reader;

    field $operation_types :param :reader;
    field $prototype       :param :reader;

    field $flags   :param :reader;
    field $private :param :reader;
}
