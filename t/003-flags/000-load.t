#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use ok 'Allium::Flags::Opcode::PrivateFlags';
use ok 'Allium::Flags::Opcode::StaticFlags';

use ok 'Allium::Flags::Operation::PrivateFlags';
use ok 'Allium::Flags::Operation::PublicFlags';

use ok 'Allium::Flags::Pad::Flags';
use ok 'Allium::Flags::Pad::ParentFlags';

done_testing;
