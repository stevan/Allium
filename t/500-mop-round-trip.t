#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use A;

package Foo {
    our $BAZ;
    BEGIN { $BAZ = 'BAZ!!' }

    sub foo {
        say 10, 20, 30, 40;
    }

    sub bar {
        $BAZ;
    }
}

sub DUMPER ($glob, $depth) {
    diag(('    ' x $depth),$glob);
    foreach my $g ($glob->stash->get_all_globs) {
        diag(('    ' x $depth),'  > ',$g);
    }
}

CHECK {
    my $disassembler = A->new->mop_disassembler;
    isa_ok($disassembler, 'A::MOP::Disassembler');

    my $mop = $disassembler->disassemble('Foo::');
    isa_ok($mop, 'Allium::MOP');

    diag "ORIGINAL MOP:";
    $mop->walk(\&DUMPER);

    my $env = $mop->root_env;
    isa_ok($env, 'Allium::Environment');

    my $new_env = $env->relocate(['Bar::']);
    isa_ok($new_env, 'Allium::Environment');

    isnt(refaddr $env, refaddr $new_env, '... the relocated env is different');

    $mop->load_environment( $new_env );
    diag "ORIGINAL MOP + NEW_ENV:";
    $mop->walk(\&DUMPER);

    my $new_mop = Allium::MOP->new->load_environment( $new_env );
    diag "NEW MOP (w/ NEW_ENV):";
    $new_mop->walk(\&DUMPER);
}

done_testing;
