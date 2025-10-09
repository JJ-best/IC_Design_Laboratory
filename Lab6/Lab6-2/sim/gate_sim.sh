# Synopsys VCS(Verilog Compiler Simulation)
# -R: run after compile
# -full64: tell vcs use 64-bit mode to compile
# -debug_access+all: dump all variable waveform
# +v2k: verilog-2001
# no need to use +define+SDF "written in .f file"
vcs -f gate_sim.f -R -full64 -debug_access+all +v2k 