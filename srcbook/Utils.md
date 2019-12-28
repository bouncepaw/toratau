# Utils

This chapter provides helpful functions that cannot be divided into other sections.

## if-wrapped-in

If `str` both starts with `prefix` and ends with `suffix`, apply `str` to unary function `then-λ` and return the result, else return `str`.

```scheme
(define (if-wrapped-in str prefix suffix then-λ)
  (if (and (string-prefix? prefix str)
           (string-suffix? suffix str))
    (then-λ str)
    str))
```

## exec-if-expr

`exec` `str` if it is wrapped in `%[p][` and `]`.

```scheme
(define (exec-if-expr str)
  (if-wrapped-in str (string-join (list "%" "[") "") "]" exec))
```

