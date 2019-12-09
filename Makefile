toratau := ./toratau
# toratau := ~/bin/toratau
qaraidel := ~/bin/qara2c
build: tangle compile
	echo "Build Toratau"
tangle:
	$(qaraidel) < srcbook/Scope.md > tangled/scope.scm
	cat literate/scope.scm.md | $(toratau) | $(qaraidel) >> tangled/scope.scm
	cat literate/lexer.scm.md | $(qaraidel) > tangled/lexer.scm
compile:
	chicken-csc tangled/toratau.scm -o toratau
clean:
	rm toratau
backup_exec:
	cp ./toratau ~/bin
