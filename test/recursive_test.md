## Recursive macros test

Recursive macros is an important feature of Toratau so it just has to be OK.

```
%[define print-by-two
  {%[ifeq %# 0
      {}
      {%[lines
        {%1 %2}
[apply print-by-two [apply shiftn 2 %@]]]}]}]
```

```
%[print-by-two 1 2 3 4]
```

**The test fails and it looks ugly ⇒ recursion should be provided by builtins and not implemented by user.**

