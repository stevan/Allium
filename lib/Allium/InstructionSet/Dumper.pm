
use v5.40;
use experimental qw[ class ];

# TODO: remove this dependency
use importer 'Path::Tiny' => qw[ path ];

use JSON;
use Allium::InstructionSet;

class Allium::InstructionSet::Dumper {
    field $encoder :param :reader = undef;

    ADJUST {
        $encoder //= JSON->new;
    }

    method dump_file ($filename, $instruction_set) {
        my $json = $self->dump_json($instruction_set);
        my $file = path($filename);
        $file->spew($json);
        return;
    }

    method dump_json ($instruction_set) {
        my $raw  = $self->dump($instruction_set);
        my $json = $encoder->encode($raw);
        return $json;
    }

    method dump ($instruction_set) {
        return +[ map $self->dump_opcode($_), $instruction_set->opcodes->@* ];
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
