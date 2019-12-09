# Building Toratau

After unsuccessful attempt to literatify all of Toratau, I'm going to make everything clear and explain everything so I don't get lost myself. This file is source for Makefile. Run `./build_makefile.sh` to build makefile.

Toratau depends on itself and on [Qaraidel for C](https://github.com/bouncepaw/qara2c). A safe version of Toratau has to be kept. Define paths to both Tora and Qara:

```make
toratau := ~/bin/toratau
qaraidel := ~/bin/qara2c
```

```make
build: tangle compile
	echo "Build Toratau"
```

Only some files have been literatified, and it's done wrong. See the other branch to see how the true literate program should look.

```make
tangle:
	cat literate/scope.scm.md | $(toratau) | $(qaraidel) > tangled/scope.scm
	cat literate/lexer.scm.md | $(qaraidel) > tangled/lexer.scm
```

Compilation should work without surprises but I think some checks or tests should be added to see if the code should be really compiled:

```make
compile:
	chicken-csc tangled/toratau.scm -o toratau
```

Clean-up after use:

```make
clean:
	rm toratau
```

If safe version of Toratau is compiled, backup it!:

```make
backup_exec:
	cp ./toratau ~/bin
```

