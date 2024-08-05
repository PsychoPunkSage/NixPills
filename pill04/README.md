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

## Digression about .drv files

>> It is the specification of how to build the derivation

**Analogy with C:**
* `.nix` files ~ `.c` files.
* `.drv` files are intermediate files like `.o` files. The `.drv` describes how to build a derivation; it's the bare minimum information.
* out paths are then the product of the build.

**Content of `.drv` file:**

```bash
$ nix derivation show /nix/store/slk7f6m75xcygkxpbbvwjxrgijm7n8if-PPS.drv
```

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

## Derivation set

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