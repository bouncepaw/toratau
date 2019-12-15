# Toratau

Macro processor embeddable anywhere.

Define a new macro:

```
%[define negate {Not %1}]
%[negate bad], friend
↓
Not bad, friend
```

Conditionals:

```
%[define platform-linux? 1]
%[ifdef platform-linux?
  {Running Linux}
  {Running something that's not Linux}]
↓
Running Linux
```

Repeat phrase:

```
%[dotimes 4 {ha }], this is so funny!
↓
ha ha ha ha, this is so funny!
```

Concatenate words:

```
%[cat Thou {sand } ye [cat a r s]]
↓
Thousand years
```

Include a file:

```
Contents of file1:
world

Contents of file2:
Hello, %[include file1]!
↓
Hello, world!
```

Many more applications are possible.

## Built-in macros reference

Since Toratau's source is literate, source code and documentation are almost the same thing. Check out [Prelude.md](srcbook/Prelude.md) to see description and implementation of all built-in macros.

## Syntax reference

See [Lexing.md](srcbook/Lexing.md).

## Execution

Toratau reads input from `stdin` and writes output to `stdout`. There's no built-in way to read/write a file, you have to use your shell's capabilities for that:

```bash
# Macro-expand pre.c and write output to stdout
toratau < pre.c
cat pre.c | toratau

# Macro-expand pre.c and write output to post.c
toratau < pre.c > post.c
cat pre.c | toratau > post.c
```

## Installation

Normally you need Toratau to build Toratau because its source is made with Toratau macros but you can also compile `tangled_src.scm` or just use pre-compiled `toratau` executable.

Toratau depends on [Qaraidel for C](https://github.com/bouncepaw/qara2c) and on [Chicken Scheme](https://www.call-cc.org/) compiler. Configure their executable paths:

### Configuration

Toratau is built with a makefile but the makefile is preprocessed first. Edit `metabook/Building.md` first and then run `./makemake.sh`. In `metabook/Building.md` you can configure executable paths for Qaraidel, Chicken Scheme compiler and Toratau itself. If you want to run a specific task, pass the task's name:

```bash
# tangle and compile
./makemake.sh

# just tangle
./makemake.sh tangle

# just compile
./makemake.sh compile

# clean up
./makemake.sh clean
```

## Contributing

If you want to contribute, just make open an issue or make a pull-request or just contact me. Any feedback is welcome!

