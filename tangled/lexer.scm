(import matchable
        (srfi 1))
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



(define (lex-whitespace chars)
  (let next-char ((len 1) (rest (cdr chars)))
    (cond ((char-whitespace? (car rest)) (next-char (+ 1 len) (cdr rest))) (else (values len rest "")))))


(define (lex-raw-string chars)
  (let next-char ((len 1) (rest (cdr chars)))
    (cond ((char-whitespace? (car rest)) (values len (cdr rest) (list->string (take chars len)))) ((equal? (car rest)  #\] ) (values len rest (list->string (take chars len)))) (else (next-char (+ 1 len) (cdr rest))))))


(define (lex-single-string chars)
  (let next-char ((len 1) (rest (cdr chars)))
    (cond ((equal? (car rest)  #\' ) (values len (cdr rest) (list->string (take chars (+ 1 len))))) ((and (equal? (car rest) #\\)
           (equal? (cadr rest) #\'))
      (next-char (+ 2 len) (cddr rest))) (else (next-char (+ 1 len) (cdr rest))))))


(define (lex-curly-string chars)
  (let next-char ((len 1) (rest (cdr chars)))
    (cond ((equal? (car rest)  #\\ ) (if (or (equal? (cadr rest) #\{)
               (equal? (cadr rest) #\}))
           (next-char (+ 2 len) (cddr rest))
           (next-char (+ 1 len) (cdr rest)))) ((equal? (car rest)  #\{ ) (let-values (((new-len new-rest _str) (lex-curly-string rest)))
         (next-char (+ len new-len) new-rest))) ((equal? (car rest)  #\} ) (values len (cdr rest) (list->string (drop (take chars len) 1)))) (else (next-char (+ 1 len) (cdr rest))))))


(define (lex-double-string chars)
  (let next-char ((len 1) (rest (cdr chars)))
    (cond ((equal? (car rest)  #\" ) (values len (cdr rest) (list->string (take chars (+ 1 len))))) ((and (equal? (car rest) #\\)
          (equal? (cadr rest) #\"))
      (next-char (+ 2 len) (cddr rest))) (else (next-char (+ 1 len) (cdr rest))))))

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
