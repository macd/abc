%module ABC
%{
    #define ABC_USE_STDINT_H = 1
    #include <stdio.h>
    #include <time.h>
    //#include "misc/util/abc_global.h"
    //#include "base/main/main.h"
    //#include "base/cmd/cmd.h"
    typedef struct Abc_Frame_t_ Abc_Frame_t;
    extern void            Abc_Start();
    extern void            Abc_Stop();
    extern Abc_Frame_t *   Abc_FrameGetGlobalFrame();
    extern int Cmd_CommandExecute( Abc_Frame_t * pAbc, const char * sCommand );
%}

extern void            Abc_Start();
extern void            Abc_Stop();
extern Abc_Frame_t *   Abc_FrameGetGlobalFrame();
extern int Cmd_CommandExecute( Abc_Frame_t * pAbc, const char * sCommand );


%pythoncode %{

import os
import sys
from ctypes import CDLL
libc = CDLL('libc.so.6')
import tempfile
import re
from collections import namedtuple
# a hack
from ABCHelpers import *

def abc_start():
    Abc_Start()
    pAbc = Abc_FrameGetGlobalFrame()
    # a hack for sure
    pname = os.path.dirname(__file__)
    Cmd_CommandExecute(pAbc, f"source {pname}/../abc.rc")
    def abc_cmd(scmd):
        old_fno = os.dup(sys.stdout.fileno())
        fd = tempfile.TemporaryFile()
        os.dup2(fd.fileno(), 1)
        status = Cmd_CommandExecute(pAbc, scmd)
        libc.fflush(None)
        os.dup2(old_fno, 1)

        fd.seek(0)
        msg = fd.read().decode()
        fd.close()
        return status, msg

    return abc_cmd

%}    

// If doing manually
// make clean
// make ABC_USE_PIC=1 ABC_USE_NO_READLINE=1 libabc.so -j8
// cd ABC-python
// swig -python ABC.i
// gcc -fPIC -I/home/macd/anaconda3/include/python3.8 -I/home/macd/ghub/abc/src ABC_wrap.c -c
// g++ -shared -fPIC -o _ABC.so `find .. -name \*.o`
// cd ..
// pip install -e ABC-python
