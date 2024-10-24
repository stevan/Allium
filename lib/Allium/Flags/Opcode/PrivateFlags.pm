
use v5.40;
use experimental qw[ class ];

class Allium::Flags::Opcode::PrivateFlags {
    field $flags :param :reader;

    # NOTE:
    # These are flags stored in the B::Op_private module, and
    # are not so much flags as bit definitions. Probably a
    # good idea to add some more code around this, but we
    # can just use this for now.

    method as_HASH {
        +{ $flags->%* }
    }
}

=pod

Bit Def example, see B::Op_private for more info.

{
   "0" : {
      "bitmask" : 1,
      "bitmax" : 0,
      "bitmin" : 0,
      "label" : "-",
      "mask_def" : "OPpARG1_MASK"
   },
   "2" : "OPpLVREF_ELEM",
   "3" : "OPpLVREF_ITER",
   "4" : {
      "bitmask" : 48,
      "bitmax" : 5,
      "bitmin" : 4,
      "enum" : [
         0, "OPpLVREF_SV", "SV",
         1, "OPpLVREF_AV", "AV",
         2, "OPpLVREF_HV", "HV",
         3, "OPpLVREF_CV", "CV"
      ],
      "mask_def" : "OPpLVREF_TYPE"
   },
   "5" : {
      "bitmask" : 48,
      "bitmax" : 5,
      "bitmin" : 4,
      "enum" : [
         0, "OPpLVREF_SV", "SV",
         1, "OPpLVREF_AV", "AV",
         2, "OPpLVREF_HV", "HV",
         3, "OPpLVREF_CV", "CV"
      ],
      "mask_def" : "OPpLVREF_TYPE"
   },
   "6" : "OPpPAD_STATE",
   "7" : "OPpLVAL_INTRO"
}

=cut
