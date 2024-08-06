# @info: The command lists exported variables.
# @reason: Nix computes the output path of the derivation. The resulting .drv file contains a list of environment variables passed to the builder.
declare -xp
echo foo > $out
