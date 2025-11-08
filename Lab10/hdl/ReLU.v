//====================================================================================
//  Module Description: ReLU for zebranet accelerator
//  Owner             : Vision Circuits and Systems Lab, National Tsing Hua University
//====================================================================================
module ReLU #(
    parameter GROUP_CHANNEL = 16,
    parameter BW_BIAS = 2*`BITWIDTH+4+$clog2(GROUP_CHANNEL)+1, 
    parameter BW_RELU = 2*`BITWIDTH+4+$clog2(GROUP_CHANNEL)+10
)(
    input [`OUT_CHANNEL*BW_BIAS-1:0] relu_in,
    input relu,
    input [`BW_FL-1:0] relu_shift_ch0,
    input [`BW_FL-1:0] relu_shift_ch1,
    input [`BW_FL-1:0] relu_shift_ch2,
    input [`BW_FL-1:0] relu_shift_ch3,
    output [`OUT_CHANNEL*BW_RELU-1:0] relu_out
);

wire signed [BW_BIAS-1:0] y0, y1, y2, y3;
assign {y0, y1, y2, y3} = relu_in;

reg signed [BW_RELU-1:0] x0, x1, x2, x3;
assign relu_out = {x0, x1, x2, x3};

always@*begin
    if(relu)begin
        x0 = (y0 < 0) ? 0 : y0; 
        x1 = (y1 < 0) ? 0 : y1; 
        x2 = (y2 < 0) ? 0 : y2; 
        x3 = (y3 < 0) ? 0 : y3; 
    end 
    else begin
        x0 = y0;
        x1 = y1;
        x2 = y2;
        x3 = y3;
    end
end

endmodule