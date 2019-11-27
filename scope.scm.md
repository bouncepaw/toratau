# Scope

This file has things related to scope along with built-in functions.

```scheme
;; Hash table
(import (srfi 69))
```

## Built-in macros

Defined using mixture of Qaraidel, Toratau and Chicken Scheme :)

%[define metadefine {
#### %1

    [%1 %2]

%3

```scheme
(define (t-%1 %2) %4)
```
}]

### Macro-defining macros

%[metadefine define {macro-name definition}
{
Define a new macro called *macro-name* in current scope with such *definition*. User can redefine existing macros using this macro. Arguments can be accessed using `%1`..`%N` where N is number of arguments. `%#` means number of passed arguments. `%*` means all arguments joined with spaces. `%@` means all arguments wrapped in `{}` and then joined with spaces.

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

%[metadefine rename {old-macro-name new-macro-name}
{
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

%[metadefine defn macro-name
{
Return definition of a macro with such *macro-name*.

    [define welcome {Hello, %1!}]
    [defn welcome] → Hello, %1!
} {

    (hash-table-ref definitions macro-name)
}]

### Conditional and meta macros

%[metadefine ifeq {str1 str2 thenc . elsec}
{
If *str1* equals *str2*, then return *then*, else return *else*. If *else* is not passed, then it is assumed that it is empty string.

    [ifeq 1 1 true] → true
    [ifeq 1 2 true] → EMPTY STRING
    [ifeq 1 2 true false] → false
} {

    (if (equal? str1 str2)
        thenc
        (if (null? elsec) "" (car elsec)))
}]

%[metadefine ifdef {macro-name thenc . elsec}
{
If macro called *macro-name* is defined, then return *then*, else return *else*. If *else* is not passed, then it is assumed that it is empty string.

    [define foo bar]
    [ifdef foo defined undefined] → defined
    [ifdef quux defined undefined] → undefined
} {

    (if (hash-table-exists? scope macro-name)
        then
        (if (null? elsec) "" (car elsec)))
}]

%[metadefine shift {arg1 . args}
{
Return all `argn`s joined with spaces.
} {

    (string-join args)
}]

%[metadefine apply {macro-name . args}
{
Call macro called *macro-name* with arguments that are in *args* separated by whitespace. Any number of *args* can be passed, they will be joined by whitespace together first.

    [define multi-hi {Hi, %1, %2 and %3}]
    [apply multi-hi {George John} Ivan] → Hi, George, John and Ivan
} {

    (exec (string-join args))
}]

%[metadefine dotimes {n expr . joiner}
{
Evaluate expression *expr* *n* times. Results of evaluation are then joined together with *joiner*, this value is then returned. If *joiner* is not passed, it is assumed as empty string.

    [dotimes 3 hi] → hihihi
    [dotimes 3 hi { }] → hi hi hi
} {
    (string-join
      (map exec (make-list n expr))
      (if (null? joiner) "" (car joiner)))
}]

### String manipulating macros

%[metadefine cat {. args}
{
Return all `args` joined together with an empty string.

    [cat Hello World] → HelloWorld
} {

    (string-join args "")
}]

%[metadefine lines {. args}
{
Return all `arg`s joined together with a newline.

    [lines Hello World] → Hello
World
} {

    (string-join args "\n")
}]

## Scope, etc

`scope` is hash-table where each key is a string that corresponds to a macro name and value is function that gets applied to arguments of the macro. Out of the box, only those above functions are in the scope. By defining and redefining macros, user can mutate scope.

```scheme
(define scope
  (alist->hash-table
    `(("define"  . ,t-define)
      ("rename"  . ,t-rename)
      ("defn"    . ,t-defn)
      ("ifeq"    . ,t-ifeq)
      ("ifdef"   . ,t-ifdef)
      ("apply"   . ,t-apply)
      ("dotimes" . ,t-dotimes)
      ("cat"     . ,t-cat)
      ("lines"   . ,t-lines))))
```

Each macro has a definition which is a string that user passed when defining their macro with `define` macro. Built-in functions have empty definition.

```scheme
(define definitions
  (alist->hash-table
    '(("define"  . "")
      ("rename"  . "")
      ("defn"    . "")
      ("ifeq"    . "")
      ("ifdef"   . "")
      ("apply"   . "")
      ("dotimes" . "")
      ("cat"     . "")
      ("lines"   . ""))))
```


