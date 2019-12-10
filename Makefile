toratau := ./toratau
#toratau := ~/bin/toratau
qaraidel := ~/bin/qara2c
build: tangle compile
	echo "Build Toratau"
tangle:
	$(toratau) < srcbook/Lexer.md | $(qaraidel) > tangled/lexer.scm
	$(qaraidel) < srcbook/Scope.md > tangled/scope.scm
	$(toratau) < srcbook/Prelude.md | $(qaraidel) >> tangled/scope.scm
compile:
	chicken-csc tangled/toratau.scm -o toratau
clean:
	rm toratau
backup_exec:
	cp ./toratau ~/bin
