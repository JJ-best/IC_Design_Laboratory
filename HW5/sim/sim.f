//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================
// testbench
test_ViT_top.v

// sram behavior model
sram_model/sram_act_small.v
sram_model/sram_act_medium.v
sram_model/sram_act_large.v
sram_model/sram_weight.v
sram_model/sram_bias.v

// add your module here
../hdl/ViT_top.v
../hdl/exp_lut.v
../hdl/div.v

// /usr/cadtool/cad/synopsys/synthesis/2020.09-sp5/dw/sim_ver/DW_div_pipe.v
// /usr/cadtool/cad/synopsys/synthesis/2020.09-sp5/dw/sim_ver/DW_div.v
// +incdir+/usr/cadtool/cad/synopsys/synthesis/2020.09-sp5/dw/sim_ver -y /usr/cadtool/cad/synopsys/synthesis/2020.09-sp5/dw/sim_ver


