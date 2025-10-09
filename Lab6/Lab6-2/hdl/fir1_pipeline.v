//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module fir1_pipeline
#(parameter N=32)
(
input      clk,
input      rst_n,
input      enable,
input      [N-1:0]x,
output reg busy,
output reg valid,
output reg [N-1:0]y
);

endmodule
