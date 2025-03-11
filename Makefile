CFLAGS=`pkg-config --cflags --libs libmongoc-1.0`

all: sample

sample: sample.c 
	gcc -o $@ $< $(CFLAGS)

import: import.c
	gcc -o $@ $< $(CFLAGS)

_build/default/sample.exe:
	dune build ./sample.exe

test: sample
	./sample | md5sum
	dune exec ./sample.exe | md5sum 

clean:
	rm -fr *.o *~ sample import
