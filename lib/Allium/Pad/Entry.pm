
use v5.40;
use experimental qw[ class ];

use Allium::Flags::Pad::Flags;

class Allium::Pad::Entry {
    field $name      :param :reader;
    field $stash     :param :reader;
    field $flags     :param :reader;
    field $cop_range :param :reader;

    method has_stash { defined $stash }
}




