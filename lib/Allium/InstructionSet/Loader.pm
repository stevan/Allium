
use v5.40;
use experimental qw[ class ];

use Allium::InstructionSet;

class Allium::InstructionSet::Loader {
    method load ($raw) {
        my @opcodes;
        foreach my $c (@$raw) {

            my @args;
            if ($c->{args}) {
                foreach my ($i, $a) (indexed $c->{args}->@*) {
                    my $type = $a->{type};
                    Allium::Opcode::ArgType->can( $type )
                        || die "Could not find type($type) for arg[$i] for opcode(",$c->{name},")";
                    push @args => Allium::Opcode::Arg->new(
                        type     => Allium::Opcode::ArgType->$type,
                        optional => !!($a->{optional}),
                    );
                }
            }

            my $flags = Allium::Opcode::Flags->new(
                ($c->{flags}
                    ? (map { ($_ => true) } $c->{flags}->@*)
                    : ())
            );

            push @opcodes => Allium::Opcode->new(
                name    => $c->{name},
                opclass => $c->{opclass},
                args    => \@args,
                flags   => $flags,
            );
        }

        return Allium::InstructionSet->new( opcodes => \@opcodes );
    }
}
