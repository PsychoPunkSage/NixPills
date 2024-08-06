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

<details><br>

## The builder environment

