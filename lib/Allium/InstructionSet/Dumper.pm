
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
            static_flags    => $self->dump_static_flags($opcode->static_flags),
            private_flags   => $self->dump_private_flags($opcode->private_flags),
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

    method dump_static_flags ($flags) {
        return $flags->as_ARRAY;
    }

    method dump_private_flags ($private) {
        return $private->as_HASH;
    }
}
