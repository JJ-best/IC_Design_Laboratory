set_option enable_save_restore false
# read file
read_file -type verilog \
../source/CPU_define.v \
../source/top.v \
../source/IF_stage.v \
../source/IF_ID.v \
../source/ID_stage.v \
../source/controller.v \
../source/regfile.v \
../source/ID_EXE.v \
../source/EXE_stage.v \
../source/alu.v \
../source/PC.v \
../source/SRAM256x32s_m.v
# timing constraint
read_file -type sgdc ./constraints.sgdc
# goal setup
current_goal lint/lint_rtl -alltop
# run goal
run_goal
# create a report file and write report message to the file
capture spyglass_lab5.rpt {write_report moresimple}
#==========================================================
# setup another goal
current_goal lint/lint_turbo_rtl -alltop
# run goal
run_goal
# append the report message to the same file created above
capture -append spyglass_lab5.rpt {write_report moresimple}
#==========================================================
current_goal lint/lint_functional_rtl -alltop
run_goal
capture -append spyglass_lab5.rpt {write_report moresimple}
#==========================================================
current_goal lint/lint_abstract -alltop
run_goal
capture -append spyglass_lab5.rpt {write_report moresimple}