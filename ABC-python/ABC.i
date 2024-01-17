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

Abc_delay = namedtuple('Abc_delay', 'gates area delay')
Abc_stats = namedtuple('Abc_stats', 'inputs outputs latches ands nd edges levels area delay')


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

# The following should be moved out of the .i file

# Kinda brittle parsing of the abc stime command. Let's hope it doesn't change
def parse_stime(timing):
    st, res = timing
    if st != 0:
        print("Error parsing timing: ABC result errored")
        return

    # find the correct line to parse (if we get a multi-line response)
    for line in res.splitlines():
        if "Gates" in line and "Area" in line and "Delay" in line:
            break
            
    toks = list(filter(lambda x: x != "", re.split("[ m=\x1b]", line)))
    g = toks.index("Gates")
    a = toks.index("Area")
    d = toks.index("Delay")
    
    gates = 0
    area = delay = 0.0
    
    try:
        gates = int(toks[g+1])
        area  = float(toks[a+1])
        delay = float(toks[d+1])
    except:
        print("Parsing area and delay failed on the following line:")
        print(res[1])
        print(toks)

    return (gates, area, delay)


# More brittle parsing, this time of print_stats command.
# NOTE: We get different info depending on whether the network is mapped
#       or not.
def parse_stats(status):
    st, res = status
    if st != 0:
        print("Error parsing stats: ABC result errored")
        return

    # find the correct line to parse (if we get a multi-line response)
    for line in res.splitlines():
        if "i/o" in line and "lat" in line and "and" in line:
            break

    # There should be an ABC command to query whether a network is mapped, but
    # I did not find it (yet), so if it is reporting a delay, it must be mapped.
    mapped = "delay" in line

    toks = list(filter(lambda x: x != "", re.split("[ m=/\x1b\n]", line)))

    # -1 means uninitialized
    inputs = outputs = latches = ands = levels = nodes = edges = gates = -1  
    area = delay = 0.0                     
    if mapped:
        io  = toks.index("o")
        lat = toks.index("lat")
        nd  = toks.index("nd")
        egd = toks.index("edge")
        lev = toks.index("lev")
        ara = toks.index("area")
        dl  = toks.index("delay")
    else:
        io  = toks.index("o")
        lat = toks.index("lat")
        ad  = toks.index("and")
        lev = toks.index("lev")
    
    try:
        inputs  = int(toks[io+1])
        outputs = int(toks[io+2])
        latches = int(toks[lat+1])
        levels  = int(toks[lev+1])
        if mapped:
            nodes = int(toks[nd+1])
            edges = int(toks[egd+1])
            area  = int(toks[ara+1])
            delay = float(toks[dl+1])
        else:
            ands = int(toks[ad+1])

    except:
        print("Parsing stats failed on the following line:")
        print(res[1])
        print(toks)

    return Abc_stats(inputs, outputs, latches, ands, nodes, edges, levels, area, delay)
                       
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
