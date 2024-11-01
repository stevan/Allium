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

my $orig = A->new->op_disassembler->disassemble(\&foo);
isa_ok($orig, 'Allium::Optree');

my $builder = Allium::SyntaxTree->new( optree => $orig );
isa_ok($builder, 'Allium::SyntaxTree');

my $root = $builder->build;
isa_ok($root, 'Allium::SyntaxTree::UnOp');
is($root->op->name, 'leavesub', '... got the expected root node');

pass $JSON->encode($root->to_JSON);

done_testing;
