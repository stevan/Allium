
use v5.40;
use experimental qw[ class ];

use Allium::InstructionSet;

class Allium::InstructionSet::Dumper {

    method dump ($config) {
        return +[ map $self->dump_opcode($_), $config->opcodes->@* ];
    }

    method dump_opcode ($opcode) {
        return +{
            category    => $opcode->category,
            name        => $opcode->name,
            description => $opcode->description,
            operation   => $opcode->operation,
            signature   => $self->dump_signature($opcode->signature),
            flags       => $self->dump_flags($opcode->flags),
            private     => $self->dump_private($opcode->private),
        }
    }

    method dump_signature ($signature) {
        return +[ map $self->dump_arg($_), @$signature ];
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
