
use v5.40;
use experimental qw[ class ];

# TODO: remove this dependency
use importer 'Path::Tiny' => qw[ path ];

use JSON;
use Allium::InstructionSet;

class Allium::InstructionSet::Loader {
    field $decoder :param :reader = undef;

    ADJUST {
        $decoder //= JSON->new;
    }

    method load_file ($filename) {
        my $file = path($filename);
        my $json = $file->slurp;
        return $self->load_json($json);
    }

    method load_json ($json) {
        my $raw = $decoder->decode($json);
        return $self->load($raw);
    }

    method load ($raw) {
        my @opcodes;
        foreach my $c (@$raw) {

            my $prototype;
            if ($c->{prototype}) {
                my @args;
                foreach my ($i, $a) (indexed $c->{prototype}->@*) {
                    push @args => Allium::Opcode::Argument->new(
                        type     => $a->{type},
                        optional => !!($a->{optional}),
                    );
                }
                $prototype = Allium::Opcode::Prototype->new( arguments => \@args );
            }

            my $flags = Allium::Flags::Opcode::StaticFlags->new(
                flags => $c->{static_flags}
            );

            my $private = Allium::Flags::Opcode::PrivateFlags->new(
                flags => $c->{private_flags},
            );

            push @opcodes => Allium::Opcode->new(
                category        => $c->{category},
                name            => $c->{name},
                description     => $c->{description},
                operation_types => $c->{operation_types},
                prototype       => $prototype,
                static_flags    => $flags,
                private_flags   => $private,
            );
        }

        return Allium::InstructionSet->new( opcodes => \@opcodes );
    }
}
