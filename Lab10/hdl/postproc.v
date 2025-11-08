//====================================================================================
//  Module Description: Post CONV layer processing for zebranet accelerator
//  Owner             : Vision Circuits and Systems Lab, National Tsing Hua University
//====================================================================================
module postproc #(
    parameter GROUP_CHANNEL = 16,
    parameter BW_BIAS = 2*`BITWIDTH+4+$clog2(GROUP_CHANNEL)+1, 
    parameter BW_RELU = 2*`BITWIDTH+4+$clog2(GROUP_CHANNEL)+10
)(
    input clk,
    input [`OUT_CHANNEL*BW_BIAS-1:0] post_in,
    input relu,
    input [4*`BW_FL-1:0] ftr_fl,
    input [`BW_FL-1:0] wgt_fl,
    input [4*`BW_FL-1:0] out_fl,
    output reg [`OUT_CHANNEL*`BITWIDTH-1:0] post_out
);

// module connection
wire [`OUT_CHANNEL*BW_RELU-1:0] relu_out; // concatenated ReLU inputs
wire [BW_RELU-1:0] relu_ch0, relu_ch1, relu_ch2, relu_ch3;
assign {relu_ch0, relu_ch1, relu_ch2, relu_ch3} = relu_out;
wire [`BITWIDTH-1:0] quantizer_out_ch0, quantizer_out_ch1, quantizer_out_ch2, quantizer_out_ch3;          // concatenated Quantization outputs

always@(posedge clk) begin
  post_out <= {quantizer_out_ch0, quantizer_out_ch1, quantizer_out_ch2, quantizer_out_ch3};
end

// calculate the shift amount of residual connectin and quantization
wire [`BW_FL-1:0] relu_shift_ch0;
wire [`BW_FL-1:0] relu_shift_ch1;
wire [`BW_FL-1:0] relu_shift_ch2;
wire [`BW_FL-1:0] relu_shift_ch3;

wire [`BW_FL-1:0] residual_shift_ch0;
wire [`BW_FL-1:0] residual_shift_ch1;
wire [`BW_FL-1:0] residual_shift_ch2;
wire [`BW_FL-1:0] residual_shift_ch3;

wire [`BW_FL-1:0] quantizer_shift_ch0;
wire [`BW_FL-1:0] quantizer_shift_ch1;
wire [`BW_FL-1:0] quantizer_shift_ch2;
wire [`BW_FL-1:0] quantizer_shift_ch3;

shifter_decoder shifter_decoder_U0(
    .ftr_fl(ftr_fl),
    .wgt_fl(wgt_fl),
    .out_fl(out_fl),
    .relu_shift_ch0(relu_shift_ch0),
    .relu_shift_ch1(relu_shift_ch1),
    .relu_shift_ch2(relu_shift_ch2),
    .relu_shift_ch3(relu_shift_ch3),
    .quantizer_shift_ch0(quantizer_shift_ch0),
    .quantizer_shift_ch1(quantizer_shift_ch1),
    .quantizer_shift_ch2(quantizer_shift_ch2),
    .quantizer_shift_ch3(quantizer_shift_ch3)
);

// ReLU
ReLU #(.GROUP_CHANNEL(GROUP_CHANNEL), .BW_BIAS(BW_BIAS), .BW_RELU(BW_RELU))
ReLU_U0 (
    .relu_in(post_in),
    .relu(relu),
    .relu_shift_ch0(relu_shift_ch0),
    .relu_shift_ch1(relu_shift_ch1),
    .relu_shift_ch2(relu_shift_ch2),
    .relu_shift_ch3(relu_shift_ch3),
    .relu_out(relu_out)
);

// quantization
quantization_1ch #(.GROUP_CHANNEL(GROUP_CHANNEL), .BW_RELU(BW_RELU))
quantization_1ch_U0 (
  .in_val(relu_ch0),
  .shift(quantizer_shift_ch0),
  .out_val(quantizer_out_ch0)
);    
quantization_1ch #(.GROUP_CHANNEL(GROUP_CHANNEL), .BW_RELU(BW_RELU))
quantization_1ch_U1 (
  .in_val(relu_ch1),
  .shift(quantizer_shift_ch1),
  .out_val(quantizer_out_ch1)
);    
quantization_1ch #(.GROUP_CHANNEL(GROUP_CHANNEL), .BW_RELU(BW_RELU))
quantization_1ch_U2 (
  .in_val(relu_ch2),
  .shift(quantizer_shift_ch2),
  .out_val(quantizer_out_ch2)
);    
quantization_1ch #(.GROUP_CHANNEL(GROUP_CHANNEL), .BW_RELU(BW_RELU))
quantization_1ch_U3 (
  .in_val(relu_ch3),
  .shift(quantizer_shift_ch3),
  .out_val(quantizer_out_ch3)
);    

endmodule