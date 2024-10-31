#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use B;
use YAML qw[ Dump ];

use A::MOP::Disassembler;

package Foo {
    our $BAR = 'BAZ!';

    sub foo {
        say 10, 20, 30, 40;
    }

    sub bar {
        $BAR;
    }
}


CHECK {
    my $d = A::MOP::Disassembler->new;

    my $mop = $d->disassemble( *Foo:: );

    #$mop->walk(sub ($glob, $depth) {
    #    say(('    ' x $depth),$glob);
    #    foreach my $g (sort { $a->OID <=> $b->OID } $glob->stash->get_all_globs) {
    #        say(('    ' x $depth),'  > ',$g);
    #    }
    #});

    $mop->walk_globs(sub ($glob) { say $glob });


}


done_testing;

