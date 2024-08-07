let
    pkgs = import <nixpkgs> {};
in
derivation {
    name = "PPS_first_drv";
    builder = "${pkgs.bash}/bin/bash";
    args = [./simple_builder.sh];

    inherit (pkgs) gcc coreutils;
    # gcc = pkgs.gcc;
    # coreutils = pkgs.coreutils;
    
    src = ./simple.c;
    system = builtins.currentSystem;
}