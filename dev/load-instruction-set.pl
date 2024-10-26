#!perl

use v5.40;
use experimental qw[ class ];

use JSON ();
use Path::Tiny;

use Allium::InstructionSet::Loader::FromPerlCheckout;
use Allium::InstructionSet::Dumper;

my $DEV_DATA_DIR = path(__FILE__)->parent->child('data');

sub main ($perl_checkout) {
    my $gen = Allium::InstructionSet::Loader::FromPerlCheckout->new(
        perl_checkout  => $perl_checkout,
        data_directory => $DEV_DATA_DIR,
    );

    my $instruction_set = $gen->generate;

    my $JSON = JSON->new->canonical->pretty;

    say Allium::InstructionSet::Dumper->new( encoder => $JSON )->dump_json($instruction_set);
}

main(@ARGV);
