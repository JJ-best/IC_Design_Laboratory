//====================================================================================
//  Module Description: Convolution layer top for zebranet accelerator
//  Owner             : Vision Circuits and Systems Lab, National Tsing Hua University
//====================================================================================
module conv_top 
(
    input clk,
    input rst_n,
    // pipeline control
    input conv_din_enable,
    output conv_dout_valid,
    // datapath control
    input [4*`BW_FL-1:0] in_fl,
    input [4*`BW_FL-1:0] out_fl,
    input [`BW_FL-1:0] wgt_fl,
    input [`BW_FL-1:0] bias_fl,
    input relu,
    // data
    input [`IN_CHANNEL*9*`BITWIDTH-1:0] in_activation,
    input [`OUT_CHANNEL/`N*`IN_CHANNEL*9*`BITWIDTH-1:0] weight,
    input [`OUT_CHANNEL*`BITWIDTH-1:0] bias,
    output [`OUT_CHANNEL*`BITWIDTH-1:0] out_acivation
);

localparam GROUP_CHANNEL = `IN_CHANNEL/`N; // group convolution for workshop II
localparam BW_BIAS = 2*`BITWIDTH+4+$clog2(GROUP_CHANNEL)+1; // additional bit for adding bias
localparam BW_RELU = 2*`BITWIDTH+4+$clog2(GROUP_CHANNEL)+10; // additional bit for ReLU margin

// variable declaration
reg [`IN_CHANNEL*9*`BITWIDTH-1:0] ftr_ff;
reg [`OUT_CHANNEL*`IN_CHANNEL/`N*9*`BITWIDTH-1:0] wgt_ff;
reg [`OUT_CHANNEL*`BITWIDTH-1:0] bias_ff;
reg relu_ff;
reg [4*`BW_FL-1:0] ftr_fl_ff, out_fl_ff;
reg [`BW_FL-1:0] wgt_fl_ff, bias_fl_ff;

wire [`OUT_CHANNEL*BW_BIAS-1:0] conv_out; // concatenated output channel 3x3 convolution results

integer chin_idx, chout_idx;

// pipeline handle
reg pipeline_ff [0:3-1];
always@(posedge clk)begin
    pipeline_ff[0] <= conv_din_enable;
    pipeline_ff[1] <= pipeline_ff[0];
    pipeline_ff[2] <= pipeline_ff[1];
end

assign conv_dout_valid = pipeline_ff[2];

// input arrangement
always@(posedge clk)begin
    relu_ff    <= relu;    
    ftr_fl_ff  <= in_fl;
    wgt_fl_ff  <= wgt_fl;
    bias_fl_ff <= bias_fl;
    out_fl_ff  <= out_fl;
    bias_ff     <= bias;
    ftr_ff <= in_activation; 
    wgt_ff <= weight;
end

// 3x3 convolution
conv3x3_16to4ch#(.BW_BIAS(BW_BIAS))
conv3x3_U0(
    .clk(clk),
    .feature(ftr_ff),
    .weight(wgt_ff),
    .bias(bias_ff),
    .ftr_fl(ftr_fl_ff),
    .wgt_fl(wgt_fl_ff),
    .bias_fl(bias_fl_ff),
    .conv3x3_4chout(conv_out)
);

// Post CONV processing
postproc #(.GROUP_CHANNEL(GROUP_CHANNEL), .BW_BIAS(BW_BIAS), .BW_RELU(BW_RELU))
postproc_U0 (
    .clk(clk),
    .post_in(conv_out),
    .relu(relu_ff),
    .ftr_fl(ftr_fl_ff),
    .wgt_fl(wgt_fl_ff),
    .out_fl(out_fl_ff),
    .post_out(out_acivation)
);

// delay control

endmodule