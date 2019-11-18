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

;; All tokens.
(define tokens (text->tokens input-chars))

(write tokens)
(newline)

