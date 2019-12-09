# Scope

In Toratau, the scope is dynamic. User can redefine any macro. Macros defined in an included file affect the parent file's scope.

The scope is represented by a hash-table `scope` which is a global variable. Yeah, global variables are bad, etc, but hey, it is straightforward. Also, every macro has a stored *definition* that is assigned when defining a macro. It is a string. Built-in macros have this string empty, so there is no difference between definitions of built-in macros and empty definitions.

```scheme
(import (srfi 69))
(define scope (make-hash-table))
(define definitions (make-hash-table))
```

The hash-table entries are added when defining the macros. See [Prelude.md](Prelude.md).

