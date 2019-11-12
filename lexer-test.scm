(load "lexer.scm")
(import toratau.lexer)
(import srfi-13)
(import (chicken string))

(define (test-lex test-name str1 str2 with-fn)
  (define-values (len chars str) (with-fn (string->list str1)))
  (define str1-lexed str)
  (print test-name "\t"
           (if (equal? str1-lexed str2) 
             "OK" 
             (string-join (list " ERROR\nIn:\n" 
                                (->string str1)
                                "\nOut:\n"
                                (->string str1-lexed)
                                "\nExpect:\n"
                                (->string str2))))))

(test-lex "Curly string test"
          "{Curly string can contain \\{ escapes\\}, can\nspan multiple lines, but %[expressions do not eval.]}  this will be dropped"
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

(test-lex "Simple expr test"
          "[it should end up as a list] "
          '("it" "should" "end" "up" "as" "a" "list")
          lex-expr)

(test-lex "Cyrillic expr test"
          "[это будет список]"
          '("это" "будет" "список")
          lex-expr)

(test-lex "Mixed expr test (curly)"
          "[it {should be simple} as hell]"
          '("it" "should be simple" "as" "hell")
          lex-expr)

#;(test-lex "Text with expr test"
          "This is text %[but this is expression] This is text again"
          "a"
          text->tokens)

(define test-tokens-text (text->tokens (string->list"This is text %[{but} this is expression] This is text again")))
(define test-tokens-goal
  (list "cat" "This is text "
        (list "but" "this" "is" "expression")
        " This is text again"))
(print "Tokenization test\t"
       (if (equal? test-tokens-text test-tokens-goal) "OK" "ERROR"))

(test-lex "Double string test"
          "\"This is part of double string %[this is expression {with curly string} et al] sounds fun\" this is dropped"
          '("cat" "This is part of double string " ("this" "is" "expression" "with curly string" "et" "al") " sounds fun")
          lex-double-string)
