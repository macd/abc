import re
from collections import namedtuple

Abc_delay = namedtuple('Abc_delay', 'gates area delay')
Abc_stats = namedtuple('Abc_stats', 'inputs outputs latches ands nodes edges levels cubes area delay')
                                  

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


def get_val(token, line):
    if token in line:
        # get rid of any enclosing space
        token = token.split()[0]
        toks = list(filter(lambda x: x != "", re.split("[ m=/\x1b\n]", line)))
        return int(toks[toks.index(token)+1])

    return -1

# More brittle parsing, this time of print_stats command.
# NOTE: We get different info depending on whether the network is mapped
#       or not (and other things too), so we have to test the output to
#       see what is actually there.
def parse_stats(status):
    st, res = status
    if st != 0:
        print("Error parsing stats: ABC result errored")
        return

    # find the correct line to parse (if we get a multi-line response)
    for line in res.splitlines():
        if "i/o" in line:
            break

    inputs  = get_val("o",    line)
    latches = get_val("lat",  line)
    levels  = get_val("lev",  line)
    nodes   = get_val(" nd ",   line)
    edges   = get_val("edge", line)
    ands    = get_val("and",  line)
    cubes   = get_val("cube", line)

    toks = list(filter(lambda x: x != "", re.split("[ m=/\x1b\n]", line)))
    outputs = int(toks[toks.index("o")+2]) if "i/o" in line else -1
    area    = float(toks[toks.index("area")+1]) if "area" in line else 0.0
    delay   = float(toks[toks.index("delay")+1]) if "delay" in line else 0.0

    return Abc_stats(inputs, outputs, latches, ands, nodes, edges, levels, cubes,
                     area, delay)

