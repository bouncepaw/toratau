# Prelude

These are built-in macros. Using them, it is trivial to implement any macro you need. If there's a macro missing without which it is non-trivial to implement any macro, it should be added.

These built-ins are written in Scheme, unlike macros defined by a user.

```scheme
(import (chicken io)
        (srfi 13)
        (srfi 69))
```

To ease creation of macros, there's that macro:

%[define macro {%1

    [%1 %2]

%3

```scheme
(define (t-%1 %2) %4)
(hash-table-set! scope "%1" t-%1)
(hash-table-set! definitions "%1" "")
```
}]

## The macros

### Metamacros

#### %[macro define {macro-name definition} {

Define a new macro called *macro-name* in current scope with such *definition*. User can redefine existing macros using this macro. Arguments can be accessed using `%1`..`%N` where N is number of passed arguments. `%#` means number of passed arguments. `%*` means all passed arguments joined with spaces. `%@` means all arguments wrapped in `{}` and then joined with spaces.

Return empty string.

    [define foo bar]
    [foo] → bar

    [define welcome {Hello, %1!}]
    [welcome world] → Hello, world!

    [define analyze-args {
    Number: %#
    Unwrapped: %*
    Wrapped: %@}]

    [analyze-args] →
    Number: 0
    Unwrapped: 
    Wrapped: 

    [analyze-args one two {three four} [foo]] →
    Number: 4
    Unwrapped: one two three four bar
    Wrapped: {one} {two} {three four} {bar}
} {

    (hash-table-set! definitions macro-name definition)
    (hash-table-set! scope macro-name (definition->lambda definition))
    ""
}]

#### %[macro rename {old-macro-name new-macro-name} {

Rename a macro called *old-macro-name* to *new-macro-name*. Is is no longer available as *old-macro-name*. Return empty string.

    [define foo bar]
    [foo] → bar
    [rename foo baz]
    [foo] → ERROR
    [baz] → bar
} {

    (hash-table-set! scope
                     new-macro-name
                     (hash-table-ref scope old-macro-name))
    (hash-table-set! definitions
                     new-macro-name
                     (hash-table-ref definitions old-macro-name))
    (hash-table-delete! scope old-macro-name)
    (hash-table-delete! definitions old-macro-name)
    ""
}]

#### %[macro defn macro-name {

Return definition of a macro with such *macro-name*.

    [define welcome {Hello, %1!}]
    [defn welcome] → Hello, %1!
} {

    (hash-table-ref definitions macro-name)
}]

### Conditional

#### %[macro ifeq {str1 str2 thenc . elsec} {

If *str1* equals *str2*, then return *thenc*, else return *elsec*. If *elsec* is not passed, then it is assumed that it is empty string.

    [ifeq 1 1 true] → true
    [ifeq 1 2 true] → 
    [ifeq 1 2 true false] → false
} {

    (if (equal? str1 str2)
        thenc
        (if (null? elsec) "" (car elsec)))
}]

#### %[macro ifdef {macro-name thenc . elsec} {

If macro called *macro-name* is defined, then return *thenc*, else return *elsec*. If *elsec* is not passed, then it is assumed that it is empty string.

    [define foo bar]
    [ifdef foo defined undefined] → defined
    [ifdef quux defined undefined] → undefined
} {

    (if (hash-table-exists? scope macro-name)
        then
        (if (null? elsec) "" (car elsec)))
}]

### String manipulating macros

#### %[macro cat {. args} {

Return all `args` joined together with an empty string.

    [cat Hello World] → HelloWorld
} {

    (string-join args "")
}]

#### %[macro lines {. args} {

Return all `args` joined together with a newline.

    [lines Hello World] → Hello
    World
} {

    (string-join args "\n")
}]

### Miscellaneous macros

#### %[macro shift {. arg} {

Wrap every `arg` in `{}`, return all but the first one joined into one string.

    [shift] → 
    [shift a] → 
    [shift a b] → b
    [shift {a b} c d {e f g}] → {c} {d} {e f g}
} {

    (cond
      ((null? arg) "")
      ((eq? 1 (length arg)) "")
      (else
        (string-join (map (lambda (a) (string-join (list "{" a "}")))
                          (cdr arg)))))
}]

#### %[macro apply {macro-name . args} {

Call macro called *macro-name* with arguments that are in *args* separated by whitespace. Any number of *args* can be passed, they will be joined by whitespace together first.

    [define multi-hi {Hi, %1, %2 and %3}]
    [apply multi-hi {George John} Ivan] → Hi, George, John and Ivan
} {

    (exec (string-join args))
}]

#### %[macro dotimes {n expr . joiner} {

Evaluate expression *expr* *n* times. Results of evaluation are then joined together with *joiner*, this value is then returned. If *joiner* is not passed, it is assumed as empty string.

    [dotimes 3 hi] → hihihi
    [dotimes 3 hi { }] → hi hi hi
} {

    (string-join
      (map exec (make-list n expr))
      (if (null? joiner) "" (car joiner)))
}]

#### %[macro include filename {

Read *filename*, evaluate is as Toratau code in current scope, return the result.

    In file1:
    Contents.

    In file2:
    [include file1]

    Result of file2:
    Contents.
} {

    (define input (open-input-file filename))
    (define text (read-string #f input))
    (close-input-port input)
    (eval
      (parse-ast
        (text->tokens (string->list text))))
}]

