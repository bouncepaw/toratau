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
          (loop objects (cdr rest) (cons (car rest) acc)))
        )))

  (define (lex-expr chars)
    (let loop ((objects '()) (rest (cdr chars)))
      (cond
        ((null? rest) 1)
        ((equal? (car rest) #\])
         (values 0 ; not really used, so it'll be 0
                 (cdr rest)
                 (reverse objects) 
                 ))
        (else
          (let-values (((_chars-taken new-rest object)
                        ((match (car rest)
                         (#\[ lex-expr)
                         (#\{ lex-curly-string)
                         (#\' lex-single-string)
                         ; (#\" lex-double-string)
                         ((? char-whitespace? _) lex-whitespace)
                         (_ lex-raw-string)) rest)))
            (loop (if (and (equal? "" object) (char-whitespace? (car rest)))
                      ; ignore empty strings produced by whitespace
                      objects
                      (cons object objects))
                  new-rest)
          )))))

  (define (lex-whitespace chars)
    (let loop ((len 1) (rest chars))
      (if (char-whitespace? (car rest))
        (loop (+ 1 len) (cdr rest))
        (values len rest ""))))

  (define (lex-raw-string chars)
    (let loop ((len 1) (rest (cdr chars)))
      (cond
        ((char-whitespace? (car rest))
         (values len (cdr rest) (list->string (take chars len))))
        ((equal? (car rest) #\])
         (values len rest (list->string (take chars len))))
        (else
          (loop (+ 1 len) (cdr rest))))))

  (define (lex-single-string chars)
    (let loop ((len 1) (rest (cdr chars)))
      (case (car rest)
        ((#\') ; end
         (values (+ 1 len)
                 (cdr rest)
                 (list->string (drop (take chars len) 1))))
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
