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
  name = "hello";
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