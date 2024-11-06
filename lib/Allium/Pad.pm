
use v5.40;
use experimental qw[ class ];

use Allium::Pad::Entry;

class Allium::Pad {
    field @entries :reader;

    method add_entry ($entry) { push @entries => $entry }
}


