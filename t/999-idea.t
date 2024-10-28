#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use B;
use YAML qw[ Dump ];

use A::MOP::Disassembler;

package Foo {
    our $BAR = 'huh?';
    BEGIN { $BAR = 'BAR!!' }

    sub foo {
        say 10, 20, 30, 40;
    }

    sub bar {
        $BAR
    }
}

INIT {
    my $d = A::MOP::Disassembler->new;

    my $mop = $d->disassemble( *Foo:: );
    #isa_ok($mop, 'Allium::MOP');

    $mop->walk(sub ($glob, $depth) {
        say(('    ' x $depth),$glob);
        foreach my $g (sort { $a->OID <=> $b->OID } $glob->stash->get_all_globs) {
            say(('    ' x $depth),'  > ',$g);
        }
    });

    warn ${^GLOBAL_PHASE};
}

my $d = A::MOP::Disassembler->new;

my $mop = $d->disassemble( *Foo:: );
#isa_ok($mop, 'Allium::MOP');

$mop->walk(sub ($glob, $depth) {
    say(('    ' x $depth),$glob);
    foreach my $g (sort { $a->OID <=> $b->OID } $glob->stash->get_all_globs) {
        say(('    ' x $depth),'  > ',$g);
    }
});


done_testing;

