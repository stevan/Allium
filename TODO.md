<!----------------------------------------------------------------------------->
# TODO
<!----------------------------------------------------------------------------->

- Need an `Allium::CompilerUnit` which should ...
    - be specific to a given package/namespace
    - it should contain ...
        - information about when it was compiled
            - what `Allium::InstructionSet` was used
            - `perl` version was used
            - date/time stamp
            - etc.
        - a serialized `Allium::MOP`
            - meaning, all the globs in the stash
        - a `$DATA` section
            - an array of serialized compile time perl data
                - each which is mapped to the OID of the `Allium::MOP::Value` object it belongs to
        - a `@CODE` section
            - a set of serialized `Allium::Optree` objects
                - each which is mapped to the OID of the `Allium::MOP::Value` object it belongs to


<!----------------------------------------------------------------------------->
## B::Concise tricks
<!----------------------------------------------------------------------------->

Dump a package symbol table, and the %INC keys to see what is loaded
```
perl -MO=Concise,-stash=Foo -I t/ -MFoo -E 'BEGIN { say join "\n" => keys %INC }'
```

Dump all the BEGIN blocks as well as the above
```
perl -MO=Concise,-stash=Foo,BEGIN -I t/ -MFoo -E 'BEGIN { say join "\n" => keys %INC }'
```

<!----------------------------------------------------------------------------->

Steps needed to improve the round-trip-ing process. A side effect of which
will be an implementation of the ObjectSpace.

### Step 1.

- A::OP::Disassembler
    - This needs to extract all the rest of the data from the B::OP objects
        - this means dealing with SV,AV,HV,CV,etc.
            - so needs ObjectSpace
        - also adding this data to the Allium::Operations

### Step 2.

- Allium::Optree
    - make sure we are dump/load-ing all the data we extracted from B
        - this will require dump/load-ing the ObjectSpace
            - and retaining connections between

### Step 3.

- A::OP::Assembler
    - needs to be able to load the ObjectSpace and the new captured B data

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->

- assemblers/disassemblers need to know about global phas
    - ${^GLOBAL_PHASE}

- write better README.md

- figure out the "Object Space"
    - this includes the package/symbol table
    - native types: Scalar, Array, Hash, etc.
    - pads, and other stuff
    - also needs tooling:
        - loader/dumper for JSON
        - assembler/disassembler for B/Perl

## Operations

- handle the bitflags more elegantly
    - currently we force them into a very verbose HASH
        - this is not sustainable (especially for private flags)
    - would be better to store the bits
        - and replicate the flags
    - perhaps the B::Op_private bitdef can be made into an object
        - and them we can write one to describe the public flags

## Runtime

- spend some time reading up on Truffle
    - https://www.graalvm.org/latest/graalvm-as-a-platform/language-implementation-framework/


<!----------------------------------------------------------------------------->
## Misc.
<!----------------------------------------------------------------------------->

Useful Unicode
```
╭╮
╰╯
┌─┬─┐
├─┼─┤
└─┴─┘
┈ ┊

┄ ┆

╌ ╎
```


Interesting diagram
```
      ╭─────────────────────────────╮
      │                  ╭───╮      │
      │  ╭───╮           │╭─╮│      │
      │  ↑   │           │↑ ││      │
void (*signal(int, void (*fp)(int)))(int);
 ↑    ↑      │      ↑    ↑  ││      │
 │    ╰──────╯      │    ╰──╯│      │
 │                  ╰────────╯      │
 ╰──────────────────────────────────╯
```
(https://tex.stackexchange.com/questions/284791/connecting-vertical-box-drawing-characters)
