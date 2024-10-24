<!----------------------------------------------------------------------------->
# Allium Instruction Set
<!----------------------------------------------------------------------------->

## Opcode Categories

- Core
    - these opcodes implement the core language features
- IO
    - these provide access the filesystem, network, etc.
- OS
    - this provides information from the OS (users, groups, etc.)
- Processes
    - these provide ways to manage processes


- Prohibited
    - these are things that we are not going to allow
- Deprecated
    - these are things that we are not going to support


```json
{
    // human information
    "category"  : "Core",
    "name"      : "warn",
    "desc"      : "warns something",

    // the Operation type(s) this opcode can be
    "operation" : [ "LISTOP" ],

    // TODO: improve on this ...
    "signature" : [
        {
            "type"     : "LIST",
            "optional" : 0,
        }
    ],

    // TODO - this is flakey and weird and needs work
    "flags" : {
        "always_produces_integer" : 1,
        "always_produces_scalar"  : 1,
        "needs_stack_mark"        : 1,
        "needs_target_scalar"     : 1,
    },

    // TODO - extract this from B::Op_Private
    "private" : {
        "foo" : 1,
    },
}
```
