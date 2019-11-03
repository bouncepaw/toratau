# toratau

Macro processor

## Introduction

Toratau gets input text. It evaluates every Toratau expression in it, result of evaluation is placed where the expression used to be.

```c
This is %[upcase caps].
↓
This is CAPS.
```

Expressions can be nested. Expressions that are not being nested are called *root expressions* and are prefixed with percent sign `%`.

```c
This is %[upcase [lowercase CAPS]].
↓
This is %[upcase caps].
↓
This is CAPS.
```

Expression consists of a macro and any number of arguments separated by whitespace. All expressions are wrapped in `[]`.

```c
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
- `"two words and an %[lowercase EXPRESSION]"`: wrapped in double quotes. Can contain any whitespace. Support backslash-escaping. Unlike other types of string, root expressions can be placed and evaluated in it.

