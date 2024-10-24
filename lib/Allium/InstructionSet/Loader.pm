
use v5.40;
use experimental qw[ class ];

use Allium::InstructionSet;

class Allium::InstructionSet::Loader {
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

            my $flags = Allium::Opcode::Flags->new(
                ($c->{flags}
                    ? (map { ($_ => true) } $c->{flags}->@*)
                    : ())
            );

            my $private = +{};

            push @opcodes => Allium::Opcode->new(
                category        => $c->{category},
                name            => $c->{name},
                description     => $c->{description},
                operation_types => $c->{operation_types},
                prototype       => $prototype,
                flags           => $flags,
                private         => $private,
            );
        }

        return Allium::InstructionSet->new( opcodes => \@opcodes );
    }
}
