#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use B;
use YAML qw[ Dump ];

use A::MOP::Disassembler;

package Foo {
    use v5.40;

    our $BAR = 'huh?';
    BEGIN { $BAR = 'BAR!!' }

    sub foo {
        say 10, 20, 30, 40;
    }

    sub bar {
        $BAR;
    }
}


CHECK {
    my $d = A::MOP::Disassembler->new;

    my ($data, $mop) = $d->disassemble( *Foo:: );

    $mop->walk(sub ($glob, $depth) {
        say(('    ' x $depth),$glob);
        foreach my $g (sort { $a->OID <=> $b->OID } $glob->stash->get_all_globs) {
            say(('    ' x $depth),'  > ',$g);
        }
    });

    say Dump $data;

}


done_testing;

