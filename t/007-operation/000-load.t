#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use ok 'Allium::Operations';

use ok 'Allium::Operation::OP';
use ok 'Allium::Operation::SVOP';
use ok 'Allium::Operation::PADOP';
use ok 'Allium::Operation::PVOP';
use ok 'Allium::Operation::COP';
use ok 'Allium::Operation::METHOP';
use ok 'Allium::Operation::UNOP';
use ok 'Allium::Operation::UNOP_AUX';
use ok 'Allium::Operation::LOGOP';
use ok 'Allium::Operation::BINOP';
use ok 'Allium::Operation::LISTOP';
use ok 'Allium::Operation::PMOP';
use ok 'Allium::Operation::LOOP';


done_testing;
