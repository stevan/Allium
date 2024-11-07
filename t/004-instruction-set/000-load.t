#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use ok 'Allium::InstructionSet';
use ok 'Allium::InstructionSet::Dumper';
use ok 'Allium::InstructionSet::Loader';
use ok 'Allium::InstructionSet::Loader::FromPerlCheckout';

done_testing;
