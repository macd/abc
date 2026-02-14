import ABC
import os.path

# Use a relative pathname for the designs
BLIFDIR = os.path.join(os.path.dirname(__file__), "designs", "blif")

abc_cmd = ABC.abc_start()

def test_read_bk():
    status, msg = abc_cmd(f"read_blif {BLIFDIR}/bk_adder_32.blif")
    assert status == 0

def test_read_cla():
    status, msg = abc_cmd(f"read_blif {BLIFDIR}/cla_32.blif")
    assert status == 0
    
def test_read_pipe():
    status, msg = abc_cmd(f"read_blif {BLIFDIR}/pipe_mult.blif")
    assert status == 0

def test_read_sin():
    status, msg = abc_cmd(f"read_blif {BLIFDIR}/sin.blif")
    assert status == 0
