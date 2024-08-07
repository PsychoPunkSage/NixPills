## Using a script as a builder

> We write a custom bash script, and we want it to be our builder. Given a `builder.sh`, we want the derivation to run `bash builder.sh`.

* We don't use **hash bangs** in builder.sh, because at the time we are writing it we do not know the path to bash in the nix store.
* We don't even use `/usr/bin/env`, because then we lose the cool stateless property of Nix. Not to mention that `PATH` gets cleared when building, so it wouldn't find bash anyway.

<details>
<summary>
Nix Statelssness
</summary>

```
Statelessness: Nix aims for complete reproducibility. Using /usr/bin/env relies on the system's environment, which can vary between systems. This breaks Nix's stateless principle.
```

```
Build Environment Isolation: Nix clears the PATH variable during builds to ensure a clean environment. Using /usr/bin/env would depend on the system's PATH, which doesn't exist in this isolated context.
```

</details><br>

First of all, let's write our [builder.sh](https://github.com/PsychoPunkSage/NixPills/tree/main/pill05/builder.sh)

**Refering bash (just like `coreutils`)**

```nix
nix-repl> :l <nixpkgs>
Added 22251 variables.

nix-repl> "${bash}"
"/nix/store/i1x9sidnvhhbbha2zhgpxkhpysw6ajmr-bash-5.2p26"
```

**Lets build the derivation**:
```nix
nix-repl> drv = derivation { name = "PPS_workable"; builder = "${bash}/bin/bash"; args = [ ./builder.sh ]; system = builtins.currentSystem; }

nix-repl> drv
«derivation /nix/store/n5isf7xs3w609chwq78nbphf22ln61ln-PPS_workable.drv»

nix-repl> :b drv

This derivation produced the following outputs:
  out -> /nix/store/i2j3gjdxhch7amlac04swlyr9amd66d5-PPS_workable
[1 built, 0 copied (1 failed), 0.0 MiB DL]
```

*  we used `./builder.sh` and not `"./builder.sh"`.

<details>
<summary>
PPS_workable Drv analysis
</summary>

```bash
nix derivation show  /nix/store/i2j3gjdxhch7amlac04swlyr9amd66d5-PPS_workable
```

```json
{
  "/nix/store/n5isf7xs3w609chwq78nbphf22ln61ln-PPS_workable.drv": {
    "args": [
      "/nix/store/d31gnn9z8nbh800fq1b1jmaq95135607-builder.sh"
    ],
    "builder": "/nix/store/i1x9sidnvhhbbha2zhgpxkhpysw6ajmr-bash-5.2p26/bin/bash",
    "env": {
      "builder": "/nix/store/i1x9sidnvhhbbha2zhgpxkhpysw6ajmr-bash-5.2p26/bin/bash",
      "name": "PPS_workable",
      "out": "/nix/store/i2j3gjdxhch7amlac04swlyr9amd66d5-PPS_workable",
      "system": "x86_64-linux"
    },
    "inputDrvs": {
      "/nix/store/wzh01sawfkrvg2srg4jl8zprz1a347gy-bash-5.2p26.drv": {
        "dynamicOutputs": {},
        "outputs": [
          "out"
        ]
      }
    },
    "inputSrcs": [
      "/nix/store/d31gnn9z8nbh800fq1b1jmaq95135607-builder.sh"
    ],
    "name": "PPS_workable",
    "outputs": {
      "out": {
        "path": "/nix/store/i2j3gjdxhch7amlac04swlyr9amd66d5-PPS_workable"
      }
    },
    "system": "x86_64-linux"
  }
}
```

</details><br>

## The builder environment

> We can use `nix-store --read-log` to see the logs our builder produced

```bash
nix-store --read-log /nix/store/i2j3gjdxhch7amlac04swlyr9amd66d5-PPS_workable
```

<details>
<summary>
Output
</summary>

```json
declare -x HOME="/homeless-shelter"
declare -x NIX_BUILD_CORES="12"
declare -x NIX_BUILD_TOP="/build"
declare -x NIX_LOG_FD="2"
declare -x NIX_STORE="/nix/store"
declare -x OLDPWD
declare -x PATH="/path-not-set"
declare -x PWD="/build"
declare -x SHLVL="1"
declare -x TEMP="/build"
declare -x TEMPDIR="/build"
declare -x TERM="xterm-256color"
declare -x TMP="/build"
declare -x TMPDIR="/build"
declare -x builder="/nix/store/i1x9sidnvhhbbha2zhgpxkhpysw6ajmr-bash-5.2p26/bin/bash"
declare -x name="PPS_workable"
declare -x out="/nix/store/i2j3gjdxhch7amlac04swlyr9amd66d5-PPS_workable"
declare -x system="x86_64-linux"
```

</details><br>

Inspection of **Output**:
* `$HOME` is not your home directory, and `/homeless-shelter` doesn't exist at all. We force packages not to depend on `$HOME` during the build process.
* `$PATH` plays the same game as `$HOME`
* `$NIX_BUILD_CORES` and `$NIX_STORE` are nix configuration options ([more](https://nixos.org/manual/nix/stable/command-ref/conf-file))
* `$PWD` and `$TMP` clearly show that nix created a temporary build directory
* Then `$builder`, `$name`, `$out`, and `$system` are variables set due to the .drv file's contents.

And that's how we were able to use `$out`(in `builder.sh`) in our derivation and put stuff in it. It's like Nix reserved a slot in the nix store for us, and we must fill it.

In terms of **autotools**, `$out` will be the `--prefix` path. Yes, not the make `DESTDIR`, but the `--prefix`. That's the essence of stateless packaging. You don't install the package in a global common path under `/`, you install it in a local isolated path under your nix store slot.


<details>
<summary>
More Info
</summary>

```
$out: 
This represents the final location where your package's files will be installed. It's like a specific folder where all the files related to your package will be placed. This folder is isolated from your system's regular file structure.
```

```
--prefix: 
This is a common flag used in many build systems (like autotools) to specify the installation prefix. It's where the built files will be copied.
```

```
Nix vs Autotools: 
Unlike autotools, Nix doesn't use --prefix to install files to a global location (like /usr/local). Instead, it uses $out to install everything within a specific, isolated directory.
```

</details><br>

## The .drv contents

We added something else to the derivation this time: the `args attribute`.
* Nix automatically copies files or directories needed for the build into the store to ensure that they are not changed during the build process and that the deployment is stateless and independent of the building machine.
* `builder.sh` is not only in the arguments passed to the builder, it's also in the input sources.
* Given that `builder.sh` is a plain file, it has no .drv associated with it. The store path is computed based on the filename and on the hash of its contents.

## Packaging simple C program:

`simple.c`
```c
void main() {
    puts("Simple!");
}
```

`simple)_builder.sh`
```bash
export PATH="$coreutils/bin:$gcc/bin"
mkdir $out
gcc -o $out/simple $src
```

**let's write the derivation and build it:**

```nix
nix-repl> simple = derivation { name = "simple"; builder = "${bash}/bin/bash"; args = [ ./simple_builder.sh ]; gcc = gcc; coreutils = coreutils; src = ./simple.c; system = builtins.currentSystem; }

nix-repl> :b simple

This derivation produced the following outputs:
  out -> /nix/store/pgd7km0f11yilp2zhkz7zq2wb1jgs2fl-simple
[2 built, 14 copied (2 failed) (268.5 MiB), 58.4 MiB DL]
```

**Analysis**
<details>
<summary>
Simple derivation
</summary>

```bash
nix derivation show /nix/store/d57y171v8i1f76dyymppwaypfzcxscfq-simple.drv
```

```json
{
  "/nix/store/d57y171v8i1f76dyymppwaypfzcxscfq-simple.drv": {
    "args": [
      "/nix/store/4wpv68jkvw9nbnh4qcblnfvdfnn74kbn-simple_builder.sh"
    ],
    "builder": "/nix/store/i1x9sidnvhhbbha2zhgpxkhpysw6ajmr-bash-5.2p26/bin/bash",
    "env": {
      "builder": "/nix/store/i1x9sidnvhhbbha2zhgpxkhpysw6ajmr-bash-5.2p26/bin/bash",
      "coreutils": "/nix/store/cnknp3yxfibxjhila0sjd1v3yglqssng-coreutils-9.5",
      "gcc": "/nix/store/62zpnw69ylcfhcpy1di8152zlzmbls91-gcc-wrapper-13.3.0",
      "name": "simple",
      "out": "/nix/store/pgd7km0f11yilp2zhkz7zq2wb1jgs2fl-simple",
      "src": "/nix/store/xxkcmj6vagqbfly000sh0cdcp154nwz9-simple.c",
      "system": "x86_64-linux"
    },
    "inputDrvs": {
      "/nix/store/9rwm5zhxx7bpxff9lddvms78shdipib2-coreutils-9.5.drv": {
        "dynamicOutputs": {},
        "outputs": [
          "out"
        ]
      },
      "/nix/store/andlgvwhg8c8f42ijg15zgcdqp7girgq-gcc-wrapper-13.3.0.drv": {
        "dynamicOutputs": {},
        "outputs": [
          "out"
        ]
      },
      "/nix/store/wzh01sawfkrvg2srg4jl8zprz1a347gy-bash-5.2p26.drv": {
        "dynamicOutputs": {},
        "outputs": [
          "out"
        ]
      }
    },
    "inputSrcs": [
      "/nix/store/4wpv68jkvw9nbnh4qcblnfvdfnn74kbn-simple_builder.sh",
      "/nix/store/xxkcmj6vagqbfly000sh0cdcp154nwz9-simple.c"
    ],
    "name": "simple",
    "outputs": {
      "out": {
        "path": "/nix/store/pgd7km0f11yilp2zhkz7zq2wb1jgs2fl-simple"
      }
    },
    "system": "x86_64-linux"
  }
}
```

</details><br>

**Running the program:**
```bash
/nix/store/pgd7km0f11yilp2zhkz7zq2wb1jgs2fl-simple/simple
```

```
Simple!
```

## Explanation

- 2 new `attributes` added, `gcc` and `coreutils`
  - `gcc = gcc`;, the name on the left is the name in the derivation set, and the name on the **right** refers to the **gcc derivation from nixpkgs**. The same applies for `coreutils`.
- `src` attribute, nothing odd --- it's just a name, to which the path `./simple.c` is assigned. Like `simple-builder.sh`, `simple.c` will be added to the store.

- **IMP:** every attribute in the set passed to `derivation` will be converted to a *string* and passed to the builder as an environment variable. This is how the builder gains access to coreutils and gcc: when converted to strings, the derivations evaluate to their output paths, and appending /bin to these leads us to their binaries.

- The same goes for the `src` variable. `$src` is the path to simple.c in the nix store.
- In `simple_builder.sh` we set the `PATH` for *gcc* and *coreutils* binaries, so that our build script can find the necessary utilities like mkdir and gcc.

## Proper Nix package

`simple.nix`
```nix
let
  pkgs = import <nixpkgs> { };
in
derivation {
  name = "simple";
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./simple_builder.sh ];
  gcc = pkgs.gcc;
  coreutils = pkgs.coreutils;
  src = ./simple.c;
  system = builtins.currentSystem;
}
```
> build it with `nix-build simple.nix`. This will create a symlink **result** in the current directory, pointing to the out path of the derivation.


nix-build does *two jobs*:
* **nix-instantiate** : parse and evaluate `simple.nix` and return the .drv file corresponding to the parsed derivation set
* **nix-store -r** : `realise the .drv file`, which actually builds it.

* In the second line of `simple.nix`, we have an import function call. **import** accepts one argument, a nix file to load.
* Afterwards, we call the function with the empty set. 

* The value returned by the nixpkgs function is a set; more specifically, it's a set of derivations. Calling `import <nixpkgs> {}` into a let-expression creates the local variable pkgs and brings it into scope.
* ~ `:l <nixpkgs>` we used in nix repl

**inherit keyword**
* `inherit foo`; is equivalent to foo = foo;.
* `inherit gcc coreutils`; is equivalent to gcc = gcc; coreutils = coreutils;.
* `inherit (pkgs) gcc coreutils`; is equivalent to gcc = pkgs.gcc; coreutils = pkgs.coreutils;.