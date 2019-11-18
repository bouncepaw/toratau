;; Expr = (Expr | String) ...
(define (parse-ast expr)
  (if (string? expr)
      expr
      (let ((parsed-expr (map parse-ast expr)))
        (cons (list-head (car parsed-expr)) (cdr parsed-expr)))))

;; Return function that receives any number of args and applies all of
;; them to corresponding function in the scope.
(define ((list-head macro-name) . args)
  (apply (hash-table-ref scope macro-name) args))
