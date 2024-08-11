## Commonly used commands

> create NAR archives from store paths

```bash
nix-store --dump
nix-store --restore
```

> find derivation path of a package using filename.

```bash
nix-instantiate [filename: hello.nix]
```

> get the direct dependencies of a package

```bash
nix-store -q --references [derivation path]
```