# Scope

This file has things related to scope along with built-in functions.


## Built-in macros

Defined using mixture of Qaraidel, Toratau and Chicken Scheme :)

### Macro-defining macros

#### define

    [define macro-name definition]

Define a new macro called *macro-name* in current scope with such *definition*. User can redefine existing macros using this macro. Arguments can be accessed using `%1`..`%N` where N is number of arguments. `%#` means number of passed arguments. `%*` means all arguments joined with spaces. `%@` means all arguments wrapped in `{}` and then joined with spaces.

Return empty string.

    [define foo bar]
    [foo] → bar

    [define welcome {Hello, %1!}]
    [welcome world] → Hello, world!

    [define analyze-args {
    Number: %#
    Unwrapped: %*
    Wrapped: %@}]

    [analyze-args] →
    Number: 0
    Unwrapped: 
    Wrapped: 

    [analyze-args one two {three four} [foo]] →
    Number: 4
    Unwrapped: one two three four bar
    Wrapped: {one} {two} {three four} {bar}


#### rename

    [rename old-macro-name new-macro-name]

Rename a macro called *old-macro-name* to *new-macro-name*. Is is no longer available as *old-macro-name*. Return empty string.

    [define foo bar]
    [foo] → bar
    [rename foo baz]
    [foo] → ERROR
    [baz] → bar


#### defn

    [defn macro-name]

Return definition of a macro with such *macro-name*.

    [define welcome {Hello, %1!}]
    [defn welcome] → Hello, %1!


### Conditional

#### ifeq

    [ifeq str1 str2 thenc . elsec]

If *str1* equals *str2*, then return *then*, else return *else*. If *else* is not passed, then it is assumed that it is empty string.

    [ifeq 1 1 true] → true
    [ifeq 1 2 true] → EMPTY STRING
    [ifeq 1 2 true false] → false


#### ifdef

    [ifdef macro-name thenc . elsec]

If macro called *macro-name* is defined, then return *then*, else return *else*. If *else* is not passed, then it is assumed that it is empty string.

    [define foo bar]
    [ifdef foo defined undefined] → defined
    [ifdef quux defined undefined] → undefined


### Meta macros

#### shift

    [shift arg1 . args]

Return all `argn`s joined with spaces.


#### apply

    [apply macro-name . args]

Call macro called *macro-name* with arguments that are in *args* separated by whitespace. Any number of *args* can be passed, they will be joined by whitespace together first.

    [define multi-hi {Hi, %1, %2 and %3}]
    [apply multi-hi {George John} Ivan] → Hi, George, John and Ivan


#### dotimes

    [dotimes n expr . joiner]

Evaluate expression *expr* *n* times. Results of evaluation are then joined together with *joiner*, this value is then returned. If *joiner* is not passed, it is assumed as empty string.

    [dotimes 3 hi] → hihihi
    [dotimes 3 hi { }] → hi hi hi


#### include

    [include filename]

Read *filename*, evaluate is as Toratau code in current scope, return the result.

    In file1:
    Contents.

    In file2:
    [include file1]

    Result of file2:
    Contents.


### String manipulating macros

#### cat

    [cat . args]

Return all `args` joined together with an empty string.

    [cat Hello World] → HelloWorld


#### lines

    [lines . args]

Return all `arg`s joined together with a newline.

    [lines Hello World] → Hello
World


### OS API

This thing is quite dangerous, as user can run any command. If you care about that redefine the following macro so it does nothing:

#### pipe-to-shell

    [pipe-to-shell text command]

Pipe *text* to *command* and return the result.

    [pipe-to-shell [include file] "head -n 1"]
    is same as running this in shell:
    cat file | head -n 1


## Scope, etc

`scope` is hash-table where each key is a string that corresponds to a macro name and value is function that gets applied to arguments of the macro. Out of the box, only those above functions are in the scope. By defining and redefining macros, user can mutate scope.

Each macro has a definition which is a string that user passed when defining their macro with `define` macro. Built-in functions have empty definition.

