# Note, if using Anaconda, must have it set up correctly
# ALSO, this link step does not link in all the $(LIBS) that are linked
# by the normal ABC Makefile, that could become a problem (but haven't seen
# that yet)
# Finally, you must have write access to site-packages to do the pip install -e ...
make clean
# define NDEBUG so that all the 18K asserts are no-ops (lots of unused variables remain)
CFLAGS=-DNDEBUG make OPTFLAGS=-O ABC_USE_PIC=1 ABC_USE_NO_READLINE=1 libabc.so -j8
cd ABC-python
swig -python ABC.i
hdrs=(`locate Python.h`)
VAR=${hdrs[-1]}
DIR=${VAR%/*}
# If locate doesn't work, try something like the following
#DIR=/home/macd/anaconda3/include/python3.11
gcc -fPIC -I$DIR -I../src ABC_wrap.c -c
g++ -shared -fPIC -o _ABC.so `find .. -name \*.o`
cd ..
pip install -e ABC-python

# now make the executable abc with readline and assert enabled.
make clean
CFLAGS=-DNDEBUG make OPTFLAGS=-O -j8
