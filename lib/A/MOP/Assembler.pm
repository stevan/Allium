
use v5.40;
use experimental qw[ class ];

use B ();

class A::MOP::Assembler {
    field $op_assembler :param :reader;
}
