#!perl

use v5.40;
use experimental qw[ class ];

use JSON;

use Allium::InstructionSet::Loader::FromPerlCheckout;
use Allium::InstructionSet::Dumper;

sub main ($perl_checkout) {
    my $gen = Allium::InstructionSet::Loader::FromPerlCheckout->new(
        perl_checkout => $perl_checkout
    );

    my $instruction_set = $gen->generate;
    warn $instruction_set;

    my $raw = Allium::InstructionSet::Dumper->new->dump($instruction_set);

    say JSON->new->pretty->canonical->encode($raw);

}

main(@ARGV);
