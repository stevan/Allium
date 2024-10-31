
use v5.40;
use experimental qw[ class ];

class Allium::Type::ContainerType :isa(Allium::Type) {}

class Allium::Type::ContainerType::Scalar :isa(Allium::Type::ContainerType) {} # SV
class Allium::Type::ContainerType::Array  :isa(Allium::Type::ContainerType) {} # AV
class Allium::Type::ContainerType::Hash   :isa(Allium::Type::ContainerType) {} # HV
class Allium::Type::ContainerType::Code   :isa(Allium::Type::ContainerType) {} # CV
class Allium::Type::ContainerType::Glob   :isa(Allium::Type::ContainerType) {} # GV
