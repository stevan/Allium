

use v5.40;
use experimental qw[ class ];

class Allium::Flags::Operation::PrivateFlags {
    field $b :param :reader;

    # does this op create a new variable?
    method is_declaration { !! ($b->private & B::OPpLVAL_INTRO) }

    method has_pad_target { !! ($b->private & B::OPpTARGET_MY) }
}
