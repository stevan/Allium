
use v5.40;
use experimental qw[ class ];

use Allium::InstructionSet;

class Allium::InstructionSet::Loader {
    method load ($raw) {
        my @opcodes;
        foreach my $c (@$raw) {

            my @signature;
            if ($c->{signature}) {
                foreach my ($i, $a) (indexed $c->{signature}->@*) {
                    my $type = $a->{type};
                    Allium::Opcode::ArgType->can( $type )
                        || die "Could not find type($type) for arg[$i] for opcode(",$c->{name},")";

                    push @signature => Allium::Opcode::Arg->new(
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

            my $private = +{};

            push @opcodes => Allium::Opcode->new(
                category    => $c->{category},
                name        => $c->{name},
                description => $c->{description},
                operation   => $c->{operation},
                signature   => \@signature,
                flags       => $flags,
                private     => $private,
            );
        }

        return Allium::InstructionSet->new( opcodes => \@opcodes );
    }
}
