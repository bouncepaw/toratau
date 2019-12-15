#toratau := ../toratau
toratau := ~/bin/toratau
qaraidel := ~/bin/qara2c
csc := chicken-csc
build: tangle compile
	echo "Build Toratau"
tangle:
	cd srcbook && $(toratau) < Implementation.md | $(qaraidel) > tangled_src.scm
	cd ..
	mv srcbook/tangled_src.scm .
compile:
	$(csc) tangled_src.scm -o toratau
clean:
	rm tangled_src.scm
backup_exec:
	cp ./toratau ~/bin
