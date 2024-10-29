<!----------------------------------------------------------------------------->
# Related Art
<!----------------------------------------------------------------------------->

This document contains links to things I have found while researching which may
be usedful in the future stages of this langauge.

<!----------------------------------------------------------------------------->
## PyPy
<!----------------------------------------------------------------------------->

Python in Python ... it has a lot to learn from and this project is very
similiar to it.

- https://pypy.org/

<!----------------------------------------------------------------------------->
## GraalVM
<!----------------------------------------------------------------------------->

Truffle would be a good option for a new Runtime. It is adapted for dynamic
languages and once targeted you can use all the other tools that come along
with it and GraalVM to get a fast JIT-ed interpreter for very little work.

Also via the Truffle Interop, you can bridge between languages, and even have
access to the GPU.

NOTE: This is an Oracle project, so pretty official, and the GPU stuff is
by NVIDIA, so also pretty legit as well.

- Truffle Language Framework & GraalVM
    - https://www.graalvm.org/latest/graalvm-as-a-platform/
    - https://www.graalvm.org/latest/graalvm-as-a-platform/language-implementation-framework/

- Interesting Truffle based projects
    - Enso Data Language
        - this is similar to some things that were discussed for the end goal of Allium
        - https://ensoanalytics.com/ << very interesting idea
        - https://github.com/enso-org/enso
    - GPU access via Truffle Interop
        - https://github.com/NVIDIA/grcuda/
        - https://github.com/NVIDIA/grcuda/blob/master/docs/grcuda.md
        - https://developer.nvidia.com/blog/grcuda-a-polyglot-language-binding-for-cuda-in-graalvm/
    - Mate
        - https://github.com/charig/TruffleMATE?tab=readme-ov-file
        - https://lafhis.dc.uba.ar/sites/default/files/papers/TowardsFullyReflectiveEnvironments.pdf
        - https://www.youtube.com/watch?v=ULRs02IXLco&ab_channel=SPLASH15Conference
        - Researchers Involved
            - https://www.researchgate.net/profile/Stefan-Marr
            - https://www.researchgate.net/profile/Stephane-Ducasse << traits guy!


<!----------------------------------------------------------------------------->
## Perl Tooling
<!----------------------------------------------------------------------------->

Perl Tooling has always sucked, but the Language Server stuff has a lot of
possibilities, what could Allium bring to the table??

- Perl Language Servers
    - https://metacpan.org/pod/Perl::LanguageServer
    - https://metacpan.org/pod/PLS
    - https://github.com/bscan/PerlNavigator



<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->

