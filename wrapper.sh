# NOTE: this link step does not link in all the $(LIBS) that are linked
# by the normal ABC Makefile, that could become a problem (but haven't seen
# that yet)
# NOTE: Should have the correct venv set (by uv) with the correct python version
# (it will use python to find Python.h)
make clean
# define NDEBUG so that all the 18K asserts are no-ops (lots of unused variables remain)
CFLAGS=-DNDEBUG make OPTFLAGS=-O ABC_USE_PIC=1 ABC_USE_NO_READLINE=1 libabc.so -j8

cd ABC-python
swig -python ABC.i

PDIR=$(python -c "import sysconfig; print(sysconfig.get_path('include'))")
#PDIR=/usr/include/python3.12
gcc -fPIC -I$PDIR -I../src ABC_wrap.c -c

# OK, this is a short cut that will cause me trouble some day
g++ -shared -fPIC -o _ABC.so `find .. -name \*.o`

cd ..

# I'm now using uv
uv pip install -e ABC-python

# now make the normal abc executable with readline and assert enabled.
make clean
CFLAGS=-DNDEBUG make OPTFLAGS=-O -j8
