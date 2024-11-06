#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use Test::Allium::DataLoader;
use Test::Allium::RegressionTester;

Test::Allium::RegressionTester
    ->new
    ->load_all_data
    ->run_regression_test;

done_testing;
