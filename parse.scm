  ;; EXECute string as Toratau expression. STR gets wrapped in implicit prefixed brackets ("expr" becomes "%[expr]", "[expr]" becomes "%[[expr]]"). Thus, STR becomes a root Toratau expression. After that, it gets lexed, then parsed, then evaluated.
(define (exec str)
  (let* ((str-wrapped (string-join (list "%[" str "]") ""))
         (chars (string->list str-wrapped))
         (tokens (text->tokens chars))
         (parsed-expr (parse-ast tokens)))
    (eval parsed-expr)))

;; Expr = (Expr | String) ...
(define (parse-ast expr)
  (cond
    ((string? expr) expr)
    ((null? expr) expr)
    (else (let ((parsed-expr (map parse-ast expr)))
            (cons (list-head (car parsed-expr)) (cdr parsed-expr))))))

;; Return function that receives any number of args and applies all of
;; them to corresponding function in the scope.
(define ((list-head macro-name) . args)
  (apply (hash-table-ref scope macro-name) args))

;; Used when defining custom macros. Return function that accepts args passed to the macro. Replce $N in definition with passed args. Return the result.
(define ((definition->lambda definition) . args)
  ; (exec
  (string-substitute*
    definition
    (map (lambda (id)
           (cons (string-join (list "%" (number->string (+ 1 id))) "")
                 (list-ref args id)))
         (iota (length args)))))
