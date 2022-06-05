FROM ubuntu:20.04
WORKDIR /
ARG SDK_URL=https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-16/wasi-sdk-16.0-linux.tar.gz
ARG SDK_FULLNAME=wasi-sdk-16.0

RUN apt-get -y update && apt-get -y install wget
RUN wget $SDK_URL
RUN tar xvf $SDK_FULLNAME-linux.tar.gz && rm -f $SDK_FULLNAME-linux.tar.gz
ENV CC=/$SDK_FULLNAME/bin/clang
ENV CXX=/$SDK_FULLNAME/bin/clang++
ENV LD=/$SDK_FULLNAME/bin/lld
ENV CFLAGS=--sysroot=/$SDK_FULLNAME/share/wasi-sysroot
ENV CXXFLAGS=--sysroot=/$SDK_FULLNAME/share/wasi-sysroot

RUN sed -i -e "s,PATH=\",PATH=\"/$SDK_FULLNAME/bin:," /etc/environment
ENV PATH="/$SDK_FULLNAME/bin:${PATH}"

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
        apt-get -y install git libxml2-dev make texinfo flex bison

WORKDIR /root
RUN git clone -b binutils-2_38 git://sourceware.org/git/binutils-gdb.git
COPY files/setjmp.h /wasi-sdk-16.0/share/wasi-sysroot/include/setjmp.h
COPY files/* /root/
RUN cd binutils-gdb && \
    git apply < /root/binutils.diff && \
    sed -i -re 's/(BUILD_DLLTOOL|DLLWRAP|WINDRES)=.*$/\1=/' binutils/configure && \
    mkdir -p build && cd build && \
    export CFLAGS="$CFLAGS -D_WASI_EMULATED_SIGNAL" \
        LDFLAGS="$LDFLAGS -lwasi-emulated-signal -lwasi-emulated-getpid" \
        AR=/wasi-sdk-16.0/bin/ar && \
    ../configure --host=wasm32-unknown-wasi --enable-64-bit-bfd --disable-debug --disable-dependency-tracking --disable-werror --enable-multilib --enable-targets=all --disable-nls --disable-gdb --disable-libdecnumber --disable-readline --disable-sim --enable-shared --prefix="/opt/binutils-wasi" && \
    make -j32 && \
    cd binutils && \
    /root/build-binutils.sh
    # cd gas && /root/build-gas.sh --host wasm32-unknown-gnu --prefix=/opt/binutils-wasi/
