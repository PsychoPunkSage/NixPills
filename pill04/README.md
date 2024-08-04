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
nix-repl> drv = derivation {name = "PPS"; builder = "PPS_builder"; system =
"PPS_system";}

nix-repl> drv
«derivation /nix/store/slk7f6m75xcygkxpbbvwjxrgijm7n8if-PPS.drv»
```
* `nix repl` does not build derivations unless you tell it to do so.
* it didn't build derivation, but it did **create the .drv file**.