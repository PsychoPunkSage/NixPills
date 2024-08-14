## Overview:
* The `Nix language` is used to write expressions that produce derivations.
* The `nix-build` tool is used to build derivations from an expression

> **`IMPORTANT:`**
- In Nix, **everything is an expression**, there are **no statements**. This is common in functional languages.
- **Values** in Nix are **immutable**.

## Values Type:

> **Command Line tool**: `nix repl`<br>
> **EXIT Command Line tool**: `:q`<br>
> * This will spin up a simple command line tool to ply around
> * The **nix repl** syntax is slightly different to **Nix syntax** when it comes to **assigning variables**<br>

Nix supports basic arithmetic operations: `+`, `-`, `*` and `/`
```nix
nix-repl> 2+3
5

nix-repl> 2-3
-1

nix-repl> 2*3
6

nix-repl> 2/3
~/dev/nix-pills/2/3
```

> **What happend with Division?**<br>
> * Nix is not a general purpose language, it's a domain-specific language for writing packages.
> * Integer division isn't actually that useful when writing package expressions.
> * Nix parsed 6/3 as a relative path to the current directory.
> * To perform Division:
>   *  leave a space after the `/`.
>   *  Alternatively, you can use `builtins.div`.

```nix
nix-repl> 6/ 3
2

nix-repl> builtins.div 6 3
2
```

### Operations:

- Arithmetic: `+`, `-`, `*` and `/ `
- Booleans: `||`, `&&` and `!`
- Relational: `!=`, `==`, `<`, `>`, `<=`, `>=`

### Datatypes:

- Simple types:  `integer`, `floating point`, `string`, `path`, `boolean` and `null`
- Complex types: `lists`, `sets` and `functions`

### Facts:

- Nix is `strongly typed`, but it's `not statically typed`. That is, you *cannot mix strings and integers*, you must first do the conversion
- Expressions will be `parsed as paths` as long as there's a `slash` not followed by a `space`

## Identifier:

`dash (-)` is allowed in identifiers, since many packages use dash in their names.

```nix 
nix-repl> a-b
error: undefined variable 'a-b'
       at «string»:1:1:
            1| a-b
             | ^

nix-repl> a - b
error: undefined variable 'a'
       at «string»:1:1:
            1| a - b
             | ^
```

## Strings:

> Strings are enclosed by *double quotes* `(")`, or *two single quotes* `('')`

```nix
nix-repl> "foo"
"foo"

nix-repl> ''foo''
"foo"
```

interpolate whole Nix expressions inside strings
```nix
nix-repl> foo = "PPS is here"

nix-repl> "${foo}"
"PPS is here"

nix-repl> ''${foo}''
"PPS is here"

nix-repl> "$f oo"
"$foo"

nix-repl> $foo
error: syntax error, unexpected invalid token
       at «string»:1:1:
            1| $foo
             | ^

nix-repl> "${2+3}"
error:
       … while evaluating a path segment
         at «string»:1:2:
            1| "${2+3}"
             |  ^

       error: cannot coerce an integer to a string: 5
```

*  Cannot mix integers and strings. You need to explicitly include conversions.

**Escaping `"`:** (use `''`)

```nix
nix-repl> ''AP is " here''
"AP is \" here"

nix-repl> ''AP is " here"''
"AP is \" here\""
```

**Escaping `${...}`:**
```nix
nix-repl> "\${foo}"
"\${foo}"

nix-repl> ''foo ''${foo} foo''
"foo \${foo} foo"
```

## Lists:

> sequence of expressions delimited by space (not comma)

```nix
nix-repl> [true "1APPPS" 45 "${foo}" (5*45)]
[
  true
  "1APPPS"
  45
  "PPS is here"
  225
]
```
* Lists in Nix, are immutable. 
* Adding or removing elements from a list is possible, but will return a new list.

## Attribute Sets:
> It is an association between `string keys` and `Nix values`. Keys can only be strings. When writing attribute sets you can also use unquoted identifiers as keys

```nix
nix-repl> s = {faa = "${foo}"; tru = true; a-b = (2-4); num = "number";}

nix-repl> s
{
  a-b = -2;
  faa = "PPS is here";
  num = "number";
  tru = true;
}
```

access elements in the attribute set:

```nix
nix-repl> s.a-b
-2

nix-repl> s.faa
"PPS is here"

nix-repl> s.num
"number"

nix-repl> s.tru
true
```

**Recurssive Atrtibute sets:**
Inside an attribute set you cannot normally refer to elements of the same attribute set. To do so, use recursive attribute sets:
```nix
nix-repl> rec {a = "54"; b = a + " PPS is here";}
{
  a = "54";
  b = "54 PPS is here";
}
```

## If expressions:

> These are expressions, not statements.<br>
> You can't have only the `then` branch, you must specify also the `else` branch, because an expression must have a value in all cases.

```nix
nix-repl> a = 3

nix-repl> b = 4

nix-repl> if a > b then "3 > 4" else "4 > 3"
"4 > 3"
```

## Let expressions:

> * Used to define local variables for inner expressions.
> * First assign variables, then `in`, then an expression which can use the defined variables.
> * The value of the whole let expression will be the value of the expression after the in.

```nix
nix-repl> let a = "${foo}"; in a
"PPS is here"

nix-repl> let a = "${foo}"; b = "-${foo}--${foo}"; in a + b
"PPS is here-PPS is here--PPS is here"

nix-repl> let a = 3; in let b = 4; in a + b
7
```

With `let` you cannot assign twice to the same variable. However, you can shadow outer variables:
```nix
nix-repl> let a = 3; a = 8; in a
error: attribute 'a' already defined at «string»:1:5
       at «string»:1:12:
            1| let a = 3; a = 8; in a
             |            ^

nix-repl> let a = 3; in let a = 8; in a
8
```

cannot refer to variables in a let expression outside of it:
```nix
nix-repl> let a = (let c = 3; in c); in c
error: undefined variable 'c'
       at «string»:1:31:
            1| let a = (let c = 3; in c); in c
             |                               ^
```

Can refer to variables in the `let` expression when assigning variables, like with recursive attribute sets:
```nix
nix-repl> let a = 4; b = a + 5; in b
9
```

> **WARNING:** beware when you want to refer to a variable from the outer scope, but it's also defined in the current `let` expression. The same applies to recursive attribute sets.

## With Expressions:

> Its something like a more granular version of `using` from C++, or `from module import *` from Python

```nix
nix-repl> numadd = {a1 = 13; b1 = 23; c1 = 43;}

nix-repl> numadd.a1 + numadd.b1
36

nix-repl> numadd.a1 + numadd.b1 + numadd.c1
79

nix-repl> with numadd; a1 + b1 + c1
79

nix-repl> numadd = {a = 13; b = 23; c1 = 43;}

nix-repl> with numadd; a + b + c1
50
```

* [case 4] If a symbol exists in the `outer scope` and would also be introduced by the `with`, it will **not be shadowed**. (Here a == 3 and b == 4 and c1 == 43)

```nix
let a = 10; in with numadd; a+c
53
```

* Let has the capacity to Shadow the outer scope var (only within its scope).

## Laziness

> Nix evaluates expressions only when needed. This is a great feature when working with packages.

```nix
nix-repl> let a = builtins.div 4 0; b = 6; in b
6
```
* Since `a` is not needed, there's no error about division by zero, because the expression is not in need to be evaluated.
* That's why we can *have all the packages defined* on demand, yet have *access to specific packages* very quickly.