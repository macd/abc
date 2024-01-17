import ABC
import os.path

# Use a relative pathname for the designs
AIGDIR = os.path.join(os.path.dirname(__file__), "designs", "aig")
LIBDIR  = os.path.join(os.path.dirname(__file__), "libraries")

abc_cmd = ABC.abc_start()

# Supposedly the &if command does do "delay-optimizing tech-independent
# synthesis" even though its doc string says it is a FPGA tech mapper.
# Go figure. Here we see that the levels of logic have been reduced from
# 255 down to 88 by this command.
def test_if():
    abc_cmd(f"read_lib {LIBDIR}/sky130_fd_sc_hs__tt_025C_1v80.lib")
    abc_cmd(f"read {AIGDIR}/adder.aig")
    st1 = ABC.parse_stats(abc_cmd("print_stats"))
    abc_cmd("&get; &if -g -K 7; &put")
    st2 = ABC.parse_stats(abc_cmd("print_stats"))
    assert st1.levels == 255 and st2.levels == 88
