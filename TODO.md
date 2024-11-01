<!----------------------------------------------------------------------------->
# TODO
<!----------------------------------------------------------------------------->

- Create an `Allium::CompilerUnit` which should ...
    - be specific to a given package/namespace
    - it should contain ...
        - information about when it was compiled
            - what `Allium::InstructionSet` was used
            - `perl` version was used
            - date/time stamp
            - etc.
        - a serialized `Allium::Environment`
            - meaning, ...
                - compile time scalar/array/hash data
                - serialized `Allium::Optree` objects

- Rethink the `A` stuff, it is gross to use

- Create a `O.pm` like harness to run `A` stuff

<!----------------------------------------------------------------------------->

- Handle the special numeric strings for Perl
    - +inf, -inf, nan
    - and their numerical equivalents
        - perl -E 'say 1e9999'         # Int
        - perl -E 'say -1e9999'        # -Inf
        - perl -E 'say 1e9999/-1e9999' # NaN
    - and how does B see them??


- Type Inference explained
    - https://bernsteinbear.com/blog/type-inference/

- Do assemblers/disassemblers need to know about global phase?
    - ${^GLOBAL_PHASE}

- write better README.md

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




```
FUNC: *Foo::foo
8  <1> leavesub[1 ref] K/REFC,1 ->(end)
-     <@> lineseq KP ->8
1        <;> nextstate(Foo 9 Foo.pm:8) v:us,*,&,$,fea=8 ->2
7        <@> say sK ->8
2           <0> pushmark s ->3
3           <$> const(IV 10) s ->4
4           <$> const(IV 20) s ->5
5           <$> const(IV 30) s ->6
6           <$> const(IV 40) s ->7
```

```

    ⑧     <1> leavesub[1 ref] K/REFC,1 ->(end)
             <@> lineseq KP ->8
  ▶ ①          <;> nextstate(Foo 9 Foo.pm:8) v:us,*,&,$,fea=8 ->2
    ⑦           <@> say sK ->8
    ②           <0> pushmark s ->3
    ③           <$> const(IV 10) s ->4
    ④           <$> const(IV 20) s ->5
    ⑤           <$> const(IV 30) s ->6
    ⑥           <$> const(IV 40) s ->7

```


```
      │
 [8]◀─┼───────╮         <1> leavesub[1 ref] K/REFC,1 ->(end)
     [1]      │       <;> nextstate(Foo 9 Foo.pm:8) v:us,*,&,$,fea=8 ->2
   ╭──┼─▶[7]──╯          <@> say sK ->8
   │  ╰─────▶[2]──╮        pushmark s
   │      ╭──[3]◀─╯        const(IV 10) s
   │      ╰─▶[4]──╮        const(IV 20) s
   │      ╭──[5]◀─╯        const(IV 30) s
   │      ╰─▶[6]──╮        const(IV 40) s
   ╰──────────────╯
```

```
◯
│  ╭────[0]◀─────╮
│  │ ╭──[1]◀───╮ │
│  ╰─┼─▶[2]──╮ │ │
╰────┼──[3]◀─╯ │ │
     ╰─▶[4]────┼─┼─╮
   ╭─┬──[5]◀─╮ │ │ │
   │ ╰─▶[6]──┼─╯ │ │
   │ ╭─▶[7]──┼───╯ │
   │ ╰───────┼─────╯
   ╰─────────╯
```



```
╭─────────────┬────────────────────────┬──────────────╮
│ opcode      │                        │  next-opcode │
├─────────────┼────────────────────────┼──────────────┤
│  5528496208 │(leavesub)              │     (end)    │
│  5364545896 │  (lineseq)             │  5528496208  │
│  5364545960 │    (nextstate)         │  5364546120  │
│  5364546056 │    (padsv_store)       │  5528430544  │
│  5364546120 │      (const)           │  5364546056  │
│  5364546176 │      (padsv)*          │  5364546056  │
│  5528430544 │    (nextstate)         │  5528430760  │
│  5528431088 │    (aassign)           │  5528496272  │
│  5528430696 │      (list)*           │  5528430872  │
│  5528430760 │        (pushmark)      │  5528430640  │
│  5528430920 │        (rv2av)         │  5528430872  │
│  5528430640 │          (const)       │  5528430920  │
│  5528430808 │      (list)*           │  5528431088  │
│  5528430872 │        (pushmark)      │  5364545848  │
│  5364545848 │        (padav)         │  5528431088  │
│  5528496272 │    (nextstate)         │  5528430976  │
│  5528496368 │    (leaveloop)         │  5528496208  │
│  5528496600 │      (enteriter)       │  5528430144  │
│  5528430208 │        (pushmark)*     │  5528430976  │
│  5528430256 │        (list)*         │  5528496600  │
│  5528430976 │          (pushmark)    │  5528431032  │
│  5528431032 │          (padav)       │  5528496600  │
│  5528496432 │      (null)*           │  5528496368  │
│  5528496488 │        (and)           │  5528496368  │
│  5528430144 │          (iter)        │  5528496488  │
│  5528430320 │          (lineseq)     │  5528496432  │
│  5528430384 │            (nextstate) │  5364545736  │
│  5528430480 │            (add)       │  5528496552  │
│  5364545736 │              (padsv)   │  5364545792  │
│  5364545792 │              (padsv)   │  5528430480  │
│  5528496552 │            (unstack)   │  5528430144  │
╰─────────────┴────────────────────────┴──────────────╯
```


























