#!perl

use v5.40;
use utf8;
use experimental qw[ class ];
use open         qw[ :std :encoding(UTF-8) ];

use Test::More;
use Test::Differences;

use A;

use Allium::SyntaxTree;
use JSON;

my $JSON = JSON->new->canonical->pretty;

sub foo {
    my $x = 0;
    foreach my $y (0 .. 10) {
        $x += $y;
    }
}

my $orig = A->new->disassemble(\&foo);

my $builder = Allium::SyntaxTree->new( optree => $orig );
my $root = $builder->build;

say $JSON->encode($root->to_JSON);


done_testing;
