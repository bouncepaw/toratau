# toratau

Macro processor

## Introduction

Toratau gets input text. It evaluates every Toratau expression in it, result of evaluation is placed where the expression used to be.

```
This is %[upcase caps].
↓
This is CAPS.
```

Expressions can be nested. Expressions that are not being nested are called *root expressions* and are prefixed with percent sign `%`.

```
This is %[upcase [lowercase CAPS]].
↓
This is %[upcase caps].
↓
This is CAPS.
```

Expression consists of a macro and any number of arguments separated by whitespace. All expressions are wrapped in `[]`.

```
expression prefix
|
| ______expression_______
↓/                       \
%[upcase [lowercase CAPS]]
  ↑      \              /
  macro   ---argument---
  name
```

Argument can be either string or expression. Strings come in this varieties:

- `word`, `210`: not wrapped in anything. Cannot contain any whitespace. Do not support backslash-escaping. These are called raw strings.
- `{two words}`: wrapped in curly braces. Can be nested easily, unlike traditional quotes. Expressions can be embedded inside: `{%[like that, with prefix]}`. `{\}}` is a string with two characters: `\` and `}`.
- `'two words'`: wrapped in single quotes. Can contain any whitespace. Evaluate to strings that contain the surrounding quotes. `\'` in it evaluates to two characters and does not end the string.
- `"two words"`: wrapped in double quotes. Can contain any whitespace. Evaluate to strings that contain the surrounding quotes. `\"` in it evaluates to two characters and does not end the string.

## Out-of-the-box macros

Toratau is shipped with a set of macros. User can redefine any of them and define their own macros. These pre-built macros provide only things that are required for comfortable macro creation.

### Macro-defining macros

#### define

```
[define macro-name definition]
```

Define a new macro called *macro-name* in current scope with such *definition*. User can redefine existing macros using this macro. Arguments can be accessed using `%1`..`%N` where N is number of arguments. `%#` means number of passed arguments. `%*` means all arguments joined with spaces. `%@` means all arguments wrapped in `{}` and then joined with spaces.

```
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
```

Return empty string.

#### rename

```
[rename old-macro-name new-macro-name]
```

Rename a macro called *old-macro-name* to *new-macro-name*. Is is no longer available as *old-macro-name*.

```
[define foo bar]
[foo] → bar
[rename foo baz]
[foo] → ERROR
[baz] → bar
```

Return empty string.

#### defn

```
[defn macro-name]
```

Return definition of a macro with such *macro-name*.

```
[define welcome {Hello, %1!}]
[defn welcome] → Hello, %1!
```

### Flow control macros

#### ifeq

```
[ifeq str1 str2 then else*]
```

If *str1* equals *str2*, then return *then*, else return *else*. If *else* is not passed, then it is assumed that it is empty string.

```
[ifeq 1 1 true] → true
[ifeq 1 2 true] → EMPTY STRING
[ifeq 1 2 true false] → false
```

#### ifdef

```
[ifdef macro-name then else*]
```

If macro called *macro-name* is defined, then return *then*, else return *else*. If *else* is not passed, then it is assumed that it is empty string.

```
[define foo bar]
[ifdef foo defined undefined] → defined
[ifdef quux defined undefined] → undefined
```

#### shift

```
[shift arg1 argn ...]
```

Return all `argn`s joined with spaces.

#### apply

```
[apply macro-name args...]
```

Call macro called *macro-name* with arguments that are in *args* separated by whitespace. Any number of *args*es can be passed, they will be joined by whitespace together first.

```
[define multi-hi {Hi, %1, %2 and %3}]
[apply multi-hi {George John} Ivan] → Hi, George, John and Ivan
```

#### dotimes

```
[dotimes n expr joiner*]
```

Evaluate expression *expr* *n* times. Results of evaluation are then joined together with *joiner*, this value is then returned. If *joiner* is not passed, it is assumed as empty string.

```
[dotimes 3 hi] → hihihi
[dotimes 3 hi { }] → hi hi hi
```

### String manipulating macros

#### cat

```
[cat arg ...]
```

Return all `arg`s joined together with an empty string.

```
[cat Hello World] → HelloWorld
```

#### lines

```
[lines arg ...]
```

Return all `arg`s joined together with a newline.

```
[lines Hello World] → Hello
World
```

