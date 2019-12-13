# Toratau, the macro-processor

You are reading literate source of Toratau, the macro-processor. Literate programming capabilities are provided by [Qaraidel for C](https://github.com/bouncepaw/qara2c). Later, when ultimate Qaraidel for any language is released, Toratau will migrate to it. For now, it's ok, as none of language-specific features of Qaraidel are used. Toratau is written in Chicken Scheme.

## What is Toratau?

This is a macro-processor. Its goal is to provide easy-to-use macros and simple way to define new ones, along with concise syntax that does not conflict with existing solutions. Consider this example:

    %[define proc {void %1 (%2) {%3}}]
    %[proc main {} {
      printf("hello world!");
      return 0;
    }]

It shows usage of two macros: `define` and `proc` (that was defined by the `define` macro). It also shows how strings look in Toratau, they are enclosed in curly braces or are not enclosed at all (the difference is discussed later).

Toratau can do a lot more, and that's what this book is about. If you read it in its rendered form (if you are reading at GitHub site, that's probably it), you don't see difference between codelets, pieces of code that go to resulting program, and examples, pieces of code that do not. It's ok for a mere reader.

If you edit Markdown files by hand, you'll notice how they differ. Examples are prefixed with 4 spaces, codelets are in fenced code blocks.

## Alternatives

The most popular alternatives for Toratau are the C Preprocessor (`cpp`) and `m4`. `cpp` is really limited (for example, it does not support recursive macros). `m4` has extremely complicated syntax. <!-- More over, NIH. -->Toratau is better as it can do (or will be able to) advanced things like recursive macros and it is *also* readable.

## How to read this book?

Just follow the links, if you're reading the rendered form. If you are not, open corresponding files. Source code starts in the next file: [Implementation.md](Implementation.md). It includes other pieces of code using macro `include`. Check it out!

## Table of contents

1. **Implementation.md**
1. [Lexing.md](Lexing.md)
1. [Parsing.md](Parsing.md)
1. [Scope.md](Scope.md)
1. [Prelude.md](Prelude.md)

