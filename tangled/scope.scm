;; Hash table
(import (srfi 69))

(define scope '())
(define definitions '())
(define (t-define macro-name definition) 

    (hash-table-set! definitions macro-name definition)
    (hash-table-set! scope macro-name (definition->lambda definition))
    ""
)
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
(define (t-defn macro-name) 

    (hash-table-ref definitions macro-name)
)
(define (t-ifeq str1 str2 thenc . elsec) 

    (if (equal? str1 str2)
        thenc
        (if (null? elsec) "" (car elsec)))
)
(define (t-ifdef macro-name thenc . elsec) 

    (if (hash-table-exists? scope macro-name)
        then
        (if (null? elsec) "" (car elsec)))
)
(define (t-shift arg1 . args) 

    (string-join args)
)
(define (t-apply macro-name . args) 

    (exec (string-join args))
)
(define (t-dotimes n expr . joiner) 
    (string-join
      (map exec (make-list n expr))
      (if (null? joiner) "" (car joiner)))
)
(define (t-cat . args) 

    (string-join args "")
)
(define (t-lines . args) 

    (string-join args "\n")
)
(define scope
  (alist->hash-table
    `(("define"  . ,t-define)
      ("rename"  . ,t-rename)
      ("defn"    . ,t-defn)
      ("ifeq"    . ,t-ifeq)
      ("ifdef"   . ,t-ifdef)
      ("apply"   . ,t-apply)
      ("dotimes" . ,t-dotimes)
      ("cat"     . ,t-cat)
      ("lines"   . ,t-lines))))
(define definitions
  (alist->hash-table
    '(("define"  . "")
      ("rename"  . "")
      ("defn"    . "")
      ("ifeq"    . "")
      ("ifdef"   . "")
      ("apply"   . "")
      ("dotimes" . "")
      ("cat"     . "")
      ("lines"   . ""))))
