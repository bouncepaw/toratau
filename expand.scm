;; macro.scm
;; Expanding macros in Toratau files
;; TODO: better naming

(module toratau.expand
  *
  (import scheme
          (chicken base)
          (srfi 13)
          (srfi 1)
          )

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

  ;; :: String -> String
  ;; Strings wrapped with in '' or {} are left unwrapped. Others (in "") are expanded.
  (define (expand-atom atom)
    (define (first+last str)
      (let ((chars (string->list str)))
        (list (car chars) (last chars))))
    (define (bare str)
      (let ((chars (string->list str)))
        (list->string (drop-right (cdr chars) 1))))
    (if (filter
          (lambda (x) (apply equal? x))
          (zip (map first+last '("{}" "''"))
               (circular-list (first+last atom))))
        (bare atom)
        (expand-string atom)))

  ;; :: String -> List<List|String>
  ;; Breaks up source text to some kind of tokens.
  ;; TODO: implement.
  (define (str->separated-src str) (list str))
)
