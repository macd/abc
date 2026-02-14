import ABC
import os.path

# Use a relative pathname for the designs and libraries
BLIFDIR = os.path.join(os.path.dirname(__file__), "designs", "blif")
LIBDIR  = os.path.join(os.path.dirname(__file__), "libraries")

abc_cmd = ABC.abc_start()


def test_parse_stime():
    lib_status,  lib_msg  = abc_cmd(f"read_lib {LIBDIR}/sky130_fd_sc_hs__tt_025C_1v80.lib")
    cstr_status, cstr_msg = abc_cmd(f"read_constr {LIBDIR}/sky130_tt.constr")
    blif_status, blif_msg = abc_cmd(f"read_blif {BLIFDIR}/cla_32.blif")
    map_status,  map_msg  = abc_cmd("strash; dch; map -B 0.9")
    tim_status,  tim_msg  = abc_cmd("stime")
    g, a, d = ABC.parse_stime((tim_status, tim_msg))
    assert g == 283
