# Toratau lexer

Lexer is a thing that gets input text in a programming language and returns structured tokens.

```scheme
(import (srfi 1)
        matchable)
```

## Text to token conversion, public API

This is the only function in this file that is meant to be used outside. `chars` is list of characters of input text. Return such list: `("cat" . objects)` (an object is either a string or a list). Lisp string is same as Toratau string, Lisp list is same as Toratau expression.

```scheme
(define (text->tokens chars)
  (let loop ((objects '()) (rest chars) (acc '()))
    (cond
      ((null? rest)
       (cons "cat" (reverse (cons (list->string (reverse acc)) objects))))
      ((and (equal? (car rest) #\%)
            (equal? (cadr rest) #\[))
       (let-values (((last-text) (list->string (reverse acc)))
                    ((_chars-taken new-rest last-expr) (lex-expr (cdr rest))))
         (loop (cons last-expr (cons last-text objects))
               new-rest
               '())))
      (else
        (loop objects (cdr rest) (cons (car rest) acc))))))
```

## Internals

### Expression lexer

This is somewhat main lexer. It calls other lexers for different objects in it. Returns three values:

- a numeric value you shouldn't care about. TODO: remove.
- rest of characters (those that are after the expression)
- list of objects in this expression

```scheme
(define (lex-expr chars)
  (let loop ((objects '()) (rest (cdr chars)))
    (cond
      ((null? rest) 1)
      ((equal? (car rest) #\])
       (values 0 ; not really used, so it'll be 0
               (cdr rest)
               (reverse objects)))
      (else
        (let-values (((_chars-taken new-rest object)
                      ((match (car rest)
                              (#\[ lex-expr)
                              (#\{ lex-curly-string)
                              (#\' lex-single-string)
                              (#\" lex-double-string)
                              ((? char-whitespace? _) lex-whitespace)
                              (_ lex-raw-string)) rest)))
          (loop (if (and (equal? "" object) (char-whitespace? (car rest)))
                    ; ignore empty strings produced by whitespace
                    objects
                    (cons object objects))
                new-rest))))))
```

### Other lexers

Whitespace lexer reads until end of whitespace. It doesn't return that whitespace, it returns empty string that will be ignored in `lex-expr`.

```scheme
(define (lex-whitespace chars)
  (let loop ((len 1) (rest chars))
    (if (char-whitespace? (car rest))
        (loop (+ 1 len) (cdr rest))
        (values len rest ""))))
```

Raw string lexer happily reads the next raw string.

```scheme
(define (lex-raw-string chars)
  (let loop ((len 1) (rest (cdr chars)))
    (cond
      ((char-whitespace? (car rest))
       (values len (cdr rest) (list->string (take chars len))))
      ((equal? (car rest) #\])
       (values len rest (list->string (take chars len))))
      (else
        (loop (+ 1 len) (cdr rest))))))
```

Single string lexing is good.

```scheme
(define (lex-single-string chars)
  (let loop ((len 1) (rest (cdr chars)))
    (case (car rest)
      ((#\')
       (values (+ 1 len)
               (cdr rest)
               (list->string (drop (take chars len) 1))))
      ((#\\)
       (if (equal? #\' (cadr rest))
           (loop (+ 2 len) (cddr rest))
           (loop (+ 1 len) (cdr rest))))
      (else
        (loop (+ 1 len) (cdr rest))))))
```

Curly string lexing is cool. Nesting is supported! TODO: support nesting expressions as well.

```scheme
(define (lex-curly-string chars)
  (let loop ((len 1) (rest (cdr chars)))
    (case (car rest)
      ((#\\)
       (if (or (equal? (cadr rest) #\{)
               (equal? (cadr rest) #\}))
           (loop (+ 2 len) (cddr rest))
           (loop (+ 1 len) (cdr rest))))
      ((#\{)
       (let-values (((new-len new-rest _str) (lex-curly-string rest)))
         (loop (+ len new-len) new-rest)))
      ((#\})
       (values (+ 1 len)
               (cdr rest)
               (list->string (drop (take chars len) 1))))
      (else
        (loop (+ 1 len) (cdr rest))))))
```

Double string lexing is good. TODO: drop support nesting expressions.

```scheme
(define (lex-double-string chars)
  (let loop ((len 0) (rest (cdr chars)))
    (cond
      ((and (equal? (car rest) #\\)
            (equal? (cadr rest) #\"))
       (loop (+ 1 len) (cddr rest)))
      ((equal? (car rest) #\")
       (values len
               (cdr rest)
               (text->tokens (drop (take chars (+ 1 len)) 1))))
      (else
        (loop (+ 1 len) (cdr rest))))))
```
