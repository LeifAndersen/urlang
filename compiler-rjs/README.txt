Racket to JavaScript Compiler
=============================

This collection contains a compiler that hopefully
will evolve into a compiler that can compile Racket
programs into JavaScript programs.

The real Racket runtime is *huge* so it is is doubtful,
that all corners of Racket will be covered. However
I hope to the compiler eventually will be able to
compile a large subset of all Racket programs.

The status so far:

    - no tco
    - no continuation marks
    - no exceptions

The runtime library is in "runtime.rkt".
See the complete list of support data structures
and implemented functions in the source.

/Jens Axel Søgaard


