#!perl

use v5.40;
use utf8;
use experimental qw[ class ];
use open         qw[ :std :encoding(UTF-8) ];

use Test::More;
use JSON ();

use A;
use Allium::Optree::Dumper;
use Allium::Optree::Loader;

sub foo {
    my $x = 10;
    my $y = $x + 100;
}

my $JSON = JSON->new->pretty->canonical;

sub pprint ($op) {
    say($op->addr,('  ' x $op->depth),join ':' => $op->type, $op->name)
}

my $orig = A->new->disassemble(\&foo);
$orig->walk(top_down => \&pprint);

my $dump = Allium::Optree::Dumper->new->dump($orig);
#say $JSON->encode($dump);

my $new  = Allium::Optree::Loader->new->load($dump);
isa_ok($new, 'Allium::Optree');

$new->walk(top_down => \&pprint);

done_testing;
