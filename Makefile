toratau := ~/bin/toratau
qaraidel := ~/bin/qara2c

build: tangle weave compile
	echo "Build Toratau"

tangle:
	cat literate/scope.scm.md | $(toratau) | $(qaraidel) > tangled/scope.scm
	cat literate/lexer.scm.md | $(qaraidel) > tangled/lexer.scm

weave:
	cat literate/scope.scm.md | $(toratau) | $(qaraidel) --weave > doc/scope.md

compile:
	chicken-csc tangled/toratau.scm -o toratau

clean:
	rm toratau

backup_exec:
	cp ./toratau ~/bin
