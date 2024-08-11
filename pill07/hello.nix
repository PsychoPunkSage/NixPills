let
  pkgs = import <nixpkgs> { };
  baseDrv = import ./autotools.nix pkgs; # passed pkgs (i.e. 1st parameter) -> this ill return a fn that will req. `attrs`
in
baseDrv {
    name = "PPS_hello_trimmed";
    src = ./hello-2.12.1.tar.gz;
}
# derivation {
#   name = "hello";
#   builder = "${pkgs.bash}/bin/bash";
#   args = [ ./builder.sh ];
#   buildInputs = with pkgs; [
#     gnutar
#     gzip
#     gnumake
#     gcc
#     coreutils
#     gawk
#     gnused
#     gnugrep
#     binutils.bintools
#   ];
#   src = ./hello-2.12.1.tar.gz;
#   system = builtins.currentSystem;
# }
