# Ultimate test

Test all built-ins.

## Metamacros

```
%[define foo bar]
%[foo] == bar
%[define semicolon {%1;}]
%[semicolon e] == e;
```

```
%[rename foo bar]
%[bar] == bar
```

```
%[defn bar] == bar
%[defn defn] ==  (empty)
```

## Conditional

```
%[ifeq 1 1 true] == true
%[ifeq 1 2 true] ==  (empty)
%[ifeq 1 2 true false] == false
%[ifeq 1 2 true {%[ifeq 1 1 falsetrue falsefalse]}] == falsetrue
```

```
%[define quux is_here]
%[ifdef quux isdef isntdef] == isdef
%[ifdef quux isdef] == isdef
%[ifdef quuux isdef] ==  (empty)
%[ifdef quuux isdef isntdef] == isntdef
```

## String manipulating

```
%[cat a b] == ab
%[lines a b] == a
b
```

## Misc

```
%[shiftn 3 a b c d] == {d}
%[shiftn 0 a b] == {a} {b}
%[shiftn 1 a] ==  (empty)
%[shiftn 4] ==  (empty)
```

```
%[shift] ==  (empty)
%[shift a] ==  (empty)
%[shift a b] == {b}
%[shift {a b} c d {e f g}] == {c} {d} {e f g}
```

```
%[define sum {%1 + %2}]
%[apply sum 1 2] == 1 + 2
%[apply sum [apply shift [shift a b c d]]] == c + d
```

```
%[dotimes 3 a] == aaa
%[include file1] == world

```

