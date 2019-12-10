(import (clojurian syntax)
        regex
        (srfi 13)
        (srfi 69))
(define (exec str)
  (-> str
      string->list
      text->tokens
      parse-ast
      eval))
(define (parse-ast expr)
  (cond
    ((string? expr) expr)
    ((null? expr) expr)
    (else
      (let ((parsed-expr (map parse-ast expr)))
        (cons (list-head (car parsed-expr))
              (cdr parsed-expr))))))
(define ((list-head macro-name) . args)
  (apply (hash-table-ref scope macro-name) args))
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
           (cons (string-join (list "%" (number->string (+ 1 id))) "")
                 (list-ref args id)))
         (iota (length args))))
  (-> definition
      (string-substitute* (append special-alist args-alist))
      string->list
      text->tokens
      parse-ast
      eval))
