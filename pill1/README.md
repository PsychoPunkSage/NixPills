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

## Path Merging:
**Path merging** in Nix generally refers to the process of combining the output paths of multiple derivations into a single, unified directory structure.
> **man:** to get man support inside the nix env.
```bash
nix-env -i man-db
```
**Location**: `~/.nix-profile/bin/man` ($ which man)
**Derivation Path**: `man-db-2.12.1  /nix/store/k46l5ki5ppfsrbz0wpzxs707zxk9s669-man-db-2.12.1` ($ nix-env -q --out-path)

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