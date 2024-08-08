set -e
unset PATH
echo "BUILD INPUTS: ${buildInput}"
echo "BASE INPUTS: ${buildInput}"
for p in $baseInputs $buildInputs; do
    export PATH=$p/bin${PATH:+:}$PATH
done

echo "SRC: ${src}"
tar -xf $src

for d in *; do
    if [ -d "$d" ]; then
        cd "$d"
        break
    fi
done

./configure --prefix=$out
make
make install
