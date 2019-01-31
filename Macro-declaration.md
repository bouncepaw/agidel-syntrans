# Macro declaration

This article guides Agidel plugins developers how to create macros.

## In a nutshell

Module `agidel.core` exports such Scheme macro:

```scheme
(define-agidel (name arg1[:q] arg2[:q]…) body)
```

`name` is the name of Agidel macro. It can contain any characters a
Scheme symbol can contain. Then there's list of arguments. By default,
each of them gets evaluated. To prevent this, postfix an arg's name
with `:q`. It means `← quote this argument, do not eval it`. Place
actual code in the `body`, all normal Scheme rules apply there.
Remember to return a function.

For example:

```scheme
; a plugin file
(import (agidel core) format)
(define-agidel (first lst:q)
  (car lst))
(define-agidel (hello who-to-salute)
  (format "Hello, ~A" who-to-salute))

; an agidel file
(hello (first ("John" "Not a John")))
```

Notice how `first` does not evaluate the list `("John" "Not a John")`,
but instead reads it as it is. `hello` in its turn does eval list
`(first ("John" "Not a John"))`.

Also, rest-arguments are supported:

```scheme
(define-agidel (name arg1[:q] arg2[:q] . rest[:q]))
```

The `[:q]` after `rest` means that all elements of the `rest`-list
will be quoted.

For example:

```scheme
; a plugin file
(import (agidel core) format srfi-13)

(define-agidel (hello-all . people)
  (string-join (map (lambda (person) (format "Hello, ~A\n" person))
                    people)))
```
