;; macro.scm
;; This file is about creating Macro objects.

(module toratau.macro
  *
  (import scheme (chicken base))

  (define (Macro definition)
    (define macro (definition->fn definition))
    (lambda (method)
      (case method
        ((macro) macro)
        ((definition) definition))))
  )

