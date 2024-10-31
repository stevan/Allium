
use v5.40;
use experimental qw[ class ];

# TODO: remove this dependency
use importer 'Path::Tiny' => qw[ path ];

use A::OP::Assembler;
use A::OP::Disassembler;

use A::MOP::Assembler;
use A::MOP::Disassembler;

use Allium::InstructionSet::Loader;

class A {
    field $instruction_set :param = undef;

    field $op_assembler;
    field $mop_assembler;

    field $op_disassembler;
    field $mop_disassembler;

    method instruction_set  { $instruction_set //= $self->load_default_instruction_set }

    method op_assembler {
        $op_assembler //= A::OP::Assembler->new(
            instruction_set => $self->instruction_set
        )
    }
    method op_disassembler {
        $op_disassembler //= A::OP::Disassembler->new(
            instruction_set => $self->instruction_set
        )
    }

    method mop_assembler {
        $mop_assembler //= A::MOP::Assembler->new(
            op_assembler => $self->op_assembler
        )
    }
    method mop_disassembler {
        $mop_disassembler //= A::MOP::Disassembler->new(
            op_disassembler => $self->op_disassembler
        )
    }

    method load_default_instruction_set {
        return Allium::InstructionSet::Loader->new->load_file(
            path(__FILE__)
                ->parent
                ->parent
                ->child('data', 'instruction-sets')
                ->child('perl-5.41.4.json')
        );
    }
}
