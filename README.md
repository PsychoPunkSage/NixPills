## ISSUES with current Package Managers:

* Most of the widely used package managers (dpkg, rpm, ...) mutate the global state of the system.
* If a package **foo-1.0** installs a program to **/usr/bin/foo**, you cannot install **foo-1.1** as well, unless you **change** the `installation paths` or the `binary name`.
* In theory it's possible with some current systems to install multiple versions of the same package, in practice it's very painful.
* For example:
    - If we need an **nginx service** and also an **nginx-openresty** service. We have to create a **new package** that changes all the paths to have, for example, an -openresty suffix.
    - Suppose that we want to run two different instances of `mysql`: `5.2` and `5.5`. The same thing applies, plus we have to also make sure the two mysqlclient libraries do not collide.
    -  If we want to install two whole stacks of software like `GNOME 3.10` and `GNOME 3.12`, we can imagine the amount of work.
* Setting up container is now days usually used to cater such needs, but at a different level and with other drawbacks. For example, needing orchestration tools, setting up a shared cache of packages, and new machines to monitor rather than simple services.
* **PROBLEM:** We can use virtualenv for python, or jhbuild for gnome, or whatever else. But then how do we mix the two stacks? How do we avoid recompiling the same thing when it could instead be shared? Also we need to set up your development tools to point to the different directories where libraries are installed. Not only that, there's the risk that some of the software incorrectly uses system libraries.

## Nix-Package Manager:

* Nix makes `no assumptions` about the **global state** of the system. The core of a Nix system is the **Nix store**, usually installed under `/nix/store`, and some tools to manipulate the store.
* In Nix there is the notion of a **derivation** rather than a package.
* `Derivations/packages` are stored in the Nix store as follows: `/nix/store/«hash-name»`, where the **hash** uniquely identifies the derivation (this isn't quite true), and the **name** is the name of the derivation.
    - example: `/nix/store/s4zia7hhqkin1di0f187b79sa2srhv6k-bash-4.2-p45/`. This is a directory in the Nix store which contains `bin/bash`.
    - there's no `/bin/bash`, there's only that self-contained build output in the store. To make them convenient to use from the shell, Nix will arrange for binaries to appear in your PATH as appropriate.
* We basically have a store of all packages (different versions occupying different locations), and everything in the Nix store is **immutable**.
* The `version` in the derivation name: it's only a name for us humans. We may end up having two derivations with the same name but different hashes: it's the hash that really matters.
    - Nix can manage different versions of the same software. For example, you can have `MySQL 5.2` and `MySQL 5.5` installed at the same time.
    - Each version of the software can use different versions of their dependencies. For instance, `MySQL 5.2` can use `glibc-2.18` while `MySQL 5.5` can use `glibc-2.19`.
    - We can have Python modules compiled with different versions of the GCC compiler. A `Python 2.7` module could be compiled with `GCC 4.6`, while a `Python 3` module could be compiled with `GCC 4.8`.
    - Nix ensures that these different versions and their dependencies do not interfere with each other, allowing them to coexist peacefully on the same system.