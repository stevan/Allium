#!perl

use v5.40;
use utf8;
use experimental qw[ class ];
use open         qw[ :std :encoding(UTF-8) ];

use A;

sub foo {
    my $x     = 0;
    my @array = (1 .. 10);

    foreach my $y (@array) {
        $x += $y;
    }
}

my $tree = A->new->disassemble(\&foo);

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

$tree->walk(top_down => sub ($op) {
    say('│ ',format_address($op->addr),
        (sprintf '┊%01d┊%-30s │ %10s │ %-20s │ %-15s │ ',
            $op->depth,
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


