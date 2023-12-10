import ABC
import os.path

# Use a relative pathname for the designs
BLIFDIR = os.path.join(os.path.dirname(__file__), "designs", "blif")

abc_cmd = ABC.abc_start()

def test_cec_adder():
    status, msg = abc_cmd(f"cec {BLIFDIR}/bk_adder_32.blif {BLIFDIR}/cla_32.blif")
    assert("equivalent" in msg)
