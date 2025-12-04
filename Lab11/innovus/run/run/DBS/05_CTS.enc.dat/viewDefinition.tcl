if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name lib_min\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fast_vdd1v2_basicCells.lib]\
   -si\
    [list ${::IMEX::libVar}/mmmc/fast.cdb]
create_library_set -name lib_max\
   -timing\
    [list ${::IMEX::libVar}/mmmc/slow_vdd1v2_basicCells.lib]\
   -si\
    [list ${::IMEX::libVar}/mmmc/slow.cdb]
create_rc_corner -name RC\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -qx_tech_file ${::IMEX::libVar}/mmmc/RC/gpdk045.tch
create_delay_corner -name DC_min\
   -library_set lib_min\
   -rc_corner RC
create_delay_corner -name DC_max\
   -library_set lib_max\
   -rc_corner RC
create_constraint_mode -name CN_func\
   -sdc_files\
    [list ${::IMEX::libVar}/mmmc/top_pipe_syn.sdc]
create_analysis_view -name AV_max -constraint_mode CN_func -delay_corner DC_max
create_analysis_view -name AV_min -constraint_mode CN_func -delay_corner DC_min
set_analysis_view -setup [list AV_max] -hold [list AV_min]
catch {set_interactive_constraint_mode [list CN_func] } 
