#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use Test::Allium::DataLoader;

my $data_loader = Test::Allium::DataLoader->new( data_dir => './t/000-data/' );

foreach my $code ( $data_loader->load_all_code ) {
    $code->load_optree
         ->load_allium
         ->load_concise;
    my $dump    = $code->dump_optree;
    my $concise = $code->dump_concise;
    eq_or_diff($code->allium,  $dump, '... got the same dump', { Sortkeys => true });
    eq_or_diff($code->concise, $concise, '... got the same concise');
}

done_testing;
