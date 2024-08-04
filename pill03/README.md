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
