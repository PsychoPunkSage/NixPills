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

**Build Fake Derivation:**