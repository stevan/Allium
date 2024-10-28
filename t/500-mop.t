#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use Allium::MOP;

## -------------------------------------------------------------------------------------------------

my $mop = Allium::MOP->new;
isa_ok($mop, 'Allium::MOP');

subtest '... testing autovivify' => sub {
    my $sv = $mop->autovivify('$Foo::Bar::Baz');
    isa_ok($sv, 'Allium::MOP::ScalarValue');
    ok($sv->is_undefined, '... the scalar is undefined');
    ok(!$sv->is_defined, '... the scalar is undefined');
};

subtest '... testing autovivify' => sub {
    my $av1 = $mop->autovivify('@Foo::Bar');
    my $av2 = $mop->autovivify('@Foo::Bar');

    isa_ok($av1, 'Allium::MOP::ArrayValue');
    isa_ok($av2, 'Allium::MOP::ArrayValue');

    is($av1->OID, $av2->OID, '... these are the same values');
};

subtest '... testing autovivify' => sub {
    my $gv = $mop->autovivify('*Foo');
    isa_ok($gv, 'Allium::MOP::GlobValue');

    ok(!$gv->is_namespace, '... we are not a namespace');
    is($gv->name, 'Foo', '... got the right name');
};

subtest '... testing autovivify' => sub {
    my $gv_stash = $mop->autovivify('*Foo::Bar::Gorch::');
    isa_ok($gv_stash, 'Allium::MOP::GlobValue');

    ok($gv_stash->is_namespace, '... we are a namespace');
    is($gv_stash->name, 'Gorch::', '... got the right name');

    my $stash = $mop->autovivify('%Foo::Bar::Gorch::');
    isa_ok($stash, 'Allium::MOP::Stash');
    isa_ok($stash, 'Allium::MOP::HashValue');

    is(refaddr $stash, refaddr $gv_stash->stash, '... it is the same as the gv->stash');
    is(refaddr $stash, refaddr $gv_stash->hash, '... it is the same as the gv->hash');

    my $gv = $mop->autovivify('*Foo::Bar::Gorch');
    isa_ok($gv, 'Allium::MOP::GlobValue');

    ok(!$gv->is_namespace, '... we are not a namespace');
    is($gv->name, 'Gorch', '... got the right name');

    my $sv = $mop->autovivify('$Foo::Bar::Gorch');
    isa_ok($sv, 'Allium::MOP::ScalarValue');
    is($gv->scalar->OID, $sv->OID, '... this is the scalar we expect');

    my $av = $mop->autovivify('@Foo::Bar::Gorch');
    isa_ok($av, 'Allium::MOP::ArrayValue');
    is($gv->array->OID, $av->OID, '... this is the array we expect');

    my $hv = $mop->autovivify('%Foo::Bar::Gorch');
    isa_ok($hv, 'Allium::MOP::HashValue');
    is($gv->hash->OID, $hv->OID, '... this is the hash we expect');

    my $cv = $mop->autovivify('&Foo::Bar::Gorch');
    isa_ok($cv, 'Allium::MOP::CodeValue');
    is($gv->code->OID, $cv->OID, '... this is the code we expect');
    is($cv->glob->OID, $gv->OID, '... check the connected glob');

    is($cv->glob->name, 'Gorch', '... got the connected glob name');
};


#my %arena = $mop->dump_arena->%*;
#foreach my ($id, $o) (map { $_, $arena{$_} } sort { $a <=> $b } keys %arena) {
#    say "ID: $id OBJECT: ".$o->to_string;
#}
#
#sub walk ($glob, $f, $depth=0) {
#    $f->($glob, $depth);
#    foreach my $g ($glob->stash->get_all_namespaces) {
#        walk($g, $f, $depth + 1);
#    }
#}
#
#walk($mop->main, sub ($glob, $depth) {
#    say(('    ' x $depth),$glob);
#    foreach my $g ($glob->stash->get_all_globs) {
#        say(('    ' x $depth),'  > ',$g);
#    }
#});


done_testing;
