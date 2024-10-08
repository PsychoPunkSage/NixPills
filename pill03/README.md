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

## Default and variadic attributes:

> We can specify `default values` of attributes in the argument set
```nix
nix-repl> mul = {a, b ? 3}: a*b

nix-repl> mul
«lambda @ «string»:1:2»

nix-repl> mul {a = 12;}
36

nix-repl> mul {a = 12; b = 4;}
48
```

> We can allow passing more attributes (`variadic`) than the expected ones
```nix
nix-repl> mul = {a,b,...}: a*b

nix-repl> mul {a = 2; b = 3; c = 4;}
6
```

> In the above function body you cannot access the "c" attribute. The solution is to give a name to the given set with the `@-pattern`
```nix
nix-repl> mul = set@{a,b,...}:a*b*set.c

nix-repl> mul
«lambda @ «string»:1:2»

nix-repl> mul {a = 2; b = 3; c = 4;}
24

nix-repl> mul {a = 2; b = 3;}
error:
       … while calling the 'mul' builtin
         at «string»:1:19:
            1|  set@{a,b,...}:a*b*set.c
             |                   ^

       error: attribute 'c' missing
       at «string»:1:20:
            1|  set@{a,b,...}:a*b*set.c
             |                    ^
       Did you mean one of a or b?
```

- Advantages of using argument sets:
  - Named unordered arguments: don't have to remember the order of the arguments.
  - Can pass sets, that adds a new layer of flexibility and convenience.
- Disadvantages:
  - Partial application does not work with argument sets. You have to specify the whole attribute set, not part of it.
You may find similarities with **Python **kwargs**.

## Imports:

>> The `import` function is built-in and provides a way to parse a `.nix` file. The natural approach is to define each component in a `.nix` file, then compose by importing these files.

```
Define below files:
    1. a.nix
        4
    2. b.nix
        32
    3. mul.nix
        a: b: a*a + b*b
```

```nix
nix-repl> a = import ./pill03/a.nix

nix-repl> b = import ./pill03/b.nix

nix-repl> a
4

nix-repl> b
32

nix-repl> mul = import ./pill03/mul.nix

nix-repl> mul
«lambda @ /home/psychopunk_sage/dev/nix-pills/pill03/mul.nix:1:1»

nix-repl> mul a b
1040
```

**complex example**:
```nix
nix-repl> test = import ./pill03/test.nix

nix-repl> test
«lambda @ /home/psychopunk_sage/dev/nix-pills/pill03/test.nix:1:1»

nix-repl> test {a = 4; truMsg = "Ok"; flsMsg = "Wrong";}
trace: Wrong
false

nix-repl> test {a = 100; truMsg = "Ok"; flsMsg = "Wrong";}
trace: Ok
true
```

**Explanation**:
* `test.nix`: returns a function. It accepts a set, with default attributes `b`, `trueMsg` and `falseMsg`.
* `builtins.trace` is a built-in function that takes *two arguments*. The **first** is the **message to display**, the **second** is the **value to return**.
* Then we import `test.nix`, and call the function.