docker build . --tag binutils-wasm-build
id=$(docker create binutils-wasm-build)
docker cp "$id:/root/binutils-gdb/build/binutils/binutils" ./binutils.wasm
docker rm -v "$id"
