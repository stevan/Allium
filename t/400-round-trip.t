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
    my $orig = $A->op_disassembler->disassemble(\&foo);
    $orig->walk(top_down => \&pprint);
    my $foo2 = $A->op_assembler->assemble($orig);
    *main::foo2 = $foo2;
}

pass "... we passed CHECK and will try to call foo()";
foo();
pass "... foo() still worked, so lets try our foo2()";
foo2();
pass "... foo2() worked, so I guess we did it!";

done_testing;
