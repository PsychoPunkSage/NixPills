# Nix-shell

> The `nix-shell` tool provide us in a shell after setting up the environment variables necessary to hack on a derivation. It **does not build the derivation**; it only serves as a preparation so that we can run the build steps manually.<br>
>  In a nix environment, we don't have access to libraries or programs unless they have been installed with `nix-env`. Installing libraries with `nix-env` is not good practice. We prefer to have isolated environments for development, which nix-shell provides for us.

```sh
$ nix-shell hello.nix

these 2 paths will be fetched (1.22 MiB download, 7.35 MiB unpacked):
  /nix/store/c481fhrvslr8nmhhlzdab3k7bpnhb46a-bash-interactive-5.2p26
  /nix/store/pblnj1749yp6wz28spkg0p774v0asfp0-readline-8.2p10
copying path '/nix/store/pblnj1749yp6wz28spkg0p774v0asfp0-readline-8.2p10' from 'https://cache.nixos.org'...
copying path '/nix/store/c481fhrvslr8nmhhlzdab3k7bpnhb46a-bash-interactive-5.2p26' from 'https://cache.nixos.org'...
/home/psychopunk_sage/.nix-profile/bin/manpath: can't set the locale; make sure $LC_* and $LANG are correct
direnv: error can't find bash: exec: "bash": executable file not found in $PATH
```
* expect that the GNU `hello` build inputs are available in `PATH`, including GNU `make`, but this is not the case.
* we do have the environment variables that we set in the derivation, like $baseInputs, $buildInputs, $src. 
* i.e. we can `source` our `builder.sh`, and it will build the derivation.

## A builder for nix-shell

When we sourced the `builder.sh` file, we obtained the file in the current directory. What we really wanted was the `builder.sh` that is stored in the nix store, as this is the file that would be used by nix-build