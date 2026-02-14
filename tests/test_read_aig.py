import ABC
import os.path

# Use a relative pathname for the designs
AIGDIR = os.path.join(os.path.dirname(__file__), "designs", "aig")

abc_cmd = ABC.abc_start()

def test_read_c1355():
    status, msg = abc_cmd(f"read_aiger {AIGDIR}/c1355.aig")
    assert status == 0

def test_read_c2670():
    status, msg = abc_cmd(f"read_aiger {AIGDIR}/c2670.aig")
    assert status == 0

def test_read_pipe():
    status, msg = abc_cmd(f"read_aiger {AIGDIR}/pipe_mult.aig")
    assert status == 0

def test_read_sin():
    status, msg = abc_cmd(f"read_aiger {AIGDIR}/sin.aig")
    assert status == 0

# Now test &read
#
def test_read_c1355_():
    status, msg = abc_cmd(f"&read {AIGDIR}/c1355.aig")
    assert status == 0

def test_read_c2670_():
    status, msg = abc_cmd(f"&read {AIGDIR}/c2670.aig")
    assert status == 0

def test_read_pipe_():
    status, msg = abc_cmd(f"&read {AIGDIR}/pipe_mult.aig")
    assert status == 0

def test_read_sin_():
    status, msg = abc_cmd(f"&read {AIGDIR}/sin.aig")
    assert status == 0
    
