#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use A;

use Allium::SyntaxTree;
use JSON;

my $JSON = JSON->new->canonical->pretty;

sub foo {
    my $x     = 0;
    my @array = (1 .. 10);

    foreach my $y (@array) {
        $x += $y;
    }
}

my $orig = A->new->disassemble(\&foo);

my $builder = Allium::SyntaxTree->new( optree => $orig );
my $root = $builder->build;

say $JSON->encode($root->to_JSON);


done_testing;
