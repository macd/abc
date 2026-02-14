# ABC: System for Sequential Logic Synthesis and Formal Verification

This is a forked version of [abc](https://github.com/berkeley-abc/abc)
The purpose of the fork is to add a Python wrapper around abc using
SWIG. Since the only change here is to add the Python wrapper, no
source code or Makefile changes have been made to abc.  While this
repo may lag behind berkeley-abc/abc, the intent is to track the
changes there in a timely fashion. The additions made here are the
wrapper.sh file and the directory ABC-python and the files it
contains.

In order to make and install the Python wrapped abc library after
cloning the repo you can execute the shell script wrapper.h

  ./wrapper.sh
  
Before doing that, a few things to be aware of. This uses SWIG to
generate the wrappers, so naturally, that has to be installed. Since
the SWIG generated C code includes `Python.h` we need to tell gcc
where to find it. Here we use the `locate` command and arbitrarly
pick the first entry. We need to have the `Python.h` match the version
of Python that uses this wrapper, so if the `locate` command does
not find the one you want, replace the `$DIR` variable in wrapper.sh
with the correct location. Finally, we use `pip` to install an "editable"
version of the package. This means the the library and code remain 
in the abc/ABC-python subdirectory and only a link is put into the 
site-packages directory.

### Usage

After importing ABC you initialize the package and obtain a function
that will feed commands into the abc shell. Many commands return an
integer status value and also print directly to the screen. If the 
printing is done to stdout (and not stderr) it is captured and returned
as the second member of a tuple to the Python shell. This makes it
convenient to get the results of commands such as `stime` or `print_stats`
so that you can construct dynamic higher level algorithms on top of
the basic ABC transforms.

```
Python 3.12.3 (main, Jan 22 2026, 20:57:42) [GCC 13.3.0]
Type 'copyright', 'credits' or 'license' for more information
IPython 9.6.0 -- An enhanced Interactive Python. Type '?' for help.
Tip: IPython 9.0+ has hooks to integrate AI/LLM completions.

In [1]: import ABC

In [2]: cmd = ABC.abc_start()
Loading resource file "/home/macd/ghub/abc/ABC-python/../abc.rc".

In [3]: st = cmd("read_blif tests/designs/blif/cla_32.blif")

In [4]: st
Out[4]:
(0,
 'Hierarchy reader flattened 32 instances of logic boxes and left 0 black boxes.\n')

In [5]: ps = cmd("print_stats")

In [6]: ps
Out[6]:
(0,
 '\x1b[1;37mcla                           :\x1b[0m i/o =   64/   33  lat =    0  nd =   420  edge =    606  cube =   448  lev = 64\n')
```

Of course, we are still left with the job of parsing the raw output of
ABC. Here is a (somewhat brittle) example of parsing the output of the
`stime` command: (The following is now included in the Python wrapper
and so it is available in Python after the `import ABC` command.

    def parse_timing(timing):
        st, res = timing
        if st != 0:
            print("Error parsing timing: bad ABC result")
            return

        # first find the correct line to parse
        line = ""
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
            gates = int(toks[g+1].split('\e')[0])
            area  = float(toks[a+1].split('\e')[0])
            delay = float(toks[d+1].split('\e')[0])
        except:
            print("Parsing area and delay failed on the following line:")
            print(res[1])
            print(toks)

        return (gates, area, delay)

### Tests

The tests in the tests subdirectory are set up to use python and pytest.
Here, we use uv to manage the python environment. After running `wrapper.sh`
you should be able to run pytest and see the following summary:

```
============================= test session starts =============================
platform linux -- Python 3.12.3, pytest-9.0.1, pluggy-1.6.0
rootdir: /home/macd
configfile: pyproject.toml
plugins: anyio-4.11.0
collected 19 items

tests/test_cec.py .                                                     [  5%]
tests/test_if.py .                                                      [ 10%]
tests/test_parse_stats.py .                                             [ 15%]
tests/test_parse_stime.py .                                             [ 21%]
tests/test_read_aig.py ........                                         [ 63%]
tests/test_read_blif.py ....                                            [ 84%]
tests/test_read_lib.py ...                                              [100%]

============================= 19 passed in 4.02s ==============================
```

### Dependencies
  * python
  * pytest
  * swig
  * locate
  * gcc
  * g++
  * uv
