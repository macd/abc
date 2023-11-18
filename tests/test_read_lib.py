import ABC
import os.path

# Use a relative pathname for the technology libraries
LIBDIR = os.path.join(os.path.dirname(__file__), "libraries")

abc_cmd = ABC.abc_start()

def test_read_sky25():
    status, msg = abc_cmd(f"read_lib {LIBDIR}/sky130_fd_sc_hs__tt_025C_1v80.lib")
    assert status == 0

def test_read_sky100():
    status, msg = abc_cmd(f"read_lib {LIBDIR}/sky130_fd_sc_hs__tt_100C_1v80.lib")
    assert status == 0

def test_read_nangate():
    status, msg = abc_cmd(f"read_lib {LIBDIR}/NangateOpenCellLibrary_typical.lib")
    assert status == 0
