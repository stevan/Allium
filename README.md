<!----------------------------------------------------------------------------->
# Allium
<!----------------------------------------------------------------------------->

The three key things this module provides are:

- InstructionSet
    - a bundle of Opcode defintions
- Optree
    - a tree of Operations (see below)
- SyntaxTree
    - an abstract syntax tree

The two key concepts to understand are:

- Operation
    - generic operation types (Unary, Binary, etc.)
    - compose into a tree
    - associated with an Opcode
- Opcode
    - specific operations (`add`, `pre_inc`, etc.)
    - static information such as flags & "prototype" for the opcode


<!----------------------------------------------------------------------------->
### Using `perl` as a starting point
<!----------------------------------------------------------------------------->

We can use `Allium` to essentially de-compile the opcode tree in `perl`.

- `perl foo.pl`
    - `B` optree
        - `Allium` optree
            - `Allium` AST

Now we have both an optree and an AST, now we can the following with them.

#### Transpiler

We should have sufficient information to generate source code in most
any language we like (even back to Perl), while retaining semantics.

- `Allium` AST
    - Perl source code
    - Java source code
    - etc.

#### Re-Compiler

Given the Optree we can re-compile it and target a different low level
representation (IR), or ocpode set. Possibly taking advantage of tooling
(JITs, Optimizers, etc.) to greatly improve speed & resource usage.

- `Allium` Optree
    - LLVM IR
    - JVM Opcodes
    - etc.

#### Perl Optimizer

Perl does a lot of optimizations at compile time, but is limited because
of the flexibility allowed at runtime. If we can verify that this flexibility
is not used, then it could be possible to optimize Perl opcodes more
agressively at compile-time.

<!----------------------------------------------------------------------------->
### Using `Allium` AST as a starting point
<!----------------------------------------------------------------------------->

Parsers such as `Guacamole` can target the `Allium` AST which can be used to
do the following.

#### AST to Optree

Just as ASTs can be de-compiled from Optrees, we can also compile an Optree
from an AST. This is what all compilers do, and would be exactly what `perl`
does if you gave it the same code.

However, if the parser were to add information such as types, etc. to the AST,
these could then be used to optimise the Optree. And since this is targeting
the `Allium` Optree, once in that format, you can use all the tools available
for that and the AST (see above).

Syntax extensions would be just custom AST nodes, which could be transformed
into standard AST nodes. In fact, this is the foundation for a macro system
similar to Scheme or Lisp.

<!----------------------------------------------------------------------------->
### Using `Allium` Optree as a starting point
<!----------------------------------------------------------------------------->

We've already seen what is capable with this. It can be used to create an AST,
or re-compiled to JVM opcodes. But using tools like `B::Generate` we can also
re-target the `perl` runtime, which would enable the following:

#### Compiling $other_language to `perl`

It would be pretty silly to write a Javascript compiler that targets `perl` as
a runtime and just ignore the 20 years of JS engine optimizations. But this
could open up possibilities for DSLs or other "small" languages to be run
within a Perl program and be both controllable and composable by that same
Perl program.

> NOTE: Some crazy ideas can fall out of this one if you are not careful ;)

<!----------------------------------------------------------------------------->
## What can this module do right now?
<!----------------------------------------------------------------------------->

This is a very rough list of the current set of capabilities, much of which
is very unrefined.

### Instruction Sets

- Extract opcode information about a specific Perl checkout
    - turn it into an Allium::InstructionSet
        - contains data about:
            - name, description, flags
            - valid Operation types
            - valid Private flags
            - the "prototype" of the opcode
            - etc.
    - dump/load the instruction set as JSON

### Optrees

- Extract optree from `perl` using `B`
    - turn it into an Allium::Optree
        - which is a tree of Allium::Operations
    - uses the Allium::InstructionSet to enrich the data from `B`
        - accounting for nullified ops, etc.
    - dump/load the optree as JSON
        - retaining all the connections, flags, etc.

### Syntax Trees

- An Allium::Optree can be used to create an Allium::SyntaxTree
    - Visitor interface can be used to traverse the tree
    - dump/load the syntax tree as JSON

<!----------------------------------------------------------------------------->
## What do we plan to make this module do?
<!----------------------------------------------------------------------------->

These are the next steps of development for this module, in no particular
order. The functionality described here should open up many possibilities
for the future.

### Instruction Sets

- Constructing custom instruction sets
    - can be used to limit the set of allowed opcodes, etc.
- Construction instruction sets for other versions of Perl

### Optrees

- Load Allium::Optree into `perl` using `B::Generate`
    - Round trip from `perl` to `B` to `Allium` to `B` finally back to `perl`
    - This should allow us to use `perl` opcodes as a compiler target
        - and open up the possibility for a new `Perl` parser (see more below)

### Syntax Trees

- Given an Allium::SyntaxTree, build an Allium::Optree from it
    - This allows parser to directly target the SyntaxTree
        - making it simpler for a new `Perl` parser to be written

<!----------------------------------------------------------------------------->
## What does the future hold?
<!----------------------------------------------------------------------------->

These are the features planned for this module, but have yet to be written. In
most cases the proof of concept is already written (in `B::MOP`) and now it
needs to be "ported" to use Allium.

### Compile Time MOP (Meta Object Protocol)

Modules like `Moose`, etc. provide Meta Object Protocols to introspect and
manipulate the package/class system of Perl at runtime. These tools are very
powerful and can be used to manipulate the subroutines in packages. But these
tools are limited to only being able to manipulate subroutines, and are not
able to introspect the code of the subroutine.

This module will provide the ability to introspect and manipulate the code that
is inside of subroutines at compile time, as well as all the other features of
a runtime MOP (manipulating package namespaces).

### Type Inference & Type Checking

Using the information contained in the Optree and the InstructionSet we can
determine the types for a reasonable number of SyntaxTree nodes already. From
here we can attempt to infer the remaining types of the program. This type
system will never be like `Haskell` or `Rust`, but instead something much
less rigorous and therefore more appropriate for `Perl`.

The MOP (described above) could be used to resolve subroutines & methods at
compile-time for type checking. We could additionally create some kind of type
description file for Perl modules, similar to how TypeScript uses `.d.ts` files,
so that signatures do not need to be recompiled every time.

<!----------------------------------------------------------------------------->
## What other ideas could this enable?
<!----------------------------------------------------------------------------->

### Security Vulnerability Scan

Ususally these are done at the source code level, which may be good enough, but
this could do it at the opcode level instead. Not terribly sure this is useful.







