
use v5.40;
use experimental qw[ class ];

use Allium::Flags::Pad::Flags;
use Allium::Flags::Pad::ParentFlags;

class Allium::Pad::Entry {
    field $name      :param :reader;
    field $flags     :param :reader;
    field $cop_range :param :reader;

    field $type :reader;

    ADJUST {
        $type = (split '::' => __CLASS__)[-1];
    }
}

class Allium::Pad::Entry::Outer  :isa(Allium::Pad::Entry) {
    field $parent_pad_index :param :reader;
    field $parent_lex_flags :param :reader;
}

class Allium::Pad::Entry::State  :isa(Allium::Pad::Entry) {}
class Allium::Pad::Entry::LValue :isa(Allium::Pad::Entry) {}

class Allium::Pad::Entry::Our :isa(Allium::Pad::Entry) {
    field $stash_name :param :reader;
}

class Allium::Pad::Entry::Field :isa(Allium::Pad::Entry) {}
class Allium::Pad::Entry::Temp  :isa(Allium::Pad::Entry) {}
class Allium::Pad::Entry::Local :isa(Allium::Pad::Entry) {}


