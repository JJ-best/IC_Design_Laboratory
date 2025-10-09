# Synopsys VCS(Verilog Compiler Simulation)
# -R: run after compile
# -full64: tell vcs use 64-bit mode to compile
# -debug_access+all: dump all variable waveform
# +v2k: verilog-2001
vcs -f sim_gate.f +define+GATESIM -R -full64 -debug_access+all +v2k 