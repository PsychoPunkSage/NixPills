## Installing Something:


> **Hello:** a simple CLI tool which prints "Hello world" and is mainly used to test compilers and package installations.

```bash
nix-env -i hello
```
**Location**: `~/.nix-profile/bin/hello` ($ which hello)
<br>**Derivation Path**: `hello-2.12.1  /nix/store/4prjbnvjp40kkqjds62ywy9sr94j9g4b-hello-2.12.1` ($ nix-env -q --out-path)

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

## Path Merging:
>> **Path merging** in Nix generally refers to the process of combining the output paths of multiple derivations into a single, unified directory structure.

> **man:** to get man support inside the nix env.
```bash
nix-env -i man-db
```
**Location**: `~/.nix-profile/bin/man` ($ which man)
<br>**Derivation Path**: `man-db-2.12.1  /nix/store/k46l5ki5ppfsrbz0wpzxs707zxk9s669-man-db-2.12.1` ($ nix-env -q --out-path)

> Locate All the binaries:
```bash
ls -l ~/.nix-profile/bin/
```

```
lrwxrwxrwx - root  1 Jan  1970  accessdb -> /nix/store/k46l5ki5ppfsrbz0wpzxs707zxk9s669-man-db-2.12.1/bin/accessdb
lrwxrwxrwx - root  1 Jan  1970  apropos -> /nix/store/k46l5ki5ppfsrbz0wpzxs707zxk9s669-man-db-2.12.1/bin/apropos
lrwxrwxrwx - root  1 Jan  1970  catman -> /nix/store/k46l5ki5ppfsrbz0wpzxs707zxk9s669-man-db-2.12.1/bin/catman
lrwxrwxrwx - root  1 Jan  1970  hello -> /nix/store/4prjbnvjp40kkqjds62ywy9sr94j9g4b-hello-2.12.1/bin/hello
lrwxrwxrwx - root  1 Jan  1970  lexgrog -> /nix/store/k46l5ki5ppfsrbz0wpzxs707zxk9s669-man-db-2.12.1/bin/lexgrog
lrwxrwxrwx - root  1 Jan  1970  man -> /nix/store/k46l5ki5ppfsrbz0wpzxs707zxk9s669-man-db-2.12.1/bin/man
lrwxrwxrwx - root  1 Jan  1970  man-recode -> /nix/store/k46l5ki5ppfsrbz0wpzxs707zxk9s669-man-db-2.12.1/bin/man-recode
lrwxrwxrwx - root  1 Jan  1970  mandb -> /nix/store/k46l5ki5ppfsrbz0wpzxs707zxk9s669-man-db-2.12.1/bin/mandb
lrwxrwxrwx - root  1 Jan  1970  manpath -> /nix/store/k46l5ki5ppfsrbz0wpzxs707zxk9s669-man-db-2.12.1/bin/manpath
lrwxrwxrwx - root  1 Jan  1970  whatis -> /nix/store/k46l5ki5ppfsrbz0wpzxs707zxk9s669-man-db-2.12.1/bin/whatis
```

## Querying the store:
All of the environment components point to the store.
To query and manipulate the store, there's the `nix-store` command.

> Get Runtime dependencies of `hello`
```bash
nix-store -q --references `which hello`
```

```
/nix/store/0wydilnf1c9vznywsvxqnaing4wraaxp-glibc-2.39-52
/nix/store/4prjbnvjp40kkqjds62ywy9sr94j9g4b-hello-2.12.1
```

> Get reverse dependencies of `hello`
```bash
nix-store -q --referrers `which hello`
```

```
/nix/store/4prjbnvjp40kkqjds62ywy9sr94j9g4b-hello-2.12.1
/nix/store/7qd0iq76mp363d57yn5k3q4axb6vw78s-env-manifest.nix
/nix/store/0ryx7ssprfgdkpfb2s322wclx51fwanr-user-environment
/nix/store/954cj2jrgvj9scwc8xpfmiv3zqcfmqib-env-manifest.nix
/nix/store/xck3xilgbd0przvbvqpk83alxxsdgggl-user-environment
```
* Our environments depend upon `hello` i.e. the environments are in the store, and since they contain symlinks to `hello`, therefore the environment depends upon `hello`.
* Two environments were listed, generation 2 and generation 3, since these are the ones that had hello installed in them.
* The **manifest.nix**(`~/.nix-profile/manifest.nix`) file contains metadata about the environment, such as which derivations are installed. So that nix-env can list, upgrade or remove them.

## Closures
>> The closures of a derivation is a list of all its dependencies, recursively, including absolutely everything necessary to use that derivation.

```bash
nix-store -qR `which hello`
```

```
/nix/store/560z0zfybsjb8m76n67x6c1k7gpm080w-libunistring-1.2
/nix/store/70x99mlxawd915q5nfj4swxjjnjw1ahy-libidn2-2.3.7
/nix/store/dffyikn59cy7fff2qd60gs9jl63szqnh-xgcc-13.3.0-libgcc
/nix/store/0wydilnf1c9vznywsvxqnaing4wraaxp-glibc-2.39-52
/nix/store/4prjbnvjp40kkqjds62ywy9sr94j9g4b-hello-2.12.1
```
* Copying all those derivations to the **Nix store of another machine** makes you able to run `hello` out of the box on that other machine. (0 issues possible)

```bash
nix-store -q --tree `which hello`
```

```
/nix/store/4prjbnvjp40kkqjds62ywy9sr94j9g4b-hello-2.12.1
├───/nix/store/0wydilnf1c9vznywsvxqnaing4wraaxp-glibc-2.39-52
│   ├───/nix/store/70x99mlxawd915q5nfj4swxjjnjw1ahy-libidn2-2.3.7
│   │   ├───/nix/store/560z0zfybsjb8m76n67x6c1k7gpm080w-libunistring-1.2
│   │   │   └───/nix/store/560z0zfybsjb8m76n67x6c1k7gpm080w-libunistring-1.2 [...]
│   │   └───/nix/store/70x99mlxawd915q5nfj4swxjjnjw1ahy-libidn2-2.3.7 [...]
│   ├───/nix/store/dffyikn59cy7fff2qd60gs9jl63szqnh-xgcc-13.3.0-libgcc
│   └───/nix/store/0wydilnf1c9vznywsvxqnaing4wraaxp-glibc-2.39-52 [...]
└───/nix/store/4prjbnvjp40kkqjds62ywy9sr94j9g4b-hello-2.12.1 [...]
```

*  it shows you a tree-like structure of packages that ultimately rely on the `hello`.


## Channels:

>> There's a list of channels from which we get packages, although usually we use a single channel. The tool to manage channels is `nix-channel`.

```bash
nix-channel --list

# If using NixOS, you may not see any output from the above command (if you're using the default),
# or you may see a channel whose name begins with "nixos-" instead of "nixpkgs".<br>
```
**Location**: `~/.nix-channels` (its not a symlink to nix store)<br>
**Update(channels)**: `nix-channel --update` (to update channel)<br>
**Update(packages)**: `nix-env -ue` (to update all packages)<br>
new generation of the channels profile can be made under `~/.nix-defexpr/channels`

## Resources:

> [Cheatsheet](https://wiki.nixos.org/wiki/Cheatsheet)
> [Upgrade Manual](https://nixos.org/manual/nix/stable/command-ref/nix-env#operation---upgrade)