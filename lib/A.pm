
use v5.40;
use experimental qw[ class ];

# TODO: remove this dependency
use importer 'Path::Tiny' => qw[ path ];

use A::OP::Assembler;
use A::OP::Disassembler;

use Allium::InstructionSet::Loader;

class A {
    field $instruction_set :param :reader = undef;

    ADJUST {
        $instruction_set = $self->load_default_instruction_set;
    }

    method assemble ($optree) {
        return A::OP::Assembler
                ->new( instruction_set => $instruction_set )
                ->assemble($optree);
    }

    method disassemble ($code) {
        return A::OP::Disassembler
                ->new( instruction_set => $instruction_set )
                ->disassemble($code);
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
