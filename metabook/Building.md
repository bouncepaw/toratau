# Building Toratau

After unsuccessful attempt to literatify all of Toratau, I'm going to make everything clear and explain everything so I don't get lost myself. This file is source for Makefile. Run `./build_makefile.sh` to build makefile.

Toratau depends on itself and on [Qaraidel for C](https://github.com/bouncepaw/qara2c). A safe version of Toratau has to be kept. Define paths to both Tora and Qara:

```make
toratau := ./toratau
#toratau := ~/bin/toratau
qaraidel := ~/bin/qara2c
csc := chicken-csc
```

```make
build: tangle compile
	echo "Build Toratau"
```

In directory `srcbook`: file `Implementation.md` is the main chapter that includes other source chapters when Toratau-expanded. Resulting text is fed to Qaraidel. Resulting program is compiled.

```make
tangle:
	cd srcbook && .$(toratau) < Implementation.md | $(qaraidel) > tangled_src.scm
	cd ..
	mv srcbook/tangled_src.scm .
```

Compilation should work without surprises but I think some checks or tests should be added to see if the code should be really compiled:

```make
compile:
	$(csc) tangled_src.scm -o toratau
```

Clean-up after use:

```make
clean:
	rm tangled_src.scm
```

If safe version of Toratau is compiled, backup it!:

```make
backup_exec:
	cp ./toratau ~/bin
```

