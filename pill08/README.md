# Nix-shell

> The `nix-shell` tool provide us in a shell after setting up the environment variables necessary to hack on a derivation. It **does not build the derivation**; it only serves as a preparation so that we can run the build steps manually.<br>
>  In a nix environment, we don't have access to libraries or programs unless they have been installed with `nix-env`. Installing libraries with `nix-env` is not good practice. We prefer to have isolated environments for development, which nix-shell provides for us.

```sh
$ nix-shell hello.nix
```
<details>
<summary>
Output
</summary>

```
these 2 paths will be fetched (1.22 MiB download, 7.35 MiB unpacked):
  /nix/store/c481fhrvslr8nmhhlzdab3k7bpnhb46a-bash-interactive-5.**2p26**
  /nix/store/pblnj1749yp6wz28spkg0p774v0asfp0-readline-8.2p10
copying path '/nix/store/pblnj1749yp6wz28spkg0p774v0asfp0-readline-8.2p10' from 'https://cache.nixos.org'...
copying path '/nix/store/c481fhrvslr8nmhhlzdab3k7bpnhb46a-bash-interactive-5.2p26' from 'https://cache.nixos.org'...
/home/psychopunk_sage/.nix-profile/bin/manpath: can't set the locale; make sure $LC_* and $LANG are correct
direnv: error can't find bash: exec: "bash": executable file not found in $PATH
```

</details><br>

```sh
$ nix-shell hello.nix
 23:31:30 make
make: *** No targets specified and no makefile found.  Stop.

 23:31:33 echo $baseInputs
```
<details>
<summary>
Output
</summary>

```
/nix/store/nzzl7dnay9jzgfv9fbwg1zza6ji7bjvr-gnutar-1.35 /nix/store/7m0l19yg0cb1c29wl54y24bbxsd85f4s-gzip-1.13 /nix/store/3ssglpx5xilkrmkhyl4bg0501wshmsgv-gnumake-4.4.1 /nix/store/62zpnw69ylcfhcpy1di8152zlzmbls91-gcc-wrapper-13.3.0 /nix/store/cnknp3yxfibxjhila0sjd1v3yglqssng-coreutils-9.5 /nix/store/2ywpssz17pj0vr4vj7by6aqx2gk01593-gawk-5.2.2 /nix/store/9zsm74npdqq2lgjzavlzaqrz8x44mq9d-gnused-4.9 /nix/store/k8zpadqbwqwalggnhqi74gdgrlf3if9l-gnugrep-3.11 /nix/store/qsx2xqqm0lp6d8hi86r4y0rz5v9m62wn-binutils-2.42 /nix/store/5my5b6mw7h9hxqknvggjla1ci165ly21-findutils-4.10.0 /nix/store/dv5vgsw8naxnkcc88x78vprbnn1pp44y-patchelf-0.15.0
```

</details><br>

* expect that the GNU `hello` build inputs are available in `PATH`, including GNU `make`, but this is not the case.
* we do have the environment variables that we set in the derivation, like `$baseInputs`, `$buildInputs`, `$src`. 
* i.e. we can `source` our `builder.sh`, and it will build the derivation.

```sh
 23:33:37 source builder.sh
...
```
* We sourced `builder.sh` and it ran all of the build steps, including setting up the `PATH` for us
* The working directory is no longer a temp directory created by `nix-build`, but is instead the directory in which we entered the shell. Therefore, hello-2.10 has been unpacked in the current directory.

We are able to `cd` into `hello-2.10` and type `make`, because `make` is now available.

```sh
 23:41:10 make

make  all-recursive
make[1]: Entering directory '/home/psychopunk_sage/dev/nix-pills/pill07/hello-2.12.1'
Making all in po
make[2]: Entering directory '/home/psychopunk_sage/dev/nix-pills/pill07/hello-2.12.1/po'
Makefile:170: warning: ignoring prerequisites on suffix rule definition
make[2]: Nothing to be done for 'all'.
make[2]: Leaving directory '/home/psychopunk_sage/dev/nix-pills/pill07/hello-2.12.1/po'
make[2]: Entering directory '/home/psychopunk_sage/dev/nix-pills/pill07/hello-2.12.1'
make[2]: Leaving directory '/home/psychopunk_sage/dev/nix-pills/pill07/hello-2.12.1'
make[1]: Leaving directory '/home/psychopunk_sage/dev/nix-pills/pill07/hello-2.12.1'
```
> **IMPORTANT**:<br>
> The take-away is that `nix-shell` drops us in a shell with the same (or very similar) environment used to run the builder.

## A builder for nix-shell

> [POINT 1]


When we sourced the `builder.sh` file, we obtained the file in the current directory. What we really wanted was the `builder.sh` that is stored in the **nix store**, as this is the file that would be used by `nix-build`

To do this, we will pass an environment variable through the derivation.<br>
**Note:** `$builder` is already defined, but it points to the `bash executable` rather than our `builder.sh`. Our `builder.sh` is passed as an argument to bash.

```sh
 23:52:59 echo $builder
/nix/store/i1x9sidnvhhbbha2zhgpxkhpysw6ajmr-bash-5.2p26/bin/bash
```

> [POINT 2]

We can break `builder.sh` into two files: a `setup.sh` for setting up the environment, and the real `builder.sh` that `nix-build` expects.

**Note:**  The `set -e` is annoying in nix-shell, as it will terminate the shell if an error is encountered.

**`autotools.nix`**
```nix
pkgs: attrs:
let 
    defaultAttrs = {
        builder = "${pkgs.bash}/bin/bash";
        system = builtins.currentSystem;
        args = [./builder.sh];
        setup = ./setup.sh; # <<<<
        baseInput = with pkgs; [
            gnutar
            gzip
            gnumake
            gcc
            coreutils
            gawk
            gnused
            gnugrep
            binutils.bintools
            patchelf
            findutils
        ];
        buildInputs = [];
    };
in
derivation (defaultAttrs // attrs)
```

**`builder.sh`**
```sh
set -e
source $setup
genericBuild
```

**`setup.sh`**
```sh
unset PATH
for p in $baseInputs $buildInputs; do
    export PATH=$p/bin${PATH:+:}$PATH
done

function unpackPhase() {
    tar -xzf $src

    for d in *; do
    if [ -d "$d" ]; then
        cd "$d"
        break
    fi
    done
}

function configurePhase() {
    ./configure --prefix=$out
}

function buildPhase() {
    make
}

function installPhase() {
    make install
}

function fixupPhase() {
    find $out -type f -exec patchelf --shrink-rpath '{}' \; -exec strip '{}' \; 2>/dev/null
}

function genericBuild() {
    unpackPhase
    configurePhase
    buildPhase
    installPhase
    fixupPhase
}
```

**`hello.nix`**
```nix
let
  pkgs = import <nixpkgs> { };
  mkDerivation = import ./autotools.nix pkgs;
in
mkDerivation {
  name = "hello";
  src = ./hello-2.12.1.tar.gz;
}
```

**in Nix-shell**
```nix
 01:04:04 $setup
bash: /nix/store/i8ykigqs5ljbzyc9xfss98hmaxh5g6sy-setup.sh: Permission denied
                                                                                      �
 01:04:18 source $setup
```

* We can run `unpackPhase` which unpacks `$src` and enters the directory. And you can run commands like `./configure`, `make`, and so forth manually, or run phases with their respective functions.

> **TAKEWAY:**<br>
> * `nix-shell` drops us into an isolated environment suitable for developing a project.
> * environment provides the necessary dependencies for the development shell ~ `nix-build` provides the necessary dependencies to a builder.
> * we can build and debug the project manually, executing step-by-step like we would in any other operating system.