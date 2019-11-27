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

    [%1 %[ifeq %# 5 %5 %2]]

%3

```scheme
(define (t-%1 %2)
  %4)
```
}]

### Macro-defining macros

%[metadefine define {macro-name definition}
{
Define a new macro called *macro-name* in current scope with such *definition*. User can redefine existing macros using this macro. Arguments can be accessed using `%1`..`%N` where N is number of arguments. `%#` means number of passed arguments. `%*` means all arguments joined with spaces. `%@` means all arguments wrapped in `{}` and then joined with spaces.
} {
  (hash-table-set! definitions macro-name definition)
  (hash-table-set! scope macro-name (definition->lambda definition))
  ""
}]

```scheme
(define (t-rename old-macro-name new-macro-name)
  (hash-table-set! scope
                   new-macro-name
                   (hash-table-ref scope old-macro-name))
  (hash-table-set! definitions
                   new-macro-name
                   (hash-table-ref definitions old-macro-name))
  (hash-table-delete! scope old-macro-name)
  (hash-table-delete! definitions old-macro-name)
  "")
```

```scheme
(define (t-defn macro-name)
  (hash-table-ref definitions macro-name))
```

```scheme
(define (t-ifeq str1 str2 then . else*)
  (if (equal? str1 str2)
      then
      (if (null? else*) "" (car else*))))
```

(define (t-ifdef macro-name then . else*)
  (if (hash-table-exists? scope macro-name)
      then
      (if (null? else*) "" (car else*))))

(define (t-apply . args)
  (exec (string-join args)))

(define (t-dotimes n expr . joiner)
  (string-join
    (map exec
         (make-list n expr))
    (if (null? joiner) "" joiner)))

(define (t-cat . args)
  (string-join args ""))

(define (t-lines . args)
  (string-join args "\n"))

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


