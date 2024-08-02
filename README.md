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