## Installing Something:


> **Hello:** a simple CLI tool which prints "Hello world" and is mainly used to test compilers and package installations.

```bash
nix-env -i hello
```
**Location**: `~/.nix-profile/bin/hello` ($ which hello)
**Derivation Path**: `hello-2.12.1  /nix/store/4prjbnvjp40kkqjds62ywy9sr94j9g4b-hello-2.12.1` ($ nix-env -q --out-path)

> **Listing of generations:** lists all the generations of a particular package installed on your system using Nix.
```bash
nix-env --list-generations
```

```
   1   2024-08-02 21:18:17
   2   2024-08-02 21:21:02
   3   2024-08-03 11:06:32   (current)
```

A `generation` in Nix refers to a specific version of a package. When you install a package, Nix creates a new generation, which is essentially a snapshot of the package and its dependencies at that particular point in time. This allows you to easily revert to previous versions if needed.

> Listing installed derivations:
```bash
nix-env -q
```