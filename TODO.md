<!----------------------------------------------------------------------------->
# TODO
<!----------------------------------------------------------------------------->

- write README.md

- figure out the symbol tables
    - A::MOP will crawl the Perl
    - but it has to be represented in Allium too
    - keep it simple, B::MOP is good enough

- handle the bitflags more elegantly
    - currently we force them into a very verbose HASH
        - this is not sustainable (especially for private flags)
    - would be better to store the bits
        - and replicate the flags
    - perhaps the B::Op_private bitdef can be made into an object
        - and them we can write one to describe the public flags

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
