#! /bin/bash
gcc -fPIC -o pdlib.o -c pdlib.c -Ilua &&
gcc -fpic -shared -o pdlib.so pdlib.o -Llua -llua &&

mv pdlib.so ../