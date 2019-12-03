# Implementantion

This is main entry point for Toratau source code.

## Dependencies

All of the dependencies are either built in Chicken Scheme distribution or are easily downloadable (`sudo chicken-install eggname`). Compiler will complain if you don't have any of the dependencies.

```scheme
(import (srfi 1) ; Advanced list utilities
        (srfi 69) ; Hash tables
        (chicken io)
        (chicken process) ; Piping, used in pipe-to-shell
        matchable ; Pattern matching
        regex
        (clojurian syntax))
```

## Including

I decided to come on with Toratau's own including instead of Scheme's `include`.

    %[qarainclude Lexing.md]
    %[qarainclude Parsing.md]
    %[qarainclude Scope.md]
    %[qarainclude Prelude.md]

Read the files:

- [Lexing.md](Lexing.md). Breaking source code down to tokens.
- [Parsing.md](Parsing.md). Turning the tokens to executable Lisp code and executing it.
    Test
- [Scope.md](Scope.md). Storing runtime macros.
- [Prelude.md](Prelude.md). Builtin macros.


## Algorithm

Toratau gets input text from stdin, not from a file. Thus, we need to read whole stdin first to `input-chars` which is a list of characters.

```scheme
(define input-chars
  (let loop ((chars '()'))
    (if (eof-object? char)
        (reverse chars)
        (loop (cons char chars)))))
```

The output is printed to stdout, not to a file. First, we break down source text to tokens, then we parse it and execute. The result is a string that we print.

```scheme
(display (eval (parse-ast (text->tokens input-chars))))
(newline)
```

