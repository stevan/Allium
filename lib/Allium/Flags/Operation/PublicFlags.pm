

use v5.40;
use experimental qw[ class ];

class Allium::Flags::Operation::PublicFlags {
    field $b :param :reader;

    method returns_void   { !! (($b->flags & B::OPf_WANT) == B::OPf_WANT_VOID  ) }
    method returns_scalar { !! (($b->flags & B::OPf_WANT) == B::OPf_WANT_SCALAR) }
    method returns_list   { !! (($b->flags & B::OPf_WANT) == B::OPf_WANT_LIST  ) }

    method has_arguments      { !! ($b->flags & B::OPf_KIDS   ) } # the op has arguments
    method was_parenthesized  { !! ($b->flags & B::OPf_PARENS ) } # was called with ()
    method return_container   { !! ($b->flags & B::OPf_REF    ) } # Return container, not value
    method is_lvalue          { !! ($b->flags & B::OPf_MOD    ) } # will modifiy the value
    method is_mutator_varient { !! ($b->flags & B::OPf_STACKED) } # ex: $x += 10
    method is_special         { !! ($b->flags & B::OPf_SPECIAL) } # Do something weird (see op.h)
}
