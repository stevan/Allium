
use v5.40;
use experimental qw[ class ];


use Allium::Opcode::Prototype;

use Allium::Flags::Opcode::StaticFlags;
use Allium::Flags::Opcode::PrivateFlags;

class Allium::Opcode {
    field $category    :param :reader;
    field $name        :param :reader;
    field $description :param :reader;

    field $prototype       :param :reader;
    field $operation_types :param :reader;
    field $static_flags    :param :reader;
    field $private_flags   :param :reader;
}
