(module toratau.lexer
  *
  (import scheme
          (chicken base)
          (srfi 1)
          (srfi 13))

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
    ())

  (define (lex-until-end-of-expr chars)
    (let* loop ((objects '())
                (rest (cdr chars))
                (state 'in-expr) ; or in-double, in-single, in-curly, in-raw
                (acc '()))
      (case state
        (('in-expr
          (case (car rest)
            ((#\[) ; nested expr
             (let-values (((new-rest new-obj) (lex-until-end-of-expr)))
               (loop (cons new-obj objects)
                     new-rest
                     'in-expr)))
            ((#\') ; single quoted
             (loop objects (cdr rest) 'in-single))
            ((#\") ; double quoted
             (loop objects (cdr rest) 'in-double))
            ((#\{) ; in curly
             (loop objects (cdr rest) 'in-curly))
            )))
        (('in-single)
         (case (car rest)
           ((#\') ; end
            (loop (cons (<single-string> acc) objects)
                  (cdr rest)
                  'in-expr
                  '()))
           ((#\\)
            (if (equal? #\' (cdr rest))
              (loop objects
                    (cddr rest)
                    'in-single
                    (cons #\' (cons #\\ acc)))))
           (else
             (loop objects
                   (cdr rest)
                   'in-single
                   (cons (car rest) acc)))))
        (('in-curly)
         (case (car rest)))
        (('in-raw))
        (('in-double)))))

  (define (lex-until-end-of-curly-string chars)
    (let loop ((len 1)
               (rest chars))
      (case (car rest)
        ((#\\)
         (if (or (equal? (cadr rest) #\{)
                 (equal? (cadr rest) #\}))
           (loop (+ 2 len) (cddr rest))
           (loop (+ 1 len) (cdr rest))))
        ((#\{)
         (let-values (((new-len new-rest _str) (lex-until-end-of-expr rest)))
           (loop (+ len new-len) new-rest)))
        ((#\})
         (values (+ 1 len)
                 (cdr rest)
                 (list->string (take rest (+ 1 len)))))
        (else (loop (+ 1 len) (cdr rest))))))

  (define (<single-string> chars-reversed)
    (define content (string-join (reverse (chars-reversed))) "")
    (lambda (method) content))

  )
