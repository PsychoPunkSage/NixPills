# Generic Builder

>>  generalize the builder script, write a Nix expression for GNU hello world and create a wrapper around the derivation built-in function.

## Packaging GNU hello world

We packaged a `simple.c` file (previously), which was being compiled with a raw gcc call. That's not a good example of a project. Many use autotools, and since we're going to generalize our builder, it would be better to do it with the most used build system.
> `GNU hello world`, despite its name, is a simple yet complete project which uses autotools

`hello_builder.sh`
```bash
export PATH="$gnutar/bin:$gcc/bin:$gnumake/bin:$coreutils/bin:$gawk/bin:$gzip/bin:$gnugrep/bin:$gnused/bin:$bintools/bin"
tar -xzf $src
cd hello-2.12.1
./configure --prefix=$out
make
make install
```

`hello.nix`
```bash
let
  pkgs = import <nixpkgs> { };
in
derivation {
  name = "hello";
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./hello_builder.sh ];
  inherit (pkgs)
    gnutar
    gzip
    gnumake
    gcc
    coreutils
    gawk
    gnused
    gnugrep
    ;
  bintools = pkgs.binutils.bintools;
  src = ./hello-2.12.1.tar.gz;
  system = builtins.currentSystem;
}
```

> `nix-build hello.nix` and you can launch `result/bin/hello`

## Generic Builder

generic `builder.sh` for autotools projects:
```bash
set -e
unset PATH
for p in $buildInputs; do
    export PATH=$p/bin${PATH:+:}$PATH
done

tar -xf $src

for d in *; do
    if [ -d "$d" ]; then
        cd "$d"
        break
    fi
done

./configure --prefix=$out
make
make install
```

> * Exit the build on any error with `set -e`.
> * First `unset PATH`, because it's initially set to a non-existent path.
> * We'll see this below in detail, however for each path in `$buildInputs`, we append `bin` to `PATH`.
> * Unpack the source.
> * Find a directory where the source has been unpacked and cd into it.
> * Once we're set up, compile and install.

**Rewrite hello.nix**

```nix
let
  pkgs = import <nixpkgs> { };
in
derivation {
  name = "PPS_hello";
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./builder.sh ];
  buildInputs = with pkgs; [
    gnutar
    gzip
    gnumake
    gcc
    coreutils
    gawk
    gnused
    gnugrep
    binutils.bintools
  ];
  src = ./hello-2.12.1.tar.gz;
  system = builtins.currentSystem;
}
```

The buildInputs variable is a string with out paths separated by space, perfect for bash usage in a for loop.

```
nix-repl> :l <nixpkgs>
Added 22251 variables.

nix-repl> builtins.toString gcc
"/nix/store/62zpnw69ylcfhcpy1di8152zlzmbls91-gcc-wrapper-13.3.0"

nix-repl> builtins.toString [gcc bash]
"/nix/store/62zpnw69ylcfhcpy1di8152zlzmbls91-gcc-wrapper-13.3.0 /nix/store/i1x9sidnvhhbbha2zhgpxkhpysw6ajmr-bash-5.2p26"

nix-repl> builtins.toString [gcc bash binutils.bintools]
"/nix/store/62zpnw69ylcfhcpy1di8152zlzmbls91-gcc-wrapper-13.3.0 /nix/store/i1x9sidnvhhbbha2zhgpxkhpysw6ajmr-bash-5.2p26 /nix/store/qsx2xqqm0lp6d8hi86r4y0rz5v9m62wn-binutils-2.42"
```

## A more convenient derivation function

> * in the hello.nix expression we are specifying tools that are common to more projects; we don't want to pass them every time.
> * A natural approach would be to create a function that accepts an attribute set, similar to the one used by the derivation function, and merge it with another attribute set containing values common to many projects.

**autotools.nix**
```nix
pkgs: attr:
let
    defaultAttrs = {
        builder = "${pkgs.bash}/bin/bash";
        system = builtins.currentSystem;
        args = [./builder.sh];
        baseInuts = with pkgs; [
            gnutar
            gzip
            gnumake
            gcc
            coreutils
            gawk
            gnused
            gnugrep
            binutils.bintools
        ];
        buildInputs = [ ];
    };
in
derivation {defaultAttrs // attrs}
```

* This function accepts a parameter `pkgs`, then returns a function which accepts a parameter `attrs`.
* The `// operator` is an operator between two sets. The result is the union of the two sets. In case of conflicts between attribute names, the value on the right set is preferred.
* So we use `defaultAttrs` as base set, and add (or override) the attributes from `attrs`.

```nix
nix-repl> { a = "b"; } // { c = "d"; }
{
  a = "b";
  c = "d";
}

nix-repl> { a = "b"; } // { a = "d"; }
{ a = "d"; }
```

**Running Program**
```bash
nix-store -r /nix/store/797wlxrf70fdajsz6d8bmx54fkpkiand-PPS_hello.drv
```

<details>
<summary>
Output
</summary>

```
/nix/store/93vdrxwax2yvxz5i2zsbar1w68lk3cqz-PPS_hello
```

</details><br>

```bash
/nix/store/93vdrxwax2yvxz5i2zsbar1w68lk3cqz-PPS_hello/bin/hello
```

<details>
<summary>
Output
</summary>

```
Hello, world!
```

</details><br>

**Hello.nix rewrite:**
```nix
let
  pkgs = import <nixpkgs> { };
  mkDerivation = import ./autotools.nix pkgs;
in
mkDerivation {
  name = "PPS_hello";
  src = ./hello-2.12.1.tar.gz;
}
```

## Conclusion

* Nix gives us the bare metal tools for creating derivations, setting up a build environment and storing the result in the nix store.
* Nix system is all about creating and composing derivations with the Nix language.
* **Analogy:** in C you create objects in the heap, and then you compose them inside new objects. Pointers are used to refer to other objects.

* In Nix you create derivations stored in the nix store, and then you compose them by creating new derivations. Store paths are used to refer to other derivations.