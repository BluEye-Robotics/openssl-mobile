include(default)

[settings]
os=Linux
arch=x86_64
compiler=gcc
compiler.version=11.2
compiler.libcxx=libstdc++

[buildenv]
CC=x86_64-linux-musl-gcc
CXX=x86_64-linux-musl-g++
