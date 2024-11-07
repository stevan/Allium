#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use ok 'Allium::Optree';
use ok 'Allium::Optree::Loader';
use ok 'Allium::Optree::Walker';
use ok 'Allium::Optree::Walker::BottomUp';
use ok 'Allium::Optree::Walker::ExecOrder';
use ok 'Allium::Optree::Walker::TopDown';

done_testing;
