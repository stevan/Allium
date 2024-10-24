<!----------------------------------------------------------------------------->
# TODO
<!----------------------------------------------------------------------------->

- write README.md

- figure out the symbol tables
    - A::MOP will crawl the Perl
    - but it has to be represented in Allium too
    - keep it simple, B::MOP is good enough

- Value and Container types
    - B::MOP::Opcode::Value
    - B::MOP::Opcode::Container




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
