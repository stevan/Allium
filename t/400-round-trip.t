#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use YAML qw[ Dump ];

use A;
use Allium::Optree::Dumper;

sub foo {
    say 10, 20, 30, 40;
}

sub pprint ($op) { say($op->addr,('  ' x $op->depth),join ':' => $op->type, $op->name) }

CHECK {
    my $A    = A->new;
    my $orig = $A->disassemble(\&foo);
    $orig->walk(top_down => \&pprint);
    my $foo2 = $A->assemble($orig);
    *main::foo2 = $foo2;
}

say "... foo";
foo();
say "... foo2";
foo2();
say "... ";

done_testing;
