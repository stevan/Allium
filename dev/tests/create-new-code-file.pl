#!perl

use v5.40;
use experimental qw[ class ];

use Test::Allium::DataLoader;

Test::Allium::DataLoader
    ->new( data_dir => './t/000-data/' )
    ->load_all_code
    ->create_new_code_file;

