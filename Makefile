compile:
	chicken-csc toratau.scm

clean:
	rm toratau

backup_exec:
	cp ./toratau ~/bin

tangle:
	cat scope.scm.md | ~/bin/toratau | ~/bin/qara2c

weave:
	cat scope.scm.md | ~/bin/toratau | ~/bin/qara2c --doc
