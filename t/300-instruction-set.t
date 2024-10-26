#!perl

use v5.40;
use experimental qw[ class ];

use Path::Tiny;

use Test::More;
use Test::Differences;

use Allium::InstructionSet::Loader;

my $INSTR_SET_DIR = path(__FILE__)->parent->parent->child('data')->child('instruction-sets');

my $perl_5_41_4 = Allium::InstructionSet::Loader->new->load_file(
    $INSTR_SET_DIR->child('perl-5.41.4.json')
);

isa_ok($perl_5_41_4, 'Allium::InstructionSet');

ok(scalar($perl_5_41_4->opcodes->@*) != 0, '... we have opcodes');

my $padsv = $perl_5_41_4->get('padsv');
isa_ok($padsv, 'Allium::Opcode');
is($padsv->name, 'padsv', '... got the expected name');

done_testing;
