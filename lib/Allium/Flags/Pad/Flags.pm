
use v5.40;
use experimental qw[ class ];

use constant ();

class Allium::Flags::Pad::Flags {
    field $bits :param :reader;

    field $is_outer  :param :reader = false;
    field $is_state  :param :reader = false;
    field $is_lvalue :param :reader = false;
    field $is_our    :param :reader = false;
    field $is_field  :param :reader = false;
    field $is_temp   :param :reader = false;

    method dump_flags {
        # FIXME: do this better ... we should be able to read
        # the bits if we want to, but that means we need to
        # copy those bits into Allium.
        return +{
            bits => $bits,
            ($is_outer  ? (is_outer  => true) : ()),
            ($is_state  ? (is_state  => true) : ()),
            ($is_lvalue ? (is_lvalue => true) : ()),
            ($is_our    ? (is_our    => true) : ()),
            ($is_field  ? (is_field  => true) : ()),
            ($is_temp   ? (is_temp   => true) : ()),
        }
    }
}
