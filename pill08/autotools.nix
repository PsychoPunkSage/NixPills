pkgs: attrs:
let 
    defaultAttrs = {
        builder = "${pkgs.bash}/bin/bash";
        system = builtins.currentSystem;
        args = [./builder.sh];
        setup = ./setup.sh;
        baseInputs = with pkgs; [
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