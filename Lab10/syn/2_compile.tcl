# before synthesis settings
set case_analysis_with_logic_constants true
set_fix_multiple_port_nets -feedthroughs -outputs -constants -buffer_constants

####check design####
check_design > ./$RPT_DIR/check_design.log
check_timing > ./$RPT_DIR/check_timing.log

set_clock_gating_style -max_fanout 10

### Official LEC MDP flow (Appendix) ###
## Preserve DesignWare module boundaries
# set compile_ultra_dw_ungroup false


# Synthesis all design (using : compile_ultra)
# you can add "-gate_clock" to do gated-clock
# you can add "-incremental" for higher performance
compile_ultra -gate_clock -exact_map -no_autoungroup -no_seq_output_inversion -no_boundary_optimization


### Official LEC MDP flow (Appendix) ###
## Write out intermediate netlist & resource report
# write -format verilog -hierarchy -output ./$NET_DIR/${TOPLEVEL}_syn_int.v
# report_resources -hier > ./$RPT_DIR/report_resources_${TOPLEVEL}_int.out
compile_ultra -incremental -exact_map -no_autoungroup -no_seq_output_inversion -no_boundary_optimization


# remove dummy ports
remove_unconnected_ports [get_cells -hierarchical *]
remove_unconnected_ports [get_cells -hierarchical *] -blast_buses

