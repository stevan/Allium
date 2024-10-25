#!perl

use v5.40;
use utf8;
use experimental qw[ class ];
use open         qw[ :std :encoding(UTF-8) ];

use Test::More;

use A;

sub foo ($x) {
    if ($x > 5) {
        my $y = 1000;
    }
    else {
        my $y = 1300;
        my $z = cos($y + $x);
        my @test = (1 .. 100);
    }
}

my $tree = A->new->disassemble(\&foo);

=pod
╭╮
╰╯
┌─┬─┐
├─┼─┤
└─┴─┘
┈ ┊
=cut

sub format_address ($addr) {
    state %colors;
    my @rgb = @{ $colors{$addr} //= [ map { (int(rand(64)) * 4) - 1  } qw[ r g b ] ] };
    sprintf "\e[48;2;%d;%d;%d;m %d \e[0m" => @rgb, $addr;
}

my @headers = qw[ opcode operation public-flags private-flags next-opcode ];
my @widths  = (45, 10, 20, 15, 12);

say('╭─',('─' x 45),'─┬─',('─' x 10),'─┬─',('─' x 20),'─┬─',('─' x 15),'─┬─',('─' x 12),'─╮',);
say((sprintf '│ %-45s │ %-10s │ %-20s │ %-15s │ %12s │', @headers));
say('├─',('─' x 45),'─┼─',('─' x 10),'─┼─',('─' x 20),'─┼─',('─' x 15),'─┼─',('─' x 12),'─┤',);

$tree->walk(bottom_up => sub ($op) {
    say('│ ',format_address($op->addr),
        (sprintf ' ┊ %-30s │ %10s │ %-20s │ %-15s │ ',
            (sprintf '%s(%s)%s' =>
                    ('  ' x $op->depth),
                    $op->name,
                    ($op->is_nullified ? '*' : '')),
            ($op->type),
            ($op->public_flags->to_string( seperator => ' ', verbosity => -1 )),
            ($op->private_flags->to_string( seperator => ' ', verbosity => -1 ))),
        ($op->next ? format_address($op->next->addr) : '    (end)   '),' │',
    );
});

say('╰─',('─' x 45),'─┴─',('─' x 10),'─┴─',('─' x 20),'─┴─',('─' x 15),'─┴─',('─' x 12),'─╯',);

done_testing;
