(import (srfi 1)
        (srfi 13)
        (srfi 69)
        matchable)

;; All chars from STDIN as list.
(define input-chars
  (let loop ((chars '()))
    (let ((char (read-char)))
      (if (eof-object? char)
          (reverse chars)
          (loop (cons char chars))))))

(load "lexer.scm")
(load "parse.scm")
(load "scope.scm")

;; All tokens, AST.
(define tokens (text->tokens input-chars))

(display (eval (parse-ast tokens)))
(newline)

