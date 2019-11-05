;; macro.scm
;; Expanding macros in Toratau files

(module toratau.expand
  *
  (import scheme
          (chicken base)
          (srfi 13)
          (srfi 1))

  ;; separated-src is List<List|String>. If an element is String, it is kept as is, else it is expanded and the result of expanding is kept. Next, everything saved is joined together.
  (define (expand-string str)
    (define separated-src (str->separated-src str))
    (string-join
      (map (lambda (element)
             (cond
               ((string? element) element)
               (else (expand-list element))))
           separated-src)
      ""))

  ;; 
  (define (expand-list expression)
    (cond
      ((atom? expression) (expand-atom expression))
      (else
        )))

  ;; Strings wrapped with in '' or {} or unwrapped at are left untouched. Others (in "") are expanded first.
  (define (expand-atom atom)
    (define (first+last str)
      (let ((chars (string->list str)))
        (list (car chars) (last chars))))
    (define (bare str)
      (let ((chars (string->list str)))
        (drop-right (cdr chars) 1)))
    (if (filter
          (lambda (x) (apply equal? x))
          (zip (circular-list (first+last atom))
               (map first+last (list "{}" "''"))))
        (bare atom)
        (expand-string atom)))

)
