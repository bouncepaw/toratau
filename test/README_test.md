These are tests of examples from [README.md](../README.md).

```
%[define negate {Not %1}]
%[negate bad], friend
==
Not bad, friend
```

```
%[define platform-linux? 1]
%[ifdef platform-linux?
  {Running Linux}
  {Running something that's not Linux}]
==
Running Linux
```

Repeat phrase:

```
%[dotimes 4 {ha }], this is so funny!
==
ha ha ha ha, this is so funny!
```

Concatenate words:

```
%[cat Thou {sand } ye [cat a r s]]
==
Thousand years
```

Include a file:

```
Hello, %[include file1]!
==
Hello, world!
```

