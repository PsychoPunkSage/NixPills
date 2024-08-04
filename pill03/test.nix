{a, b ? 23, truMsg ? "yes", flsMsg ? "no"}:
if a > b 
    then builtins.trace truMsg true 
    else builtins.trace flsMsg false