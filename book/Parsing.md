# Parsing

Parsing is process of turning tokens into executable structure.

## Public API

`exec` parses and *also* evaluates a `str`ing in place and returns the result. It is parsed as if it was on start of file (as normal text by default).

```scheme
(define (exec str)
  (-> str
      string->list
      text->tokens
      parse-ast
      eval))
```

`parse-ast` transforms passed `expr` (either list or string) into executable expression. A string is left as is, but a list gets all its elements parsed by `parse-ast` first; then, list's head is turned into lambda that, when called, does what corresponding macro has to do, accepting the rest of list's elements as arguments.

```scheme
(define (parse-ast expr)
  (cond
    ((string? expr) expr)
    ((null? expr) expr)
    (else
      (let ((parsed-expr (map parse-ast expr)))
        (cons (list-head (car parsed-expr))
              (cdr parsed-expr))))))
```

Consider we have macros `upcase` and `downcase` in our scope (more about that in [Scope.md](Scope.md)). `parse-ast` gets this expression:

    ("upcase" "word")

First, it parses all elements:

    parse-ast "upcase" = "upcase"
    parse-ast "word"   = "word"

Second, it turns the head of the list to lambda:

    ((lambda args ...) "word")

Finally, the result is returned. If any of the elements was a list, it would be `parse-ast`ed anyway.

## Internals

`list-head` is a helper function for `parse-ast`. It turns `macro-name` to a lambda that corresponds to the actual macro and returns it. If `macro-name` is not in scope, program fails.

```scheme
(define ((list-head macro-name) . args)
  (apply (hash-table-ref scope macro-name) args))
```

`definition->lambda` is used for macro `define` for the argument `definition`. It turns the `definition` to a lambda that gets assigned to a macro later.

```scheme
(define ((definition->lambda definition) . args)
  ;; This is alist which defines what patterns should be replaced.
  ;; %* is all args joined together
  ;; %@ is all args joined together but quoted beforehand
  ;; %# is number of args
  (define special-alist
    `(("%\\*" . ,(string-join args))
      ("%@"   . ,(string-join
                   (map (lambda (arg) (string-join (list "{" arg "}")))
                        args)))
      ("%#"   . ,(number->string (length args)))))
  ;; This is alist which defines patterns for arguments to be replaced.
  (define args-alist
    (map (lambda (id)
           (cons (string-join (list "%" (number->string (+ 1 id))))
                 (list-ref args id)))
         (iota (length args))))
  (-> definition
      (string-substitute* (append special-alist args-alist))
      string->list
      text->tokens
      parse-ast
      eval))
```

