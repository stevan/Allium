
use v5.40;
use experimental qw[ class ];

class Allium::Flags::Pad::ParentFlags {
    field $bits :param :reader;

    field $is_anon  :param :reader = false;
    field $is_multi :param :reader = false;

    method dump_flags {
        # FIXME: do this better ... we should be able to read
        # the bits if we want to, but that means we need to
        # copy those bits into Allium.
        return +{
            bits => $bits,
            ($is_anon  ? (is_anon  => true) : ()),
            ($is_multi ? (is_multi => true) : ()),
        }
    }
}
