# Lexing
<!-- %[define notora {}] %[notora { -->
Lexing is process of turning source text to list of structured tokens. Toratau syntax allows these kinds of tokens:

- Normal text. This is everything that is not part of a root expression.
- Expression. List of other expression or strings in which first element names a macro and the rest are its arguments.
  - Root expression `%[]`. It is placed inside normal text and strings that support nesting expresions.
  - Normal expresions `[]`. The are nested inside root expresions or other normal expresions.
- Strings. Sequences of characters. Root expresions inside have to be executed explicitly.
  - Raw strings `word`. They are not wrapped in anything and correspond to themselves (raw string `word` is a string of four characters `w` `o` `r` `d`). Raw strings can't contain whitespace and characters `{`, `}`, `[`, `]`, `'`, `"`.
  - Single strings `'two words'`. They are wrapped in single quotes and correspond to their contents wrapped in single quotes (single string `'a'` is a string of three characters `'` `a` `'`). Single quotes can be escaped with backtick (`\'`), but it evaluates to 2 characters (`\`, `'`).
  - Double strings `"two words"`. Everything about single strings is same about double strings except that the quotes are different.
  - Curly strings `{two words}`. Main type of strings wrapped in curly braces. Because it uses different characters for quotes, such strings can be nested easily. Closing brace can be escaped with backtick (`\}`) but that evaluates to two characters (`\` `}`). Wrapping curly braces are not part of the resulting string.

During the lexing all token types get reduced to just two:

- Expression. List of either expresions of strings in which its head is macro name and its tail is arguments to that macro. Expressed as Lisp's list.
- String. Sequence of characters. Expressed as Lisp's string.
<!-- }] end notora -->

```scheme
(import matchable
        (srfi 1)
        (srfi 13))
```

## Public API

Only one function from this file is meant to be used outside of it. Maybe someday I'll encapsulate the rest. For now there's no need for it.

`text->tokens` accepts `chars` which is a list of characters of source text. It is considered that the text is on root level. Return expression with head that is string `cat` and tail that is all the tokens in the source text.

```scheme
(define (text->tokens chars)
  (let loop ((tokens '()) (rest chars) (acc '()))
    (cond
      ((null? rest)
       (cons "cat" (reverse (cons (list->string (reverse acc)) tokens))))
      ((and (equal? (car rest) #\%)
            (equal? (cadr rest) #\[))
       (let-values (((last-text) (list->string (reverse acc)))
                    ((_chars-taken new-rest last-expr) (lex-expr (cdr rest))))
         (loop (cons last-expr (cons last-text tokens))
               new-rest
               '())))
      (else
        (loop tokens (cdr rest) (cons (car rest) acc))))))
```

## Internals

### Helper macros

The lexer functions below all follow the same template. Thus I will create a helper macro to unify them. A lexer function has a name starting with `lex-` and accepts one argument `chars`. It loops through all the characters while counting characters and saving the rest of characters.

```scheme
%[define lex {
(define (lex-%1 chars)
  (let next-char ((len 1) (rest (cdr chars)))
    %2))
}]
```

And here is some syntax sugar.

```scheme
%[cat
  [define next-char-n  {(next-char (+ %1 len) (%2 rest))}]
  [define next-char    [next-char-n 1 cdr]]
  [define next-2-chars [next-char-n 2 cddr]]
  [define cond         {(cond %*)}]
  [define whitespace?  {((char-whitespace? (car rest)) %2)}]
  [define default      {(else %2)}]
  [define is           {((equal? (car rest) %1) %3)}]
  [define return       {(values len (%1) (%2))}]]
```

### Lexers

Whitespace lexer always returns empty string, because its return value is insignificant.

```scheme
%[lex whitespace
  [cond
    [whitespace? => [next-char]]
    [default     => {(values len rest "")}]]]
```

```scheme
%[lex raw-string
  [cond
    [whitespace? => {(values len (cdr rest) (list->string (take chars len)))}]
    [is { #\] }  => {(values len rest (list->string (take chars len)))}]
    [default     => [next-char]]]]
```

```scheme
%[lex single-string
  [cond
    [is { #\' } => [return {cdr rest} {list->string (take chars (+ 1 len))}]]
    {((and (equal? (car rest) #\\)
           (equal? (cadr rest) #\'))
      (next-char (+ 2 len) (cddr rest)))}
    [default    => [next-char]]]]
```

```scheme
%[lex curly-string
  [cond
    [is { #\\ } =>
      {(if (or (equal? (cadr rest) #\{)
               (equal? (cadr rest) #\}))
           (next-char (+ 2 len) (cddr rest))
           (next-char (+ 1 len) (cdr rest)))}]
    [is { #\{ } =>
      {(let-values (((new-len new-rest _str) (lex-curly-string rest)))
         (next-char (+ len new-len) new-rest))}]
    [is { #\} } => [return {cdr rest}
                           {list->string (drop (take chars len) 1)}]]
    [default    => [next-char]]]]
```

```scheme
%[lex double-string
  [cond
    [is { #\" } => [return {cdr rest} {list->string (take chars (+ 1 len))}]]
    {((and (equal? (car rest) #\\)
          (equal? (cadr rest) #\"))
      (next-char (+ 2 len) (cddr rest)))}
    [default    => [next-char]]]]
```

`lex-expr` brings them all together:

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
          (loop (if (char-whitespace? (car rest))
                    ; ignore empty strings produced by whitespace
                    objects
                    (cons object objects))
                new-rest))))))
```
  
