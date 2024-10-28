#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use B;
use YAML qw[ Dump ];

use Allium::MOP;
use A::MOP::Disassembler;

my $d = A::MOP::Disassembler->new;

my $mop = Allium::MOP->new;
isa_ok($mop, 'Allium::MOP');

my @all = $d->walk_namespace( *Allium::MOP:: );

foreach my $symbol (@all) {
    $mop->autovivify($symbol);
}

say Dump \@all;

my %arena = $mop->dump_arena->%*;
foreach my ($id, $o) (map { $_, $arena{$_} } sort { $a <=> $b } keys %arena) {
    say "ID: $id OBJECT: ".$o->to_string;
}

sub walk ($glob, $f, $depth=0) {
    $f->($glob, $depth);
    foreach my $g ($glob->stash->get_all_namespaces) {
        walk($g, $f, $depth + 1);
    }
}

walk($mop->main, sub ($glob, $depth) {
    say(('    ' x $depth),$glob);
    foreach my $g ($glob->stash->get_all_globs) {
        say(('    ' x $depth),'  > ',$g);
    }
});


done_testing;


__END__

sub walksymtable ($namespace, $f, $depth=0) {
    state %seen;
    no strict 'refs';

    foreach my $name ( sort { $a cmp $b } keys %{ $namespace } ) {
        my $symbol = *{ $namespace . B::safename($name) };

        $f->($symbol, $depth);

        if ($name =~ /\:\:$/) {
            next if exists $seen{ $symbol };
            $seen{ $symbol }++;
            walksymtable( $symbol, $f, $depth + 1 );
        }
    }
}

walksymtable( *main:: => sub ($symbol, $depth) {
    say(('  ' x $depth),join ', ' => $symbol);
});
