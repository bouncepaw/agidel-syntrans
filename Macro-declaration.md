# Macro declaration

This article guides Agidel plugins developers how to create macros.
Note: this article is subject to change.

## In a nutshell

Module `agidel.core` exports such Scheme macro:

```scheme
(define-agidel (name arg1[:q] arg2[:q]…) docstring . body)
```

`name` is the name of Agidel macro. It can contain any characters a
Scheme symbol can contain. Then there's list of arguments. By default,
each of them gets evaluated. To prevent this, postfix an arg's name
with `:q`. It means `← quote this argument, do not eval it`.
`docstring` is description of the macro. It is meant to be extracted
by documentation generation, that will be made someday. Place actual
code in the `body`, all normal Scheme rules apply there. Remember to
return a function.

For example:

```scheme
; a plugin file
(import (agidel core) format)
(define-agidel (first lst:q)
  "Get 1st elt."
  (car lst))
(define-agidel (hello who-to-salute)
  "Salute someone."
  (format "Hello, ~A" who-to-salute))

; an agidel file
(hello (first ("John" "Not a John")))
```

Notice how `first` does not evaluate the list `("John" "Not a John")`,
but instead reads it as it is. `hello` in its turn does eval list
`(first ("John" "Not a John"))`.

Also, rest-arguments are supported:

```scheme
(define-agidel (name arg1[:q] arg2[:q]… . rest[:q]) docstring . body)
```

The `[:q]` after `rest` means that all elements of the `rest`-list
will be quoted.

For example:

```scheme
; a plugin file
(import (agidel core) format srfi-13)

(define-agidel (hello-all . people)
  "Salute all the `people`."
  (string-join (map (lambda (person) (format "Hello, ~A\n" person))
                    people)))
```

## Where to put these declarations?

Create a module named `agidel-plugin.<plugin-name>` in a file named
`<plugin-name>.scm`. Export all Agidel macros you have made and a
symbol named `_agidel-arities` (this is an internal data structure
used by `schemeify` syntrans). If you have an interesting function
that can be useful for other Agidel plugins, it would be better to put
it into a different module.

Such files shall be put in `$AGIDEL_DIR/plugin`, which defaults to
`~/.agidel/plugin`. 

If you want, you can share your plugins any way you want. The
preferred way is to publish them to the Chicken Scheme Egg repository,
as all official Agidel modules will be published there one day.
