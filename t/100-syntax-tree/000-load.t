#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use ok 'Allium::SyntaxTree';

use ok 'Allium::SyntaxTree::Node';
use ok 'Allium::SyntaxTree::Expression';
use ok 'Allium::SyntaxTree::UnOp';
use ok 'Allium::SyntaxTree::BinOp';
use ok 'Allium::SyntaxTree::ListOp';
use ok 'Allium::SyntaxTree::Statement';

done_testing;
