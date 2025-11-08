//====================================================================================
//  Module Description: Shift amount controller for zebranet accelerator
//  Owner             : Vision Circuits and Systems Lab, National Tsing Hua University
//====================================================================================
module shifter_decoder 
(
    input [4*`BW_FL-1:0] ftr_fl,
    input [`BW_FL-1:0] wgt_fl,
    input [4*`BW_FL-1:0] out_fl,
    output reg [`BW_FL-1:0] relu_shift_ch0,
    output reg [`BW_FL-1:0] relu_shift_ch1,
    output reg [`BW_FL-1:0] relu_shift_ch2,
    output reg [`BW_FL-1:0] relu_shift_ch3,
    output reg [`BW_FL-1:0] quantizer_shift_ch0,
    output reg [`BW_FL-1:0] quantizer_shift_ch1,
    output reg [`BW_FL-1:0] quantizer_shift_ch2,
    output reg [`BW_FL-1:0] quantizer_shift_ch3
);

wire [`BW_FL-1:0] ftr_fl_ch0, ftr_fl_ch1, ftr_fl_ch2, ftr_fl_ch3;
wire [`BW_FL-1:0] out_fl_ch0, out_fl_ch1, out_fl_ch2, out_fl_ch3;
assign {ftr_fl_ch0, ftr_fl_ch1, ftr_fl_ch2, ftr_fl_ch3} = ftr_fl;
assign {out_fl_ch0, out_fl_ch1, out_fl_ch2, out_fl_ch3} = out_fl;

/////////////////////////////////////////////////////////////////////////////////
// WorkshopII : Calculate shift amount for postprocessing operations.          //
// WorkshopIII: Align four tuples for directional ReLU and modify shift amount.//
//     Note: Do not implement sequential circuit.                              //
/////////////////////////////////////////////////////////////////////////////////
always@*begin
    relu_shift_ch0 = 0;  
    relu_shift_ch1 = 0;
    relu_shift_ch2 = 0;
    relu_shift_ch3 = 0;

    quantizer_shift_ch0 = ftr_fl_ch0 + wgt_fl - out_fl_ch0;
    quantizer_shift_ch1 = ftr_fl_ch1 + wgt_fl - out_fl_ch1;
    quantizer_shift_ch2 = ftr_fl_ch2 + wgt_fl - out_fl_ch2;
    quantizer_shift_ch3 = ftr_fl_ch3 + wgt_fl - out_fl_ch3;
end
endmodule