<!----------------------------------------------------------------------------->
# ARCHITECTURE
<!----------------------------------------------------------------------------->

## `perl` and `Allium`

The layer between `perl` and `Allium` is the `A` module, which has two main
functions.

- Assembly
    - Given `Allium` objects as input, this can "assemble" them in `perl`
- Disassembly
    - Given a `perl` interpreter as input, this can "disassemble" it into `Allium` objects

The `A::OP` namespace handle (dis)assembling any subroutines (`CV`s) to/from `Allium::Optree`
objects, while the `A::MOP` namespace handles (dis)assembling the root `perl` stash (`defstash`)
into `Allium::MOP` objects.

The `A` module makes heavy use of the `B` framework, and uses the `B::Generate` module when
"assembling" subroutines (`CV`s).

## `Allium` Components

All `Allium` compnents store their information in a way that is independent from `perl` itself.
This means that once "disassembled" into `Allium` objects and serialized to disk, the original
program does not need to be loaded into `perl` in order to loaded by `Allium`.

In fact, an `Allium` environment loaded from disk is an entirely symbolic representation of a
Perl program frozen in time.

### `Allium::InstructionSet` - information about the Perl opcode set

This module is a representation of an instruciton set of the Perl language. It is a collection of
`Allium::Opcode` objects with information about each opcode such as:

- The category, name and description of the opcode
- The set of static flags for this opcode
- The bit definitions of the private flags used by this opcode
- The set of possible Operation types this opcode can be used with
- The prototype of the opcode

The plan is to add more information as this project matures, such as proper type signatures for
the opcodes, etc.

### `Allium::MOP` - a compile time Meta Object Protocol

This is a representation of the namespace tree in Perl. It can be used to (re)create a namespace,
or set of namespaces, with all the value containers within it. It does not store literal values,
but each value has a unique `OID` which can be used to bind literals after loading the namespace.

The primary way to interact with the `Allium::MOP` is via the `autovivify` and `lookup` methods,
passing them fully qualified names. The `autovivify` method will find a value container or create it,
creating any intermediary namespaces that are needed. This tries to matches the semantics of Perl's
package system as closely as possible. The `lookup` method also tries to find a value container,
but returns nothing if it was unable to find it (or one of the intermediary packages).

### `Allium::Optree` - a model for Perl code

This is a representation of an opcode tree from `perl` in a format that can be easily (de)serialized
into any JSON like format. It retains all the connections between nodes such that it can be
recreated in `perl` (see `A::OP` information above).

### `Allium::SyntaxTree` - an AST for Perl code

This is an AST (Abstract Syntax Tree) for Perl code which is generated from an `Allium::Optree`.
While this is normally done the other way around (AST generates opcodes), this does not preclude
us from doing that using a parser such as `Guacamole` to target the `Allium::SyntaxTree` objects.
And while this might at first glance seem impossible, this is exactly what the `B::Desparse` module
does.

Currently this component is at a very early stage, but the earlier prototype `B::MOP` module used
the AST to implement a number of useful tools such as dependency resolution (at a sub call level)
and Type Inference.













