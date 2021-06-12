make clean
make ABC_USE_PIC=1 ABC_USE_NO_READLINE=1 libabc.so -j8
cd ABC-python
swig -python ABC.i
hdrs=(`locate Python.h`)
VAR=${hdrs[0]}
DIR=${VAR%/*}
gcc -fPIC -I$DIR -I../src ABC_wrap.c -c
g++ -shared -fPIC -o _ABC.so `find .. -name \*.o`
cd ..
pip install -e ABC-python
