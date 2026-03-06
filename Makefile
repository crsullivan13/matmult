CC=gcc
OPTS=-Ofast -march=native -flto
CFLAGS=$(OPTS) -std=c11 -g
LFLAGS=-flto 

all: matrix

clean:
	rm -f matrix
