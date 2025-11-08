//====================================================================================
//  Module Description: RTL simulation for zebranet accelerator
//  Owner             : Vision Circuits and Systems Lab, National Tsing Hua University
//====================================================================================

// residual connection

`timescale 1ns/10ps

`define CYCLE 10.0
`define INST_FILE "./data/instruction.dat"

// `define FSDB

`define MD_DIR "./data/bw8R1/"
`define BITWIDTH 8
`define N 1

`define IMG_HEIGHT 160
`define IMG_WIDTH  240

// 0: forget directly, 1: reuse internally, 2: reuse externally
`define INF_MODE 2 
`define BLK_HEIGHT 16
`define BLK_WIDTH  64

`define ACT_FL_FILE {`MD_DIR, "activation_fl.dat"}
`define PARAM_FL_FILE {`MD_DIR, "param_fl.dat"}

`define WEIGHT_FILE0 {`MD_DIR, "param_data/conv_head.conv.weight.dat"}
`define WEIGHT_FILE1 {`MD_DIR, "param_data/conv_body.0.body.0.weight.dat"   }
`define WEIGHT_FILE2 {`MD_DIR, "param_data/conv_body.1.body.0.weight.dat"   }
`define WEIGHT_FILE3 {`MD_DIR, "param_data/conv_body.2.body.0.weight.dat"   }
`define WEIGHT_FILE4 {`MD_DIR, "param_data/conv_body.3.body.0.weight.dat"   }
`define WEIGHT_FILE5 {`MD_DIR, "param_data/conv_body.4.body.0.weight.dat"   }
`define WEIGHT_FILE6 {`MD_DIR, "param_data/conv_body.5.body.0.weight.dat"   }
`define WEIGHT_FILE7 {`MD_DIR, "param_data/conv_tail.body.0.weight.dat"}

`define BIAS_FILE0 {`MD_DIR, "param_data/conv_head.conv.bias.dat"}
`define BIAS_FILE1 {`MD_DIR, "param_data/conv_body.0.body.0.bias.dat"   }
`define BIAS_FILE2 {`MD_DIR, "param_data/conv_body.1.body.0.bias.dat"   }
`define BIAS_FILE3 {`MD_DIR, "param_data/conv_body.2.body.0.bias.dat"   }
`define BIAS_FILE4 {`MD_DIR, "param_data/conv_body.3.body.0.bias.dat"   }
`define BIAS_FILE5 {`MD_DIR, "param_data/conv_body.4.body.0.bias.dat"   }
`define BIAS_FILE6 {`MD_DIR, "param_data/conv_body.5.body.0.bias.dat"   }
`define BIAS_FILE7 {`MD_DIR, "param_data/conv_tail.body.0.bias.dat"}

`define OUT_DIR "./result/"
`define OUT_FILE {`OUT_DIR, "out.dat"}
`define TOTAL_LAYER 8

// testing modes: CONV1, RESBLOCK1, IMAGE_OUT
`define OUT_ACT_FILE0 { `MD_DIR, "activation_data/conv_head.SRAM_output.dat"   }
`define OUT_ACT_FILE1 { `MD_DIR, "activation_data/conv_body.0.SRAM_output.dat" }
`define OUT_ACT_FILE2 { `MD_DIR, "activation_data/conv_body.1.SRAM_output.dat" }
`define OUT_ACT_FILE3 { `MD_DIR, "activation_data/conv_body.2.SRAM_output.dat" }
`define OUT_ACT_FILE4 { `MD_DIR, "activation_data/conv_body.3.SRAM_output.dat" }
`define OUT_ACT_FILE5 { `MD_DIR, "activation_data/conv_body.4.SRAM_output.dat" }
`define OUT_ACT_FILE6 { `MD_DIR, "activation_data/conv_body.5.SRAM_output.dat" }
`define OUT_ACT_FILE7 { `MD_DIR, "activation_data/conv_tail.SRAM_out.dat"      }

`define IN_ACT_FILE { `MD_DIR, "activation_data/conv_head.SRAM_input.dat" }
`define GOLD_FILE   { `MD_DIR, "activation_data/conv_tail.SRAM_out.dat" }


module test_cnn;

parameter BASE_CHANNEL = 16; // model base channel
parameter MAX_CHANNEL  = 96; // preserved space for last layer
parameter INST_LEN = 8*4;

parameter BW_FL = 4;
parameter IN_CHANNEL = 16; // conv engine parallelism
parameter OUT_CHANNEL=  4; // conv engine parallelism
parameter CONV_LATENCY = 1; // latency of conv engine (conv pipeline)
parameter POST_LATENCY = 8; // latency of conv engine (full pipeline)

// image IO interface
// block out size
parameter IMG_O_HEIGHT = `IMG_HEIGHT*4;
parameter IMG_O_WIDTH = `IMG_WIDTH*4;

parameter BLK_O_HEIGHT = `BLK_HEIGHT;
parameter BLK_O_WIDTH = (`INF_MODE==0)? (`BLK_WIDTH-`TOTAL_LAYER*2): `BLK_WIDTH;


parameter IMG_I_MEM_SIZE = (`IMG_HEIGHT+`TOTAL_LAYER*2)*(`IMG_WIDTH+`TOTAL_LAYER*2)*3;
parameter IMG_O_MEM_SIZE = IMG_O_HEIGHT*IMG_O_WIDTH*3;

// feature block interface
parameter BLK_MEM_SIZE = `BLK_HEIGHT*`BLK_WIDTH*BASE_CHANNEL;
parameter REUSE_X_MEM_SIZE = (`IMG_HEIGHT+`TOTAL_LAYER*2)*BASE_CHANNEL*2*`TOTAL_LAYER;
parameter REUSE_Y_MEM_SIZE = `BLK_WIDTH*BASE_CHANNEL*2*`TOTAL_LAYER; 

//========== memory ==========//

// per model memory for configuration signal (instruction,parameter,frational length), load one for every image
reg [INST_LEN-1:0] inst [0:`TOTAL_LAYER-1]; // one line presents configuration for one layer
reg [`BITWIDTH-1:0] bias_mem [0: MAX_CHANNEL*`TOTAL_LAYER-1]; // one line presents bias for one output channel
reg [9*MAX_CHANNEL*`BITWIDTH-1:0] wgt_mem [0: MAX_CHANNEL*`TOTAL_LAYER-1]; // one line presents conv filter for one output channel
reg [9*MAX_CHANNEL*`BITWIDTH-1:0] wgt_mem_test [0: MAX_CHANNEL-1]; // one line presents conv filter for one output channel

reg [BW_FL-1:0] act_fl_mem [0:2*`TOTAL_LAYER-1]; // one line presents frational length for one layer output (note: first line presents input)
reg [BW_FL-1:0] param_fl_mem [0:2*`TOTAL_LAYER-1]; // one line presents frational length for one layer weight/bias


// external image memory interface
reg [`BITWIDTH-1:0] external_img_input_mem  [0:IMG_I_MEM_SIZE-1];
reg [`BITWIDTH-1:0] external_img_output_mem [0:IMG_O_MEM_SIZE-1];

reg [`BITWIDTH-1:0] golden_img_output_mem [0:IMG_O_MEM_SIZE-1];

// on-chip image feature block buffer interface
reg [`BITWIDTH-1:0] internal_block_mem_0 [0:BLK_MEM_SIZE-1];
reg [`BITWIDTH-1:0] internal_block_mem_1 [0:BLK_MEM_SIZE-1];
reg [`BITWIDTH-1:0] internal_block_mem_2 [0:BLK_MEM_SIZE-1];

// feature boundary reuse buffer interface (y-dir, row-dir, along-stripe)
reg [`BITWIDTH-1:0] internal_reuse_mem_y [0:REUSE_Y_MEM_SIZE-1];

// feature boundary reuse buffer interface (x-dir, col-dir, across-stripe)
reg [`BITWIDTH-1:0] internal_reuse_mem_x [0:REUSE_X_MEM_SIZE-1];
reg [`BITWIDTH-1:0] external_reuse_mem_x [0:REUSE_X_MEM_SIZE-1];


//========== debugging ==========//
// for last layer reorder purpose 
parameter VIRTUAL_BLK_OUT_SIZE = `BLK_HEIGHT*`BLK_WIDTH*MAX_CHANNEL;
reg [`BITWIDTH-1:0] virtual_block_output [0:VIRTUAL_BLK_OUT_SIZE-1];

// for per-layer imtermidiate feature check
parameter INTER_FEATURE_MEM_SIZE = (`IMG_HEIGHT+`TOTAL_LAYER*2)*(`IMG_WIDTH+`TOTAL_LAYER*2)*MAX_CHANNEL;
reg [`BITWIDTH-1:0] inter_feature_mem [0:INTER_FEATURE_MEM_SIZE*`TOTAL_LAYER-1];


//========== main loops ==========//
reg fsdb_turnon_flag;

reg clk;
reg rst_n;
// pipeline control
reg conv_din_enable;
wire conv_dout_valid;
// datapath control
reg relu; // relu enable
// frational length
reg [4*BW_FL-1:0] in_fl; // input activation fl
reg [4*BW_FL-1:0] out_fl; // output activation fl
reg [BW_FL-1:0] wgt_fl;   // weight fl
reg [BW_FL-1:0] bias_fl;  // bias fl
// data
reg [IN_CHANNEL*9*`BITWIDTH-1:0] in_activation; // input activation data (16-ch)
reg [OUT_CHANNEL*IN_CHANNEL*9*`BITWIDTH-1:0] weight; // weight data (16-ch to 4-ch)
reg [OUT_CHANNEL*`BITWIDTH-1:0] bias; // bias data (4-ch)
wire [OUT_CHANNEL*`BITWIDTH-1:0] out_acivation; // output activation data (4-ch)

conv_top conv_top_U0(
    .clk(clk),
    .rst_n(rst_n),
    .conv_din_enable(conv_din_enable),
    .conv_dout_valid(conv_dout_valid),
    .in_fl(in_fl),
    .wgt_fl(wgt_fl),
    .bias_fl(bias_fl),
    .out_fl(out_fl),
    .in_activation(in_activation),
    .weight(weight),
    .bias(bias),
    .relu(relu),
    .out_acivation(out_acivation)
);


//========== Initialization ==========//
always #(`CYCLE/2) clk = ~clk;
initial begin
    wait(fsdb_turnon_flag);
	$fsdbDumpfile("cnn.fsdb");
	$fsdbDumpvars("+mda", test_cnn);
    $fsdbDumpvars(2);
end

initial begin
    clk = 0;    
    rst_n = 1;
    #(`CYCLE*2) rst_n = 0; 
    #(`CYCLE*2) rst_n = 1; 
end

integer cycle_cnt;

always@(posedge clk)begin
    if(~rst_n)begin
        cycle_cnt <= 0;
    end else begin
        cycle_cnt <= cycle_cnt + 1;
    end
end
//========== variable declaration ==========//
integer signed pixel_x_idx_in, pixel_y_idx_in;
integer signed block_x_idx_in, block_y_idx_in;
integer signed layer_idx_in;

integer signed pixel_x_idx_out, pixel_y_idx_out;
integer signed block_x_idx_out, block_y_idx_out;
integer signed layer_idx_out;

reg [3:0] Relu, srcSRAM, resSRAM, dstSRAM;
reg [7:0] CHout, CHin; 
reg [11:0] blkH_out, blkW_out;

//========== load pattern from file ==========//
initial begin
    load_instruction;
    load_wgt;
    load_bias;
    load_fl; 
    load_act;
    load_golden;
    load_inter_feature;
    // debugging
    fsdb_turnon_flag = 0;
    `ifdef FSDB
        fsdb_turnon_flag = 1;
    `endif
    $display("Load files finish.");
    case(1)
        (`INF_MODE==0): $display("\n ==> (Inference Mode = %d)\n Perform whole frame inference for block-based layer-fusion with directly forgotten in across-stripe overlapped region!", `INF_MODE); 
        (`INF_MODE==1): $display("\n ==> (Inference Mode = %d)\n Perform whole frame inference for block-based layer-fusion with internally reusing in across-stripe overlapped region!", `INF_MODE);
        (`INF_MODE==2): $display("\n ==> (Inference Mode = %d)\n Perform whole frame inference for block-based layer-fusion with externally reusing in across-stripe overlapped region!", `INF_MODE);
    endcase
    #(1000000000000*`CYCLE) $finish;
end

// pattern feed  
initial begin 
    // signal & variable initialization
    pixel_x_idx_in = 0; pixel_y_idx_in = 0;
    block_x_idx_in = 0; block_y_idx_in = 0;
    layer_idx_in = 0;

    conv_din_enable = 0;
    wait(rst_n==0);
    wait(rst_n==1); 
    while (pixel_x_idx_in+`BLK_WIDTH <= `IMG_WIDTH) begin // across stripe partition (x-dim)
        while (pixel_y_idx_in+`BLK_HEIGHT <= `IMG_HEIGHT) begin // along stripe partition (y-dim)
            input_block_preparation; // read image block (external memory -> internal block buffer)
            // fsdb_turnon_flag = 1;
            while(layer_idx_in < `TOTAL_LAYER)begin // layer-by-layer inference for one block
                engine_config; // feed configuration in one cycle (intruction, frational length)

                conv_layer_inference; // perform convolution for whole block 
                
                @(negedge clk);
                layer_idx_in = layer_idx_in + 1; // prepare next layer
                // $finish;
            end
            // $display("end of layer");
            // fsdb_turnon_flag = 1;
            @(negedge clk);
            layer_idx_in = 0; block_y_idx_in = block_y_idx_in + 1;
        end
        // $display("end of y");
        pixel_y_idx_in = 0;
        block_y_idx_in = 0; block_x_idx_in = block_x_idx_in + 1; ;
    end
        
end

// result latch
initial begin
    // signal & variable initialization
    pixel_x_idx_out = 0; pixel_y_idx_out = 0;
    block_x_idx_out = 0; block_y_idx_out = 0;
    layer_idx_out = 0;
    wait(rst_n==0);
    wait(rst_n==1);

    while (pixel_x_idx_out+BLK_O_WIDTH*4 < IMG_O_WIDTH) begin // across stripe partition (x-dim)
        while (pixel_y_idx_out+BLK_O_HEIGHT*4 < IMG_O_HEIGHT) begin // along stripe partition (y-dim)
            // $display("=========================================>");
            while(layer_idx_out < `TOTAL_LAYER)begin // layer-by-layer inference for one block
                // $display("BlkOut Y_idx = %d, X_idx = %d, Layer = %d", block_y_idx_out, block_x_idx_out, layer_idx_out);
                per_layer_output_block_preparation; // block buffer storage
                `ifdef CHECK_RESULT_LAYER
                    if (layer_idx_out < `TOTAL_LAYER-1) begin
                        block_out_per_layer_result_check; // check result (per layer)
                    end
                `endif
                @(negedge clk);
                layer_idx_out = layer_idx_out + 1; // prepare next layer
            end
            block_out_per_model_result_check;
            @(negedge clk);
            // $display("end of layer (out)");
            // $display("Y, X = %d, %d", pixel_y_idx_out, pixel_x_idx_out);
            layer_idx_out = 0; block_y_idx_out = block_y_idx_out + 1; 
        end
        // $display("end of y (out)");
        pixel_y_idx_out = 0;
        block_y_idx_out = 0; block_x_idx_out = block_x_idx_out + 1;  
    end
    $display("\n\n\n------------------------------");
    $display("-- Simulation finish, ALL PASS!  --");
    write_image;
    case(1)
        (`INF_MODE==0): $display("(Inference Mode = %d)\n The inference of whole frame for block-based layer-fusion with directly forgotten in across-stripe overlapped region has passed!", `INF_MODE); 
        (`INF_MODE==1): $display("(Inference Mode = %d)\n The inference of whole frame for block-based layer-fusion with internally reusing in across-stripe overlapped region has passed!", `INF_MODE);
        (`INF_MODE==2): $display("(Inference Mode = %d)\n The inference of whole frame for block-based layer-fusion with externally reusing in across-stripe overlapped region has passed!", `INF_MODE);
    endcase
    case(1)
        (`INF_MODE==0): $display("\n ==> On-chip block buffer size = %d KB, On-chip reuse buffer size = %d KB", BLK_MEM_SIZE/1024*2, REUSE_Y_MEM_SIZE/1024);
        (`INF_MODE==1): $display("\n ==> On-chip block buffer size = %d KB, On-chip reuse buffer size = %d KB", BLK_MEM_SIZE/1024*2, (REUSE_Y_MEM_SIZE+REUSE_X_MEM_SIZE)/1024);
        (`INF_MODE==2): $display("\n ==> On-chip block buffer size = %d KB, On-chip reuse buffer size = %d KB, Off-chip reuse feature access = %d KB", BLK_MEM_SIZE/1024*2, REUSE_Y_MEM_SIZE/1024, REUSE_X_MEM_SIZE*2*4/1024);
    endcase
    case(1)
        (`INF_MODE==0): $display("\n ==> Off-chip frame_in access = %d KB, Off-chip frame_out access = %d KB ", (64*16)*5*11*3/1024, (160*4)*(240*4)*3/1024);
        (`INF_MODE==1): $display("\n ==> Off-chip frame_in access = %d KB, Off-chip frame_out access = %d KB ", (64*16)*4*11*3/1024, (160*4)*(240*4)*3/1024);
        (`INF_MODE==2): $display("\n ==> Off-chip frame_in access = %d KB, Off-chip frame_out access = %d KB ", (64*16)*4*11*3/1024, (160*4)*(240*4)*3/1024);
    endcase
    $display("\n ==> Total simulation cycle count = %d", cycle_cnt);
    $display("------------------------------\n\n\n");
    $finish;
end





// -------------------------------------------
`include "task.v"

endmodule
