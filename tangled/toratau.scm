(import (srfi 1))

;; All chars from STDIN as list.
(define input-chars
  (let loop ((chars '()))
    (let ((char (read-char)))
      (if (eof-object? char)
          (reverse chars)
          (loop (cons char chars))))))

(include-relative "lexer.scm")
(include-relative "parse.scm")
(include-relative "scope.scm")

;; All tokens, AST.
(define tokens (text->tokens input-chars))

(display (eval (parse-ast tokens)))
(newline)

