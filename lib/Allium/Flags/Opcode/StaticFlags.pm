
use v5.40;
use experimental qw[ class ];

use constant ();

class Allium::Flags::Opcode::StaticFlags {
    field $flags :param :reader;

    # NOTE:
    # These are flags stored in the opcode "config" in opcode.h, meaning
    # they are static and so always associated with the opcode.

    method needs_stack_mark       { !! grep /^OA_MARK$/,               @$flags }
    method needs_constant_folding { !! grep /^OA_FOLDCONST$/,          @$flags }
    method produces_scalar        { !! grep /^OA_RETSCALAR$/,          @$flags }
    method produces_integer       { !! grep /^OA_RETINT$/,             @$flags }
    method needs_target           { !! grep /^OA_TARGET$/,             @$flags }
    method target_can_be_in_pad   { !! grep /^OA_TARGET\|OA_TARGLEX$/, @$flags }
    method has_integer_version    { !! grep /^OA_OTHERINT$/,           @$flags }
    method defaults_to_topic      { !! grep /^OA_DEFGV$/,              @$flags }
    method make_temp_copy_in_list { !! grep /^OA_DANGEROUS$/,          @$flags }

    # -------------------------------------------------------------------
    #    | Description                         | Perl Constant
    # -------------------------------------------------------------------
    #  m | needs stack mark                    | (OA_MARK)
    #  f | needs constant folding              | (OA_FOLDCONST)
    #  s | produces a scalar                   | (OA_RETSCALAR)
    #  i | produces an integer                 | (OA_RETINT)             # << not in perl
    #  t | needs a target                      | (OA_TARGET)
    #  T | target can be in a pad              | (OA_TARGET|OA_TARGLEX)
    #  I | has a corresponding integer version | (OA_OTHERINT)
    #  d | make temp copy in list assignment   | (OA_DANGEROUS)
    #  u | uses $_ if no argument given        | (OA_DEFGV)
    # -------------------------------------------------------------------

    method as_ARRAY {
        +[ $flags->@* ]
    }
}
