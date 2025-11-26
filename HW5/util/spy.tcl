set_option enable_save_restore false
# read file
read_file -type verilog \
../hdl/ViT_top.v \
../hdl/exp_lut.v \
../hdl/div.v
# timing constraint
# read_file -type sgdc ./constraints.sgdc

# goal setup
current_goal lint/lint_rtl -alltop
# run goal
run_goal
# create a report file and write report message to the file
capture spyglass_ViT_top.rpt {write_report moresimple}
#==========================================================
# setup another goal
current_goal lint/lint_turbo_rtl -alltop
# run goal
run_goal
# append the report message to the same file created above
capture -append spyglass_ViT_top.rpt {write_report moresimple}
#==========================================================
current_goal lint/lint_abstract -alltop
run_goal
capture -append spyglass_ViT_top.rpt {write_report moresimple}
#==========================================================
read_file -type sgdc ./constraints.sgdc
set_option design_top ViT_top

current_goal lint/lint_functional_rtl
run_goal
capture -append spyglass_ViT_top.rpt {write_report moresimple}