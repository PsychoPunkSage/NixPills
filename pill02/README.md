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