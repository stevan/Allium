
use v5.40;
use experimental qw[ class ];

class Allium::Flags::Opcode::StaticFlags {
    field $flags :param :reader;

    # NOTE:
    # These are flags stored in the opcode "config" in opcode.h, meaning
    # they are static and so always associated with the opcode.

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
