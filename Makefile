CC=riscv64-unknown-linux-gnu-gcc
OPTS=-Ofast -march=rv64gc -flto
CFLAGS=$(OPTS) -std=c11 -g

CXX=riscv64-unknown-linux-gnu-g++
CXXFLAGS=$(OPTS) -std=c++17

all: matrix

clean:
	rm -f matrix
