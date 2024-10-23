
use v5.40;
use experimental qw[ class ];

class A::OP       :isa(Allium::Operation::OP)       {}
class A::SVOP     :isa(Allium::Operation::SVOP)     {}
class A::PADOP    :isa(Allium::Operation::PADOP)    {}
class A::PVOP     :isa(Allium::Operation::PVOP)     {}
class A::COP      :isa(Allium::Operation::COP)      {}
class A::METHOP   :isa(Allium::Operation::METHOP)   {}
class A::UNOP     :isa(Allium::Operation::UNOP)     {}
class A::UNOP_AUX :isa(Allium::Operation::UNOP_AUX) {}
class A::LOGOP    :isa(Allium::Operation::LOGOP)    {}
class A::BINOP    :isa(Allium::Operation::BINOP)    {}
class A::LISTOP   :isa(Allium::Operation::LISTOP)   {}
class A::PMOP     :isa(Allium::Operation::PMOP)     {}
class A::LOOP     :isa(Allium::Operation::LOOP)     {}
