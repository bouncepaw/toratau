(load "lexer.scm")
(import toratau.lexer)
(import srfi-13)

#|
(define test-string
  "
  Begin text file.

  These lines have to be groupped in one text blocs.
  %[this is an expression
    {This is string %[but this is not an expression]}
    two words
    'That\\'s a string too'
    \"This is string %[and this is an {expression}]\"
    [this is nested expression
          [very deep [right] ]]
    ]
  Back to normal text. End of transmission.
  ")

(print "Test Toratau lexer with this text:" test-string)
(print "Lexer does not eval text. It just transforms it to a form that is more easily understood by the evaluator.")
|#

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

