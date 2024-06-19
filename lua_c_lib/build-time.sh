#! /bin/bash
gcc -fPIC -o time.o -c time.c -Ilua &&
gcc -fpic -shared -o time.so time.o -Llua -llua &&

cp time.so ../lua-ui/lib/ &&
mv time.so ../scripts &&
rm time.o