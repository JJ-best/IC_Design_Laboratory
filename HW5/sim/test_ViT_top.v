//======================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2025 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//======================================================================================================

`timescale 1ns/100ps

`define PAT_L 0
`define PAT_U 1
`define NUM_PAT (`PAT_U-`PAT_L+1)

`define PAT_NAME_LENGTH 3
`define CYCLE 10
`define END_CYCLES 20000 // you can enlarge the cycle count limit for longer simulation
`define FLAG_VERBOSE 1  
`define FLAG_DUMPWV 1

module test_vit_top;

// Parameters (adjust as needed)
localparam CH_NUM = 8;
localparam BW_PER_ACT = 10;
localparam ACT_PER_ADDR = 1;
localparam BW_PER_SRAM_GROUP_ADDR = CH_NUM*ACT_PER_ADDR*BW_PER_ACT; // 8 x 10 = 80
localparam WEIGHT_PER_ADDR = 16, BIAS_PER_ADDR = 1;
localparam BW_PER_PARAM = 10;

localparam PATCHEMBED = 5'd0, LNORM1 = 5'd1, QKV_HEAD0 = 5'd2, QKV_HEAD1 = 5'd3;
localparam QKMUL_HEAD0_CHUNK0 = 5'd4, QKMUL_HEAD0_CHUNK1 = 5'd5, QKMUL_HEAD0_CHUNK2 = 5'd6, QKMUL_HEAD0_CHUNK3 = 5'd7, QKMUL_HEAD1_CHUNK0 = 5'd8, QKMUL_HEAD1_CHUNK1 = 5'd9, QKMUL_HEAD1_CHUNK2 = 5'd10, QKMUL_HEAD1_CHUNK3 = 5'd11;
localparam SOFTMAX_HEAD0_CHUNK0 = 5'd12, SOFTMAX_HEAD0_CHUNK1 = 5'd13, SOFTMAX_HEAD0_CHUNK2 = 5'd14, SOFTMAX_HEAD0_CHUNK3 = 5'd15, SOFTMAX_HEAD1_CHUNK0 = 5'd16, SOFTMAX_HEAD1_CHUNK1 = 5'd17, SOFTMAX_HEAD1_CHUNK2 = 5'd18, SOFTMAX_HEAD1_CHUNK3 = 5'd19;
localparam VMUL_HEAD0 = 5'd20, VMUL_HEAD1 = 5'd21, OPROJ = 5'd22, RESIDUAL1 = 5'd23, LNORM2 = 5'd24, FFN_HIDDEN_CHUNK0 = 5'd25, FFN_HIDDEN_CHUNK1 = 5'd26, FFNOUT = 5'd27, RESIDUAL2 = 5'd28;
localparam A0=0, A1=1, A2=2, A3=3, B0=4, B1=5, B2=6, B3=7, C0=8, C1=9, C2=10, C3=11, D0=12, D1=13, D2=14, D3=15;
localparam A = 0, B = 1, C = 2, D = 3;

integer test_layer;
reg [8*26-1:0] layer_str;

initial begin
    layer_str = 0;
    `ifdef PATCHEMBED
        test_layer = PATCHEMBED;
        layer_str = "      Patch embedding     ";
    `elsif LNORM1
        test_layer = LNORM1;
        layer_str = "     L1 normalization1    ";
    `elsif QKV_HEAD0
        test_layer = QKV_HEAD0;
        layer_str = "   QKV projection head0   ";
    `elsif QKV_HEAD1
        test_layer = QKV_HEAD1;
        layer_str = "   QKV projection head1   ";
    `elsif QKMUL_HEAD0_CHUNK0
        test_layer = QKMUL_HEAD0_CHUNK0;
        layer_str = "   Q@K head0 row00~row15   ";
    `elsif QKMUL_HEAD0_CHUNK1
        test_layer = QKMUL_HEAD0_CHUNK1;
        layer_str = "   Q@K head0 row16~row31   ";
    `elsif QKMUL_HEAD0_CHUNK2
        test_layer = QKMUL_HEAD0_CHUNK2;
        layer_str = "   Q@K head0 row32~row47   ";
    `elsif QKMUL_HEAD0_CHUNK3
        test_layer = QKMUL_HEAD0_CHUNK3;
        layer_str = "   Q@K head0 row48~row63   ";
    `elsif QKMUL_HEAD1_CHUNK0
        test_layer = QKMUL_HEAD1_CHUNK0;
        layer_str = "   Q@K head1 row00~row15   ";
    `elsif QKMUL_HEAD1_CHUNK1
        test_layer = QKMUL_HEAD1_CHUNK1;
        layer_str = "   Q@K head1 row16~row31   ";
    `elsif QKMUL_HEAD1_CHUNK2
        test_layer = QKMUL_HEAD1_CHUNK2;
        layer_str = "   Q@K head1 row32~row47   ";
    `elsif QKMUL_HEAD1_CHUNK3
        test_layer = QKMUL_HEAD1_CHUNK3;
        layer_str = "   Q@K head1 row48~row63   ";
    `elsif SOFTMAX_HEAD0_CHUNK0
        test_layer = SOFTMAX_HEAD0_CHUNK0;
        layer_str = " Softmax head0 row00~row15 ";
    `elsif SOFTMAX_HEAD0_CHUNK1
        test_layer = SOFTMAX_HEAD0_CHUNK1;
        layer_str = " Softmax head0 row16~row31 ";
    `elsif SOFTMAX_HEAD0_CHUNK2
        test_layer = SOFTMAX_HEAD0_CHUNK2;
        layer_str = " Softmax head0 row32~row47 ";
    `elsif SOFTMAX_HEAD0_CHUNK3
        test_layer = SOFTMAX_HEAD0_CHUNK3;
        layer_str = " Softmax head0 row48~row63 ";
    `elsif SOFTMAX_HEAD1_CHUNK0
        test_layer = SOFTMAX_HEAD1_CHUNK0;
        layer_str = " Softmax head1 row00~row15 ";
    `elsif SOFTMAX_HEAD1_CHUNK1
        test_layer = SOFTMAX_HEAD1_CHUNK1;
        layer_str = " Softmax head1 row16~row31 ";
    `elsif SOFTMAX_HEAD1_CHUNK2
        test_layer = SOFTMAX_HEAD1_CHUNK2;
        layer_str = " Softmax head1 row32~row47 ";
    `elsif SOFTMAX_HEAD1_CHUNK3
        test_layer = SOFTMAX_HEAD1_CHUNK3;
        layer_str = " Softmax head1 row48~row63 ";
    `elsif VMUL_HEAD0
        test_layer = VMUL_HEAD0;
        layer_str = "     Softmax@V head0      ";
    `elsif VMUL_HEAD1
        test_layer = VMUL_HEAD1;
        layer_str = "     Softmax@V head1      ";
    `elsif OPROJ
        test_layer = OPROJ;
        layer_str = "       O projection       ";
    `elsif RESIDUAL1
        test_layer = RESIDUAL1;
        layer_str = "      Residual add 1      ";
    `elsif LNORM2
        test_layer = LNORM2;
        layer_str = "     L1 normalization2    ";
    `elsif FFN_HIDDEN_CHUNK0
        test_layer = FFN_HIDDEN_CHUNK0;
        layer_str = "FFN hidden layer ch00~ch23";
    `elsif FFN_HIDDEN_CHUNK1
        test_layer = FFN_HIDDEN_CHUNK1;
        layer_str = "FFN hidden layer ch24~ch47";
    `elsif FFNOUT
        test_layer = FFNOUT;
        layer_str = "     FFN output layer      ";
    `elsif RESIDUAL2
        test_layer = RESIDUAL2;
        layer_str = "      Residual add 2      ";
    `endif
end

integer i;
// ===== pattern files ===== // 
reg [44*8-1:0] patch_embed_a0_golden_file, patch_embed_a1_golden_file, patch_embed_a2_golden_file, patch_embed_a3_golden_file;
reg [37*8-1:0] lnorm1_b0_golden_file, lnorm1_b1_golden_file, lnorm1_b2_golden_file, lnorm1_b3_golden_file;
reg [52*8-1:0] qkv_head0_c0_golden_file, qkv_head0_c1_golden_file, qkv_head0_c2_golden_file, qkv_head0_c3_golden_file;
reg [52*8-1:0] qkv_head1_c0_golden_file, qkv_head1_c1_golden_file, qkv_head1_c2_golden_file, qkv_head1_c3_golden_file;
reg [57*8-1:0] qkmul_head0_chunk0_d0_golden_file, qkmul_head0_chunk0_d1_golden_file, qkmul_head0_chunk0_d2_golden_file, qkmul_head0_chunk0_d3_golden_file;
reg [57*8-1:0] qkmul_head0_chunk1_d0_golden_file, qkmul_head0_chunk1_d1_golden_file, qkmul_head0_chunk1_d2_golden_file, qkmul_head0_chunk1_d3_golden_file;
reg [57*8-1:0] qkmul_head0_chunk2_d0_golden_file, qkmul_head0_chunk2_d1_golden_file, qkmul_head0_chunk2_d2_golden_file, qkmul_head0_chunk2_d3_golden_file;
reg [57*8-1:0] qkmul_head0_chunk3_d0_golden_file, qkmul_head0_chunk3_d1_golden_file, qkmul_head0_chunk3_d2_golden_file, qkmul_head0_chunk3_d3_golden_file;
reg [57*8-1:0] qkmul_head1_chunk0_d0_golden_file, qkmul_head1_chunk0_d1_golden_file, qkmul_head1_chunk0_d2_golden_file, qkmul_head1_chunk0_d3_golden_file;
reg [57*8-1:0] qkmul_head1_chunk1_d0_golden_file, qkmul_head1_chunk1_d1_golden_file, qkmul_head1_chunk1_d2_golden_file, qkmul_head1_chunk1_d3_golden_file;
reg [57*8-1:0] qkmul_head1_chunk2_d0_golden_file, qkmul_head1_chunk2_d1_golden_file, qkmul_head1_chunk2_d2_golden_file, qkmul_head1_chunk2_d3_golden_file;
reg [57*8-1:0] qkmul_head1_chunk3_d0_golden_file, qkmul_head1_chunk3_d1_golden_file, qkmul_head1_chunk3_d2_golden_file, qkmul_head1_chunk3_d3_golden_file;
reg [57*8-1:0] softmax_head0_chunk0_b0_golden_file, softmax_head0_chunk0_b1_golden_file, softmax_head0_chunk0_b2_golden_file, softmax_head0_chunk0_b3_golden_file;
reg [57*8-1:0] softmax_head0_chunk1_b0_golden_file, softmax_head0_chunk1_b1_golden_file, softmax_head0_chunk1_b2_golden_file, softmax_head0_chunk1_b3_golden_file;
reg [57*8-1:0] softmax_head0_chunk2_b0_golden_file, softmax_head0_chunk2_b1_golden_file, softmax_head0_chunk2_b2_golden_file, softmax_head0_chunk2_b3_golden_file;
reg [57*8-1:0] softmax_head0_chunk3_b0_golden_file, softmax_head0_chunk3_b1_golden_file, softmax_head0_chunk3_b2_golden_file, softmax_head0_chunk3_b3_golden_file;
reg [57*8-1:0] softmax_head1_chunk0_b0_golden_file, softmax_head1_chunk0_b1_golden_file, softmax_head1_chunk0_b2_golden_file, softmax_head1_chunk0_b3_golden_file;
reg [57*8-1:0] softmax_head1_chunk1_b0_golden_file, softmax_head1_chunk1_b1_golden_file, softmax_head1_chunk1_b2_golden_file, softmax_head1_chunk1_b3_golden_file;
reg [57*8-1:0] softmax_head1_chunk2_b0_golden_file, softmax_head1_chunk2_b1_golden_file, softmax_head1_chunk2_b2_golden_file, softmax_head1_chunk2_b3_golden_file;
reg [57*8-1:0] softmax_head1_chunk3_b0_golden_file, softmax_head1_chunk3_b1_golden_file, softmax_head1_chunk3_b2_golden_file, softmax_head1_chunk3_b3_golden_file;
reg [54*8-1:0] vmul_head0_d0_golden_file, vmul_head0_d1_golden_file, vmul_head0_d2_golden_file, vmul_head0_d3_golden_file;
reg [54*8-1:0] vmul_head1_d0_golden_file, vmul_head1_d1_golden_file, vmul_head1_d2_golden_file, vmul_head1_d3_golden_file;
reg [42*8-1:0] oproj_c0_golden_file, oproj_c1_golden_file, oproj_c2_golden_file, oproj_c3_golden_file;
reg [56*8-1:0] residual1_b0_golden_file, residual1_b1_golden_file, residual1_b2_golden_file, residual1_b3_golden_file;
reg [37*8-1:0] lnorm2_a0_golden_file, lnorm2_a1_golden_file, lnorm2_a2_golden_file, lnorm2_a3_golden_file;
reg [50*8-1:0] ffn_hidden_c0_golden_file, ffn_hidden_c1_golden_file, ffn_hidden_c2_golden_file, ffn_hidden_c3_golden_file;
reg [50*8-1:0] ffn_hidden_d0_golden_file, ffn_hidden_d1_golden_file, ffn_hidden_d2_golden_file, ffn_hidden_d3_golden_file;
reg [48*8-1:0] ffnout_a0_golden_file, ffnout_a1_golden_file, ffnout_a2_golden_file, ffnout_a3_golden_file;
reg [56*8-1:0] residual2_b0_golden_file, residual2_b1_golden_file, residual2_b2_golden_file, residual2_b3_golden_file;

// ===== module I/O ===== //
reg clk;
reg srst_n;
reg enable;
wire valid;

wire [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_weight; // 9 x 8 = 72
wire [8-1:0] sram_raddr_weight; //

wire [BIAS_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_bias; // 1 x 8 = 8
wire [7-1:0] sram_raddr_bias; // ceil(log2(40)) = 6

wire sram_wen_a0, sram_wen_a1, sram_wen_a2, sram_wen_a3;
wire sram_wen_b0, sram_wen_b1, sram_wen_b2, sram_wen_b3;
wire sram_wen_c0, sram_wen_c1, sram_wen_c2, sram_wen_c3;
wire sram_wen_d0, sram_wen_d1, sram_wen_d2, sram_wen_d3;

wire [BW_PER_SRAM_GROUP_ADDR-1:0] sram_rdata_a0, sram_rdata_a1, sram_rdata_a2, sram_rdata_a3;
wire [BW_PER_SRAM_GROUP_ADDR-1:0] sram_rdata_b0, sram_rdata_b1, sram_rdata_b2, sram_rdata_b3;
wire [BW_PER_SRAM_GROUP_ADDR-1:0] sram_rdata_c0, sram_rdata_c1, sram_rdata_c2, sram_rdata_c3;
wire [BW_PER_SRAM_GROUP_ADDR-1:0] sram_rdata_d0, sram_rdata_d1, sram_rdata_d2, sram_rdata_d3;

wire [5-1:0] sram_addr_a0, sram_addr_a1, sram_addr_a2, sram_addr_a3;  
wire [5-1:0] sram_addr_b0, sram_addr_b1, sram_addr_b2, sram_addr_b3;
wire [6-1:0] sram_addr_c0, sram_addr_c1, sram_addr_c2, sram_addr_c3;
wire [6-1:0] sram_addr_d0, sram_addr_d1, sram_addr_d2, sram_addr_d3;

wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a0, sram_wordmask_a1, sram_wordmask_a2, sram_wordmask_a3;
wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b0, sram_wordmask_b1, sram_wordmask_b2, sram_wordmask_b3;
wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_c0, sram_wordmask_c1, sram_wordmask_c2, sram_wordmask_c3;
wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_d0, sram_wordmask_d1, sram_wordmask_d2, sram_wordmask_d3;

wire [BW_PER_SRAM_GROUP_ADDR-1:0] sram_wdata_a0, sram_wdata_a1, sram_wdata_a2, sram_wdata_a3;
wire [BW_PER_SRAM_GROUP_ADDR-1:0] sram_wdata_b0, sram_wdata_b1, sram_wdata_b2, sram_wdata_b3;
wire [BW_PER_SRAM_GROUP_ADDR-1:0] sram_wdata_c0, sram_wdata_c1, sram_wdata_c2, sram_wdata_c3;
wire [BW_PER_SRAM_GROUP_ADDR-1:0] sram_wdata_d0, sram_wdata_d1, sram_wdata_d2, sram_wdata_d3;

// Instantiate ViT RTL module
ViT_top #(
.CH_NUM(CH_NUM),
.ACT_PER_ADDR(ACT_PER_ADDR),
.BW_PER_ACT(BW_PER_ACT),
.WEIGHT_PER_ADDR(WEIGHT_PER_ADDR), 
.BIAS_PER_ADDR(BIAS_PER_ADDR),
.BW_PER_PARAM(BW_PER_PARAM)
) uut (
.clk(clk),
.srst_n(srst_n),
.enable(enable),
.valid(valid),

.sram_rdata_a0(sram_rdata_a0),
.sram_rdata_a1(sram_rdata_a1),
.sram_rdata_a2(sram_rdata_a2),
.sram_rdata_a3(sram_rdata_a3),
.sram_rdata_b0(sram_rdata_b0),
.sram_rdata_b1(sram_rdata_b1),
.sram_rdata_b2(sram_rdata_b2),
.sram_rdata_b3(sram_rdata_b3),
.sram_rdata_c0(sram_rdata_c0),
.sram_rdata_c1(sram_rdata_c1),
.sram_rdata_c2(sram_rdata_c2),
.sram_rdata_c3(sram_rdata_c3),
.sram_rdata_d0(sram_rdata_d0),
.sram_rdata_d1(sram_rdata_d1),
.sram_rdata_d2(sram_rdata_d2),
.sram_rdata_d3(sram_rdata_d3),
.sram_rdata_weight(sram_rdata_weight),
.sram_rdata_bias(sram_rdata_bias),

.sram_addr_a0(sram_addr_a0),
.sram_addr_a1(sram_addr_a1),
.sram_addr_a2(sram_addr_a2),
.sram_addr_a3(sram_addr_a3),
.sram_addr_b0(sram_addr_b0),
.sram_addr_b1(sram_addr_b1),
.sram_addr_b2(sram_addr_b2),
.sram_addr_b3(sram_addr_b3),
.sram_addr_c0(sram_addr_c0),
.sram_addr_c1(sram_addr_c1),
.sram_addr_c2(sram_addr_c2),
.sram_addr_c3(sram_addr_c3),
.sram_addr_d0(sram_addr_d0),
.sram_addr_d1(sram_addr_d1),
.sram_addr_d2(sram_addr_d2),
.sram_addr_d3(sram_addr_d3),
.sram_raddr_weight(sram_raddr_weight),
.sram_raddr_bias(sram_raddr_bias),

.sram_wen_a0(sram_wen_a0),
.sram_wen_a1(sram_wen_a1),
.sram_wen_a2(sram_wen_a2),
.sram_wen_a3(sram_wen_a3),
.sram_wen_b0(sram_wen_b0),
.sram_wen_b1(sram_wen_b1),
.sram_wen_b2(sram_wen_b2),
.sram_wen_b3(sram_wen_b3),
.sram_wen_c0(sram_wen_c0),
.sram_wen_c1(sram_wen_c1),
.sram_wen_c2(sram_wen_c2),
.sram_wen_c3(sram_wen_c3),
.sram_wen_d0(sram_wen_d0),
.sram_wen_d1(sram_wen_d1),
.sram_wen_d2(sram_wen_d2),
.sram_wen_d3(sram_wen_d3),

.sram_wordmask_a0(sram_wordmask_a0),
.sram_wordmask_a1(sram_wordmask_a1),
.sram_wordmask_a2(sram_wordmask_a2),
.sram_wordmask_a3(sram_wordmask_a3),
.sram_wordmask_b0(sram_wordmask_b0),
.sram_wordmask_b1(sram_wordmask_b1),
.sram_wordmask_b2(sram_wordmask_b2),
.sram_wordmask_b3(sram_wordmask_b3),
.sram_wordmask_c0(sram_wordmask_c0),
.sram_wordmask_c1(sram_wordmask_c1),
.sram_wordmask_c2(sram_wordmask_c2),
.sram_wordmask_c3(sram_wordmask_c3),
.sram_wordmask_d0(sram_wordmask_d0),
.sram_wordmask_d1(sram_wordmask_d1),
.sram_wordmask_d2(sram_wordmask_d2),
.sram_wordmask_d3(sram_wordmask_d3),

.sram_wdata_a0(sram_wdata_a0),
.sram_wdata_a1(sram_wdata_a1),
.sram_wdata_a2(sram_wdata_a2),
.sram_wdata_a3(sram_wdata_a3),
.sram_wdata_b0(sram_wdata_b0),
.sram_wdata_b1(sram_wdata_b1),
.sram_wdata_b2(sram_wdata_b2),
.sram_wdata_b3(sram_wdata_b3),
.sram_wdata_c0(sram_wdata_c0),
.sram_wdata_c1(sram_wdata_c1),
.sram_wdata_c2(sram_wdata_c2),
.sram_wdata_c3(sram_wdata_c3),
.sram_wdata_d0(sram_wdata_d0),
.sram_wdata_d1(sram_wdata_d1),
.sram_wdata_d2(sram_wdata_d2),
.sram_wdata_d3(sram_wdata_d3)
);


// ===== sram connection ===== //
// SRAM for PARAM
sram_weight #(
.WEIGHT_PER_ADDR(WEIGHT_PER_ADDR),
.BW_PER_PARAM(BW_PER_PARAM)
) sram_weight_u(
.clk(clk),
.csb(1'b0),
.wsb(1'b1),
.wdata({WEIGHT_PER_ADDR*BW_PER_PARAM{1'b0}}), 
.waddr(8'd0), 
.raddr(sram_raddr_weight), 
.rdata(sram_rdata_weight)
);

sram_bias #(
.BIAS_PER_ADDR(BIAS_PER_ADDR),
.BW_PER_PARAM(BW_PER_PARAM)
) sram_bias_u(
.clk(clk),
.csb(1'b0),
.wsb(1'b1),
.wdata({BIAS_PER_ADDR*BW_PER_PARAM{1'b0}}), 
.waddr(7'd0), 
.raddr(sram_raddr_bias), 
.rdata(sram_rdata_bias)
);

// SRAM A
sram_act_small sram_act_a0(.clk(clk), .wordmask(sram_wordmask_a0), .csb(1'b0), .wsb(sram_wen_a0), .wdata(sram_wdata_a0),  .waddr(sram_addr_a0),  .raddr(sram_addr_a0),  .rdata(sram_rdata_a0));
sram_act_small sram_act_a1(.clk(clk), .wordmask(sram_wordmask_a1), .csb(1'b0), .wsb(sram_wen_a1), .wdata(sram_wdata_a1),  .waddr(sram_addr_a1),  .raddr(sram_addr_a1),  .rdata(sram_rdata_a1));
sram_act_small sram_act_a2(.clk(clk), .wordmask(sram_wordmask_a2), .csb(1'b0), .wsb(sram_wen_a2), .wdata(sram_wdata_a2),  .waddr(sram_addr_a2),  .raddr(sram_addr_a2),  .rdata(sram_rdata_a2));
sram_act_small sram_act_a3(.clk(clk), .wordmask(sram_wordmask_a3), .csb(1'b0), .wsb(sram_wen_a3), .wdata(sram_wdata_a3),  .waddr(sram_addr_a3),  .raddr(sram_addr_a3),  .rdata(sram_rdata_a3));
// SRAM B
sram_act_small sram_act_b0(.clk(clk), .wordmask(sram_wordmask_b0), .csb(1'b0), .wsb(sram_wen_b0), .wdata(sram_wdata_b0),  .waddr(sram_addr_b0),  .raddr(sram_addr_b0),  .rdata(sram_rdata_b0));
sram_act_small sram_act_b1(.clk(clk), .wordmask(sram_wordmask_b1), .csb(1'b0), .wsb(sram_wen_b1), .wdata(sram_wdata_b1),  .waddr(sram_addr_b1),  .raddr(sram_addr_b1),  .rdata(sram_rdata_b1));
sram_act_small sram_act_b2(.clk(clk), .wordmask(sram_wordmask_b2), .csb(1'b0), .wsb(sram_wen_b2), .wdata(sram_wdata_b2),  .waddr(sram_addr_b2),  .raddr(sram_addr_b2),  .rdata(sram_rdata_b2));
sram_act_small sram_act_b3(.clk(clk), .wordmask(sram_wordmask_b3), .csb(1'b0), .wsb(sram_wen_b3), .wdata(sram_wdata_b3),  .waddr(sram_addr_b3),  .raddr(sram_addr_b3),  .rdata(sram_rdata_b3));

// SRAM C
sram_act_medium sram_act_c0(.clk(clk), .wordmask(sram_wordmask_c0), .csb(1'b0), .wsb(sram_wen_c0), .wdata(sram_wdata_c0),  .waddr(sram_addr_c0),  .raddr(sram_addr_c0),  .rdata(sram_rdata_c0));
sram_act_medium sram_act_c1(.clk(clk), .wordmask(sram_wordmask_c1), .csb(1'b0), .wsb(sram_wen_c1), .wdata(sram_wdata_c1),  .waddr(sram_addr_c1),  .raddr(sram_addr_c1),  .rdata(sram_rdata_c1));
sram_act_medium sram_act_c2(.clk(clk), .wordmask(sram_wordmask_c2), .csb(1'b0), .wsb(sram_wen_c2), .wdata(sram_wdata_c2),  .waddr(sram_addr_c2),  .raddr(sram_addr_c2),  .rdata(sram_rdata_c2));
sram_act_medium sram_act_c3(.clk(clk), .wordmask(sram_wordmask_c3), .csb(1'b0), .wsb(sram_wen_c3), .wdata(sram_wdata_c3),  .waddr(sram_addr_c3),  .raddr(sram_addr_c3),  .rdata(sram_rdata_c3));

// SRAM D
sram_act_large sram_act_d0(.clk(clk), .wordmask(sram_wordmask_d0), .csb(1'b0), .wsb(sram_wen_d0), .wdata(sram_wdata_d0),  .waddr(sram_addr_d0),  .raddr(sram_addr_d0),  .rdata(sram_rdata_d0));
sram_act_large sram_act_d1(.clk(clk), .wordmask(sram_wordmask_d1), .csb(1'b0), .wsb(sram_wen_d1), .wdata(sram_wdata_d1),  .waddr(sram_addr_d1),  .raddr(sram_addr_d1),  .rdata(sram_rdata_d1));
sram_act_large sram_act_d2(.clk(clk), .wordmask(sram_wordmask_d2), .csb(1'b0), .wsb(sram_wen_d2), .wdata(sram_wdata_d2),  .waddr(sram_addr_d2),  .raddr(sram_addr_d2),  .rdata(sram_rdata_d2));
sram_act_large sram_act_d3(.clk(clk), .wordmask(sram_wordmask_d3), .csb(1'b0), .wsb(sram_wen_d3), .wdata(sram_wdata_d3),  .waddr(sram_addr_d3),  .raddr(sram_addr_d3),  .rdata(sram_rdata_d3));

// ===== waveform dumpping ===== //

initial begin
    if(`FLAG_DUMPWV)begin
        $fsdbDumpfile("hw5_digit_classifier.fsdb");
        $fsdbDumpvars("+mda");
    end
end

// ===== parameter & golden answers ===== //
reg [BW_PER_SRAM_GROUP_ADDR-1:0] input_sram_value_bank0 [0:32-1];
reg [BW_PER_SRAM_GROUP_ADDR-1:0] input_sram_value_bank1 [0:32-1];
reg [BW_PER_SRAM_GROUP_ADDR-1:0] input_sram_value_bank2 [0:32-1];
reg [BW_PER_SRAM_GROUP_ADDR-1:0] input_sram_value_bank3 [0:32-1];
reg [BW_PER_SRAM_GROUP_ADDR-1:0] golden_sram_value_bank0 [0:48-1];
reg [BW_PER_SRAM_GROUP_ADDR-1:0] golden_sram_value_bank1 [0:48-1];
reg [BW_PER_SRAM_GROUP_ADDR-1:0] golden_sram_value_bank2 [0:48-1];
reg [BW_PER_SRAM_GROUP_ADDR-1:0] golden_sram_value_bank3 [0:48-1];

reg [BW_PER_PARAM-1:0] lnorm1_w [0:16-1];
reg [BIAS_PER_ADDR*BW_PER_PARAM-1:0] lnorm1_b [0:16-1];
reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] qproj_w [0:16-1];
reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] kproj_w [0:16-1];
reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] vproj_w [0:16-1];
reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] oproj_w [0:16-1];
reg [BW_PER_PARAM-1:0] lnorm2_w [0:16-1];
reg [BIAS_PER_ADDR*BW_PER_PARAM-1:0] lnorm2_b [0:16-1];
reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] ffn_fc1_w [0:48-1];
reg [BIAS_PER_ADDR*BW_PER_PARAM-1:0] ffn_fc1_b [0:48-1];
reg [WEIGHT_PER_ADDR*BW_PER_PARAM*3-1:0] ffn_fc2_w [0:16-1];
reg [BIAS_PER_ADDR*BW_PER_PARAM-1:0] ffn_fc2_b [0:16-1];

// ===== system reset ===== //
initial begin
    clk = 0;
    load_param;
    while(1) #(`CYCLE/2) clk = ~clk;
end

initial begin
  #(`CYCLE * `END_CYCLES);
    $display("\n========================================================");
    $display("   Error!!! Simulation time is too long...            ");
    $display("   There might be something wrong in your code.       ");
    $display("   If your design really needs such a long time,      ");
    $display("   increase the END_CYCLES setting in the testbench.  ");
    $display("========================================================");
    $finish;
end

// ===== cycle counter ===== //
integer cycle_cnt;
integer aver_cycle_cnt;
initial begin
    cycle_cnt = 0;
    aver_cycle_cnt = 0;
    while(1) begin 
        cycle_cnt = cycle_cnt + 1;
        @(negedge clk);
    end
end

// ===== output comparision ===== //
integer m, l;
integer error_bank0, error_bank1,error_bank2, error_bank3;
integer error_total;
integer error_tmp;
integer pat_idx;
integer total_err_pat;

initial begin
  // check if PAT_L and PAT_U are both valid
  if((`PAT_L < 0) || (`PAT_L > `NUM_PAT-1) || (`PAT_U < 0) || (`PAT_U > `NUM_PAT-1)) begin
    $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
    $display("X                                                                             X");
    $display("X   Error!!! PAT_L and PAT_U should be within the range [0, %3d]              X", `NUM_PAT-1);
    $display("X                                                                             X");
    $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
    $finish;
  end
  else if(`PAT_L > `PAT_U) begin
    $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
    $display("X                                                        X");
    $display("X   Error!!! PAT_L should be smaller or equal to PAT_U   X");
    $display("X                                                        X");
    $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
    $finish;    
  end

  // show simulation configuration
    $display("\n%c[1;36mStart checking %s layer ... %c[0m\n", 27, layer_str, 27);

    total_err_pat = 0;
    for(pat_idx=`PAT_L; pat_idx<=`PAT_U;pat_idx=pat_idx+1)begin
        sram_act_a0.reset_sram;
        sram_act_a1.reset_sram;
        sram_act_a2.reset_sram;
        sram_act_a3.reset_sram;

        sram_act_b0.reset_sram;
        sram_act_b1.reset_sram;
        sram_act_b2.reset_sram;
        sram_act_b3.reset_sram;

        sram_act_c0.reset_sram;
        sram_act_c1.reset_sram;
        sram_act_c2.reset_sram;
        sram_act_c3.reset_sram;

        sram_act_d0.reset_sram;
        sram_act_d1.reset_sram;
        sram_act_d2.reset_sram;
        sram_act_d3.reset_sram;

        load_golden(pat_idx, test_layer);

        error_bank0 = 0;
        error_bank1 = 0;
        error_bank2 = 0;
        error_bank3 = 0;
        

        $display("\n========================================================================");
        $display("======================== Pattern No. %02d ========================", pat_idx);
        $display("========================================================================");
        $display();

        srst_n = 1;
        enable = 0;
        @(negedge clk); srst_n = 1'b0;
        @(negedge clk); srst_n = 1'b1; enable = 1'b1;
        @(negedge clk); enable = 1'b0;
        
        wait(valid);
        
        @(negedge clk);
        case (test_layer)
            PATCHEMBED:                                                                             compare_output(A,  0, 32);
            LNORM1:                                                                                 compare_output(B,  0, 32);
            QKV_HEAD0, QKV_HEAD1:                                                                   compare_output(C,  0, 48);
            QKMUL_HEAD0_CHUNK0, QKMUL_HEAD0_CHUNK1, QKMUL_HEAD0_CHUNK2, QKMUL_HEAD0_CHUNK3:         compare_output(D, 32, 32);
            QKMUL_HEAD1_CHUNK0, QKMUL_HEAD1_CHUNK1, QKMUL_HEAD1_CHUNK2, QKMUL_HEAD1_CHUNK3:         compare_output(D, 32, 32);
            SOFTMAX_HEAD0_CHUNK0, SOFTMAX_HEAD0_CHUNK1, SOFTMAX_HEAD0_CHUNK2, SOFTMAX_HEAD0_CHUNK3: compare_output(B,  0, 32);
            SOFTMAX_HEAD1_CHUNK0, SOFTMAX_HEAD1_CHUNK1, SOFTMAX_HEAD1_CHUNK2, SOFTMAX_HEAD1_CHUNK3: compare_output(B,  0, 32);
            VMUL_HEAD0:                                                                             compare_output(D,  0, 16);
            VMUL_HEAD1:                                                                             compare_output(D, 16, 16);
            OPROJ:                                                                                  compare_output(C,  0, 32);
            RESIDUAL1:                                                                              compare_output(B,  0, 32);
            LNORM2:                                                                                 compare_output(A,  0, 32);
            FFN_HIDDEN_CHUNK0:                                                                      compare_output(C,  0, 48);
            FFN_HIDDEN_CHUNK1:                                                                      compare_output(D,  0, 48);
            FFNOUT:                                                                                 compare_output(A,  0, 32);
            RESIDUAL2:                                                                              compare_output(B,  0, 32);
        endcase
    end // for pat_idx

    aver_cycle_cnt = cycle_cnt / `NUM_PAT;
    // summary of all pattern
    $display("\n\n\n                   Summary of all pattern: ");
    if(total_err_pat == 0) begin 
        $display("------------------------------------------------------------\n");
        $write("%c[1;32mCongratulations! %c[0m",27, 27);
        $display("Your %s layer is correct!", layer_str);
        $display("Total cycle count = %0d", cycle_cnt);
        $display("Average cycle count per pattern = %0d", aver_cycle_cnt);
        $display("-----------------------------PASS---------------------------\n");
        
    end else begin
        $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
        $display("X                                                            X");
        $display("X        %c[1;31mFAIL%c[0m in %-26s layer!!!         X",27,27, layer_str);
        $display("X              %3d patterns are failed... (T ~ T)            X", total_err_pat);
        $display("X                                                            X");
        $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
        $display("Total cycle count = %0d", cycle_cnt);
        $display("Average cycle count per pattern = %0d", aver_cycle_cnt);
    end
    $finish;
end

task load_param;
    begin
        $readmemb("param/blocks_0_ln1_weight.dat", lnorm1_w);
        $readmemb("param/blocks_0_ln1_bias.dat", lnorm1_b);
        $readmemb("param/blocks_0_attn_q_proj_weight.dat", qproj_w);
        $readmemb("param/blocks_0_attn_k_proj_weight.dat", kproj_w);
        $readmemb("param/blocks_0_attn_v_proj_weight.dat", vproj_w);
        $readmemb("param/blocks_0_attn_o_proj_weight.dat", oproj_w);
        $readmemb("param/blocks_0_ln2_weight.dat", lnorm2_w);
        $readmemb("param/blocks_0_ln2_bias.dat", lnorm2_b);
        $readmemb("param/blocks_0_ffn_0_weight.dat", ffn_fc1_w);
        $readmemb("param/blocks_0_ffn_0_bias.dat", ffn_fc1_b);
        $readmemb("param/blocks_0_ffn_3_weight.dat", ffn_fc2_w);
        $readmemb("param/blocks_0_ffn_3_bias.dat", ffn_fc2_b);

        // store weights into sram
        sram_weight_u.load_param(0, {lnorm1_w[ 0], lnorm1_w[ 1], lnorm1_w[ 2], lnorm1_w[ 3],
                                           lnorm1_w[ 4], lnorm1_w[ 5], lnorm1_w[ 6], lnorm1_w[ 7],
                                           lnorm1_w[ 8], lnorm1_w[ 9], lnorm1_w[10], lnorm1_w[11],
                                           lnorm1_w[12], lnorm1_w[13], lnorm1_w[14], lnorm1_w[15]});        
        for(i=0; i<16; i=i+1) begin
            sram_weight_u.load_param(i + 1, qproj_w[i]);
        end
        for(i=0; i<16; i=i+1) begin
            sram_weight_u.load_param(i + 17, kproj_w[i]);
        end
        for(i=0; i<16; i=i+1) begin
            sram_weight_u.load_param(i + 33, vproj_w[i]);
        end
        for(i=0; i<16; i=i+1) begin
            sram_weight_u.load_param(i + 49, oproj_w[i]);
        end

        sram_weight_u.load_param(65, {lnorm2_w[ 0], lnorm2_w[ 1], lnorm2_w[ 2], lnorm2_w[ 3],
                                           lnorm2_w[ 4], lnorm2_w[ 5], lnorm2_w[ 6], lnorm2_w[ 7],
                                           lnorm2_w[ 8], lnorm2_w[ 9], lnorm2_w[10], lnorm2_w[11],
                                           lnorm2_w[12], lnorm2_w[13], lnorm2_w[14], lnorm2_w[15]});

        for(i=0; i<48; i=i+1) begin
            sram_weight_u.load_param(i + 66, ffn_fc1_w[i]);
        end
        for(i=0; i<48; i=i+3) begin
            sram_weight_u.load_param(i + 114, ffn_fc2_w[i][47:32]);
            sram_weight_u.load_param(i + 115, ffn_fc2_w[i][31:16]);
            sram_weight_u.load_param(i + 116, ffn_fc2_w[i][15: 0]);
        end
        
        // store biases into sram
        for(i=0; i<16; i=i+1) begin
            sram_bias_u.load_param(i, lnorm1_b[i]);
        end
        for(i=0; i<16; i=i+1) begin
            sram_bias_u.load_param(i + 16, lnorm2_b[i]);
        end
        for(i=0; i<48; i=i+1) begin
            sram_bias_u.load_param(i + 32, ffn_fc1_b[i]);
        end
        for(i=0; i<16; i=i+1) begin
            sram_bias_u.load_param(i + 80, ffn_fc2_b[i]);
        end
    end
endtask

task load_golden(
    input integer index,
    input integer layer
);
    reg [8-1:0] index_digit_2, index_digit_1, index_digit_0;
    begin

        index_digit_2 = (index % 1000) / 100 + 48;
        index_digit_1 = (index % 100 ) / 10 + 48;
        index_digit_0 = (index % 10  ) + 48;

        patch_embed_a0_golden_file = "golden/pos_enc/activation_pos_enc_000_a0.dat"; // 44 char
        patch_embed_a1_golden_file = "golden/pos_enc/activation_pos_enc_000_a1.dat";
        patch_embed_a2_golden_file = "golden/pos_enc/activation_pos_enc_000_a2.dat";
        patch_embed_a3_golden_file = "golden/pos_enc/activation_pos_enc_000_a3.dat";
        lnorm1_b0_golden_file = "golden/norm1/activation_ln_000_b0.dat"; // 37 char
        lnorm1_b1_golden_file = "golden/norm1/activation_ln_000_b1.dat";
        lnorm1_b2_golden_file = "golden/norm1/activation_ln_000_b2.dat";
        lnorm1_b3_golden_file = "golden/norm1/activation_ln_000_b3.dat";
        qkv_head0_c0_golden_file = "golden/qkv_proj/activation_qkv_proj_head0_000_c0.dat"; // 52 char
        qkv_head0_c1_golden_file = "golden/qkv_proj/activation_qkv_proj_head0_000_c1.dat";
        qkv_head0_c2_golden_file = "golden/qkv_proj/activation_qkv_proj_head0_000_c2.dat";
        qkv_head0_c3_golden_file = "golden/qkv_proj/activation_qkv_proj_head0_000_c3.dat";
        qkv_head1_c0_golden_file = "golden/qkv_proj/activation_qkv_proj_head1_000_c0.dat";
        qkv_head1_c1_golden_file = "golden/qkv_proj/activation_qkv_proj_head1_000_c1.dat";
        qkv_head1_c2_golden_file = "golden/qkv_proj/activation_qkv_proj_head1_000_c2.dat";
        qkv_head1_c3_golden_file = "golden/qkv_proj/activation_qkv_proj_head1_000_c3.dat";
        qkmul_head0_chunk0_d0_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk0_d0.dat"; // 57 char
        qkmul_head0_chunk0_d1_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk0_d1.dat";
        qkmul_head0_chunk0_d2_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk0_d2.dat";
        qkmul_head0_chunk0_d3_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk0_d3.dat";
        qkmul_head0_chunk1_d0_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk1_d0.dat";
        qkmul_head0_chunk1_d1_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk1_d1.dat";
        qkmul_head0_chunk1_d2_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk1_d2.dat";
        qkmul_head0_chunk1_d3_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk1_d3.dat";
        qkmul_head0_chunk2_d0_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk2_d0.dat";
        qkmul_head0_chunk2_d1_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk2_d1.dat";
        qkmul_head0_chunk2_d2_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk2_d2.dat";
        qkmul_head0_chunk2_d3_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk2_d3.dat";
        qkmul_head0_chunk3_d0_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk3_d0.dat";
        qkmul_head0_chunk3_d1_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk3_d1.dat";
        qkmul_head0_chunk3_d2_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk3_d2.dat";
        qkmul_head0_chunk3_d3_golden_file = "golden/qk_attn/activation_qk_attn_000_head0_chunk3_d3.dat";
        qkmul_head1_chunk0_d0_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk0_d0.dat";
        qkmul_head1_chunk0_d1_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk0_d1.dat";
        qkmul_head1_chunk0_d2_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk0_d2.dat";
        qkmul_head1_chunk0_d3_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk0_d3.dat";
        qkmul_head1_chunk1_d0_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk1_d0.dat";
        qkmul_head1_chunk1_d1_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk1_d1.dat";
        qkmul_head1_chunk1_d2_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk1_d2.dat";
        qkmul_head1_chunk1_d3_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk1_d3.dat";
        qkmul_head1_chunk2_d0_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk2_d0.dat";
        qkmul_head1_chunk2_d1_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk2_d1.dat";
        qkmul_head1_chunk2_d2_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk2_d2.dat";
        qkmul_head1_chunk2_d3_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk2_d3.dat";
        qkmul_head1_chunk3_d0_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk3_d0.dat";
        qkmul_head1_chunk3_d1_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk3_d1.dat";
        qkmul_head1_chunk3_d2_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk3_d2.dat";
        qkmul_head1_chunk3_d3_golden_file = "golden/qk_attn/activation_qk_attn_000_head1_chunk3_d3.dat";
        softmax_head0_chunk0_b0_golden_file = "golden/softmax/activation_softmax_000_head0_chunk0_b0.dat"; // 57 char
        softmax_head0_chunk0_b1_golden_file = "golden/softmax/activation_softmax_000_head0_chunk0_b1.dat";
        softmax_head0_chunk0_b2_golden_file = "golden/softmax/activation_softmax_000_head0_chunk0_b2.dat";
        softmax_head0_chunk0_b3_golden_file = "golden/softmax/activation_softmax_000_head0_chunk0_b3.dat";
        softmax_head0_chunk1_b0_golden_file = "golden/softmax/activation_softmax_000_head0_chunk1_b0.dat";
        softmax_head0_chunk1_b1_golden_file = "golden/softmax/activation_softmax_000_head0_chunk1_b1.dat";
        softmax_head0_chunk1_b2_golden_file = "golden/softmax/activation_softmax_000_head0_chunk1_b2.dat";
        softmax_head0_chunk1_b3_golden_file = "golden/softmax/activation_softmax_000_head0_chunk1_b3.dat";
        softmax_head0_chunk2_b0_golden_file = "golden/softmax/activation_softmax_000_head0_chunk2_b0.dat";
        softmax_head0_chunk2_b1_golden_file = "golden/softmax/activation_softmax_000_head0_chunk2_b1.dat";
        softmax_head0_chunk2_b2_golden_file = "golden/softmax/activation_softmax_000_head0_chunk2_b2.dat";
        softmax_head0_chunk2_b3_golden_file = "golden/softmax/activation_softmax_000_head0_chunk2_b3.dat";
        softmax_head0_chunk3_b0_golden_file = "golden/softmax/activation_softmax_000_head0_chunk3_b0.dat";
        softmax_head0_chunk3_b1_golden_file = "golden/softmax/activation_softmax_000_head0_chunk3_b1.dat";
        softmax_head0_chunk3_b2_golden_file = "golden/softmax/activation_softmax_000_head0_chunk3_b2.dat";
        softmax_head0_chunk3_b3_golden_file = "golden/softmax/activation_softmax_000_head0_chunk3_b3.dat";
        softmax_head1_chunk0_b0_golden_file = "golden/softmax/activation_softmax_000_head1_chunk0_b0.dat";
        softmax_head1_chunk0_b1_golden_file = "golden/softmax/activation_softmax_000_head1_chunk0_b1.dat";
        softmax_head1_chunk0_b2_golden_file = "golden/softmax/activation_softmax_000_head1_chunk0_b2.dat";
        softmax_head1_chunk0_b3_golden_file = "golden/softmax/activation_softmax_000_head1_chunk0_b3.dat";
        softmax_head1_chunk1_b0_golden_file = "golden/softmax/activation_softmax_000_head1_chunk1_b0.dat";
        softmax_head1_chunk1_b1_golden_file = "golden/softmax/activation_softmax_000_head1_chunk1_b1.dat";
        softmax_head1_chunk1_b2_golden_file = "golden/softmax/activation_softmax_000_head1_chunk1_b2.dat";
        softmax_head1_chunk1_b3_golden_file = "golden/softmax/activation_softmax_000_head1_chunk1_b3.dat";
        softmax_head1_chunk2_b0_golden_file = "golden/softmax/activation_softmax_000_head1_chunk2_b0.dat";
        softmax_head1_chunk2_b1_golden_file = "golden/softmax/activation_softmax_000_head1_chunk2_b1.dat";
        softmax_head1_chunk2_b2_golden_file = "golden/softmax/activation_softmax_000_head1_chunk2_b2.dat";
        softmax_head1_chunk2_b3_golden_file = "golden/softmax/activation_softmax_000_head1_chunk2_b3.dat";
        softmax_head1_chunk3_b0_golden_file = "golden/softmax/activation_softmax_000_head1_chunk3_b0.dat";
        softmax_head1_chunk3_b1_golden_file = "golden/softmax/activation_softmax_000_head1_chunk3_b1.dat";
        softmax_head1_chunk3_b2_golden_file = "golden/softmax/activation_softmax_000_head1_chunk3_b2.dat";
        softmax_head1_chunk3_b3_golden_file = "golden/softmax/activation_softmax_000_head1_chunk3_b3.dat";
        vmul_head0_d0_golden_file = "golden/v_softmax/activation_v_softmax_000_head0_d0.dat"; //  54 char
        vmul_head0_d1_golden_file = "golden/v_softmax/activation_v_softmax_000_head0_d1.dat";
        vmul_head0_d2_golden_file = "golden/v_softmax/activation_v_softmax_000_head0_d2.dat";
        vmul_head0_d3_golden_file = "golden/v_softmax/activation_v_softmax_000_head0_d3.dat";
        vmul_head1_d0_golden_file = "golden/v_softmax/activation_v_softmax_000_head1_d0.dat"; //  54 char
        vmul_head1_d1_golden_file = "golden/v_softmax/activation_v_softmax_000_head1_d1.dat";
        vmul_head1_d2_golden_file = "golden/v_softmax/activation_v_softmax_000_head1_d2.dat";
        vmul_head1_d3_golden_file = "golden/v_softmax/activation_v_softmax_000_head1_d3.dat";
        oproj_c0_golden_file = "golden/o_proj/activation_o_proj_000_c0.dat"; // 42 char
        oproj_c1_golden_file = "golden/o_proj/activation_o_proj_000_c1.dat";
        oproj_c2_golden_file = "golden/o_proj/activation_o_proj_000_c2.dat";
        oproj_c3_golden_file = "golden/o_proj/activation_o_proj_000_c3.dat";
        residual1_b0_golden_file = "golden/residual_add1/activation_residual_add1_000_b0.dat"; // 56 char
        residual1_b1_golden_file = "golden/residual_add1/activation_residual_add1_000_b1.dat";
        residual1_b2_golden_file = "golden/residual_add1/activation_residual_add1_000_b2.dat";
        residual1_b3_golden_file = "golden/residual_add1/activation_residual_add1_000_b3.dat";
        lnorm2_a0_golden_file = "golden/norm2/activation_ln_000_a0.dat"; // 37 char
        lnorm2_a1_golden_file = "golden/norm2/activation_ln_000_a1.dat";
        lnorm2_a2_golden_file = "golden/norm2/activation_ln_000_a2.dat";
        lnorm2_a3_golden_file = "golden/norm2/activation_ln_000_a3.dat";
        ffn_hidden_c0_golden_file = "golden/ffn_hidden/activation_ffn_hidden_000_c0.dat"; // 50 char
        ffn_hidden_c1_golden_file = "golden/ffn_hidden/activation_ffn_hidden_000_c1.dat";
        ffn_hidden_c2_golden_file = "golden/ffn_hidden/activation_ffn_hidden_000_c2.dat";
        ffn_hidden_c3_golden_file = "golden/ffn_hidden/activation_ffn_hidden_000_c3.dat";
        ffn_hidden_d0_golden_file = "golden/ffn_hidden/activation_ffn_hidden_000_d0.dat"; // 50 char
        ffn_hidden_d1_golden_file = "golden/ffn_hidden/activation_ffn_hidden_000_d1.dat";
        ffn_hidden_d2_golden_file = "golden/ffn_hidden/activation_ffn_hidden_000_d2.dat";
        ffn_hidden_d3_golden_file = "golden/ffn_hidden/activation_ffn_hidden_000_d3.dat";
        ffnout_a0_golden_file = "golden/ffn_final/activation_ffn_final_000_a0.dat"; // 48 char
        ffnout_a1_golden_file = "golden/ffn_final/activation_ffn_final_000_a1.dat";
        ffnout_a2_golden_file = "golden/ffn_final/activation_ffn_final_000_a2.dat";
        ffnout_a3_golden_file = "golden/ffn_final/activation_ffn_final_000_a3.dat";
        residual2_b0_golden_file = "golden/residual_add2/activation_residual_add2_000_b0.dat"; // 56 char
        residual2_b1_golden_file = "golden/residual_add2/activation_residual_add2_000_b1.dat";
        residual2_b2_golden_file = "golden/residual_add2/activation_residual_add2_000_b2.dat";
        residual2_b3_golden_file = "golden/residual_add2/activation_residual_add2_000_b3.dat";

        patch_embed_a0_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        patch_embed_a1_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        patch_embed_a2_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        patch_embed_a3_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        lnorm1_b0_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        lnorm1_b1_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        lnorm1_b2_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        lnorm1_b3_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkv_head0_c0_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkv_head0_c1_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkv_head0_c2_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkv_head0_c3_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkv_head1_c0_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkv_head1_c1_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkv_head1_c2_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkv_head1_c3_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk0_d0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk0_d1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk0_d2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk0_d3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk1_d0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk1_d1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk1_d2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk1_d3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk2_d0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk2_d1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk2_d2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk2_d3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk3_d0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk3_d1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk3_d2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head0_chunk3_d3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk0_d0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk0_d1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk0_d2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk0_d3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk1_d0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk1_d1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk1_d2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk1_d3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk2_d0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk2_d1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk2_d2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk2_d3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk3_d0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk3_d1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk3_d2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        qkmul_head1_chunk3_d3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk0_b0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk0_b1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk0_b2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk0_b3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk1_b0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk1_b1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk1_b2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk1_b3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk2_b0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk2_b1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk2_b2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk2_b3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk3_b0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk3_b1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk3_b2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head0_chunk3_b3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk0_b0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk0_b1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk0_b2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk0_b3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk1_b0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk1_b1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk1_b2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk1_b3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk2_b0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk2_b1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk2_b2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk2_b3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk3_b0_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk3_b1_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk3_b2_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        softmax_head1_chunk3_b3_golden_file[20*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};       
        vmul_head0_d0_golden_file[13*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        vmul_head0_d1_golden_file[13*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        vmul_head0_d2_golden_file[13*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        vmul_head0_d3_golden_file[13*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        vmul_head1_d0_golden_file[13*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        vmul_head1_d1_golden_file[13*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        vmul_head1_d2_golden_file[13*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        vmul_head1_d3_golden_file[13*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        oproj_c0_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        oproj_c1_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        oproj_c2_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        oproj_c3_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        residual1_b0_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        residual1_b1_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        residual1_b2_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        residual1_b3_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        lnorm2_a0_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        lnorm2_a1_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        lnorm2_a2_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        lnorm2_a3_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        ffn_hidden_c0_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        ffn_hidden_c1_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        ffn_hidden_c2_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        ffn_hidden_c3_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        ffn_hidden_d0_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        ffn_hidden_d1_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        ffn_hidden_d2_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        ffn_hidden_d3_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        ffnout_a0_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        ffnout_a1_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        ffnout_a2_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        ffnout_a3_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        residual2_b0_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        residual2_b1_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        residual2_b2_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};
        residual2_b3_golden_file[7*8+:`PAT_NAME_LENGTH*8] = {index_digit_2, index_digit_1, index_digit_0};


        $readmemb(patch_embed_a0_golden_file, input_sram_value_bank0);
        $readmemb(patch_embed_a1_golden_file, input_sram_value_bank1);
        $readmemb(patch_embed_a2_golden_file, input_sram_value_bank2);
        $readmemb(patch_embed_a3_golden_file, input_sram_value_bank3);
        // load golden
        case (test_layer)
            PATCHEMBED: begin
                $readmemb(patch_embed_a0_golden_file, golden_sram_value_bank0);
                $readmemb(patch_embed_a1_golden_file, golden_sram_value_bank1);
                $readmemb(patch_embed_a2_golden_file, golden_sram_value_bank2);
                $readmemb(patch_embed_a3_golden_file, golden_sram_value_bank3);
            end
            LNORM1: begin
                $readmemb(lnorm1_b0_golden_file, golden_sram_value_bank0);
                $readmemb(lnorm1_b1_golden_file, golden_sram_value_bank1);
                $readmemb(lnorm1_b2_golden_file, golden_sram_value_bank2);
                $readmemb(lnorm1_b3_golden_file, golden_sram_value_bank3);
            end
            QKV_HEAD0: begin
                $readmemb(qkv_head0_c0_golden_file, golden_sram_value_bank0);
                $readmemb(qkv_head0_c1_golden_file, golden_sram_value_bank1);
                $readmemb(qkv_head0_c2_golden_file, golden_sram_value_bank2);
                $readmemb(qkv_head0_c3_golden_file, golden_sram_value_bank3);
            end
            QKV_HEAD1: begin
                $readmemb(qkv_head1_c0_golden_file, golden_sram_value_bank0);
                $readmemb(qkv_head1_c1_golden_file, golden_sram_value_bank1);
                $readmemb(qkv_head1_c2_golden_file, golden_sram_value_bank2);
                $readmemb(qkv_head1_c3_golden_file, golden_sram_value_bank3);
            end
            QKMUL_HEAD0_CHUNK0: begin
                $readmemb(qkmul_head0_chunk0_d0_golden_file, golden_sram_value_bank0);
                $readmemb(qkmul_head0_chunk0_d1_golden_file, golden_sram_value_bank1);
                $readmemb(qkmul_head0_chunk0_d2_golden_file, golden_sram_value_bank2);
                $readmemb(qkmul_head0_chunk0_d3_golden_file, golden_sram_value_bank3);
            end
            QKMUL_HEAD0_CHUNK1: begin
                $readmemb(qkmul_head0_chunk1_d0_golden_file, golden_sram_value_bank0);
                $readmemb(qkmul_head0_chunk1_d1_golden_file, golden_sram_value_bank1);
                $readmemb(qkmul_head0_chunk1_d2_golden_file, golden_sram_value_bank2);
                $readmemb(qkmul_head0_chunk1_d3_golden_file, golden_sram_value_bank3);
            end
            QKMUL_HEAD0_CHUNK2: begin
                $readmemb(qkmul_head0_chunk2_d0_golden_file, golden_sram_value_bank0);
                $readmemb(qkmul_head0_chunk2_d1_golden_file, golden_sram_value_bank1);
                $readmemb(qkmul_head0_chunk2_d2_golden_file, golden_sram_value_bank2);
                $readmemb(qkmul_head0_chunk2_d3_golden_file, golden_sram_value_bank3);
            end
            QKMUL_HEAD0_CHUNK3: begin
                $readmemb(qkmul_head0_chunk3_d0_golden_file, golden_sram_value_bank0);
                $readmemb(qkmul_head0_chunk3_d1_golden_file, golden_sram_value_bank1);
                $readmemb(qkmul_head0_chunk3_d2_golden_file, golden_sram_value_bank2);
                $readmemb(qkmul_head0_chunk3_d3_golden_file, golden_sram_value_bank3);
            end
            QKMUL_HEAD1_CHUNK0: begin
                $readmemb(qkmul_head1_chunk0_d0_golden_file, golden_sram_value_bank0);
                $readmemb(qkmul_head1_chunk0_d1_golden_file, golden_sram_value_bank1);
                $readmemb(qkmul_head1_chunk0_d2_golden_file, golden_sram_value_bank2);
                $readmemb(qkmul_head1_chunk0_d3_golden_file, golden_sram_value_bank3);
            end
            QKMUL_HEAD1_CHUNK1: begin
                $readmemb(qkmul_head1_chunk1_d0_golden_file, golden_sram_value_bank0);
                $readmemb(qkmul_head1_chunk1_d1_golden_file, golden_sram_value_bank1);
                $readmemb(qkmul_head1_chunk1_d2_golden_file, golden_sram_value_bank2);
                $readmemb(qkmul_head1_chunk1_d3_golden_file, golden_sram_value_bank3);
            end
            QKMUL_HEAD1_CHUNK2: begin
                $readmemb(qkmul_head1_chunk2_d0_golden_file, golden_sram_value_bank0);
                $readmemb(qkmul_head1_chunk2_d1_golden_file, golden_sram_value_bank1);
                $readmemb(qkmul_head1_chunk2_d2_golden_file, golden_sram_value_bank2);
                $readmemb(qkmul_head1_chunk2_d3_golden_file, golden_sram_value_bank3);
            end
            QKMUL_HEAD1_CHUNK3: begin
                $readmemb(qkmul_head1_chunk3_d0_golden_file, golden_sram_value_bank0);
                $readmemb(qkmul_head1_chunk3_d1_golden_file, golden_sram_value_bank1);
                $readmemb(qkmul_head1_chunk3_d2_golden_file, golden_sram_value_bank2);
                $readmemb(qkmul_head1_chunk3_d3_golden_file, golden_sram_value_bank3);
            end
            SOFTMAX_HEAD0_CHUNK0: begin
                $readmemb(softmax_head0_chunk0_b0_golden_file, golden_sram_value_bank0);
                $readmemb(softmax_head0_chunk0_b1_golden_file, golden_sram_value_bank1);
                $readmemb(softmax_head0_chunk0_b2_golden_file, golden_sram_value_bank2);
                $readmemb(softmax_head0_chunk0_b3_golden_file, golden_sram_value_bank3);
            end
            SOFTMAX_HEAD0_CHUNK1: begin
                $readmemb(softmax_head0_chunk1_b0_golden_file, golden_sram_value_bank0);
                $readmemb(softmax_head0_chunk1_b1_golden_file, golden_sram_value_bank1);
                $readmemb(softmax_head0_chunk1_b2_golden_file, golden_sram_value_bank2);
                $readmemb(softmax_head0_chunk1_b3_golden_file, golden_sram_value_bank3);
            end
            SOFTMAX_HEAD0_CHUNK2: begin
                $readmemb(softmax_head0_chunk2_b0_golden_file, golden_sram_value_bank0);
                $readmemb(softmax_head0_chunk2_b1_golden_file, golden_sram_value_bank1);
                $readmemb(softmax_head0_chunk2_b2_golden_file, golden_sram_value_bank2);
                $readmemb(softmax_head0_chunk2_b3_golden_file, golden_sram_value_bank3);
            end
            SOFTMAX_HEAD0_CHUNK3: begin
                $readmemb(softmax_head0_chunk3_b0_golden_file, golden_sram_value_bank0);
                $readmemb(softmax_head0_chunk3_b1_golden_file, golden_sram_value_bank1);
                $readmemb(softmax_head0_chunk3_b2_golden_file, golden_sram_value_bank2);
                $readmemb(softmax_head0_chunk3_b3_golden_file, golden_sram_value_bank3);
            end
            SOFTMAX_HEAD1_CHUNK0: begin
                $readmemb(softmax_head1_chunk0_b0_golden_file, golden_sram_value_bank0);
                $readmemb(softmax_head1_chunk0_b1_golden_file, golden_sram_value_bank1);
                $readmemb(softmax_head1_chunk0_b2_golden_file, golden_sram_value_bank2);
                $readmemb(softmax_head1_chunk0_b3_golden_file, golden_sram_value_bank3);
            end
            SOFTMAX_HEAD1_CHUNK1: begin
                $readmemb(softmax_head1_chunk1_b0_golden_file, golden_sram_value_bank0);
                $readmemb(softmax_head1_chunk1_b1_golden_file, golden_sram_value_bank1);
                $readmemb(softmax_head1_chunk1_b2_golden_file, golden_sram_value_bank2);
                $readmemb(softmax_head1_chunk1_b3_golden_file, golden_sram_value_bank3);
            end
            SOFTMAX_HEAD1_CHUNK2: begin
                $readmemb(softmax_head1_chunk2_b0_golden_file, golden_sram_value_bank0);
                $readmemb(softmax_head1_chunk2_b1_golden_file, golden_sram_value_bank1);
                $readmemb(softmax_head1_chunk2_b2_golden_file, golden_sram_value_bank2);
                $readmemb(softmax_head1_chunk2_b3_golden_file, golden_sram_value_bank3);
            end
            SOFTMAX_HEAD1_CHUNK3: begin
                $readmemb(softmax_head1_chunk3_b0_golden_file, golden_sram_value_bank0);
                $readmemb(softmax_head1_chunk3_b1_golden_file, golden_sram_value_bank1);
                $readmemb(softmax_head1_chunk3_b2_golden_file, golden_sram_value_bank2);
                $readmemb(softmax_head1_chunk3_b3_golden_file, golden_sram_value_bank3);
            end
            VMUL_HEAD0: begin
                $readmemb(vmul_head0_d0_golden_file, golden_sram_value_bank0);
                $readmemb(vmul_head0_d1_golden_file, golden_sram_value_bank1);
                $readmemb(vmul_head0_d2_golden_file, golden_sram_value_bank2);
                $readmemb(vmul_head0_d3_golden_file, golden_sram_value_bank3);
            end
            VMUL_HEAD1: begin
                $readmemb(vmul_head1_d0_golden_file, golden_sram_value_bank0);
                $readmemb(vmul_head1_d1_golden_file, golden_sram_value_bank1);
                $readmemb(vmul_head1_d2_golden_file, golden_sram_value_bank2);
                $readmemb(vmul_head1_d3_golden_file, golden_sram_value_bank3);
            end
            OPROJ: begin
                $readmemb(oproj_c0_golden_file, golden_sram_value_bank0);
                $readmemb(oproj_c1_golden_file, golden_sram_value_bank1);
                $readmemb(oproj_c2_golden_file, golden_sram_value_bank2);
                $readmemb(oproj_c3_golden_file, golden_sram_value_bank3);
            end
            RESIDUAL1: begin
                $readmemb(residual1_b0_golden_file, golden_sram_value_bank0);
                $readmemb(residual1_b1_golden_file, golden_sram_value_bank1);
                $readmemb(residual1_b2_golden_file, golden_sram_value_bank2);
                $readmemb(residual1_b3_golden_file, golden_sram_value_bank3);
            end
            LNORM2: begin
                $readmemb(lnorm2_a0_golden_file, golden_sram_value_bank0);
                $readmemb(lnorm2_a1_golden_file, golden_sram_value_bank1);
                $readmemb(lnorm2_a2_golden_file, golden_sram_value_bank2);
                $readmemb(lnorm2_a3_golden_file, golden_sram_value_bank3);
            end
            FFN_HIDDEN_CHUNK0: begin
                $readmemb(ffn_hidden_c0_golden_file, golden_sram_value_bank0);
                $readmemb(ffn_hidden_c1_golden_file, golden_sram_value_bank1);
                $readmemb(ffn_hidden_c2_golden_file, golden_sram_value_bank2);
                $readmemb(ffn_hidden_c3_golden_file, golden_sram_value_bank3);
            end
            FFN_HIDDEN_CHUNK1: begin
                $readmemb(ffn_hidden_d0_golden_file, golden_sram_value_bank0);
                $readmemb(ffn_hidden_d1_golden_file, golden_sram_value_bank1);
                $readmemb(ffn_hidden_d2_golden_file, golden_sram_value_bank2);
                $readmemb(ffn_hidden_d3_golden_file, golden_sram_value_bank3);
            end
            FFNOUT: begin
                $readmemb(ffnout_a0_golden_file, golden_sram_value_bank0);
                $readmemb(ffnout_a1_golden_file, golden_sram_value_bank1);
                $readmemb(ffnout_a2_golden_file, golden_sram_value_bank2);
                $readmemb(ffnout_a3_golden_file, golden_sram_value_bank3);
            end
            RESIDUAL2: begin
                $readmemb(residual2_b0_golden_file, golden_sram_value_bank0);
                $readmemb(residual2_b1_golden_file, golden_sram_value_bank1);
                $readmemb(residual2_b2_golden_file, golden_sram_value_bank2);
                $readmemb(residual2_b3_golden_file, golden_sram_value_bank3);
            end
        endcase     
        
        // store patch embedded data into sram A
        // a0
        for(i=0; i<32 ;i=i+1)begin
            sram_act_a0.load_act(i, input_sram_value_bank0[i]);
        end
        // a1
        for(i=0; i<32 ;i=i+1)begin
            sram_act_a1.load_act(i, input_sram_value_bank1[i]);
        end
        // a2
        for(i=0; i<32 ;i=i+1)begin
            sram_act_a2.load_act(i, input_sram_value_bank2[i]);
        end
        // a3
        for(i=0; i<32 ;i=i+1)begin
            sram_act_a3.load_act(i, input_sram_value_bank3[i]);
        end
    end
endtask

task compare_output(input integer sram_sel, input integer start_addr, input integer check_len);
    integer m, l;
    integer error_tmp;
    case (sram_sel)
        A: begin
            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank0[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_a0.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #A0 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(A0, m, start_addr);
                    error_bank0 = error_bank0 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #A0 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank0 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #A0 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #A0 have %0d errors!", layer_str, error_bank0);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank1[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_a1.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #A1 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(A1, m, start_addr);
                    error_bank1 = error_bank1 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #A1 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank1 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #A1 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #A1 have %0d errors!", layer_str, error_bank1);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank2[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_a2.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #A2 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(A2, m, start_addr);
                    error_bank2 = error_bank2 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #A2 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank2 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #A2 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #A2 have %0d errors!", layer_str, error_bank2);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank3[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_a3.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #A3 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(A3, m, start_addr);
                    error_bank3 = error_bank3 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #A3 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank3 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #A3 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #A3 have %0d errors!", layer_str, error_bank3);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            error_total = error_bank0 + error_bank1 + error_bank2 + error_bank3; 

            // summary of this pattern
            if(`FLAG_VERBOSE) $display("\n========================================================================");
            if(error_total == 0) begin
                if(`FLAG_VERBOSE) $display("Congratulations! Your %s layer is correct!", layer_str);
                if(`FLAG_VERBOSE) $display("Pattern No. %02d is successfully passed !", pat_idx);
                else              $write("%c[1;32mPASS! %c[0m",27, 27);
            end else begin
                if(`FLAG_VERBOSE) $display("There are total %0d errors in your %s layer.", error_total, layer_str);
                if(`FLAG_VERBOSE) $display("Pattern No. %02d is failed...", pat_idx);
                else              $write("%c[1;31mFAIL! %c[0m",27, 27);
                total_err_pat = total_err_pat + 1;
            end
            if(`FLAG_VERBOSE) $display("========================================================================");
            // $finish;
        end
        B: begin
            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank0[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_b0.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #B0 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(B0, m, start_addr);
                    error_bank0 = error_bank0 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #B0 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank0 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #B0 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #B0 have %0d errors!", layer_str, error_bank0);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank1[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_b1.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #B1 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(B1, m, start_addr);
                    error_bank1 = error_bank1 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #B1 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank1 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #B1 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #B1 have %0d errors!", layer_str, error_bank1);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank2[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_b2.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #B2 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(B2, m, start_addr);
                    error_bank2 = error_bank2 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #B2 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank2 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #B2 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #B2 have %0d errors!", layer_str, error_bank2);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank3[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_b3.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #B3 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(B3, m, start_addr);
                    error_bank3 = error_bank3 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #B3 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank3 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #B3 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #B3 have %0d errors!", layer_str, error_bank3);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            error_total = error_bank0 + error_bank1 + error_bank2 + error_bank3; 

            // summary of this pattern
            if(`FLAG_VERBOSE) $display("\n========================================================================");
            if(error_total == 0) begin
                if(`FLAG_VERBOSE) $display("Congratulations! Your %s layer is correct!", layer_str);
                if(`FLAG_VERBOSE) $display("Pattern No. %02d is successfully passed !", pat_idx);
                else              $write("%c[1;32mPASS! %c[0m",27, 27);
            end else begin
                if(`FLAG_VERBOSE) $display("There are total %0d errors in your %s layer.", error_total, layer_str);
                if(`FLAG_VERBOSE) $display("Pattern No. %02d is failed...", pat_idx);
                else              $write("%c[1;31mFAIL! %c[0m",27, 27);
                total_err_pat = total_err_pat + 1;
            end
            if(`FLAG_VERBOSE) $display("========================================================================");
            // $finish;
        end
        C: begin
            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank0[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_c0.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #C0 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(C0, m, start_addr);
                    error_bank0 = error_bank0 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #C0 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank0 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #C0 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #C0 have %0d errors!", layer_str, error_bank0);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank1[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_c1.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #C1 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(C1, m, start_addr);
                    error_bank1 = error_bank1 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #C1 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank1 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #C1 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #C1 have %0d errors!", layer_str, error_bank1);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank2[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_c2.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #C2 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(C2, m, start_addr);
                    error_bank2 = error_bank2 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #C2 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank2 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #C2 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #C2 have %0d errors!", layer_str, error_bank2);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank3[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_c3.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #C3 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(C3, m, start_addr);
                    error_bank3 = error_bank3 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #C3 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank3 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #C3 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #C3 have %0d errors!", layer_str, error_bank3);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            error_total = error_bank0 + error_bank1 + error_bank2 + error_bank3; 

            // summary of this pattern
            if(`FLAG_VERBOSE) $display("\n========================================================================");
            if(error_total == 0) begin
                if(`FLAG_VERBOSE) $display("Congratulations! Your %s layer is correct!", layer_str);
                if(`FLAG_VERBOSE) $display("Pattern No. %02d is successfully passed !", pat_idx);
                else              $write("%c[1;32mPASS! %c[0m",27, 27);
            end else begin
                if(`FLAG_VERBOSE) $display("There are total %0d errors in your %s layer.", error_total, layer_str);
                if(`FLAG_VERBOSE) $display("Pattern No. %02d is failed...", pat_idx);
                else              $write("%c[1;31mFAIL! %c[0m",27, 27);
                total_err_pat = total_err_pat + 1;
            end
            if(`FLAG_VERBOSE) $display("========================================================================");
            // $finish;
        end
        D: begin
            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank0[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_d0.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #D0 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(D0, m, start_addr);
                    error_bank0 = error_bank0 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #D0 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank0 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #D0 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #D0 have %0d errors!", layer_str, error_bank0);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank1[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_d1.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #D1 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(D1, m, start_addr);
                    error_bank1 = error_bank1 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #D1 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank1 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #D1 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #D1 have %0d errors!", layer_str, error_bank1);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank2[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_d2.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #D2 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(D2, m, start_addr);
                    error_bank2 = error_bank2 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #D2 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank2 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #D2 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #D2 have %0d errors!", layer_str, error_bank2);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            for(m=0; m<check_len; m=m+1) begin
                error_tmp = 0;
                for(l=0; l<8; l=l+1) begin
                    if((golden_sram_value_bank3[m][l*BW_PER_ACT+:BW_PER_ACT] !== sram_act_d3.mem[m+start_addr][l*BW_PER_ACT+:BW_PER_ACT]))
                        error_tmp = error_tmp + 1;
                end
                if (error_tmp != 0) begin
                    if(`FLAG_VERBOSE) $display("Sram #D3 address %0d FAIL!", (m+start_addr));
                    if(`FLAG_VERBOSE) display_error(D3, m, start_addr);
                    error_bank3 = error_bank3 + 1;
                end else begin
                    if(`FLAG_VERBOSE) $display("Sram #D3 address %0d PASS!", (m+start_addr));
                end
            end

            if(`FLAG_VERBOSE) $display("========================================================================");
            if(error_bank3 == 0) begin
                if(`FLAG_VERBOSE) $display("%s results in sram #D3 are successfully passed!", layer_str);
            end else begin
                $display("%s results in sram #D3 have %0d errors!", layer_str, error_bank3);
            end
            if(`FLAG_VERBOSE) $display("========================================================================\n");

            error_total = error_bank0 + error_bank1 + error_bank2 + error_bank3; 

            // summary of this pattern
            if(`FLAG_VERBOSE) $display("\n========================================================================");
            if(error_total == 0) begin
                if(`FLAG_VERBOSE) $display("Congratulations! Your %s layer is correct!", layer_str);
                if(`FLAG_VERBOSE) $display("Pattern No. %02d is successfully passed !", pat_idx);
                else              $write("%c[1;32mPASS! %c[0m",27, 27);
            end else begin
                if(`FLAG_VERBOSE) $display("There are total %0d errors in your %s layer.", error_total, layer_str);
                if(`FLAG_VERBOSE) $display("Pattern No. %02d is failed...", pat_idx);
                else              $write("%c[1;31mFAIL! %c[0m",27, 27);
                total_err_pat = total_err_pat + 1;
            end
            if(`FLAG_VERBOSE) $display("========================================================================");
        end
    endcase
endtask

task display_error(
input [3:0] which_sram,
input integer addr_offset,
input integer addr_start
);
    begin
        case(which_sram)
            A0: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_a0.mem[addr_start+addr_offset][79:70]), $signed(sram_act_a0.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_a0.mem[addr_start+addr_offset][59:50]), $signed(sram_act_a0.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_a0.mem[addr_start+addr_offset][39:30]), $signed(sram_act_a0.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_a0.mem[addr_start+addr_offset][19:10]), $signed(sram_act_a0.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank0[addr_offset][79:70]), $signed(golden_sram_value_bank0[addr_offset][69:60]),
                    $signed(golden_sram_value_bank0[addr_offset][59:50]), $signed(golden_sram_value_bank0[addr_offset][49:40]),
                    $signed(golden_sram_value_bank0[addr_offset][39:30]), $signed(golden_sram_value_bank0[addr_offset][29:20]),
                    $signed(golden_sram_value_bank0[addr_offset][19:10]), $signed(golden_sram_value_bank0[addr_offset][ 9: 0]));
            end
            A1: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_a1.mem[addr_start+addr_offset][79:70]), $signed(sram_act_a1.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_a1.mem[addr_start+addr_offset][59:50]), $signed(sram_act_a1.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_a1.mem[addr_start+addr_offset][39:30]), $signed(sram_act_a1.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_a1.mem[addr_start+addr_offset][19:10]), $signed(sram_act_a1.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank1[addr_offset][79:70]), $signed(golden_sram_value_bank1[addr_offset][69:60]),
                    $signed(golden_sram_value_bank1[addr_offset][59:50]), $signed(golden_sram_value_bank1[addr_offset][49:40]),
                    $signed(golden_sram_value_bank1[addr_offset][39:30]), $signed(golden_sram_value_bank1[addr_offset][29:20]),
                    $signed(golden_sram_value_bank1[addr_offset][19:10]), $signed(golden_sram_value_bank1[addr_offset][ 9: 0]));
            end
            A2: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_a2.mem[addr_start+addr_offset][79:70]), $signed(sram_act_a2.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_a2.mem[addr_start+addr_offset][59:50]), $signed(sram_act_a2.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_a2.mem[addr_start+addr_offset][39:30]), $signed(sram_act_a2.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_a2.mem[addr_start+addr_offset][19:10]), $signed(sram_act_a2.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank2[addr_offset][79:70]), $signed(golden_sram_value_bank2[addr_offset][69:60]),
                    $signed(golden_sram_value_bank2[addr_offset][59:50]), $signed(golden_sram_value_bank2[addr_offset][49:40]),
                    $signed(golden_sram_value_bank2[addr_offset][39:30]), $signed(golden_sram_value_bank2[addr_offset][29:20]),
                    $signed(golden_sram_value_bank2[addr_offset][19:10]), $signed(golden_sram_value_bank2[addr_offset][ 9: 0]));
            end
            A3: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_a3.mem[addr_start+addr_offset][79:70]), $signed(sram_act_a3.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_a3.mem[addr_start+addr_offset][59:50]), $signed(sram_act_a3.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_a3.mem[addr_start+addr_offset][39:30]), $signed(sram_act_a3.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_a3.mem[addr_start+addr_offset][19:10]), $signed(sram_act_a3.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank3[addr_offset][79:70]), $signed(golden_sram_value_bank3[addr_offset][69:60]),
                    $signed(golden_sram_value_bank3[addr_offset][59:50]), $signed(golden_sram_value_bank3[addr_offset][49:40]),
                    $signed(golden_sram_value_bank3[addr_offset][39:30]), $signed(golden_sram_value_bank3[addr_offset][29:20]),
                    $signed(golden_sram_value_bank3[addr_offset][19:10]), $signed(golden_sram_value_bank3[addr_offset][ 9: 0]));
            end
            B0: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_b0.mem[addr_start+addr_offset][79:70]), $signed(sram_act_b0.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_b0.mem[addr_start+addr_offset][59:50]), $signed(sram_act_b0.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_b0.mem[addr_start+addr_offset][39:30]), $signed(sram_act_b0.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_b0.mem[addr_start+addr_offset][19:10]), $signed(sram_act_b0.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank0[addr_offset][79:70]), $signed(golden_sram_value_bank0[addr_offset][69:60]),
                    $signed(golden_sram_value_bank0[addr_offset][59:50]), $signed(golden_sram_value_bank0[addr_offset][49:40]),
                    $signed(golden_sram_value_bank0[addr_offset][39:30]), $signed(golden_sram_value_bank0[addr_offset][29:20]),
                    $signed(golden_sram_value_bank0[addr_offset][19:10]), $signed(golden_sram_value_bank0[addr_offset][ 9: 0]));
            end
            B1: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_b1.mem[addr_start+addr_offset][79:70]), $signed(sram_act_b1.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_b1.mem[addr_start+addr_offset][59:50]), $signed(sram_act_b1.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_b1.mem[addr_start+addr_offset][39:30]), $signed(sram_act_b1.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_b1.mem[addr_start+addr_offset][19:10]), $signed(sram_act_b1.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank1[addr_offset][79:70]), $signed(golden_sram_value_bank1[addr_offset][69:60]),
                    $signed(golden_sram_value_bank1[addr_offset][59:50]), $signed(golden_sram_value_bank1[addr_offset][49:40]),
                    $signed(golden_sram_value_bank1[addr_offset][39:30]), $signed(golden_sram_value_bank1[addr_offset][29:20]),
                    $signed(golden_sram_value_bank1[addr_offset][19:10]), $signed(golden_sram_value_bank1[addr_offset][ 9: 0]));
            end
            B2: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_b2.mem[addr_start+addr_offset][79:70]), $signed(sram_act_b2.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_b2.mem[addr_start+addr_offset][59:50]), $signed(sram_act_b2.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_b2.mem[addr_start+addr_offset][39:30]), $signed(sram_act_b2.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_b2.mem[addr_start+addr_offset][19:10]), $signed(sram_act_b2.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank2[addr_offset][79:70]), $signed(golden_sram_value_bank2[addr_offset][69:60]),
                    $signed(golden_sram_value_bank2[addr_offset][59:50]), $signed(golden_sram_value_bank2[addr_offset][49:40]),
                    $signed(golden_sram_value_bank2[addr_offset][39:30]), $signed(golden_sram_value_bank2[addr_offset][29:20]),
                    $signed(golden_sram_value_bank2[addr_offset][19:10]), $signed(golden_sram_value_bank2[addr_offset][ 9: 0]));
            end
            B3: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_b3.mem[addr_start+addr_offset][79:70]), $signed(sram_act_b3.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_b3.mem[addr_start+addr_offset][59:50]), $signed(sram_act_b3.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_b3.mem[addr_start+addr_offset][39:30]), $signed(sram_act_b3.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_b3.mem[addr_start+addr_offset][19:10]), $signed(sram_act_b3.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank3[addr_offset][79:70]), $signed(golden_sram_value_bank3[addr_offset][69:60]),
                    $signed(golden_sram_value_bank3[addr_offset][59:50]), $signed(golden_sram_value_bank3[addr_offset][49:40]),
                    $signed(golden_sram_value_bank3[addr_offset][39:30]), $signed(golden_sram_value_bank3[addr_offset][29:20]),
                    $signed(golden_sram_value_bank3[addr_offset][19:10]), $signed(golden_sram_value_bank3[addr_offset][ 9: 0]));
            end
            C0: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_c0.mem[addr_start+addr_offset][79:70]), $signed(sram_act_c0.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_c0.mem[addr_start+addr_offset][59:50]), $signed(sram_act_c0.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_c0.mem[addr_start+addr_offset][39:30]), $signed(sram_act_c0.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_c0.mem[addr_start+addr_offset][19:10]), $signed(sram_act_c0.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank0[addr_offset][79:70]), $signed(golden_sram_value_bank0[addr_offset][69:60]),
                    $signed(golden_sram_value_bank0[addr_offset][59:50]), $signed(golden_sram_value_bank0[addr_offset][49:40]),
                    $signed(golden_sram_value_bank0[addr_offset][39:30]), $signed(golden_sram_value_bank0[addr_offset][29:20]),
                    $signed(golden_sram_value_bank0[addr_offset][19:10]), $signed(golden_sram_value_bank0[addr_offset][ 9: 0]));
            end
            C1: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_c1.mem[addr_start+addr_offset][79:70]), $signed(sram_act_c1.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_c1.mem[addr_start+addr_offset][59:50]), $signed(sram_act_c1.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_c1.mem[addr_start+addr_offset][39:30]), $signed(sram_act_c1.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_c1.mem[addr_start+addr_offset][19:10]), $signed(sram_act_c1.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank1[addr_offset][79:70]), $signed(golden_sram_value_bank1[addr_offset][69:60]),
                    $signed(golden_sram_value_bank1[addr_offset][59:50]), $signed(golden_sram_value_bank1[addr_offset][49:40]),
                    $signed(golden_sram_value_bank1[addr_offset][39:30]), $signed(golden_sram_value_bank1[addr_offset][29:20]),
                    $signed(golden_sram_value_bank1[addr_offset][19:10]), $signed(golden_sram_value_bank1[addr_offset][ 9: 0]));
            end
            C2: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_c2.mem[addr_start+addr_offset][79:70]), $signed(sram_act_c2.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_c2.mem[addr_start+addr_offset][59:50]), $signed(sram_act_c2.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_c2.mem[addr_start+addr_offset][39:30]), $signed(sram_act_c2.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_c2.mem[addr_start+addr_offset][19:10]), $signed(sram_act_c2.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank2[addr_offset][79:70]), $signed(golden_sram_value_bank2[addr_offset][69:60]),
                    $signed(golden_sram_value_bank2[addr_offset][59:50]), $signed(golden_sram_value_bank2[addr_offset][49:40]),
                    $signed(golden_sram_value_bank2[addr_offset][39:30]), $signed(golden_sram_value_bank2[addr_offset][29:20]),
                    $signed(golden_sram_value_bank2[addr_offset][19:10]), $signed(golden_sram_value_bank2[addr_offset][ 9: 0]));
            end
            C3: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_c3.mem[addr_start+addr_offset][79:70]), $signed(sram_act_c3.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_c3.mem[addr_start+addr_offset][59:50]), $signed(sram_act_c3.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_c3.mem[addr_start+addr_offset][39:30]), $signed(sram_act_c3.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_c3.mem[addr_start+addr_offset][19:10]), $signed(sram_act_c3.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank3[addr_offset][79:70]), $signed(golden_sram_value_bank3[addr_offset][69:60]),
                    $signed(golden_sram_value_bank3[addr_offset][59:50]), $signed(golden_sram_value_bank3[addr_offset][49:40]),
                    $signed(golden_sram_value_bank3[addr_offset][39:30]), $signed(golden_sram_value_bank3[addr_offset][29:20]),
                    $signed(golden_sram_value_bank3[addr_offset][19:10]), $signed(golden_sram_value_bank3[addr_offset][ 9: 0]));
            end
            D0: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_d0.mem[addr_start+addr_offset][79:70]), $signed(sram_act_d0.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_d0.mem[addr_start+addr_offset][59:50]), $signed(sram_act_d0.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_d0.mem[addr_start+addr_offset][39:30]), $signed(sram_act_d0.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_d0.mem[addr_start+addr_offset][19:10]), $signed(sram_act_d0.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank0[addr_offset][79:70]), $signed(golden_sram_value_bank0[addr_offset][69:60]),
                    $signed(golden_sram_value_bank0[addr_offset][59:50]), $signed(golden_sram_value_bank0[addr_offset][49:40]),
                    $signed(golden_sram_value_bank0[addr_offset][39:30]), $signed(golden_sram_value_bank0[addr_offset][29:20]),
                    $signed(golden_sram_value_bank0[addr_offset][19:10]), $signed(golden_sram_value_bank0[addr_offset][ 9: 0]));
            end
            D1: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_d1.mem[addr_start+addr_offset][79:70]), $signed(sram_act_d1.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_d1.mem[addr_start+addr_offset][59:50]), $signed(sram_act_d1.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_d1.mem[addr_start+addr_offset][39:30]), $signed(sram_act_d1.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_d1.mem[addr_start+addr_offset][19:10]), $signed(sram_act_d1.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank1[addr_offset][79:70]), $signed(golden_sram_value_bank1[addr_offset][69:60]),
                    $signed(golden_sram_value_bank1[addr_offset][59:50]), $signed(golden_sram_value_bank1[addr_offset][49:40]),
                    $signed(golden_sram_value_bank1[addr_offset][39:30]), $signed(golden_sram_value_bank1[addr_offset][29:20]),
                    $signed(golden_sram_value_bank1[addr_offset][19:10]), $signed(golden_sram_value_bank1[addr_offset][ 9: 0]));
            end
            D2: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_d2.mem[addr_start+addr_offset][79:70]), $signed(sram_act_d2.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_d2.mem[addr_start+addr_offset][59:50]), $signed(sram_act_d2.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_d2.mem[addr_start+addr_offset][39:30]), $signed(sram_act_d2.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_d2.mem[addr_start+addr_offset][19:10]), $signed(sram_act_d2.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank2[addr_offset][79:70]), $signed(golden_sram_value_bank2[addr_offset][69:60]),
                    $signed(golden_sram_value_bank2[addr_offset][59:50]), $signed(golden_sram_value_bank2[addr_offset][49:40]),
                    $signed(golden_sram_value_bank2[addr_offset][39:30]), $signed(golden_sram_value_bank2[addr_offset][29:20]),
                    $signed(golden_sram_value_bank2[addr_offset][19:10]), $signed(golden_sram_value_bank2[addr_offset][ 9: 0]));
            end
            D3: begin
                $write("Your answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(sram_act_d3.mem[addr_start+addr_offset][79:70]), $signed(sram_act_d3.mem[addr_start+addr_offset][69:60]),
                    $signed(sram_act_d3.mem[addr_start+addr_offset][59:50]), $signed(sram_act_d3.mem[addr_start+addr_offset][49:40]),
                    $signed(sram_act_d3.mem[addr_start+addr_offset][39:30]), $signed(sram_act_d3.mem[addr_start+addr_offset][29:20]),
                    $signed(sram_act_d3.mem[addr_start+addr_offset][19:10]), $signed(sram_act_d3.mem[addr_start+addr_offset][ 9: 0]));
                $write("But the golden answer is \n%d (ch0)\n%d (ch1)\n%d (ch2)\n%d (ch3) \n%d (ch4)\n%d (ch5)\n%d (ch6)\n%d (ch7)\n", 
                    $signed(golden_sram_value_bank3[addr_offset][79:70]), $signed(golden_sram_value_bank3[addr_offset][69:60]),
                    $signed(golden_sram_value_bank3[addr_offset][59:50]), $signed(golden_sram_value_bank3[addr_offset][49:40]),
                    $signed(golden_sram_value_bank3[addr_offset][39:30]), $signed(golden_sram_value_bank3[addr_offset][29:20]),
                    $signed(golden_sram_value_bank3[addr_offset][19:10]), $signed(golden_sram_value_bank3[addr_offset][ 9: 0]));
            end
        endcase
    end
endtask

endmodule