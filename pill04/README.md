## The Derivation function:

>> A derivation from a Nix language view point is simply a `set`, with some `attributes`. Therefore you can pass the derivation around with variables like anything else.

The `derivation` function receives a set as its first argument. This set requires at least the following three attributes:
* **name**: the `name of the derivation`. In the nix store the format is **hash-name**, that's the name.
* **system**: is the `name of the system` in which the derivation can be built. For example, x86_64-linux.
* **builder**: is the `binary program` that builds the derivation.

Check your System name
```nix
nix-repl> builtins.currentSystem
"x86_64-linux"
```

Faking derivation build:
```nix
nix-repl> drv = derivation {name = "PPS"; builder = "PPS_builder"; system = "PPS_system";}

nix-repl> drv
«derivation /nix/store/slk7f6m75xcygkxpbbvwjxrgijm7n8if-PPS.drv»
```
* `nix repl` does not build derivations unless you tell it to do so.
* it didn't build derivation, but it did **create the .drv file**.

## Digression about .drv files:

>> It is the specification of how to build the derivation

**Analogy with C:**
* `.nix` files ~ `.c` files.
* `.drv` files are intermediate files like `.o` files. The `.drv` describes how to build a derivation; it's the bare minimum information.
* out paths are then the product of the build.

**Content of `.drv` file:**

```bash
$ nix derivation show /nix/store/slk7f6m75xcygkxpbbvwjxrgijm7n8if-PPS.drv
```

<details>
<summary>
Output
</summary>

```json
{
  "/nix/store/slk7f6m75xcygkxpbbvwjxrgijm7n8if-PPS.drv": {
    "args": [],
    "builder": "PPS_builder",
    "env": {
      "builder": "PPS_builder",
      "name": "PPS",
      "out": "/nix/store/ffcqjrgix8v9zzg89xp7lqmjd11hwhrm-PPS",
      "system": "PPS_system"
    },
    "inputDrvs": {},
    "inputSrcs": [],
    "name": "PPS",
    "outputs": {
      "out": {
        "path": "/nix/store/ffcqjrgix8v9zzg89xp7lqmjd11hwhrm-PPS"
      }
    },
    "system": "PPS_system"
  }
}
```

</details><br>

**Theory:**
* We can see there's an out path, but it does not exist yet. We never told Nix to build it, but we know beforehand where the build output will be. 
* Nix ever built the big derivation just because we accessed it in Nix, we would have to wait a long time.
* The hash of the out path is based solely on the input derivations in the current version of Nix, not on the contents of the build product.

Summary of the `.drv` format:
* There can be multiple `output paths`. By default nix creates output path i.e. `out`.
* (here) The list of input derivations is empty because we are not referring to any other derivation. Otherwise, there would be a list of other `.drv` files.
* Then a list of environment variables passed to the builder.

This it the minimum necessary information to build our derivation.

> **IMPORTANT**:<br>
> * The `builder` will not inherit any variable from the running shell, otherwise builds would suffer from non-determinism.
> * So the `Environment variables` are passed to the builder (those you see in the .drv) along with some other Nix related configuration (number of cores, temp dir, ...).

<details>
<summary>
    Non-determinism
</summary>

```
- build process would produce different results depending on factors outside the defined build environment.
```
```
- if the builder inherited variables from your running shell, the build could produce different results on different machines or at different times, even with the same code and inputs. This is because shell environments can vary between systems and over time.
```
```
- isolating the build environment and using only the defined variables in the .drv file, Nix ensures reproducible and deterministic builds.
```

</details><br>

**Build Fake Derivation:**

1. With `nix repl`
```nix
nix-repl> drv = derivation {name = "PPS"; builder = "PPS_builder"; system = "PPS_system";}

nix-repl> drv
«derivation /nix/store/slk7f6m75xcygkxpbbvwjxrgijm7n8if-PPS.drv»

nix-repl> :b drv
error: a 'PPS_system' with features {} is required to build '/nix/store/slk7f6m75xcygkxpbbvwjxrgijm7n8if-PPS.drv', but I am a 'x86_64-linux' with features {benchmark, big-parallel, kvm, nixos-test, uid-range}
[0 copied (1 failed), 0.0 MiB DL]
```

* The `:b` is a `nix repl` specific command to build a derivation.

2. With `nix-store`

```bash
nix-store -r /nix/store/slk7f6m75xcygkxpbbvwjxrgijm7n8if-PPS.drv
```

```
this derivation will be built:
  /nix/store/slk7f6m75xcygkxpbbvwjxrgijm7n8if-PPS.drv
error: a 'PPS_system' with features {} is required to build '/nix/store/slk7f6m75xcygkxpbbvwjxrgijm7n8if-PPS.drv', but I am a 'x86_64-linux' with features {benchmark, big-parallel, kvm, nixos-test, uid-range}
```

## Derivation set:

**Check for Attributes:**
```nix
nix-repl> drv = derivation {name = "PPS"; builder = "PPS_builder"; system = "PPS_system";}

nix-repl> builtins.isAttrs drv
true

nix-repl> builtins.attrNames drv
[
  "all"
  "builder"
  "drvAttrs"
  "drvPath"
  "name"
  "out"
  "outPath"
  "outputName"
  "system"
  "type"
]
```

* `builtins.isAttrs`: returns true if the argument is a set. 
* `builtins.attrNames`: returns a list of keys of the given set.

**drvAttrs:**
```nix
nix-repl> drv.drvAttrs
{
  builder = "PPS_builder";
  name = "PPS";
  system = "PPS_system";
}

nix-repl> drv.name
"PPS"

nix-repl> drv.builder
"PPS_builder"

nix-repl> drv.system
"PPS_system"

nix-repl> drv == drv.out
true

nix-repl> drv.all
[
  «derivation /nix/store/slk7f6m75xcygkxpbbvwjxrgijm7n8if-PPS.drv»
]
```

* `out` is just the derivation itself. (*reason*: we only have one output from the derivation.)
* That's also the reason why `d.all` is a singleton

**drvPath:** path of the `.drv` file
```nix
nix-repl> drv.drvPath
"/nix/store/slk7f6m75xcygkxpbbvwjxrgijm7n8if-PPS.drv"
```

## Referring Other derivations:

> We use the `outPath`. The `outPath` describes the location of the files of a derivation. To make it more convenient, Nix is able to do a conversion from a derivation set to a string.

```nix
nix-repl> drv.outPath
"/nix/store/ffcqjrgix8v9zzg89xp7lqmjd11hwhrm-PPS"

nix-repl> builtins.toString drv
"/nix/store/ffcqjrgix8v9zzg89xp7lqmjd11hwhrm-PPS"
```

* Nix does the **set to string conversion** as long as there is the `outPath` attribute

```nix
nix-repl> d = {outPath = "Yooo";}

nix-repl> builtins.toString d
"Yooo"

nix-repl> builtins.toString {a = "Yooo";}
error:
       … while calling the 'toString' builtin
         at «string»:1:1:
            1| builtins.toString {a = "Yooo";}
             | ^

       … while evaluating the first argument passed to builtins.toString

       error: cannot coerce a set to a string: { a = "Yooo"; }
```

**Using Binaries from coreutils**

```nix
nix-repl> coreutils
error: undefined variable 'coreutils'
       at «string»:1:1:
            1| coreutils
             | ^

nix-repl> :l <nixpkgs>
Added 22251 variables.

nix-repl> coreutils
«derivation /nix/store/9rwm5zhxx7bpxff9lddvms78shdipib2-coreutils-9.5.drv»

nix-repl> coreutils.outPath
"/nix/store/cnknp3yxfibxjhila0sjd1v3yglqssng-coreutils-9.5"

nix-repl> "${coreutils}/bin/true"
"/nix/store/cnknp3yxfibxjhila0sjd1v3yglqssng-coreutils-9.5/bin/true"
```

## An almost working derivation:

```nix
nix-repl> realDrv = derivation {name = "PPS_V1"; system = builtins.currentSystem; builder = "${coreutils}/bin/true";}

nix-repl> realDrv.drvAttrs
{
  builder = "/nix/store/cnknp3yxfibxjhila0sjd1v3yglqssng-coreutils-9.5/bin/true";
  name = "PPS_V1";
  system = "x86_64-linux";
}

nix-repl> :b realDrv
error: builder for '/nix/store/khzqfjq6hpfvf84cjqblrb5c7vwg51r0-PPS_V1.drv' failed to produce output path for output 'out' at '/nix/store/khzqfjq6hpfvf84cjqblrb5c7vwg51r0-PPS_V1.drv.chroot/root/nix/store/68d7f2xrsy22wy0jzzxn85ws1zyy6g1d-PPS_V1'
[0 built (1 failed), 4 copied (1 failed) (2.3 MiB), 0.8 MiB DL]
```
* **Obvious note**: every time we change the derivation, a new hash is created.

**Examine .drv file**
```bash
nix derivation show /nix/store/khzqfjq6hpfvf84cjqblrb5c7vwg51r0-PPS_V1.drv
```

<details>
<summary>
Output
</summary>

```json
warning: The interpretation of store paths arguments ending in `.drv` recently changed. If this command is now failing try again with '/nix/store/khzqfjq6hpfvf84cjqblrb5c7vwg51r0-PPS_V1.drv^*'
{
  "/nix/store/khzqfjq6hpfvf84cjqblrb5c7vwg51r0-PPS_V1.drv": {
    "args": [],
    "builder": "/nix/store/cnknp3yxfibxjhila0sjd1v3yglqssng-coreutils-9.5/bin/true",
    "env": {
      "builder": "/nix/store/cnknp3yxfibxjhila0sjd1v3yglqssng-coreutils-9.5/bin/true",
      "name": "PPS_V1",
      "out": "/nix/store/68d7f2xrsy22wy0jzzxn85ws1zyy6g1d-PPS_V1",
      "system": "x86_64-linux"
    },
    "inputDrvs": {
      "/nix/store/9rwm5zhxx7bpxff9lddvms78shdipib2-coreutils-9.5.drv": {
        "dynamicOutputs": {},
        "outputs": [
          "out"
        ]
      }
    },
    "inputSrcs": [],
    "name": "PPS_V1",
    "outputs": {
      "out": {
        "path": "/nix/store/68d7f2xrsy22wy0jzzxn85ws1zyy6g1d-PPS_V1"
      }
    },
    "system": "x86_64-linux"
  }
}
```

</details><br>

* Nix added a dependency to our `.drv`, it's the `coreutils.drv`. 
* Before doing our build, Nix should build the `coreutils.drv`. Since coreutils is already in our nix store, no build is needed
* out path (coreutils): `/nix/store/cnknp3yxfibxjhila0sjd1v3yglqssng-coreutils-9.5`

## When is the derivation built:

> Nix does not build derivations **during evaluation** of Nix expressions. So, we have to do `:b drv` in `nix repl`, or use `nix-store -r`.
>   * **Instantiate/Evaluation time**: Nix expression is parsed, interpreted and finally returns a derivation set. During evaluation, you can refer to other derivations because Nix will create .drv files and we will know out paths beforehand.
>   * **Realise/Build time**: the .drv from the derivation set is built, first building .drv inputs (build dependencies). This is achieved with `nix-store -r`.

* Think of it as of compile time and link time like with C/C++ projects. You first compile all source files to object files. Then link object files in a single executable.
* In Nix, first the Nix expression (usually in a .nix file) is compiled to .drv, then each .drv is built and the product is installed in the relative out paths.