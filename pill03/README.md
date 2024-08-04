## Nameless and Single Parameter:

> Functions are anonymous (lambdas), and only have a single parameter<br>
> Type the parameter name, then ":", then the body of the function.

```nix
nix-repl> x : x*x
«lambda @ «string»:1:1»
```

We can store functions in variables.

```nix
nix-repl> dbl = x: x*x

nix-repl> dbl
«lambda @ «string»:1:2»

nix-repl> dbl 4
16
```

> **IMPORTANT**: to call a function, name the variable, `then space`, then the argument. Nothing else to say, it's as easy as that.

## More than One Parameter:

> Take a `Deep Breath`, this may take a while to grasp

```nix
nix-repl> tmul = a: (b: a*b)

nix-repl> tmul
«lambda @ «string»:1:2»

nix-repl> tmul 42
«lambda @ «string»:1:6»

nix-repl> (tmul 42) 8
336

nix-repl> tmul 42 8
336
```
> **NOTE**: We defined a function that takes the parameter `a`, the body **returns** `another function`. This other function takes a parameter `b` and returns `a*b`

> `parentheses` can be ignored.

```nix
nix-repl> tmul = a: b: a*b

nix-repl> tmul
«lambda @ «string»:1:2»

nix-repl> tmul 32
«lambda @ «string»:1:5»

nix-repl> tmul 32 23
736
```

## Argument Set:

> It is possible to pattern match over a set in the parameter.

using a *set as argument*:
```nix
nix-repl> tmul = set: set.x * set.y

nix-repl> tmul
«lambda @ «string»:1:2»

nix-repl> tmul {x = 12; y = 10;}
120
```

using *pattern matching*:
```nix
nix-repl> tmul = {a, b}: a*b

nix-repl> tmul
«lambda @ «string»:1:2»

nix-repl> tmul {x = 12; y = 10;}
error:
       … from call site
         at «string»:1:1:
            1| tmul {x = 12; y = 10;}
             | ^

       error: function 'anonymous lambda' called without required argument 'a'
       at «string»:1:2:
            1|  {a, b}: a*b
             |  ^

nix-repl> tmul {a = 12; b = 10;}
120
```
* Only a set with exactly the attributes required by the function is accepted, nothing more, nothing less. (NOT even different name)