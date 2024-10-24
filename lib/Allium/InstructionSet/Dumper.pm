
use v5.40;
use experimental qw[ class ];

use Allium::InstructionSet;

class Allium::InstructionSet::Dumper {

    method dump ($config) {
        return +[ map $self->dump_opcode($_), $config->opcodes->@* ];
    }

    method dump_opcode ($opcode) {
        return +{
            category        => $opcode->category,
            name            => $opcode->name,
            description     => $opcode->description,
            operation_types => $opcode->operation_types,
            prototype       => $self->dump_prototype($opcode->prototype),
            flags           => $self->dump_flags($opcode->flags),
            private         => $self->dump_private($opcode->private),
        }
    }

    method dump_prototype ($prototype) {
        return +[] unless $prototype;
        return +[ map $self->dump_arg($_), $prototype->arguments->@* ];
    }

    method dump_arg ($args) {
        return +{
            type     => $_->type,
            optional => $_->optional ? 1 : 0,
        };
    }

    method dump_flags ($flags) {
        return +{ $flags->get_flags_as_hash };
    }

    method dump_private ($private) {
        return +{};
    }
}
