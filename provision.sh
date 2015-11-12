# Upgrade the base system
sudo apt-get update

# Install required dependencies
sudo apt-get install -y \
    git \
    build-essential \
    gcc-arm-linux-gnueabihf \
    curl \
    g++ \
    make \
    cmake \
    xz-utils \
    python \
    libssl-dev

mkdir /build
cd /build
curl http://www.musl.libc.org/releases/musl-1.1.12.tar.gz | tar xvzf -
cd /build/musl-1.1.12
./configure --prefix=/musl --disable-shared
make -j2
make install

cd /build
curl http://llvm.org/releases/3.7.0/llvm-3.7.0.src.tar.xz | tar xJf -
curl http://llvm.org/releases/3.7.0/libunwind-3.7.0.src.tar.xz | tar xJf -
cd /build/libunwind-build
cmake ../libunwind-3.7.0.src -DLLVM_PATH=/build/llvm-3.7.0.src \
    -DLIBUNWIND_ENABLE_SHARED=0
make -j2
cp lib/libunwind.a /musl/lib

export PATH=/musl/bin:$PATH
export PATH=/rust/bin:$PATH
export LD_LIBRARY_PATH=/rust/lib

# Dockerfile-rust
git clone http://github.com/rust-lang/rust
cd /build/rust
./configure --musl-root=/musl --prefix=/rust \
    --target=x86_64-unknown-linux-musl

make -j2
make install

cd /build
git clone --recursive https://github.com/rust-lang/cargo
cd /build/cargo
./configure --prefix=/rust --enable-optimize
make -j2
make install

rm -rf /build

#git clone http://github.com/mozilla/rust.git /rust-build
#cd /rust-build
#git checkout stable
#configure --target=arm-unknown-linux-gnueabihf,x86_64-unknown-linux-gnu
#make -j2



