let
    pkgs = import <nixpkgs> {};
    mkDerivation = import ./autotools.nix pkgs;
in
mkDerivation {
    name = "PPS_hello_pill08";
    src = ./hello-2.12.1.tar.gz;
}