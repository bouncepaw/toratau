;; If you are reading this code not in Markdown file, you are probably
;; reading its tangled form. Check out the literate form too.
(import (srfi 1) ; Advanced list utilities
        (srfi 13) ; String
        (srfi 69) ; Hash tables
        (chicken io)
        (chicken process) ; Piping, used in pipe-to-shell
        matchable ; Pattern matching
        regex
        (clojurian syntax))
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
(define scope (make-hash-table))
(define definitions (make-hash-table))
(define (t-define macro-name definition) 

    (hash-table-set! definitions macro-name definition)
    (hash-table-set! scope macro-name (definition->lambda definition))
    ""
)
(hash-table-set! scope "define" t-define)
(hash-table-set! definitions "define" "")
(define (t-rename old-macro-name new-macro-name) 

    (hash-table-set! scope
                     new-macro-name
                     (hash-table-ref scope old-macro-name))
    (hash-table-set! definitions
                     new-macro-name
                     (hash-table-ref definitions old-macro-name))
    (hash-table-delete! scope old-macro-name)
    (hash-table-delete! definitions old-macro-name)
    ""
)
(hash-table-set! scope "rename" t-rename)
(hash-table-set! definitions "rename" "")
(define (t-defn macro-name) 

    (hash-table-ref definitions macro-name)
)
(hash-table-set! scope "defn" t-defn)
(hash-table-set! definitions "defn" "")
(define (t-ifeq str1 str2 thenc . elsec) 

    (if (equal? str1 str2)
        thenc
        (if (null? elsec) "" (car elsec)))
)
(hash-table-set! scope "ifeq" t-ifeq)
(hash-table-set! definitions "ifeq" "")
(define (t-ifdef macro-name thenc . elsec) 

    (if (hash-table-exists? scope macro-name)
        thenc
        (if (null? elsec) "" (car elsec)))
)
(hash-table-set! scope "ifdef" t-ifdef)
(hash-table-set! definitions "ifdef" "")
(define (t-cat . args) 

    (string-join args "")
)
(hash-table-set! scope "cat" t-cat)
(hash-table-set! definitions "cat" "")
(define (t-lines . args) 

    (string-join args "\n")
)
(hash-table-set! scope "lines" t-lines)
(hash-table-set! definitions "lines" "")
(define (t-shift . arg) 

    (cond
      ((null? arg) "")
      ((eq? 1 (length arg)) "")
      (else
        (string-join (map (lambda (a) (string-join (list "{" a "}") ""))
                          (cdr arg))))))
(hash-table-set! scope "shift" t-shift)
(hash-table-set! definitions "shift" "")
(define (t-shiftn n . arg) 

    (if (eq? (length arg) 0)
        ""
        (string-join
          (map (lambda (a) (string-join (list "{" a "}") ""))
               (drop arg (string->number n))))))
(hash-table-set! scope "shiftn" t-shiftn)
(hash-table-set! definitions "shiftn" "")
(define (t-shift . arg) 

    (apply (hash-table-ref scope "shiftn") "1" arg)
)
(hash-table-set! scope "shift" t-shift)
(hash-table-set! definitions "shift" "")
(define (t-apply . els) 

    (exec (string-join (list "%" "[" (string-join els) "]") ""))
)
(hash-table-set! scope "apply" t-apply)
(hash-table-set! definitions "apply" "")
(define (t-dotimes n expr . joiner) 

    (string-join
      (map exec (make-list (string->number n) expr))
      (if (null? joiner) "" (car joiner)))
)
(hash-table-set! scope "dotimes" t-dotimes)
(hash-table-set! definitions "dotimes" "")
(define (t-include filename) 

    (define input (open-input-file filename))
    (define text (read-string #f input))
    (close-input-port input)
    (eval
      (parse-ast
        (text->tokens (string->list text))))
)
(hash-table-set! scope "include" t-include)
(hash-table-set! definitions "include" "")
(-> (read-string)
    string->list
    text->tokens
    parse-ast
    eval
    display)
(newline)
