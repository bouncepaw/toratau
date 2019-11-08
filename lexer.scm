(module toratau.lexer
  *
  (import scheme
          (chicken base)
          (srfi 1)
          (srfi 13)
          matchable)

  (define (<text-block> lines)
    ; where lines is Listof Cons<LineNo, String>
    (define from-line (caar lines))
    (define to-line (car (last lines)))
    (define content (string-join (map cdr lines) "\n" 'infix))
    (lambda (method)
      (case method
        ((range) (cons from-line to-line))
        ((content) content))))

;   (define (text->tokens chars)
;     ())

  (define (lex-expr chars)
    (let loop ((objects '()) (rest (cdr chars)))
      (if (equal? #\] (car rest))
        (values 0 ; not really used, so it'll be 0
                (reverse objects) 
                (cdr chars))
        (let-values (((_chars-taken new-rest object)
                      ((match (car rest)
                         (#\[ lex-expr)
                         (#\{ lex-curly-string)
                         (#\' lex-single-string)
                         ; (#\" lex-double-string)
                         ((? char-whitespace?) lex-whitespace)
                         (_ lex-raw-string)) chars)))
          (loop (cons object objects) new-rest)))))

  (define (lex-whitespace chars)
    (let loop ((len 1) (rest chars))
      (if (char-whitespace? (car rest))
        (loop (+ 1 len) (cdr rest))
        (values len (cdr rest) (list->string (take chars len))))))

  (define (lex-raw-string chars)
    (let loop ((len 1) (rest (cdr chars)))
      (cond
        ((char-whitespace? (car rest))
         (values len (cdr rest) (list->string (take chars len))))
        (else
          (loop (+ 1 len) (cdr rest))))))

  (define (lex-single-string chars)
    (let loop ((len 1) (rest (cdr chars)))
      (case (car rest)
        ((#\') ; end
         (values (+ 1 len)
                 (cdr rest)
                 (list->string (take chars (+ 1 len)))))
        ((#\\)
         (if (equal? #\' (cadr rest))
           (loop (+ 2 len) (cddr rest))
           (loop (+ 1 len) (cdr rest))))
        (else
          (loop (+ 1 len) (cdr rest))))))

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

  )
