(load "lexer.scm")
(import toratau.lexer)
(import srfi-13)

(define (test-lex test-name str1 str2 with-fn)
  (define-values (len chars str) (with-fn (string->list str1)))
  (define str1-lexed str)
  (print test-name "\t"
           (if (equal? str1-lexed str2) 
             " OK" 
             (string-join (list " ERROR\nIn:\n" str1 "\nOut:\n" str1-lexed 
                          "\nExpect:\n" str2)))))

(test-lex "Curly string test"
          "{Curly string can contain \\{ escapes\\}, can\nspan multiple lines, but %[expressions do not eval.]}"
          "Curly string can contain \\{ escapes\\}, can\nspan multiple lines, but %[expressions do not eval.]"
          lex-curly-string)

(test-lex "Single string test"
          "'Single strings can contain \\'escapes\\', can\nspan multiple lines, but %[expressions do not eval].'"
          "Single strings can contain \\'escapes\\', can\nspan multiple lines, but %[expressions do not eval]."
          lex-single-string)

(test-lex "Unwrapped string test"
          "string 
        everything else {is here}"
          "string"
          lex-raw-string)
