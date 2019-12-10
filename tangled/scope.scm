(import (srfi 69))
(define scope (make-hash-table))
(define definitions (make-hash-table))
(import (chicken io))
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
        then
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
        (string-join (map (lambda (a) (string-join (list "{" a "}")))
                          (cdr arg))))))
(hash-table-set! scope "shift" t-shift)
(hash-table-set! definitions "shift" "")
(define (t-apply macro-name . args) 

    (exec (string-join args))
)
(hash-table-set! scope "apply" t-apply)
(hash-table-set! definitions "apply" "")
(define (t-dotimes n expr . joiner) 

    (string-join
      (map exec (make-list n expr))
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
