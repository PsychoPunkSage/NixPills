let
    pkgs = import <nixpkgs> {};
in
derivation {
    name = "hello_PPS";
    builder = "${pkgs.bash}/bin/bash";
    system = builtins.currentSystem;
    args = [./hello_builder.sh];
    builderInputs = with pkgs; [ 
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
}