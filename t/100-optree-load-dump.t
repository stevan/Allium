#!perl

use v5.40;
use utf8;
use experimental qw[ class ];
use open         qw[ :std :encoding(UTF-8) ];

use Test::More;
use Test::Differences;

use A;
use Allium::Optree::Dumper;
use Allium::Optree::Loader;

sub foo {
    my $x = 10;
    my $y = $x + 100;
}

sub pprint ($op) {
    say($op->addr,('  ' x $op->depth),join ':' => $op->type, $op->name)
}
my $orig = A->new->disassemble(\&foo);
#$orig->walk(top_down => \&pprint);
my $dump1 = Allium::Optree::Dumper->new->dump($orig);
my $copy  = Allium::Optree::Loader->new->load($dump1);
my $dump2 = Allium::Optree::Dumper->new->dump($copy);
#$new->walk(top_down => \&pprint);

isa_ok($orig, 'Allium::Optree');
isa_ok($copy, 'Allium::Optree');
is($orig->root->addr, $copy->root->addr, '... the roots are identical');
is($orig->start->addr, $copy->start->addr, '... the starts are identical');
eq_or_diff($dump1, $dump2, '... the op dumps are identical');

done_testing;
