import ABC
import os.path

# Use a relative pathname for the designs and libraries
BLIFDIR = os.path.join(os.path.dirname(__file__), "designs", "blif")
LIBDIR  = os.path.join(os.path.dirname(__file__), "libraries")

abc_cmd = ABC.abc_start()

def test_parse_stats():
    lib_status,  lib_msg  = abc_cmd(f"read_lib {LIBDIR}/sky130_fd_sc_hs__tt_025C_1v80.lib")
    cstr_status, cstr_msg = abc_cmd(f"read_constr {LIBDIR}/sky130_tt.constr")
    blif_status, blif_msg = abc_cmd(f"read_blif {BLIFDIR}/cla_32.blif")
    map_status,  map_msg  = abc_cmd("strash; dch; map -B 0.9")
    abc_stats = abc_cmd("print_stats")
    s = ABC.parse_stats(abc_stats)
    assert s.levels == 34
