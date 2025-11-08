//====================================================================================
//  Module Description: 1 channel quantization for zebranet accelerator
//  Owner             : Vision Circuits and Systems Lab, National Tsing Hua University
//====================================================================================
module quantization_1ch #(
    parameter GROUP_CHANNEL = 16,
    parameter BW_RELU = 2*`BITWIDTH+4+$clog2(GROUP_CHANNEL)+10
)(
    input signed [BW_RELU-1:0] in_val,
    input [`BW_FL-1:0] shift,
    output reg [`BITWIDTH-1:0] out_val  
);

////////////////////////////////////////////////////////////
// Worhsop II: implement dynamic fixed-point quantization //
//     Note: Do not implement sequential circuit.         //
////////////////////////////////////////////////////////////
wire signed [BW_RELU-1:0] rounding = 1'b1 <<< (shift-1);
wire signed [BW_RELU-1:0] upper_bound = $signed(8'h7f) <<< shift;
wire signed [BW_RELU-1:0] lower_bound = $signed(8'h80) <<< shift;
reg signed [BW_RELU-1:0] round_val;

always@*begin
    round_val = in_val + rounding;
    out_val = (round_val > upper_bound) ? 8'h7f : (round_val<lower_bound) ? 8'h80 : round_val[shift +: `BITWIDTH];
end

endmodule
