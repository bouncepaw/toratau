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

- `word`, `210`: not wrapped in anything. Cannot contain any whitespace. Do not support backslash-escaping.
- `'two words'`: wrapped in single quotes. Can contain any whitespace. Support backslash-escaping.
- `{two words}`: wrapped in curly braces. The same thing as single quotes but it can be nested more easily.
- `"two words and an %[lowercase EXPRESSION]"`: wrapped in double quotes. Can contain any whitespace. Support backslash-escaping. Unlike other types of string, root expressions can be placed and evaluated in it.

## Out-of-the-box macros

Macros is shipped with a set of macros. User can redefine any of them and define their own macros.

### Macro-defining macros

#### define

```
[define macro-name definition]
```

Define a new macro called *macro-name* in current scope with such *definition*. User can redefine existing macros using this macro. Arguments can be accessed using `%1`..`%N` where N is number of arguments.

Return empty string.

#### rename

```
[rename old-macro-name new-macro-name]
```

Rename a macro called *old-macro-name* to *new-macro-name*. Is is no longer available as *old-macro-name*.

Return empty string.

#### defn

```
[defn macro-name]
```

Get definition of a macro with such *macro-name*.

### Flow control macros

#### ifeq

```
[ifeq str1 str2 then else*]
```

If *str1* equals *str2*, then return *then*, else return *else*. If *else* is not passed, then it is assumed that it is empty string.

#### ifdef

```
[ifdef macro-name then else*]
```

If macro called *macro-name* is defined, then return *then*, else return *else*. If *else* is not passed, then it is assumed that it is empty string.

#### apply

```
[apply macro-name args...]
```

Call macro called *macro-name* with arguments that are in *args* separated by whitespace. Any number of *args*es can be passed, they will be joined by whitespace together first.

#### dotimes

```
[dotimes n expr joiner*]
```

Evaluate expression *expr* *n* times. Results of evaluation are then joined together with *joiner*, this value is then returned. If *joiner* is not passed, it is assumed as empty string.

