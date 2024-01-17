import ABC
import os.path

# Use a relative pathname for the designs
BLIFDIR = os.path.join(os.path.dirname(__file__), "designs", "blif")
AIGDIR = os.path.join(os.path.dirname(__file__), "designs", "aig")

abc_cmd = ABC.abc_start()

def test_cec_adder():
    # old cec
    status, msg = abc_cmd(f"cec {BLIFDIR}/bk_adder_32.blif {BLIFDIR}/cla_32.blif")
    assert("equivalent" in msg)
    _ = abc_cmd(f"read {BLIFDIR}/bk_adder_32.blif; &get")
    # new and improved (but -x is slower??)
    status, msg = abc_cmd(f"&cec -x {AIGDIR}/cla_32.aig")
    assert("equivalent" in msg)
