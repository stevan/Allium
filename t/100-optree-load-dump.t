#!perl

use v5.40;
use experimental qw[ class ];

use Sub::Util;

use Test::More;
use Test::Differences;

use A;
use Allium::Optree::Dumper;
use Allium::Optree::Loader;

sub foo {
    foreach (0 .. 10) {
        say;
    }
}

sub bar {
    my $x = 100;
    $x += 200 - 30;
    return $x;
}

sub baz ($x, $y) {
    return "~~~ $x" . $y . " hello";
}

sub gorch ($x) {
    if ($x > 5) {
        my $y = 1000;
    }
    else {
        my $y = 1300;
        my $z = cos($y + $x);
        my @test = (1 .. 100);
    }
}

our $SCALAR;
our @ARRAY;
our %HASH;

sub bling {
    return $SCALAR, @ARRAY, %HASH;
}


foreach my $code (\&foo, \&bar, \&baz, \&gorch, \&bling) {
    my $name = Sub::Util::subname($code);
    subtest "... testing load/dump for code($name)[".(refaddr $code)."]" => sub {
        my $orig = A->new->op_disassembler->disassemble($code);
        isa_ok($orig, 'Allium::Optree');

        #$orig->walk(top_down  => sub ($op) { say sprintf '%s(%s)' => $op->type, $op->name });

        my $dump1 = Allium::Optree::Dumper->new->dump($orig);

        #use YAML qw[ Dump ];
        #warn Dump $dump1->{pad};

        my $copy  = Allium::Optree::Loader->new->load($dump1);
        isa_ok($copy, 'Allium::Optree');

        #$copy->walk(top_down  => sub ($op) {
        #    return unless $op isa Allium::Operation::SVOP;
        #    say sprintf 'OP(%s) : SYM(%s) = VAL(%s)' =>
        #        ($op->name // '~'),
        #        ($op->binding->symbol ? $op->binding->symbol->full_name : '~'),
        #        ($op->binding->value // '~'),
        #    ;
        #});

        my $dump2 = Allium::Optree::Dumper->new->dump($copy);

        #use YAML qw[ Dump ];
        #warn Dump $dump2;

        isa_ok($orig, 'Allium::Optree');
        isa_ok($copy, 'Allium::Optree');
        is($orig->root->addr, $copy->root->addr, '... the roots are identical');
        is($orig->start->addr, $copy->start->addr, '... the starts are identical');
        eq_or_diff($dump1, $dump2, '... the op dumps are identical');
    };
}

done_testing;
