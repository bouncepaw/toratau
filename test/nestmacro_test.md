# Test nested macro calls

Define macro and call it

```
%[define foo bar]
%[foo] == bar
```

Define macro that calls macro `foo` when called

```
%[define foofoo {%[foo]}]
%[foofoo] == %[foo] == bar
```

Define macro that defines macro `ja` and calls it when called

```
%[define quux {%[define ja jaja]%[ja]}]
%[quux] == %[ja] == jaja
```

