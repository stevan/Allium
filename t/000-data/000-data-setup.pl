#!perl

use v5.40;
use experimental qw[ class ];

use Test::Allium::DataLoader;

Test::Allium::DataLoader
    ->new( data_dir => './t/000-data/' )
    ->write_initial_data_set;

