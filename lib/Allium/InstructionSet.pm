
use v5.40;
use experimental qw[ class ];

use Allium::Opcode;

class Allium::InstructionSet {
    field $opcodes :param :reader;

    field %index;
    ADJUST {
        %index = map { ($_->name => $_) } @$opcodes;
    }

    method get($name) {
        return $index{$name}
            // die "Could not find the opcode($name)";
    }
}
