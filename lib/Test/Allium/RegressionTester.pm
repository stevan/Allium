
use v5.40;
use experimental qw[ class ];

use importer 'Path::Tiny'        => qw[ path ];
use importer 'Test::More'        => qw[ subtest isa_ok ];
use importer 'Test::Differences' => qw[ eq_or_diff ];

use Test::Allium::DataLoader;

use Allium::Optree::Loader;
use Allium::Optree::Dumper;

class Test::Allium::RegressionTester {
    field $data_loader :reader;

    field @data;

    ADJUST {
        $data_loader = Test::Allium::DataLoader->new(
            data_dir => path(__FILE__) # /this file
                            ->parent   # /Allium
                            ->parent   # /Test
                            ->parent   # /lib
                            ->parent   # /
                            ->child('t')
                            ->child('000-data')
        );
    }

    method load_all_data {
        $data_loader->load_all_code;
        @data = map {
            $_->load_optree
              ->load_allium
              ->load_concise
        } $data_loader->shuffle_code;
        $self;
    }

    method run_regression_test {
        subtest sprintf('... running regression (%d) test(s)' => scalar @data) => sub {
            foreach my $code ( @data ) {
                subtest sprintf('... running regression for(%s)' => $code->subname ) => sub {
                    subtest sprintf('... testing against stored run for(%s)' => $code->subname ) => sub {
                        my $dump    = $code->dump_optree;
                        my $concise = $code->dump_concise;
                        eq_or_diff($dump,    $code->allium,  '... got the same dump', { Sortkeys => true });
                        eq_or_diff($concise, $code->concise, '... got the same concise');
                    };

                    subtest sprintf('... testing load/dump cycle for(%s)' => $code->subname ) => sub {
                        my $optree = Allium::Optree::Loader->new->load($code->allium);
                        isa_ok($optree, 'Allium::Optree');

                        my $dump = Allium::Optree::Dumper->new->dump($optree);
                        eq_or_diff($dump, $code->allium,      '... got the same dump (allium)',  { Sortkeys => true });
                        eq_or_diff($dump, $code->dump_optree, '... got the same dump (current)', { Sortkeys => true });
                    };

                    subtest sprintf('... testing top_down/bottom_up walkers for(%s)' => $code->subname ) => sub {
                        my (@top_down, @bottom_up);

                        my $optree = $code->optree;
                        $optree->walk(top_down  => sub ($op) { push @top_down  => $op });
                        $optree->walk(bottom_up => sub ($op) { push @bottom_up => $op });

                        eq_or_diff(
                            [ map $_->addr, @top_down ],
                            [ map $_->addr, reverse @bottom_up ],
                            '... top-down <-> bottom_up works'
                        );
                    };
                };
            }
        };
        $self;
    }
}
