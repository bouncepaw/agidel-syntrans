# agidel-syntrans

So, imagine yourself doing that:
```bash
λ agidel file.lisp
```

Before actual evaluating, the file goes through a list of so-called syntax
transformers. Each of them does one simple thing: one strips comments of the
code, other one transforms bracket expressions to their true form, others make
the code ready to be read by the Agidel transpiler.

This repository contains all the syntax transformers I, author of Agidel, made
by myself. However, it's easy for you to create your own syntax transformer.
More about it below.

The list of syntax transformers to be used when transpiling can also be
configured. More about it below.

## Creating a syntax transformer

Make yourself familiar with [Chicken Scheme
eggs](http://wiki.call-cc.org/man/5/Extensions) Create an egg. When naming the
module, follow this convention: `agidel-syntrans.<name here>`. Each such module
must export function `main` which accepts one argument — source code before
transformation as a string — and returns the code after transformation. For
example: 

```scheme
(module 
 agidel-syntrans.hello
 *
 (import scheme format)
 
 (define (main source-string)
   (format "Hello, ~A" source-string)))
```

Then share this egg with everyone else.

## Configuring list of syntax transformers

There is a file named `$AGIDEL_DIR/syntrans`. It contains list of syntax
transformers that should be used when transpiling Agidel. For example:

```lisp
(discomment
 disbracket
 disbrace
 prepare
 eval)
```

As you can see, even Agidel evaluation is implemented as a syntax
transformer. Output of the final syntax transformer is the output of
the whole transpilation process.

If no such file is found, the default list is used instead. 
