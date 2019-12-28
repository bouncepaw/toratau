# Implementantion

This is the entry point for Toratau.

## Dependencies

All of the dependencies are either with Chicken Scheme distribution or are easily downloadable (`sudo chicken-install eggname`). Compiler will complain if you don't have any of the dependencies.

```scheme
;; If you are reading this code not in Markdown file, you are probably
;; reading its tangled form. Check out the literate form too.
(import (srfi 1) ; Advanced list utilities
        (srfi 13) ; String
        (srfi 69) ; Hash tables
        (chicken io)
        (chicken process) ; Piping, used in pipe-to-shell
        matchable ; Pattern matching
        regex
        (clojurian syntax))
```

## Including

I decided to come on with Toratau's own including instead of Scheme's `include`.

    %[include Lexing.md]
    %[include Parsing.md]
    %[include Scope.md]
    %[include Prelude.md]
    %[include Utils.md]

Read the source chapters:

- [Lexing.md](Lexing.md). Breaking source code down to tokens.
- [Parsing.md](Parsing.md). Turning the tokens to executable Lisp code and executing it.
- [Scope.md](Scope.md). Storing runtime macros.
- [Prelude.md](Prelude.md). Built-in macros.
- [Utils.md](Utils.md). Helpful utilities.


## Algorithm

Toratau gets input text from `stdin`, not from a file. The output is printed to `stdout`, not to a file. First, we break down source text to tokens, then we parse it and execute. The result is a string that we print.

```scheme
(-> (read-string)
    string->list
    text->tokens
    parse-ast
    eval
    display)
(newline)
```

