
use v5.40;
use experimental qw[ class ];

class Allium::Type::ValueType :isa(Allium::Type) {
    field $name :reader;
    ADJUST { $name = __CLASS__ =~ s/^Allium\:\:Type\:\:ValueType\:\://r }
}

# this is kind of a top-type, but also can hold the mixed SV types
class Allium::Type::ValueType::Any :isa(Allium::Type::ValueType) {} # PVIV, PVNV

# these are special types with specific constants associated, but they are
# also often inferred (with True/False) as well
class Allium::Type::ValueType::Null  :isa(Allium::Type::ValueType::Any) {} # sv_undef
class Allium::Type::ValueType::True  :isa(Allium::Type::ValueType::Any) {} # sv_yes
class Allium::Type::ValueType::False :isa(Allium::Type::ValueType::Any) {} # sv_no

# This is a small numerical tower (borrowed from Scheme) see Wikipedia for
# a good description: https://en.wikipedia.org/wiki/Numerical_tower but
# my basic summary is that each type can contain all the types above it
# this better matches the way Perl behaves in my opinion (as opposed to
# a specific Float and Int which inherit from Num, or something more
# complex like in Raku, etc).
#
#   [____Int____]   Integers
#  [_____Rat_____]  Floats
# [______Num______] Inf, -Int, NaN
#
class Allium::Type::ValueType::Num :isa(Allium::Type::ValueType::Any) {} # Inf, -Int, NaN
class Allium::Type::ValueType::Rat :isa(Allium::Type::ValueType::Num) {} # NV, IV
class Allium::Type::ValueType::Int :isa(Allium::Type::ValueType::Rat) {} # IV

# strings are string ...
class Allium::Type::ValueType::Str :isa(Allium::Type::ValueType::Any) {} # PV

# and then we have refs, ...
class Allium::Type::ValueType::Ref :isa(Allium::Type::ValueType::Any) {} # RV
# we might not need these, but why not ...
class Allium::Type::ValueType::Ref::Scalar :isa(Allium::Type::ValueType::Ref) {} # RV<SV>
class Allium::Type::ValueType::Ref::Array  :isa(Allium::Type::ValueType::Ref) {} # RV<AV>
class Allium::Type::ValueType::Ref::Hash   :isa(Allium::Type::ValueType::Ref) {} # RV<HV>
class Allium::Type::ValueType::Ref::Code   :isa(Allium::Type::ValueType::Ref) {} # RV<CV>
class Allium::Type::ValueType::Ref::Glob   :isa(Allium::Type::ValueType::Ref) {} # RV<GV>

