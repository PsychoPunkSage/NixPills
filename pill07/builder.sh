set -e
# Step 1
unset PATH
echo "BUILD INPUTS: ${buildInput}"
echo "BASE INPUTS: ${buildInput}"
for p in $baseInputs $buildInputs; do
    export PATH=$p/bin${PATH:+:}$PATH
done

# Step 2
echo "SRC: ${src}"
tar -xf $src

# Step 3
for d in *; do
    if [ -d "$d" ]; then
        cd "$d"
        break
    fi
done

# Step 4
./configure --prefix=$out
# Step 5
make
# Step 6
make install
# Step 7
find $out -type f -exec patchelf --shrink-rpath '{}' \; -exec strip '{}' \; 2>/dev/null
