(module toratau.scope *
  (import scheme
          (chicken base)
          (srfi 69))

  (define scope
    (alist->hash-table
      `(("define"  . ,t-define)
        ("rename"  . ,t-rename)
        ("defn"    . ,t-defn)
        ("ifeq"    . ,t-ifeq)
        ("ifdef"   . ,t-ifdef)
        ("apply"   . ,t-apply)
        ("dotimes" . ,t-dotimes))))

  (define (t-define . args))

  (define (t-rename old-macro-name new-macro-name))

  (define (t-defn macro-name))

  (define (t-ifeq str1 str2 then else*))

  (define (t-ifdef macro-name then else*))

  (define (t-apply macro-name . args))

  (define (t-dotimes n expr . joiner))
  )
