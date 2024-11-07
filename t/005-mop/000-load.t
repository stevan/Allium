#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use ok 'Allium::MOP';
use ok 'Allium::MOP::Stash';
use ok 'Allium::MOP::ScalarValue';
use ok 'Allium::MOP::ArrayValue';
use ok 'Allium::MOP::HashValue';
use ok 'Allium::MOP::CodeValue';
use ok 'Allium::MOP::GlobValue';

done_testing;
