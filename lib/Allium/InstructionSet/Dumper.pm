
use v5.40;
use experimental qw[ class ];

use Allium::InstructionSet;

class Allium::InstructionSet::Dumper {

    method dump ($config) {
        return +[ map $self->dump_opcode($_), $config->opcodes->@* ];
    }

    method dump_opcode ($opcode) {
        return +{
            name    => $opcode->name,
            opclass => $opcode->opclass,
            args    => $self->dump_args($opcode->args),
            flags   => $self->dump_flags($opcode->flags),
        }
    }

    method dump_args ($args) {
        return +[ map $self->dump_arg($_), @$args ];
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
}
