# Automatic Runtime Dependencies:
>> Analyze build and runtime dependencies, and we enhance our builder to eliminate unnecessary runtime dependencies.

## Build dependencies:

<details>
<summary>
Given
</summary>

```
have the deivation of `hello.nix` from pill06
```

```
In my case;
drvPath := /nix/store/93vdrxwax2yvxz5i2zsbar1w68lk3cqz-PPS_hello
```

</details><br>

`nix-instantiate` is used to find the derivation path of nix package.<br>Lets analyze the build dependencies for our GNU `hello` package:
```bash
nix-instantiate hello.nix
```
<details>
<summary>
Output
</summary>

```
/nix/store/797wlxrf70fdajsz6d8bmx54fkpkiand-PPS_hello.drv
```

</details><br>

```bash
nix-store -q --references /nix/store/797wlxrf70fdajsz6d8bmx54fkpkiand-PPS_hello.drv
```
<details>
<summary>
Output
</summary>

```
/nix/store/wzh01sawfkrvg2srg4jl8zprz1a347gy-bash-5.2p26.drv
/nix/store/0m01ir3gfi9hmfg8d070g85zy5lsrr0k-gzip-1.13.drv
/nix/store/1bylj3i9hwpkqv43craxxsxscrq88dxb-gnugrep-3.11.drv
/nix/store/4nmbjqfgb6gcy4b7ky6fdxx38p88ldi2-gawk-5.2.2.drv
/nix/store/6wybplhw5xcdgw93jc23ij7bpy0yiz4w-gnutar-1.35.drv
/nix/store/9rwm5zhxx7bpxff9lddvms78shdipib2-coreutils-9.5.drv
/nix/store/andlgvwhg8c8f42ijg15zgcdqp7girgq-gcc-wrapper-13.3.0.drv
/nix/store/fimilhby9fyqbfwmw826id3hwfhya6qx-hello-2.12.1.tar.gz
/nix/store/h0vmv20ipiwv1jzwvidiabl5clbazk9p-binutils-2.42.drv
/nix/store/nwywcvg6vsfi9j6md714mm09my9j6mvm-gnumake-4.4.1.drv
/nix/store/ykidc3b0v6kcv6l3adfxw67bn49k9lf9-builder.sh
/nix/store/zn04d4a926y6qvgbm6w6dpwq2mxyaxa6-gnused-4.9.drv
```

</details><br>

* It has precisely the derivations referenced in the derivation function; nothing more, nothing less.
* We may not use some of them at all.
* However, given that our generic `mkDerivation` function always pulls such dependencies (think of it like `build-essential` from Debian), we will already have these packages in the nix store for any future packages that need them.

<details>
<summary>
Note
</summary>


`nix-store -q --references /nix/store/797wlxrf70fdajsz6d8bmx54fkpkiand-PPS_hello.drv`
```
lists all the derivations that depend on the specified derivation.
```
`nix-store -qR /nix/store/797wlxrf70fdajsz6d8bmx54fkpkiand-PPS_hello.drv `
```
recursively lists all derivations that depend on the specified derivation, including indirect dependencies.
```

</details><br>

## NAR files:

> The `NAR` format =>  `Nix ARchive`<br>
> * designed due to existing archive formats, such as tar, being insufficient<br>
> * **REASON:**<br>
>   * Nix benefits from deterministic build tools
>   * commonly used archivers lack this property, they: 
>       - add padding, 
>       - do not sort files, 
>       - add timestamps, and so on
>   * This can result in directories containing **bit-identical** files turning into **non-bit-identical** archives, which leads to different hashes.
> * Thus the `NAR` format was developed as a simple, deterministic archive format. `NAR`s are used extensively within Nix

To create NAR archives from store paths, we can use `nix-store --dump` and `nix-store --restore`.

> A NAR (Nix Archive) is like taking a snapshot of the final product of the build. It captures the entire output of the build process, whether it's a single file or a complex directory structure. This snapshot is then stored for later use.

## Run Dependencies:

* Nix handles runtime dependencies for us automatically.
* the NixOS operating system is built off of it. The underlying mechanism relies on the hash of the store paths
  * Dump the derivation as a NAR. By serializing the derivation output into a NAR, Nix ensures that the exact same result can be reproduced later, even if the build process or the system environment changes.
  * For each build dependency, `.drv` and its relative out path, search the contents of the NAR for this out path.
  * If the path is found, then it's a runtime dependency.

**Dependencies for packages:**
```nix
nix-instantiate hello.nix
```

```
/nix/store/797wlxrf70fdajsz6d8bmx54fkpkiand-PPS_hello.drv
```

```nix
nix-store -r /nix/store/797wlxrf70fdajsz6d8bmx54fkpkiand-PPS_hello.drv
```

```
/nix/store/93vdrxwax2yvxz5i2zsbar1w68lk3cqz-PPS_hello
```

```nix
nix-store -q --references /nix/store/93vdrxwax2yvxz5i2zsbar1w68lk3cqz-PPS_hello
```

```
/nix/store/0wydilnf1c9vznywsvxqnaing4wraaxp-glibc-2.39-52
/nix/store/1vp54ln0frvhzgasr2a377mfbwvqdm6i-glibc-2.39-52-dev
/nix/store/kgmfgzb90h658xg0i7mxh9wgyx0nrqac-gcc-13.3.0-lib
/nix/store/zw4dkm2hl72kfz7j2ci4qbc0avgxzz75-gcc-13.3.0
/nix/store/93vdrxwax2yvxz5i2zsbar1w68lk3cqz-PPS_hello
```

* `gcc` shouldn't be in this list!
* It is present because of [ld rpath](http://en.wikipedia.org/wiki/Rpath):the list of directories where libraries can be found at runtime
* In Nix, we have to refer to particular versions of libraries, and thus the rpath has an important role

* The build process adds the `gcc` lib path thinking it may be useful at runtime, but this isn't necessary. To address issues like these, Nix provides a tool called **`patchelf`**, which reduces the rpath to the paths that are actually used by the binary.

<details>
<summary>
ld rpath
</summary>

`ld` is a linker, a program that combines object files and libraries into an executable file.

`rpath` is a linker option that specifies a set of directories to search for shared libraries when running the executable. It helps the operating system find the necessary libraries to execute the program correctly.

**In simpler terms:**

`ld` is the builder of a program, and `rpath` is the address book it uses to find the program's libraries when it runs.

</details><br>

## Phases in the builder:

The builder has six phases:
1. The **environment setup** phase
2. The **unpack phase**: we unpack the sources in the current directory (remember, Nix changes to a temporary directory first)
3. The **change directory** phase, where we change source root to the directory that has been unpacked
4. The **configure** phase: `./configure`
5. The **build** phase: `make`
6. The **install** phase: `make install`

Now we will add a new phase after the installation phase, which we call the "fixup" phase. 

At the end of the `builder.sh`, we append:
```sh
find $out -type f -exec patchelf --shrink-rpath '{}' \; -exec strip '{}' \; 2>/dev/null
```

* for each file we `run patchelf --shrink-rpath` and `strip`
* Add `findutils` and `patchelf` to the baseInputs of autotools.nix

```nix
nix-repl> [patchelf findutils]
[
  «derivation /nix/store/7cfixbv0nijhn36f95wmhr6b9a4l53az-patchelf-0.15.0.drv»
  «derivation /nix/store/4finnyc5dy4ibjjlp6ihwq7rrwb7hv1q-findutils-4.10.0.drv»
]
```

Here is the final result after the build

```sh
nix-build hello.nix
```
<details>
<summary>
Output
</summary>

```
this derivation will be built:
  /nix/store/hifbqmp41jkb6m233zycmnxb49na5yjs-PPS_hello_trimmed.drv

  ...........

/nix/store/92g1yv9y8d41wpjc09d7qi7qmfxh6pwa-PPS_hello_trimmed
```

</details>

```sh
nix-store -r /nix/store/92g1yv9y8d41wpjc09d7qi7qmfxh6pwa-PPS_hello_trimmed/bin/hello
```

<details>
<summary>
Output
</summary>

```
Hello, world!
```

</details>

```sh
nix-store -q --references /nix/store/92g1yv9y8d41wpjc09d7qi7qmfxh6pwa-PPS_hello_trimmed
```

<details>
<summary>
Output
</summary>

```
/nix/store/0wydilnf1c9vznywsvxqnaing4wraaxp-glibc-2.39-52
/nix/store/92g1yv9y8d41wpjc09d7qi7qmfxh6pwa-PPS_hello_trimmed
```

</details>

```sh
strings result/bin/hello| grep gcc
# Gives no Output
```