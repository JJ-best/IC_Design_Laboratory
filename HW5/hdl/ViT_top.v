// new version
module ViT_top #(
    parameter CH_NUM = 8,
    parameter ACT_PER_ADDR = 1,
    parameter BW_PER_ACT = 10,
    parameter WEIGHT_PER_ADDR = 16,
    parameter BIAS_PER_ADDR = 1,
    parameter BW_PER_PARAM = 10
) (
    // Control signals
    input wire clk,
    input wire srst_n,
    input wire enable,
    output wire valid,

    // SRAM read data inputs
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a0,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a1,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a2,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a3,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b0,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b1,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b2,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b3,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_c0,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_c1,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_c2,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_c3,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_d0,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_d1,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_d2,
    input wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_d3,
    input wire [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_weight,
    input wire [BIAS_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_bias,

    // SRAM address outputs
    output reg  [5-1:0] sram_addr_a0,
    output reg  [5-1:0] sram_addr_a1,
    output reg  [5-1:0] sram_addr_a2,
    output reg  [5-1:0] sram_addr_a3,
    output reg  [5-1:0] sram_addr_b0,
    output reg  [5-1:0] sram_addr_b1,
    output reg  [5-1:0] sram_addr_b2,
    output reg  [5-1:0] sram_addr_b3,
    output reg  [6-1:0] sram_addr_c0,
    output reg  [6-1:0] sram_addr_c1,
    output reg  [6-1:0] sram_addr_c2,
    output reg  [6-1:0] sram_addr_c3,
    output reg  [6-1:0] sram_addr_d0,
    output reg  [6-1:0] sram_addr_d1,
    output reg  [6-1:0] sram_addr_d2,
    output reg  [6-1:0] sram_addr_d3,
    output wire [8-1:0] sram_raddr_weight,
    output wire [7-1:0] sram_raddr_bias,

    // SRAM write enable outputs (low active)
    output wire sram_wen_a0,
    output wire sram_wen_a1,
    output wire sram_wen_a2,
    output wire sram_wen_a3,
    output reg  sram_wen_b0,
    output reg  sram_wen_b1,
    output reg  sram_wen_b2,
    output reg  sram_wen_b3,
    output wire sram_wen_c0,
    output wire sram_wen_c1,
    output wire sram_wen_c2,
    output wire sram_wen_c3,
    output reg  sram_wen_d0,
    output reg  sram_wen_d1,
    output reg  sram_wen_d2,
    output reg  sram_wen_d3,

    // SRAM word mask outputs
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a0,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a1,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a2,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a3,
    output reg  [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b0,
    output reg  [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b1,
    output reg  [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b2,
    output reg  [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b3,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_c0,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_c1,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_c2,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_c3,
    output reg  [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_d0,
    output reg  [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_d1,
    output reg  [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_d2,
    output reg  [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_d3,

    // SRAM write data outputs
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a0,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a1,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a2,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a3,
    output reg  [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b0,
    output reg  [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b1,
    output reg  [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b2,
    output reg  [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b3,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_c0,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_c1,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_c2,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_c3,
    output reg  [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_d0,
    output reg  [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_d1,
    output reg  [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_d2,
    output reg  [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_d3
);



// ===== part1: read the normalize bias out ===== //
reg [(BW_PER_ACT-1):0] bias_reg [0:15]; // 0->ch0, 15->ch15
reg [3:0] bias_addr_cnt;
reg bias_finish;
reg [4:0] sram_addr_cnt_a; // sram A addr controller
reg valid_3; 
// ===== read sram B ===== //
// SRAM B addr controller
reg [4:0] sram_addr_cnt_b;
reg valid_1;
reg valid_2;

reg [3:0] cnt8; // count 8 cycle
reg [2:0]sram_b_wen_cnt;
wire [5:0] sramc_addr;

wire[5:0] sram_addr_cnt_c;
// ===== read sram C ===== //
reg [3:0] sramc_k_addr_cnt;
reg [3:0] sramc_k_addr_cnt_d;
wire [4:0] sramc_k_addr;
reg access_k;
reg signed[(BW_PER_ACT-1):0] c_bank0_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] c_bank1_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] c_bank2_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] c_bank3_dat[0:(CH_NUM-1)];
reg signed [9:0] c_bank_dat_reg[0:7];
reg sramc_addr_d;

// ===== sram D ===== //
wire [5:0] sramd_waddr;
reg [2:0]qk_cnt8;
reg [4:0]sramd_raddr_cnt;
wire [5:0]sramd_raddr;
reg [68:0] df_stage9_Q50[0:7];

reg [39:0] exp_sum_reg;
reg [33:0]exp_shift_1[0:7];
reg [33:0]exp_shift_2[0:7];
reg [33:0]exp_shift_3[0:7];
reg [33:0]exp_shift_4[0:7];
reg [33:0]exp_shift_5[0:7];
reg [33:0]exp_shift_6[0:7];
reg [33:0]exp_shift_7[0:7];
reg [33:0]exp_shift_8[0:7];
reg [33:0]exp_shift_9[0:7];

// ----- softmax ----- //
reg valid_12;
reg valid_12_d1;
reg valid_12_d2;
reg valid_12_d3;
reg valid_12_d4;
reg valid_12_d5;
reg valid_12_d6;
reg [1:0] sramb_wcnt;
reg [4:0] sramb_waddr_softmax;
reg [1:0]sramd_cnt;
reg [79:0] softmax_wdata;
reg [9:0] softmax_wdata_ch[0:7];


// ===== step 14 ===== //
reg [2:0] sramb_rcnt;
reg [3:0] sramc_addr_vproj_cnt; // last 4-bit addr counter
wire [5:0] sramc_addr_vproj;    // sram C addr for vproj
reg [4:0] sramb_addr_vproj_cnt; // last 5-bit addr counter
wire [4:0] sramb_addr_vproj;    // sram B addr for vproj
reg [9:0] sramb_dat_vproj[0:3];
wire [2:0] vproj_cnt8;
reg valid_13;
// ----- vproj write sram D ----- //
reg [5:0] vproj_wcnt; 
wire accum_done;
reg [4:0] vproj_sramd_waddr;
wire [79:0] vproj_wdata;
reg head_sel;
reg valid_14;
// ----- orpojection ----- //
reg signed[(BW_PER_ACT-1):0] d_bank0_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] d_bank1_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] d_bank2_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] d_bank3_dat[0:(CH_NUM-1)];

// ----- residual ----- //
reg [4:0] sramb_addr_res;
wire sramb_wen_res;
reg [7:0] sramb_wordmask_res;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] b_bank0_w;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] b_bank1_w;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] b_bank2_w;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] b_bank3_w;
// ===== Top Level Finite State Machine ===== //
localparam IDLE       = 5'd0;
localparam R_BIAS_A   = 5'd1;
localparam NORMAL     = 5'd2;
localparam NORMAL_T   = 5'd3;
localparam PROJ       = 5'd4;
localparam PROJ_T     = 5'd5;
localparam R_SRAM_C   = 5'd6; // multiply QK
localparam R_SRAM_C_T = 5'd7;
localparam SOFTMAX    = 5'd8;
localparam SOFTMAX_T  = 5'd9;
localparam V_PROJ     = 5'd10;
localparam V_PROJ_T   = 5'd11;
localparam O_PROJ     = 5'd12;
localparam O_PROJ_T   = 5'd13;
localparam DONE       = 5'd14;

localparam demask_h   = 8'b0000_1111;
localparam demask_l   = 8'b1111_0000;
localparam mask_all   = 8'b1111_1111;
localparam demask_all = 8'b0000_0000;

reg [4:0]top_state;
reg [4:0]top_state_n;


always @(posedge clk) begin
    if (!srst_n) begin
        top_state <= IDLE;
    end else begin
        top_state <= top_state_n;
    end
end

always @(*) begin
    case (top_state)
        IDLE: begin
            if (enable) begin
                top_state_n = R_BIAS_A;
            end else begin
                top_state_n = IDLE;
            end
        end
        R_BIAS_A: begin
            if (bias_finish) begin
                top_state_n = NORMAL;
            end else begin
                top_state_n = R_BIAS_A;
            end
        end
        NORMAL: begin
            if (sram_addr_cnt_a == 5'd1 && cnt8==4'd1 && valid_2) begin
                top_state_n = NORMAL_T;
            end else begin
                top_state_n = NORMAL;
            end
        end
        NORMAL_T: begin
            if (sram_b_wen_cnt == 3'd7 && sram_addr_b0 == 5'd31) begin
                top_state_n = PROJ;
            end else begin
                top_state_n = NORMAL_T;
            end
        end
        PROJ: begin
            if ((sram_raddr_weight == 8'd40|| sram_raddr_weight == 8'd48)&& sram_addr_cnt_b == 5'd31) begin
                top_state_n = PROJ_T;
            end else begin
                top_state_n = PROJ;
            end
        end
        PROJ_T: begin
            if (sram_wen_c0 == 0 && sram_addr_cnt_c == 6'd47) begin
                top_state_n = R_SRAM_C;
            end else begin
                top_state_n = PROJ_T;
            end
        end
        R_SRAM_C: begin
            if (sramd_waddr == 6'd63 && qk_cnt8==3'd4) begin
                top_state_n = R_SRAM_C_T;
            end else begin
                top_state_n = R_SRAM_C;
            end
        end
        R_SRAM_C_T: begin
            if (sramd_waddr == 6'd63 && qk_cnt8==3'd7) begin
                top_state_n = SOFTMAX;
            end else begin
                top_state_n = R_SRAM_C_T;
            end
        end
        SOFTMAX: begin
            if (sram_addr_d0 == 6'd63 && sramd_cnt == 2'b11) begin
                top_state_n = SOFTMAX_T;
            end else begin
                top_state_n = SOFTMAX;
            end
        end
        SOFTMAX_T: begin
            if (sramb_waddr_softmax == 5'd31 && sramb_wcnt == 2'b11) begin
                top_state_n = V_PROJ;
            end else begin
                top_state_n = SOFTMAX_T;
            end
        end
        V_PROJ: begin
            if (sram_addr_b0 == 5'd31 && sram_addr_c0 == 6'd47) begin
                top_state_n = V_PROJ_T;
            end else begin
                top_state_n = V_PROJ;
            end
        end
        V_PROJ_T: begin
            if (accum_done && vproj_wcnt==6'd63) begin
                top_state_n = (!head_sel)? R_BIAS_A: O_PROJ;
            end else if (accum_done && vproj_wcnt[3:0]==4'b1111) begin
                top_state_n = R_SRAM_C;
            end else begin
                top_state_n = V_PROJ_T;
            end
        end
        O_PROJ: begin
            if ((sram_raddr_weight == 8'd64)&& sram_addr_cnt_b == 5'd31) begin
                top_state_n = O_PROJ_T;
            end else begin
                top_state_n = O_PROJ;
            end
        end
        O_PROJ_T: begin // TODO: O_PROJ_T 不要換那麼快
            if (sram_addr_b0 == 5'd0) begin
                top_state_n = DONE;
            end else begin
                top_state_n = O_PROJ_T;
            end
        end
        DONE: begin
            top_state_n = DONE;
        end
        default: begin
           top_state_n = IDLE; 
        end
    endcase
end

// tmp cnt
reg [3:0]tmp_cnt;
always @(posedge clk) begin
    if (!srst_n) begin
        tmp_cnt <= 0;
    end else if (top_state == DONE)begin
        tmp_cnt <= tmp_cnt + 1;
    end
end
// should be 1 for correct answer
assign valid = (tmp_cnt == 4'b1111)? 1:0;

// ===== read the normalize bias out ===== //
// SRAM-bias: 1 data / addr
// read from addr 0~15, store the bias for ch0~15 into register

integer i;
always @(posedge clk) begin
    if (top_state == R_BIAS_A) begin
        bias_reg[15] <= sram_rdata_bias;
        for (i=14; i>=0; i=i-1) begin
            bias_reg[i] <= bias_reg[i+1];
        end
    end
end


always @(posedge clk) begin
    if (!srst_n) begin
        bias_finish <= 0;
    end else begin
        bias_finish <= (bias_addr_cnt == 4'b1111)? 1:0;
    end
end

assign sram_raddr_bias = bias_addr_cnt;
always @(posedge clk) begin
    if (top_state == R_BIAS_A) begin
        bias_addr_cnt <= bias_addr_cnt + 1;
    end else begin
        bias_addr_cnt <= 0;
    end
end

// ===== 1. read the patched embedded from SRAM A ===== //
// SRAM A: 64@16ch
// addr 0~15: 0~7ch, addr 16~31: 8~15ch

//               token0: {addr0_bank0, addr16_bank0}, 
//               token1: {addr0_bank1, addr16_bank1}, 
//               token2: {addr0_bank2, addr16_bank2}, 
//               token3: {addr0_bank3, addr16_bank3}
//
//               token4: {addr1_bank0, addr17_bank0}, 
//               token5: {addr1_bank1, addr17_bank1}, 
//               token6: {addr1_bank2, addr17_bank2}, 
//               token7: {addr1_bank3, addr17_bank3}
//
//               token8:  {addr2_bank0, addr18_bank0}, 
//               token9:  {addr2_bank1, addr18_bank1}, 
//               token10: {addr2_bank2, addr18_bank2}, 
//               token11: {addr2_bank3, addr18_bank3}
// ...
//               token60:  {addr15_bank0, addr31_bank0}, 
//               token61:  {addr15_bank1, addr31_bank1}, 
//               token62:  {addr15_bank2, addr31_bank2}, 
//               token63:  {addr15_bank3, addr31_bank3}

// SRAM A access:
// addr0 -> addr(0+16) -> addr1 -> addr(1+16) -> ... -> addr15 -> addr(15+16)
// 00000 -> 10000 -> 00001 -> 10001 -> ... -> 01111 -> 11111
// toggle the MSB addr, and increment the LSB addr


// SRAM A is read only
assign sram_wen_a0 = 1'b1;
assign sram_wen_a1 = 1'b1;
assign sram_wen_a2 = 1'b1;
assign sram_wen_a3 = 1'b1;

always @(posedge clk) begin
    if (!srst_n) begin
        cnt8 <= 0;
    end else if (top_state == NORMAL) begin
        cnt8 <= (cnt8 == 4'd8)? 0 : cnt8 + 1;
    end else if (top_state != NORMAL && top_state != NORMAL_T) begin
        cnt8 <= 0;
    end
end 
// SRAM A addr controller
always @(posedge clk) begin
    if (top_state == NORMAL) begin
        if ((sram_addr_a0[4] == 0) | (sram_addr_a0[4] == 1 && cnt8 == 4'd8)) begin
            sram_addr_cnt_a <= sram_addr_cnt_a + 1;
        end else begin
            sram_addr_cnt_a <= sram_addr_cnt_a;
        end
    end else begin
        sram_addr_cnt_a <= 0;
    end
end

always @(*) begin
    case (top_state)
        NORMAL, NORMAL_T: begin
            sram_addr_a0 = {sram_addr_cnt_a[0], sram_addr_cnt_a[4:1]};
            sram_addr_a1 = {sram_addr_cnt_a[0], sram_addr_cnt_a[4:1]};
            sram_addr_a2 = {sram_addr_cnt_a[0], sram_addr_cnt_a[4:1]};
            sram_addr_a3 = {sram_addr_cnt_a[0], sram_addr_cnt_a[4:1]};
        end
        O_PROJ, O_PROJ_T: begin
            sram_addr_a0 = sram_addr_cnt_c;
            sram_addr_a1 = sram_addr_cnt_c;
            sram_addr_a2 = sram_addr_cnt_c;
            sram_addr_a3 = sram_addr_cnt_c;
        end
        default: begin
            sram_addr_a0 = 0;
            sram_addr_a1 = 0;
            sram_addr_a2 = 0;
            sram_addr_a3 = 0;
        end   
    endcase
end

// ----- debug signal ----- //
reg signed[(BW_PER_ACT-1):0] a_bank0_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] a_bank1_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] a_bank2_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] a_bank3_dat[0:(CH_NUM-1)];


always @(*) begin
    // MSB-first ordering: [79:70], [69:60], ..., [9:0]
    a_bank0_dat[0] = sram_rdata_a0[79:70]; // ch0
    a_bank0_dat[1] = sram_rdata_a0[69:60]; // ch1
    a_bank0_dat[2] = sram_rdata_a0[59:50]; // ch2
    a_bank0_dat[3] = sram_rdata_a0[49:40]; // ch3
    a_bank0_dat[4] = sram_rdata_a0[39:30]; // ch4
    a_bank0_dat[5] = sram_rdata_a0[29:20]; // ch5
    a_bank0_dat[6] = sram_rdata_a0[19:10]; // ch6
    a_bank0_dat[7] = sram_rdata_a0[9:0];   // ch7

    a_bank1_dat[0] = sram_rdata_a1[79:70];
    a_bank1_dat[1] = sram_rdata_a1[69:60];
    a_bank1_dat[2] = sram_rdata_a1[59:50];
    a_bank1_dat[3] = sram_rdata_a1[49:40];
    a_bank1_dat[4] = sram_rdata_a1[39:30];
    a_bank1_dat[5] = sram_rdata_a1[29:20];
    a_bank1_dat[6] = sram_rdata_a1[19:10];
    a_bank1_dat[7] = sram_rdata_a1[9:0];

    a_bank2_dat[0] = sram_rdata_a2[79:70];
    a_bank2_dat[1] = sram_rdata_a2[69:60];
    a_bank2_dat[2] = sram_rdata_a2[59:50];
    a_bank2_dat[3] = sram_rdata_a2[49:40];
    a_bank2_dat[4] = sram_rdata_a2[39:30];
    a_bank2_dat[5] = sram_rdata_a2[29:20];
    a_bank2_dat[6] = sram_rdata_a2[19:10];
    a_bank2_dat[7] = sram_rdata_a2[9:0];

    a_bank3_dat[0] = sram_rdata_a3[79:70];
    a_bank3_dat[1] = sram_rdata_a3[69:60];
    a_bank3_dat[2] = sram_rdata_a3[59:50];
    a_bank3_dat[3] = sram_rdata_a3[49:40];
    a_bank3_dat[4] = sram_rdata_a3[39:30];
    a_bank3_dat[5] = sram_rdata_a3[29:20];
    a_bank3_dat[6] = sram_rdata_a3[19:10];
    a_bank3_dat[7] = sram_rdata_a3[9:0];
end

// since we need 2 cycle to get complete token, so we need to store the 
// first half cycle data, and connect to next cycle data
// ===== store data per channel ===== //
reg signed[BW_PER_ACT-1:0] a_bank0_reg_h [0:CH_NUM-1];
reg signed[BW_PER_ACT-1:0] a_bank1_reg_h [0:CH_NUM-1];
reg signed[BW_PER_ACT-1:0] a_bank2_reg_h [0:CH_NUM-1];
reg signed[BW_PER_ACT-1:0] a_bank3_reg_h [0:CH_NUM-1];
reg signed[BW_PER_ACT-1:0] a_bank0_reg_l [0:CH_NUM-1];
reg signed[BW_PER_ACT-1:0] a_bank1_reg_l [0:CH_NUM-1];
reg signed[BW_PER_ACT-1:0] a_bank2_reg_l [0:CH_NUM-1];
reg signed[BW_PER_ACT-1:0] a_bank3_reg_l [0:CH_NUM-1];


// ---- bank0 ---- //
always @(posedge clk) begin
    if (cnt8 == 4'd1) begin
        a_bank0_reg_h[0] <= a_bank0_dat[0];
        a_bank0_reg_h[1] <= a_bank0_dat[1];
        a_bank0_reg_h[2] <= a_bank0_dat[2];
        a_bank0_reg_h[3] <= a_bank0_dat[3];
        a_bank0_reg_h[4] <= a_bank0_dat[4];
        a_bank0_reg_h[5] <= a_bank0_dat[5];
        a_bank0_reg_h[6] <= a_bank0_dat[6];
        a_bank0_reg_h[7] <= a_bank0_dat[7];
        valid_1 <= 0;
    end
    if (cnt8 == 4'd2) begin
        a_bank0_reg_l[0] <= a_bank0_dat[0];
        a_bank0_reg_l[1] <= a_bank0_dat[1];
        a_bank0_reg_l[2] <= a_bank0_dat[2];
        a_bank0_reg_l[3] <= a_bank0_dat[3];
        a_bank0_reg_l[4] <= a_bank0_dat[4];
        a_bank0_reg_l[5] <= a_bank0_dat[5];
        a_bank0_reg_l[6] <= a_bank0_dat[6];
        a_bank0_reg_l[7] <= a_bank0_dat[7];
        valid_1 <= (top_state == NORMAL)? 1:0;
    end
end

// ---- bank1 ---- //
always @(posedge clk) begin
    if (cnt8 == 4'd1) begin
        a_bank1_reg_h[0] <= a_bank1_dat[0];
        a_bank1_reg_h[1] <= a_bank1_dat[1];
        a_bank1_reg_h[2] <= a_bank1_dat[2];
        a_bank1_reg_h[3] <= a_bank1_dat[3];
        a_bank1_reg_h[4] <= a_bank1_dat[4];
        a_bank1_reg_h[5] <= a_bank1_dat[5];
        a_bank1_reg_h[6] <= a_bank1_dat[6];
        a_bank1_reg_h[7] <= a_bank1_dat[7];
    end
    if (cnt8 == 4'd2) begin
        a_bank1_reg_l[0] <= a_bank1_dat[0];
        a_bank1_reg_l[1] <= a_bank1_dat[1];
        a_bank1_reg_l[2] <= a_bank1_dat[2];
        a_bank1_reg_l[3] <= a_bank1_dat[3];
        a_bank1_reg_l[4] <= a_bank1_dat[4];
        a_bank1_reg_l[5] <= a_bank1_dat[5];
        a_bank1_reg_l[6] <= a_bank1_dat[6];
        a_bank1_reg_l[7] <= a_bank1_dat[7];
    end
end

// ---- bank2 ---- //
always @(posedge clk) begin
    if (cnt8 == 4'd1) begin
        a_bank2_reg_h[0] <= a_bank2_dat[0];
        a_bank2_reg_h[1] <= a_bank2_dat[1];
        a_bank2_reg_h[2] <= a_bank2_dat[2];
        a_bank2_reg_h[3] <= a_bank2_dat[3];
        a_bank2_reg_h[4] <= a_bank2_dat[4];
        a_bank2_reg_h[5] <= a_bank2_dat[5];
        a_bank2_reg_h[6] <= a_bank2_dat[6];
        a_bank2_reg_h[7] <= a_bank2_dat[7];
    end
    if (cnt8 == 4'd2) begin
        a_bank2_reg_l[0] <= a_bank2_dat[0];
        a_bank2_reg_l[1] <= a_bank2_dat[1];
        a_bank2_reg_l[2] <= a_bank2_dat[2];
        a_bank2_reg_l[3] <= a_bank2_dat[3];
        a_bank2_reg_l[4] <= a_bank2_dat[4];
        a_bank2_reg_l[5] <= a_bank2_dat[5];
        a_bank2_reg_l[6] <= a_bank2_dat[6];
        a_bank2_reg_l[7] <= a_bank2_dat[7];
    end
end

// ---- bank3 ---- //
always @(posedge clk) begin
    if (cnt8 == 4'd1) begin
        a_bank3_reg_h[0] <= a_bank3_dat[0];
        a_bank3_reg_h[1] <= a_bank3_dat[1];
        a_bank3_reg_h[2] <= a_bank3_dat[2];
        a_bank3_reg_h[3] <= a_bank3_dat[3];
        a_bank3_reg_h[4] <= a_bank3_dat[4];
        a_bank3_reg_h[5] <= a_bank3_dat[5];
        a_bank3_reg_h[6] <= a_bank3_dat[6];
        a_bank3_reg_h[7] <= a_bank3_dat[7];
    end
    if (cnt8 == 4'd2) begin
        a_bank3_reg_l[0] <= a_bank3_dat[0];
        a_bank3_reg_l[1] <= a_bank3_dat[1];
        a_bank3_reg_l[2] <= a_bank3_dat[2];
        a_bank3_reg_l[3] <= a_bank3_dat[3];
        a_bank3_reg_l[4] <= a_bank3_dat[4];
        a_bank3_reg_l[5] <= a_bank3_dat[5];
        a_bank3_reg_l[6] <= a_bank3_dat[6];
        a_bank3_reg_l[7] <= a_bank3_dat[7];
    end
end

integer g;
reg signed [BW_PER_ACT-1:0] a_bank_reg_h_d[0:CH_NUM-1];
always @(posedge clk) begin
    for (g=0;g<8;g=g+1) begin
        a_bank_reg_h_d[g] <= a_bank3_reg_h[g];
    end
end
// ===== 2. normalization (computation per token) ===== //

// ----- token mean ----- //
// token_sum = Σ x_i,  i = 0~15 (8 from _dat + 8 from _reg)
// token_mean μ = token_sum / 16   // divide by 16

// in sram A, data(1-bit sign + 3-bit integer + 6-bit fraction)
// after addition 16 number, the sum is (1-bit sign + 7-bit integer + 6-bit fraction)
// then to get mean, view the sum as (1-bit sign + 3-bit integer + 10-bit fraction)
reg signed[BW_PER_ACT+3:0] token0_mean;
reg signed[BW_PER_ACT+3:0] token1_mean;
reg signed[BW_PER_ACT+3:0] token2_mean;
reg signed[BW_PER_ACT+3:0] token3_mean;
reg signed[BW_PER_ACT+3:0] token_mean;
reg signed[BW_PER_ACT+3:0] token_mean_n;
reg signed[BW_PER_ACT-1:0] a_bank_dat[0:15];

integer k;
always @(*) begin
    for (k = 0; k < 16; k = k + 1) begin
        case (cnt8)
            3: begin a_bank_dat[k] = (k < 8) ? a_bank0_reg_h[k] : a_bank0_reg_l[k-8]; end
            4: begin a_bank_dat[k] = (k < 8) ? a_bank0_reg_h[k] : a_bank0_reg_l[k-8]; end
            5: begin a_bank_dat[k] = (k < 8) ? a_bank1_reg_h[k] : a_bank1_reg_l[k-8]; end
            6: begin a_bank_dat[k] = (k < 8) ? a_bank1_reg_h[k] : a_bank1_reg_l[k-8]; end
            7: begin a_bank_dat[k] = (k < 8) ? a_bank2_reg_h[k] : a_bank2_reg_l[k-8]; end
            8: begin a_bank_dat[k] = (k < 8) ? a_bank2_reg_h[k] : a_bank2_reg_l[k-8]; end
            0: begin a_bank_dat[k] = (k < 8) ? a_bank3_reg_h[k] : a_bank3_reg_l[k-8]; end
            1: begin a_bank_dat[k] = (k < 8) ? a_bank3_reg_h[k] : a_bank3_reg_l[k-8]; end
            default: begin a_bank_dat[k] = 0; end
        endcase
    end
end


always @(*) begin
    token_mean_n = a_bank_dat[0]  + a_bank_dat[1]  + a_bank_dat[2]  + a_bank_dat[3]  + 
                   a_bank_dat[4]  + a_bank_dat[5]  + a_bank_dat[6]  + a_bank_dat[7]  + 
                   a_bank_dat[8]  + a_bank_dat[9]  + a_bank_dat[10] + a_bank_dat[11] + 
                   a_bank_dat[12] + a_bank_dat[13] + a_bank_dat[14] + a_bank_dat[15];
end

always @(posedge clk) begin
    if (valid_1) begin
    token_mean <= token_mean_n;
    end
    valid_2 <= valid_1;
end

// ----- token MAE ----- //
// token_mae = Σ |x_i - μ| / 16,  i = 0~15 (8 from _dat + 8 from _reg)

// to get abs value, we calculate x_i(1-bit sign + 3-bit integer + 6-bit fraction)
// minus μ (1-bit sign + 3-bit integer + 10-bit fraction)
// the result abs data may be (1-bit sign + 3-bit integer + 10-bit fraction)
// sum 16 as data so the result may be (1-bit sign + 7-bit integer + 10-bit fraction)
// then devide by 16, so we view the sum as (1-bit sign + 3-bit integer + 14-bit fraction)
// to get the MAE
reg [13:0] a_bank_minus[0:15];
reg [13:0] a_bank_minux_x[0:15];
reg [13:0] a_bank_abs[0:15];
reg [17:0] token_mae;

always @(*) begin
    for (k = 0; k < 16; k = k + 1) begin
        case (cnt8)
            4: begin a_bank_minux_x[k] = (k < 8) ? {a_bank0_reg_h[k], 4'b0} : {a_bank0_reg_l[k-8], 4'b0}; end
            5: begin a_bank_minux_x[k] = (k < 8) ? {a_bank0_reg_h[k], 4'b0} : {a_bank0_reg_l[k-8], 4'b0}; end
            6: begin a_bank_minux_x[k] = (k < 8) ? {a_bank1_reg_h[k], 4'b0} : {a_bank1_reg_l[k-8], 4'b0}; end
            7: begin a_bank_minux_x[k] = (k < 8) ? {a_bank1_reg_h[k], 4'b0} : {a_bank1_reg_l[k-8], 4'b0}; end
            8: begin a_bank_minux_x[k] = (k < 8) ? {a_bank2_reg_h[k], 4'b0} : {a_bank2_reg_l[k-8], 4'b0}; end
            0: begin a_bank_minux_x[k] = (k < 8) ? {a_bank2_reg_h[k], 4'b0} : {a_bank2_reg_l[k-8], 4'b0}; end
            1: begin a_bank_minux_x[k] = (k < 8) ? {a_bank3_reg_h[k], 4'b0} : {a_bank3_reg_l[k-8], 4'b0}; end
            2: begin a_bank_minux_x[k] = (k < 8) ? {a_bank_reg_h_d[k], 4'b0} : {a_bank3_reg_l[k-8], 4'b0}; end
            default: begin a_bank_minux_x[k] = 0; end
        endcase
    end
end

always @(*) begin
    for (k=0; k<16; k=k+1) begin
        a_bank_minus[k] = a_bank_minux_x[k] - token_mean;
    end
end

always @(*) begin
    // absolute value: if the sign bit is 1, get 2's complement
    for (k=0; k<16; k=k+1) begin
        a_bank_abs[k] = a_bank_minus[k][13]? (~a_bank_minus[k] + 1'b1): a_bank_minus[k];
    end
end

always @(posedge clk) begin
    token_mae <= a_bank_abs[0]  + a_bank_abs[1]  + a_bank_abs[2]  + a_bank_abs[3]  + 
                a_bank_abs[4]  + a_bank_abs[5]  + a_bank_abs[6]  + a_bank_abs[7]  + 
                a_bank_abs[8]  + a_bank_abs[9]  + a_bank_abs[10] + a_bank_abs[11] + 
                a_bank_abs[12] + a_bank_abs[13] + a_bank_abs[14] + a_bank_abs[15];
end



// ----- token normalize ----- //
// x_i' = (x_i - μ) / MAE
// x_i (1-bit sign + 3-bit integer + 6-bit fraction)
// μ   (1-bit sign + 3-bit integer + 10-bit fraction)
// (x_i - μ) can use a_bankx_minus
// MAE (1-bit sign + 3-bit integer + 14-bit fraction)

// for fix-pointed division, you
// only need to perform to fraction-bit = 6, while 
// the more fractional point can be clipped.
// so we take (x_i - μ) (1-bit sign + 3-bit integer + 6-bit fraction)
// devided by MAE (1-bit sign + 3-bit integer + 6-bit fraction)

// since the binary divider will give the quocient only(integer), the remainder
// will be discard, to fix this problem, we (x_i - μ) << 6 then do the division
// this may preserve the accuracy, then result >> 6 to get correct value

// For fixed-point division, we first change the input dividend and divisor to positive
// numbers, then perform the division to fraction-bit = 6. If the original answer is negative, we then
// change the result back to a negative number (i.e. positive divisor and negative dividend, or
// negative divisor and positive dividend).

wire [17:0] token_mae_abs;
wire [38:0] token_nor[0:7];
reg signed[BW_PER_ACT-1:0] token_nor_t[0:7];
reg [BW_PER_ACT-1:0] token_nor_reg[0:7];
reg [13:0] a_bank_abs_sel[0:7];
reg sel_toggle; // this signal toggle when valid_2 is high
reg valid_2_d0;
reg valid_2_d1;
reg valid_2_d2;
reg valid_2_d3;
reg valid_2_d4;
reg valid_2_d5;
reg valid_2_d6;
reg valid_2_d7;
reg a_bank_minus_sign_d0[0:15];
reg a_bank_minus_sign_d1[0:15];
reg a_bank_minus_sign_d2[0:15];
reg a_bank_minus_sign_d3[0:15];
reg a_bank_minus_sign_d4[0:15];
reg a_bank_minus_sign_d5[0:15];
reg a_bank_minus_sign_d6[0:15];
reg a_bank_minus_sign_d7[0:15];
reg token_mae_sign_d0;
reg token_mae_sign_d1;
reg token_mae_sign_d2;
reg token_mae_sign_d3;
reg token_mae_sign_d4;
reg token_mae_sign_d5;
reg token_mae_sign_d6;
reg token_mae_sign_d7;
reg sel_toggle_d0;
reg sel_toggle_d1;
reg sel_toggle_d2;
reg sel_toggle_d3;
reg sel_toggle_d4;
reg sel_toggle_d5;
reg sel_toggle_d6;
reg sel_toggle_d7;

always @(posedge clk) begin
    if (valid_2) begin
        sel_toggle <= ~sel_toggle;
    end else begin
        sel_toggle <= 0;
    end
end

// divider pipelien 4-stage, delay 3 cycle
always @(posedge clk) begin
    valid_2_d0 <= valid_2;
    valid_2_d1 <= valid_2_d0;
    valid_2_d2 <= valid_2_d1;
    valid_2_d3 <= valid_2_d2;
    valid_2_d4 <= valid_2_d3;
    valid_2_d5 <= valid_2_d4;
    valid_2_d6 <= valid_2_d5;
    valid_2_d7 <= valid_2_d6;
    for (k=0; k<16; k=k+1) begin
        a_bank_minus_sign_d0[k] <= a_bank_minus[k][13];
        a_bank_minus_sign_d1[k] <= a_bank_minus_sign_d0[k];
        a_bank_minus_sign_d2[k] <= a_bank_minus_sign_d1[k];
        a_bank_minus_sign_d3[k] <= a_bank_minus_sign_d2[k];
        a_bank_minus_sign_d4[k] <= a_bank_minus_sign_d3[k];
        a_bank_minus_sign_d5[k] <= a_bank_minus_sign_d4[k];
        a_bank_minus_sign_d6[k] <= a_bank_minus_sign_d5[k];
        a_bank_minus_sign_d7[k] <= a_bank_minus_sign_d6[k];
    end
    token_mae_sign_d1 <= token_mae[17]; // already pipe at token_mae
    token_mae_sign_d2 <= token_mae_sign_d1;
    token_mae_sign_d3 <= token_mae_sign_d2;
    token_mae_sign_d4 <= token_mae_sign_d3;
    token_mae_sign_d5 <= token_mae_sign_d4;
    token_mae_sign_d6 <= token_mae_sign_d5;
    token_mae_sign_d7 <= token_mae_sign_d6;
    sel_toggle_d0 <= sel_toggle;
    sel_toggle_d1 <= sel_toggle_d0;
    sel_toggle_d2 <= sel_toggle_d1;
    sel_toggle_d3 <= sel_toggle_d2;
    sel_toggle_d4 <= sel_toggle_d3;
    sel_toggle_d5 <= sel_toggle_d4;
    sel_toggle_d6 <= sel_toggle_d5;
    sel_toggle_d7 <= sel_toggle_d6;
end
always @(*) begin
    if (!sel_toggle) begin
        for (k=0; k<8; k=k+1) begin
            a_bank_abs_sel[k] = a_bank_abs[k];
        end
    end else begin
        for (k=0; k<8; k=k+1) begin
            a_bank_abs_sel[k] = a_bank_abs[k+8];
        end 
    end
end

reg [13:0]a_bank_abs_sel_d1[0:7];
always @(posedge clk) begin
    for (k=0; k<8; k=k+1) begin
        a_bank_abs_sel_d1[k] <= a_bank_abs_sel[k];
    end
end

assign token_mae_abs = (token_mae[17])? ~token_mae + 1: token_mae;
localparam N = 39;
localparam M = 39;
reg [(N-1):0]dividend[0:7];
reg [(M-1):0]divisor[0:7];
reg [(N-1):0] dividend_debug[0:7];
reg [(M-1):0] divisor_debug[0:7];
always @(*) begin
    case (top_state)
        NORMAL: begin
            for (k=0; k<8; k=k+1) begin
                dividend[k] = {a_bank_abs_sel_d1[k], 4'b0, 6'b0};
                divisor[k]  = {token_mae_abs};
            end
        end
        NORMAL_T: begin
            for (k=0; k<8; k=k+1) begin
                dividend[k] = {a_bank_abs_sel_d1[k], 4'b0, 6'b0};
                divisor[k]  = {token_mae_abs};
            end
        end
        SOFTMAX, SOFTMAX_T: begin
            for (k=0; k<8; k=k+1) begin
                dividend[k] = {exp_shift_9[k][33:1], 6'b0};
                divisor[k]  = exp_sum_reg[39:1];
            end
        end
        default: begin
            for (k=0; k<8; k=k+1) begin
                dividend[k] = 0;
                divisor[k]  = 0;
            end
        end 
    endcase
    // for (k=0; k<8; k=k+1) begin
    //     dividend[k] = (top_state != SOFTMAX)? {a_bank_abs_sel_d1[k], 4'b0, 6'b0}: {exp_shift_9[k][33:10], 6'b0};
    //     divisor[k]  = (top_state != SOFTMAX)? {token_mae_abs}: exp_sum_reg[39:10];
    // end

    for (k=0; k<8; k=k+1) begin
        dividend_debug[k] = {exp_shift_9[k][33:1]}; // exp(x)
        divisor_debug[k] = {exp_sum_reg[39:1]}; // sum exp(x)
    end

    // exponent: 14-bit integer + 20-bit fraction
    // exponent sum: 20-bit integer + 20-bit fraction
    // the floating point is already align, no need to shift for alignment
    // to store 6-bit fraction, shift the dividend << 6
    // dividend = {exp_shift_d9, 6'b0}
    // divisor  = {exp_sum_reg}
    // since dividend of divider is 24-bit 
    // so the dividend can only use 18-bit(14-bit integer + 4-bit fraction + 6'b0)
    // the divisor use (20-bit integer + 4-bit fraction), align to dividend
end

// 0: Layernorm, 1: Softmax
wire mode_sel = (top_state == NORMAL || top_state == NORMAL_T)? 1'b0: 1'b1;

div div0(
    .clk(clk),
    .dividend(dividend[0]),
    .divisor(divisor[0]),
    .mode_sel(mode_sel),
    .merchant(token_nor[0]),
    .remainder()
);
div div1(
    .clk(clk),
    .dividend(dividend[1]),
    .divisor(divisor[1]),
    .mode_sel(mode_sel),
    .merchant(token_nor[1]),
    .remainder()
);
div div2(
    .clk(clk),
    .dividend(dividend[2]),
    .divisor(divisor[2]),
    .mode_sel(mode_sel),
    .merchant(token_nor[2]),
    .remainder()
);
div div3(
    .clk(clk),
    .dividend(dividend[3]),
    .divisor(divisor[3]),
    .mode_sel(mode_sel),
    .merchant(token_nor[3]),
    .remainder()
);
div div4(
    .clk(clk),
    .dividend(dividend[4]),
    .divisor(divisor[4]),
    .mode_sel(mode_sel),
    .merchant(token_nor[4]),
    .remainder()
);
div div5(
    .clk(clk),
    .dividend(dividend[5]),
    .divisor(divisor[5]),
    .mode_sel(mode_sel),
    .merchant(token_nor[5]),
    .remainder()
);
div div6(
    .clk(clk),
    .dividend(dividend[6]),
    .divisor(divisor[6]),
    .mode_sel(mode_sel),
    .merchant(token_nor[6]),
    .remainder()
);
div div7(
    .clk(clk),
    .dividend(dividend[7]),
    .divisor(divisor[7]),
    .mode_sel(mode_sel),
    .merchant(token_nor[7]),
    .remainder()
);

always @(posedge clk) begin
    for (k=0; k<8; k=k+1) begin
        token_nor_reg[k] <= token_nor[k];
    end
end
// consider the sign of numerator and denominator, if both positive(0), then 
// the result preserve, else, take 2's complement
always @(*) begin
    for (k=0; k<8; k=k+1) begin
        if (!sel_toggle_d7) begin
            token_nor_t[k] = (!a_bank_minus_sign_d7[k] && !token_mae_sign_d7)? token_nor_reg[k]: ~token_nor_reg[k]+1'b1;
        end else begin
            token_nor_t[k] = (!a_bank_minus_sign_d7[k+8] && !token_mae_sign_d7)? token_nor_reg[k]: ~token_nor_reg[k]+1'b1;
        end
    end
end

// ----- multiply with parameter and add bias ----- //
// result = weight * x_nor + bias
// x_normalize (1-sign + 3-bit integer + 6-bit fraction)
// weight and bias (1-bit sign + 2-bit integer + 7-bit fraction)
// weight * x_nor (1-bit sign + 6-bit integer + 13-bit fraction)
// then add with bias (1-bit sign + 2-bit integer + 7-bit fraction)
// then quantize the result to (1-bit sign + 3-bit integer + 6-bit fraction)


// There are weight-sram and bias-sram
// 1. weight-sram
// each addr store 16 weight(ch0(MSB) -> ch15(LSB)), 160-bit/addr
// 2. bias-sram
// each addr store 1 bias, 10-bit/addr

reg signed[(BW_PER_PARAM-1):0] weight_reg [0:15];
always @(*) begin
    weight_reg[0]  = sram_rdata_weight[159:150];// ch0 weight
    weight_reg[1]  = sram_rdata_weight[149:140];// ch1 weight
    weight_reg[2]  = sram_rdata_weight[139:130];
    weight_reg[3]  = sram_rdata_weight[129:120];
    weight_reg[4]  = sram_rdata_weight[119:110];
    weight_reg[5]  = sram_rdata_weight[109:100];
    weight_reg[6]  = sram_rdata_weight[99 :90 ];
    weight_reg[7]  = sram_rdata_weight[89 :80 ];
    weight_reg[8]  = sram_rdata_weight[79 :70 ];
    weight_reg[9]  = sram_rdata_weight[69 :60 ];
    weight_reg[10] = sram_rdata_weight[59 :50 ];
    weight_reg[11] = sram_rdata_weight[49 :40 ];
    weight_reg[12] = sram_rdata_weight[39 :30 ];
    weight_reg[13] = sram_rdata_weight[29 :20 ];
    weight_reg[14] = sram_rdata_weight[19 :10 ];
    weight_reg[15] = sram_rdata_weight[9  :0  ];// ch15 weight
end

// x_normalize (1-sign + 3-bit integer + 6-bit fraction)
// weight and bias (1-bit sign + 2-bit integer + 7-bit fraction)
// weight * x_nor (1-bit sign + 6-bit integer + 13-bit fraction)

// 8 multiplier 
reg signed [19:0] token_x_nor_weight [0:7];
always @(*) begin
    for (k=0; k<8; k=k+1) begin
        if (!sel_toggle_d7) begin
            token_x_nor_weight[k] = token_nor_t[k] * weight_reg[k];
        end else begin
            token_x_nor_weight[k] = token_nor_t[k] * weight_reg[k+8];
        end
    end
end

// weight * x_nor (1-bit sign + 6-bit integer + 13-bit fraction)
// then add with bias (1-bit sign + 2-bit integer + 7-bit fraction)
// the result(accumalated output) is (1-bit sign + 6-bit integer + 13-bit fraction)
reg signed[19:0] token_x_nor_result[0:7];
always @(posedge clk) begin
    for (k=0; k<8; k=k+1) begin
        if (!sel_toggle_d7) begin
             token_x_nor_result[k] <= token_x_nor_weight[k] + {{4{bias_reg[k][BW_PER_ACT-1]}}, bias_reg[k], 6'b0};
        end else begin
            token_x_nor_result[k] <= token_x_nor_weight[k] + {{4{bias_reg[k+8][BW_PER_ACT-1]}}, bias_reg[k+8], 6'b0};
        end
    end
    valid_3 <= valid_2_d7;
end

// ===== 3. Quantize the result to 10-bit and write the result to SRAM B ===== //
// since the accumalated output have 13-bit fraction(12-0), but we only want 
// 6-bit fraction, thus we need to find rounding output. That is, if the 
// (6-0) fraction bit is > 100_0000 than + 1 to (12-7) fraction
// to implement this, we add 100_0000 to accumulated output, so if the last 7 bit 
// of original accumulated output > 100_0000 it will add 1 to (12-7) fraction

reg signed [19:0] token_rounding_output[0:7];
always @(*) begin
    for (k=0; k<8; k=k+1) begin
        token_rounding_output[k] = token_x_nor_result[k] + 7'b100_0000;
    end
end
reg signed [12:0] token_quan[0:7];
// quantize output (13-bit)
always @(*) begin
    for (k=0; k<8; k=k+1) begin
        token_quan[k] = token_rounding_output[k][19:7];
    end
end

// quantize to 10-bit
// if quantized output > 511 (10-bit sign number max), then quantized output = 511
// if quantized output < -512(10-bit sign number min), then quantized output = -512
reg [9:0] token_quan_10[0:7];

always @(*) begin
    for (k=0; k<8; k=k+1) begin
        if (token_quan[k] > 13'sd511) begin
            token_quan_10[k] = 10'sd511;
        end else if (token_quan[k] < -13'sd512) begin
            token_quan_10[k] = -10'sd512;
        end else begin
            token_quan_10[k] = token_quan[k][9:0];
        end
    end
end

// concanacated the data to write into sram B
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] b_bank_w;
always @(*) begin
    b_bank_w = {token_quan_10[0], token_quan_10[1], token_quan_10[2], token_quan_10[3], 
                token_quan_10[4], token_quan_10[5], token_quan_10[6], token_quan_10[7]};
end

always @(*) begin
    case (top_state)
        NORMAL, NORMAL_T: begin
            sram_wdata_b0 = b_bank_w;
            sram_wdata_b1 = b_bank_w;
            sram_wdata_b2 = b_bank_w;
            sram_wdata_b3 = b_bank_w;
        end
        SOFTMAX, SOFTMAX_T: begin
            sram_wdata_b0 = softmax_wdata;
            sram_wdata_b1 = softmax_wdata;
            sram_wdata_b2 = softmax_wdata;
            sram_wdata_b3 = softmax_wdata;
        end
        O_PROJ, O_PROJ_T: begin
            sram_wdata_b0 = b_bank0_w;
            sram_wdata_b1 = b_bank1_w;
            sram_wdata_b2 = b_bank2_w;
            sram_wdata_b3 = b_bank3_w;
        end
        default: begin
            sram_wdata_b0 = 0;
            sram_wdata_b1 = 0;
            sram_wdata_b2 = 0;
            sram_wdata_b3 = 0;
        end 
    endcase
end

// write the result into sram B
// SRAM B: 64@16ch
// addr 0~15: 0~7ch, addr 16~31: 8~15ch

//               token0: {addr0_bank0, addr16_bank0}, 
//               token1: {addr0_bank1, addr16_bank1}, 
//               token2: {addr0_bank2, addr16_bank2}, 
//               token3: {addr0_bank3, addr16_bank3}
//
//               token4: {addr1_bank0, addr17_bank0}, 
//               token5: {addr1_bank1, addr17_bank1}, 
//               token6: {addr1_bank2, addr17_bank2}, 
//               token7: {addr1_bank3, addr17_bank3}
//
//               token8:  {addr2_bank0, addr18_bank0}, 
//               token9:  {addr2_bank1, addr18_bank1}, 
//               token10: {addr2_bank2, addr18_bank2}, 
//               token11: {addr2_bank3, addr18_bank3}
// ...
//               token60:  {addr15_bank0, addr31_bank0}, 
//               token61:  {addr15_bank1, addr31_bank1}, 
//               token62:  {addr15_bank2, addr31_bank2}, 
//               token63:  {addr15_bank3, addr31_bank3}

// SRAM B access:
// The token_quan_10 output sequance
// token0 ch0-7   -> addr0  write: bank0, mask: bank1,2,3
// token0 ch8-15  -> addr16 write: bank0, mask: bank1,2,3
// token1 ch0-7   -> addr0  write: bank1, mask: bank0,2,3
// token1 ch8-15  -> addr16 write: bank1, mask: bank0,2,3
// token2 ch0-7   -> addr0  write: bank2, mask: bank0,1,3
// token2 ch8-15  -> addr16 write: bank2, mask: bank0,1,3
// token3 ch0-7   -> addr0  write: bank3, mask: bank0,1,2
// token4 ch8-15  -> addr16 write: bank3, mask: bank0,1,2

// token5 ch0-7   -> addr1  write: bank0, mask: bank1,2,3
// token5 ch8-15  -> addr17 write: bank0, mask: bank1,2,3
// token6 ch0-7   -> addr1  write: bank1, mask: bank0,2,3
// token6 ch8-15  -> addr17 write: bank1, mask: bank0,2,3
// token7 ch0-7   -> addr1  write: bank2, mask: bank0,1,3
// token7 ch8-15  -> addr17 write: bank2, mask: bank0,1,3
// token8 ch0-7   -> addr1  write: bank3, mask: bank0,1,2
// token8 ch8-15  -> addr17 write: bank3, mask: bank0,1,2
// ...
// token62 ch0-7  -> addr15 write: bank2, mask: bank0,1,3
// token62 ch8-15 -> addr31 write: bank2, mask: bank0,1,3
// token63 ch0-7  -> addr15 write: bank3, mask: bank0,1,2
// token63 ch8-15 -> addr31 write: bank3, mask: bank0,1,2

// addr0 -> addr(0+16) -> addr1 -> addr(1+16) -> ... -> addr15 -> addr(15+16)
// 00000 -> 10000 -> 00001 -> 10001 -> ... -> 01111 -> 11111
// toggle the MSB addr, and increment the LSB addr

reg [3:0]b_base_addr_cnt_b; // lowest 4-bit counter
wire b_msb_addr;
wire [4:0] b_addr_norm;
assign b_msb_addr = ~sel_toggle_d7;
always @(posedge clk) begin
    if (!srst_n) begin
        b_base_addr_cnt_b <= 0;
    end else if (!valid_3 && (top_state == NORMAL && sram_addr_cnt_a > 5'd3|| (top_state == NORMAL_T))) begin
        b_base_addr_cnt_b <= b_base_addr_cnt_b + 1;
    end else if (top_state == NORMAL | top_state == NORMAL_T) begin
        b_base_addr_cnt_b <= b_base_addr_cnt_b;
    end else begin
        b_base_addr_cnt_b <= 0;
    end
end
assign b_addr_norm = {b_msb_addr, b_base_addr_cnt_b};
always @(*) begin
    case (top_state)
        NORMAL, NORMAL_T: begin
            sram_addr_b0 = b_addr_norm;
            sram_addr_b1 = b_addr_norm;
            sram_addr_b2 = b_addr_norm;
            sram_addr_b3 = b_addr_norm;
        end
        PROJ: begin
            sram_addr_b0 = {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};
            sram_addr_b1 = {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};
            sram_addr_b2 = {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};
            sram_addr_b3 = {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};
        end
        SOFTMAX, SOFTMAX_T: begin
            sram_addr_b0 = sramb_waddr_softmax;
            sram_addr_b1 = sramb_waddr_softmax;
            sram_addr_b2 = sramb_waddr_softmax;
            sram_addr_b3 = sramb_waddr_softmax;
        end
        V_PROJ: begin
            sram_addr_b0 = sramb_addr_vproj;
            sram_addr_b1 = sramb_addr_vproj;
            sram_addr_b2 = sramb_addr_vproj;
            sram_addr_b3 = sramb_addr_vproj;
        end
        O_PROJ, O_PROJ_T: begin
            sram_addr_b0 = sramb_addr_res;
            sram_addr_b1 = sramb_addr_res;
            sram_addr_b2 = sramb_addr_res;
            sram_addr_b3 = sramb_addr_res;
        end
        default: begin
            sram_addr_b0 = 0;
            sram_addr_b1 = 0;
            sram_addr_b2 = 0;
            sram_addr_b3 = 0;
        end
            
    endcase
end
// SRAM B can be write if valid_3, low active write

always @(posedge clk) begin
    if (valid_3) begin
        sram_b_wen_cnt <= sram_b_wen_cnt + 1;
    end else begin
        sram_b_wen_cnt <= 0;
    end
end
always @(*) begin
    case (top_state)
        NORMAL, NORMAL_T: begin
            sram_wen_b0 = !(valid_3 && sram_b_wen_cnt[2:1]==2'b00);
            sram_wen_b1 = !(valid_3 && sram_b_wen_cnt[2:1]==2'b01);
            sram_wen_b2 = !(valid_3 && sram_b_wen_cnt[2:1]==2'b10);
            sram_wen_b3 = !(valid_3 && sram_b_wen_cnt[2:1]==2'b11);
            sram_wordmask_b0 = 8'b0;
            sram_wordmask_b1 = 8'b0;
            sram_wordmask_b2 = 8'b0;
            sram_wordmask_b3 = 8'b0;
        end
        SOFTMAX, SOFTMAX_T: begin
            sram_wen_b0 = !(valid_12_d6 && sramb_wcnt == 2'b00);
            sram_wen_b1 = !(valid_12_d6 && sramb_wcnt == 2'b01);
            sram_wen_b2 = !(valid_12_d6 && sramb_wcnt == 2'b10);
            sram_wen_b3 = !(valid_12_d6 && sramb_wcnt == 2'b11);
            sram_wordmask_b0 = 8'b0;
            sram_wordmask_b1 = 8'b0;
            sram_wordmask_b2 = 8'b0;
            sram_wordmask_b3 = 8'b0;
        end
        O_PROJ, O_PROJ_T: begin
            sram_wen_b0 = sramb_wen_res;
            sram_wen_b1 = sramb_wen_res;
            sram_wen_b2 = sramb_wen_res;
            sram_wen_b3 = sramb_wen_res;
            sram_wordmask_b0 = sramb_wordmask_res;
            sram_wordmask_b1 = sramb_wordmask_res;
            sram_wordmask_b2 = sramb_wordmask_res;
            sram_wordmask_b3 = sramb_wordmask_res;
        end
        default: begin
            // read only
            sram_wen_b0 = 1'b1;
            sram_wen_b1 = 1'b1;
            sram_wen_b2 = 1'b1;
            sram_wen_b3 = 1'b1;
            sram_wordmask_b0 = mask_all;
            sram_wordmask_b1 = mask_all;
            sram_wordmask_b2 = mask_all;
            sram_wordmask_b3 = mask_all;
        end
    endcase
end




// assign sram_addr_b0 = {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};
// assign sram_addr_b1 = {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};
// assign sram_addr_b2 = {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};
// assign sram_addr_b3 = {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};



// ===== 4. Read normalized data from SRAM B. ===== //
reg signed[(BW_PER_ACT-1):0] b_bank0_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] b_bank1_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] b_bank2_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] b_bank3_dat[0:(CH_NUM-1)];

// SRAM B addr controller

always @(posedge clk) begin
    if (top_state == PROJ || top_state == O_PROJ) begin
        sram_addr_cnt_b <= sram_addr_cnt_b + 1;
    end else begin
        sram_addr_cnt_b <= 0;
    end
end

always @(*) begin
    // MSB-first ordering: [79:70], [69:60], ..., [9:0]
    b_bank0_dat[0] = sram_rdata_b0[79:70]; // ch0
    b_bank0_dat[1] = sram_rdata_b0[69:60]; // ch1
    b_bank0_dat[2] = sram_rdata_b0[59:50]; // ch2
    b_bank0_dat[3] = sram_rdata_b0[49:40]; // ch3
    b_bank0_dat[4] = sram_rdata_b0[39:30]; // ch4
    b_bank0_dat[5] = sram_rdata_b0[29:20]; // ch5
    b_bank0_dat[6] = sram_rdata_b0[19:10]; // ch6
    b_bank0_dat[7] = sram_rdata_b0[9:0];   // ch7

    b_bank1_dat[0] = sram_rdata_b1[79:70];
    b_bank1_dat[1] = sram_rdata_b1[69:60];
    b_bank1_dat[2] = sram_rdata_b1[59:50];
    b_bank1_dat[3] = sram_rdata_b1[49:40];
    b_bank1_dat[4] = sram_rdata_b1[39:30];
    b_bank1_dat[5] = sram_rdata_b1[29:20];
    b_bank1_dat[6] = sram_rdata_b1[19:10];
    b_bank1_dat[7] = sram_rdata_b1[9:0];

    b_bank2_dat[0] = sram_rdata_b2[79:70];
    b_bank2_dat[1] = sram_rdata_b2[69:60];
    b_bank2_dat[2] = sram_rdata_b2[59:50];
    b_bank2_dat[3] = sram_rdata_b2[49:40];
    b_bank2_dat[4] = sram_rdata_b2[39:30];
    b_bank2_dat[5] = sram_rdata_b2[29:20];
    b_bank2_dat[6] = sram_rdata_b2[19:10];
    b_bank2_dat[7] = sram_rdata_b2[9:0];

    b_bank3_dat[0] = sram_rdata_b3[79:70];
    b_bank3_dat[1] = sram_rdata_b3[69:60];
    b_bank3_dat[2] = sram_rdata_b3[59:50];
    b_bank3_dat[3] = sram_rdata_b3[49:40];
    b_bank3_dat[4] = sram_rdata_b3[39:30];
    b_bank3_dat[5] = sram_rdata_b3[29:20];
    b_bank3_dat[6] = sram_rdata_b3[19:10];
    b_bank3_dat[7] = sram_rdata_b3[9:0];
end

// ----- projection ----- //
// Q, K, V projection matrix are 16 by 16 matrix
// then allocate in the weight sram (16ch / addr)
// addr 1~16 : column vector of Q {q0, q1, ... q15}
// addr 17~32: column vector of K {k0, k1, ... k15}
// addr 33~48: column vector of V {v0, v1, ... v15}
// read out each column vector and hold 2 cycle,
// so we can multiply each token with weight
reg [7:0]weight_addr_cnt;
reg [7:0]weight_addr_cnt_n;
// the weight addr will increment 1 every 32 cycle,
// since we read a token / 2 cycle, and there is 4 bank
// so 4 token / 2 cycle, 4 token multiply to weight will
// generate 4 element every 2 cycle, and the projection 
// result have 64 element per column, needs 16*2=32 cycle
// to generate, then we can change the weight (increment 
// the weight address)

// since sram C can store only 1 head of each 3 projection 
// matrix Q, K, V, so the head size is 64 by 8. Thus, we 
// only calculate one head of projection matrix each process

// top_state: PROJ
// the weight addr = 
// Q Head 0: 1  -> 2  -> 3  -> 4  -> 5  -> 6  -> 7  -> 8
// K Head 0: 17 -> 18 -> 19 -> 20 -> 21 -> 22 -> 23 -> 24
// V Head 0: 33 -> 34 -> 35 -> 36 -> 37 -> 38 -> 39 -> 40
// top_state: PROJ_2
// the weight addr = 
// Q Head 0: 9  -> 10 -> 11 -> 12 -> 13 -> 14 -> 15 -> 16
// K Head 0: 25 -> 26 -> 27 -> 28 -> 29 -> 30 -> 31 -> 32
// V Head 0: 41 -> 42 -> 43 -> 44 -> 45 -> 46 -> 47 -> 48
// top_state: O_PROJ
// the weight addr = 
// O: 49 -> 50 -> ... -> 64

reg [4:0]col_cnt;
reg phase;

always @(posedge clk) begin
    if (!srst_n) begin
        head_sel <= 0;
    end else if (accum_done && vproj_wcnt==6'd63) begin
        head_sel <= 1;
    end
end
always @(posedge clk) begin
    if (!srst_n) begin
        weight_addr_cnt <= 1;
    end else if (phase && col_cnt==5'd31) begin
        weight_addr_cnt <= weight_addr_cnt_n;
    end
end
always @(*) begin
    if (top_state == PROJ && head_sel) begin
        case (weight_addr_cnt)
            8'd16:   weight_addr_cnt_n = 8'd25;
            8'd32:   weight_addr_cnt_n = 8'd41;
            8'd48:   weight_addr_cnt_n = 8'd49; // jump to o projection weight
            default: weight_addr_cnt_n = weight_addr_cnt + 1;
        endcase
    end else if (top_state == PROJ) begin
        case (weight_addr_cnt)
            8'd8:    weight_addr_cnt_n = 8'd17;
            8'd24:   weight_addr_cnt_n = 8'd33;
            8'd40:   weight_addr_cnt_n = 8'd9 ; // next head1 addr start from 9
            default: weight_addr_cnt_n = weight_addr_cnt + 1;
        endcase
    end else if (top_state == O_PROJ) begin
        weight_addr_cnt_n = weight_addr_cnt + 1;
    end else begin
        weight_addr_cnt_n = 1;
    end
end


always @(posedge clk) begin
    if (!srst_n) begin
        col_cnt <= 0;
    end else if (top_state == PROJ || top_state == O_PROJ) begin
        col_cnt <= col_cnt + 1;
    end else begin
        col_cnt <= 0;
    end
end
always @(posedge clk) begin
    if (!srst_n) begin
        phase <= 0;
    end else if (top_state == PROJ || top_state == O_PROJ) begin
        phase <= ~phase;
    end else begin
        phase <= 0;
    end
end
assign sram_raddr_weight = (top_state==PROJ || top_state == O_PROJ)? weight_addr_cnt:0;



// ===== 5. Implement head 0 of K projection, Q projection and V projection. ===== //

// ----- weight multiplication ----- //
// sram B data (1-bit sign + 3-bit integer + 6-bit fraction)
// weight      (1-bit sign + 2-bit integer + 7-bit fraction)
reg signed[9:0] weight_sel[0:7];
always @(*) begin
    for (i=0; i<8; i=i+1) begin
        weight_sel[i] = (phase)? weight_reg[i]: weight_reg[i+8];
    end
end

// multiply of data and weight
// (1-bit sign + 6-bit integer + 13-bit fraction)
reg signed[19:0] bank0_proj_mul_n[0:7];
reg signed[19:0] bank1_proj_mul_n[0:7];
reg signed[19:0] bank2_proj_mul_n[0:7];
reg signed[19:0] bank3_proj_mul_n[0:7];

// register
reg signed[19:0] bank0_proj_mul;
reg signed[19:0] bank1_proj_mul;
reg signed[19:0] bank2_proj_mul;
reg signed[19:0] bank3_proj_mul;

// 32 multiplier, this part may also use by Q * K^T 

// sram B data / Q matrix
reg signed [9:0] mul0_in1[0:7];
reg signed [9:0] mul1_in1[0:7];
reg signed [9:0] mul2_in1[0:7];
reg signed [9:0] mul3_in1[0:7];
// projection weight / K^T matrix
reg signed [9:0] mul0_in2[0:7];
reg signed [9:0] mul1_in2[0:7];
reg signed [9:0] mul2_in2[0:7];
reg signed [9:0] mul3_in2[0:7];

always @(*) begin
    for (i=0; i<8; i=i+1) begin
        case (top_state)
            PROJ, PROJ_T: begin
                // sram B data
                mul0_in1[i] = b_bank0_dat[i];
                mul1_in1[i] = b_bank1_dat[i];
                mul2_in1[i] = b_bank2_dat[i];
                mul3_in1[i] = b_bank3_dat[i];
                // projection weight
                mul0_in2[i] = weight_sel[i];
                mul1_in2[i] = weight_sel[i];
                mul2_in2[i] = weight_sel[i];
                mul3_in2[i] = weight_sel[i];
            end
            R_SRAM_C, R_SRAM_C_T: begin
                // Q matrix
                mul0_in1[i] = c_bank_dat_reg[i];
                mul1_in1[i] = c_bank_dat_reg[i];
                mul2_in1[i] = c_bank_dat_reg[i];
                mul3_in1[i] = c_bank_dat_reg[i];
                // K^T matrix
                mul0_in2[i] = c_bank0_dat[i];
                mul1_in2[i] = c_bank1_dat[i];
                mul2_in2[i] = c_bank2_dat[i];
                mul3_in2[i] = c_bank3_dat[i];
            end
            V_PROJ, V_PROJ_T: begin
                // softmax matrix 4ch
                mul0_in1[i] = sramb_dat_vproj[0];
                mul1_in1[i] = sramb_dat_vproj[1];
                mul2_in1[i] = sramb_dat_vproj[2];
                mul3_in1[i] = sramb_dat_vproj[3];
                // K^T matrix
                mul0_in2[i] = c_bank0_dat[i]; // token0 ch0-7
                mul1_in2[i] = c_bank1_dat[i]; // token1 ch0-7
                mul2_in2[i] = c_bank2_dat[i]; // token2 ch0-7
                mul3_in2[i] = c_bank3_dat[i]; // token3 ch0-7
            end
            O_PROJ, O_PROJ_T: begin
                // sram D data(softmax V)
                mul0_in1[i] = d_bank0_dat[i];
                mul1_in1[i] = d_bank1_dat[i];
                mul2_in1[i] = d_bank2_dat[i];
                mul3_in1[i] = d_bank3_dat[i];
                // O projection weight
                mul0_in2[i] = weight_sel[i];
                mul1_in2[i] = weight_sel[i];
                mul2_in2[i] = weight_sel[i];
                mul3_in2[i] = weight_sel[i];
            end
            default: begin
                mul0_in1[i] = 0;
                mul1_in1[i] = 0;
                mul2_in1[i] = 0;
                mul3_in1[i] = 0;

                mul0_in2[i] = 0;
                mul1_in2[i] = 0;
                mul2_in2[i] = 0;
                mul3_in2[i] = 0;
            end 
        endcase
    end
end
reg phase_d1;
reg phase_d2;
// sram B data / Q matrix
reg signed [9:0] mul0_in1_reg[0:7];
reg signed [9:0] mul1_in1_reg[0:7];
reg signed [9:0] mul2_in1_reg[0:7];
reg signed [9:0] mul3_in1_reg[0:7];
// projection weight / K^T matrix
reg signed [9:0] mul0_in2_reg[0:7];
reg signed [9:0] mul1_in2_reg[0:7];
reg signed [9:0] mul2_in2_reg[0:7];
reg signed [9:0] mul3_in2_reg[0:7];
always @(posedge clk) begin
    for (i=0; i<8;i=i+1) begin
        mul0_in1_reg[i] <= mul0_in1[i];
        mul1_in1_reg[i] <= mul1_in1[i];
        mul2_in1_reg[i] <= mul2_in1[i];
        mul3_in1_reg[i] <= mul3_in1[i];
        mul0_in2_reg[i] <= mul0_in2[i];
        mul1_in2_reg[i] <= mul1_in2[i];
        mul2_in2_reg[i] <= mul2_in2[i];
        mul3_in2_reg[i] <= mul3_in2[i];
    end
end
always @(posedge clk) begin
    for (i=0; i<8; i=i+1) begin
        bank0_proj_mul_n[i] <= mul0_in1_reg[i] * mul0_in2_reg[i];
        bank1_proj_mul_n[i] <= mul1_in1_reg[i] * mul1_in2_reg[i]; 
        bank2_proj_mul_n[i] <= mul2_in1_reg[i] * mul2_in2_reg[i];
        bank3_proj_mul_n[i] <= mul3_in1_reg[i] * mul3_in2_reg[i];
    end
    phase_d1 <= phase;
    phase_d2 <= phase_d1;
end
reg signed [19:0] bank0_proj_add_n ;
reg signed [19:0] bank1_proj_add_n ;
reg signed [19:0] bank2_proj_add_n ;
reg signed [19:0] bank3_proj_add_n ;
always @(*) begin
    bank0_proj_add_n = bank0_proj_mul_n[0] + bank0_proj_mul_n[1]
                     + bank0_proj_mul_n[2] + bank0_proj_mul_n[3]
                     + bank0_proj_mul_n[4] + bank0_proj_mul_n[5]
                     + bank0_proj_mul_n[6] + bank0_proj_mul_n[7];

    bank1_proj_add_n = bank1_proj_mul_n[0] + bank1_proj_mul_n[1]
                      + bank1_proj_mul_n[2] + bank1_proj_mul_n[3]
                      + bank1_proj_mul_n[4] + bank1_proj_mul_n[5]
                      + bank1_proj_mul_n[6] + bank1_proj_mul_n[7];

    bank2_proj_add_n = bank2_proj_mul_n[0] + bank2_proj_mul_n[1]
                     + bank2_proj_mul_n[2] + bank2_proj_mul_n[3]
                     + bank2_proj_mul_n[4] + bank2_proj_mul_n[5]
                     + bank2_proj_mul_n[6] + bank2_proj_mul_n[7];

    bank3_proj_add_n = bank3_proj_mul_n[0] + bank3_proj_mul_n[1]
                     + bank3_proj_mul_n[2] + bank3_proj_mul_n[3]
                     + bank3_proj_mul_n[4] + bank3_proj_mul_n[5]
                     + bank3_proj_mul_n[6] + bank3_proj_mul_n[7];
end
reg signed [19:0]bank0_proj_add ;
reg signed [19:0]bank1_proj_add ;
reg signed [19:0]bank2_proj_add ;
reg signed [19:0]bank3_proj_add ;
reg valid_4;
always @(posedge clk) begin
    if (phase_d2) begin
        bank0_proj_add <= bank0_proj_add_n;
        bank1_proj_add <= bank1_proj_add_n;
        bank2_proj_add <= bank2_proj_add_n;
        bank3_proj_add <= bank3_proj_add_n;
    end 
end
always @(posedge clk) begin
    if (!srst_n) begin
        valid_4 <= 0;
    end else begin
        valid_4 <= phase_d2;
    end
end

reg signed [19:0]bank0_proj_result ;
reg signed [19:0]bank1_proj_result ;
reg signed [19:0]bank2_proj_result ;
reg signed [19:0]bank3_proj_result ;
always @(*) begin
    bank0_proj_result = bank0_proj_add_n + bank0_proj_add;
    bank1_proj_result = bank1_proj_add_n + bank1_proj_add;
    bank2_proj_result = bank2_proj_add_n + bank2_proj_add;
    bank3_proj_result = bank3_proj_add_n + bank3_proj_add;
end
// ===== 6. Quantize the result to 10-bit and write the result to SRAM C. ===== //
reg signed [19:0]bank0_proj_reg ;
reg signed [19:0]bank1_proj_reg ;
reg signed [19:0]bank2_proj_reg ;
reg signed [19:0]bank3_proj_reg ;
reg valid_5;
always @(posedge clk) begin
    if (!srst_n) begin
        valid_5 <= 0;
    end else begin
        valid_5 <= valid_4;
    end
end
always @(posedge clk) begin
    bank0_proj_reg <= bank0_proj_result;
    bank1_proj_reg <= bank1_proj_result;
    bank2_proj_reg <= bank2_proj_result;
    bank3_proj_reg <= bank3_proj_result;
end


reg signed[19:0] token0_proj_rounding_output;
reg signed[19:0] token1_proj_rounding_output;
reg signed[19:0] token2_proj_rounding_output;
reg signed[19:0] token3_proj_rounding_output;
// rounding output
always @(*) begin
    token0_proj_rounding_output = bank0_proj_reg + 7'b100_0000;
    token1_proj_rounding_output = bank1_proj_reg + 7'b100_0000;
    token2_proj_rounding_output = bank2_proj_reg + 7'b100_0000;
    token3_proj_rounding_output = bank3_proj_reg + 7'b100_0000;
end

reg signed[12:0] token0_proj_quan;
reg signed[12:0] token1_proj_quan;
reg signed[12:0] token2_proj_quan;
reg signed[12:0] token3_proj_quan;
// quantized output (13-bit)
always @(*) begin
    token0_proj_quan = token0_proj_rounding_output[19:7];
    token1_proj_quan = token1_proj_rounding_output[19:7];
    token2_proj_quan = token2_proj_rounding_output[19:7];
    token3_proj_quan = token3_proj_rounding_output[19:7];
end

// quantize to 10-bit
// if quantized output > 511 (10-bit sign number max), then quantized output = 511
// if quantized output < -512(10-bit sign number min), then quantized output = -512
reg [9:0] token0_proj_quan_10;
reg [9:0] token1_proj_quan_10;
reg [9:0] token2_proj_quan_10;
reg [9:0] token3_proj_quan_10;

always @(*) begin
    if (token0_proj_quan > 13'sd511) begin
        token0_proj_quan_10 = 10'sd511;
    end else if (token0_proj_quan < -13'sd512) begin
        token0_proj_quan_10 = -10'sd512;
    end else begin
        token0_proj_quan_10 = token0_proj_quan[9:0];
    end

    if (token1_proj_quan > 13'sd511) begin
        token1_proj_quan_10 = 10'sd511;
    end else if (token1_proj_quan < -13'sd512) begin
        token1_proj_quan_10 = -10'sd512;
    end else begin
        token1_proj_quan_10 = token1_proj_quan[9:0];
    end

    if (token2_proj_quan > 13'sd511) begin
        token2_proj_quan_10 = 10'sd511;
    end else if (token2_proj_quan < -13'sd512) begin
        token2_proj_quan_10 = -10'sd512;
    end else begin
        token2_proj_quan_10 = token2_proj_quan[9:0];
    end

    if (token3_proj_quan > 13'sd511) begin
        token3_proj_quan_10 = 10'sd511;
    end else if (token3_proj_quan < -13'sd512) begin
        token3_proj_quan_10 = -10'sd512;
    end else begin
        token3_proj_quan_10 = token3_proj_quan[9:0];
    end
end

// ===== write result into sram C ===== //
// each 2 cycle we write 4 element into sram C
// remember use data mask to write different channel of sram C
// ----- Q projection start ----- //
// ----- first 32 cycle: mask pat = 0111_1111
// token 0,  1,  2,  3 ch0 -> addr0(sram C address)
// token 4,  5,  6,  7 ch0 -> addr1
// ...
// token60, 61, 62, 63 ch0 -> addr15
// ----- second 32 cycle: mask pat = 1011_1111
// token 0,  1,  2,  3 ch1 -> addr0
// token 4,  5,  6,  7 ch1 -> addr1
// ...
// token60, 61, 62, 63 ch1 -> addr15
// ...
// ----- 8th 32 cycle: mask pat = 1111_1110
// token 0,  1,  2,  3 ch15 -> addr0
// token 4,  5,  6,  7 ch15 -> addr1
// ...
// token60, 61, 62, 63 ch15 -> addr15
// ----- Q projection finish ----- //

// ----- K projection start ----- //
// ----- first 32 cycle
// token 0,  1,  2,  3 ch0 -> addr16
// token 4,  5,  6,  7 ch0 -> addr17
// ...
// token60, 61, 62, 63 ch0 -> addr31
// ----- second 32 cycle
// token 0,  1,  2,  3 ch1 -> addr16
// token 4,  5,  6,  7 ch1 -> addr17
// ...
// token60, 61, 62, 63 ch1 -> addr31
// ...
// ----- 8th 32 cycle
// token 0,  1,  2,  3 ch15 -> addr16
// token 4,  5,  6,  7 ch15 -> addr17
// ...
// token60, 61, 62, 63 ch15 -> addr31
// ----- K projection finish ----- //

// ----- V projection start ----- //
// ----- first 32 cycle
// token 0,  1,  2,  3 ch0 -> addr32
// token 4,  5,  6,  7 ch0 -> addr33
// ...
// token60, 61, 62, 63 ch0 -> addr47
// ----- second 32 cycle
// token 0,  1,  2,  3 ch1 -> addr32
// token 4,  5,  6,  7 ch1 -> addr33
// ...
// token60, 61, 62, 63 ch1 -> addr47
// ...
// ----- 8th 32 cycle
// token 0,  1,  2,  3 ch15 -> addr32
// token 4,  5,  6,  7 ch15 -> addr33
// ...
// token60, 61, 62, 63 ch15 -> addr47
// ----- V projection finish ----- //
// totally need 256 * 3 cycle to finish the linear projection layer
// do 2 times, so need 256 * 6 = 1536 cycle
assign sram_wen_c0 = !valid_5;
assign sram_wen_c1 = !valid_5;
assign sram_wen_c2 = !valid_5;
assign sram_wen_c3 = !valid_5;

localparam mask_proj_pat0 = 8'b0111_1111;
localparam mask_proj_pat1 = 8'b1011_1111;
localparam mask_proj_pat2 = 8'b1101_1111;
localparam mask_proj_pat3 = 8'b1110_1111;
localparam mask_proj_pat4 = 8'b1111_0111;
localparam mask_proj_pat5 = 8'b1111_1011;
localparam mask_proj_pat6 = 8'b1111_1101;
localparam mask_proj_pat7 = 8'b1111_1110;
wire proj_stage_done;
wire proj_finish;


reg [3:0] sram_c_block_cnt; // token group 0(0,1,2,3)~15(60,61,62,63)
reg [2:0] sram_c_ch_cnt;    // channel 0~7
reg [1:0] sram_c_proj_cnt;  // 0:Q, 1:K, 2:V

wire [5:0] sram_c_proj_base =
    (sram_c_proj_cnt == 2'd0) ? 6'd0  :
    (sram_c_proj_cnt == 2'd1) ? 6'd16 :
                                6'd32;

always @(posedge clk) begin
    if (!srst_n) begin
        sram_c_block_cnt <= 0;
        sram_c_ch_cnt    <= 0;
        sram_c_proj_cnt  <= 0;
    end else if (valid_5) begin
        sram_c_block_cnt <= (sram_c_block_cnt == 4'd15)? 0 : sram_c_block_cnt + 1;
        sram_c_ch_cnt    <= (sram_c_block_cnt == 4'd15)? sram_c_ch_cnt + 1: sram_c_ch_cnt;
        sram_c_proj_cnt  <= (sram_c_ch_cnt == 3'd7 && sram_c_block_cnt == 4'd15)? sram_c_proj_cnt + 1: sram_c_proj_cnt;
    end else if (top_state != PROJ && top_state != PROJ_T && top_state != O_PROJ && top_state != O_PROJ_T) begin
        sram_c_block_cnt <= 0;
        sram_c_ch_cnt    <= 0;
        sram_c_proj_cnt  <= 0;
    end
end

assign sram_addr_cnt_c = sram_c_proj_base + sram_c_block_cnt;

always @(*) begin
    case (top_state)
        PROJ, PROJ_T, O_PROJ, O_PROJ_T: begin
            sram_addr_c0 = sram_addr_cnt_c;
            sram_addr_c1 = sram_addr_cnt_c;
            sram_addr_c2 = sram_addr_cnt_c;
            sram_addr_c3 = sram_addr_cnt_c;
        end
        R_SRAM_C, R_SRAM_C_T: begin
            sram_addr_c0 = sramc_addr;
            sram_addr_c1 = sramc_addr;
            sram_addr_c2 = sramc_addr;
            sram_addr_c3 = sramc_addr;
        end
        V_PROJ: begin
            sram_addr_c0 = sramc_addr_vproj;
            sram_addr_c1 = sramc_addr_vproj;
            sram_addr_c2 = sramc_addr_vproj;
            sram_addr_c3 = sramc_addr_vproj;
        end
        default: begin
            sram_addr_c0 = 0;
            sram_addr_c1 = 0;
            sram_addr_c2 = 0;
            sram_addr_c3 = 0;
        end
            
    endcase
end

reg [7:0]wordmask_c;
always @(*) begin
    case (sram_c_ch_cnt)
        0: wordmask_c = mask_proj_pat0;
        1: wordmask_c = mask_proj_pat1;
        2: wordmask_c = mask_proj_pat2;
        3: wordmask_c = mask_proj_pat3;
        4: wordmask_c = mask_proj_pat4;
        5: wordmask_c = mask_proj_pat5;
        6: wordmask_c = mask_proj_pat6;
        7: wordmask_c = mask_proj_pat7;
    endcase
end
assign sram_wordmask_c0 = wordmask_c;
assign sram_wordmask_c1 = wordmask_c;
assign sram_wordmask_c2 = wordmask_c;
assign sram_wordmask_c3 = wordmask_c;

reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] c_bank0_w;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] c_bank1_w;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] c_bank2_w;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] c_bank3_w;
always @(*) begin
    // the token_proj_quan10 will locate at different location
    case (sram_c_ch_cnt)
        0: begin
            c_bank0_w = {token0_proj_quan_10, 70'b0};
            c_bank1_w = {token1_proj_quan_10, 70'b0};
            c_bank2_w = {token2_proj_quan_10, 70'b0};
            c_bank3_w = {token3_proj_quan_10, 70'b0};
        end
        1: begin
            c_bank0_w = {10'b0, token0_proj_quan_10, 60'b0};
            c_bank1_w = {10'b0, token1_proj_quan_10, 60'b0};
            c_bank2_w = {10'b0, token2_proj_quan_10, 60'b0};
            c_bank3_w = {10'b0, token3_proj_quan_10, 60'b0};
        end
        2: begin
            c_bank0_w = {20'b0, token0_proj_quan_10, 50'b0};
            c_bank1_w = {20'b0, token1_proj_quan_10, 50'b0};
            c_bank2_w = {20'b0, token2_proj_quan_10, 50'b0};
            c_bank3_w = {20'b0, token3_proj_quan_10, 50'b0};
        end
        3: begin
            c_bank0_w = {30'b0, token0_proj_quan_10, 40'b0};
            c_bank1_w = {30'b0, token1_proj_quan_10, 40'b0};
            c_bank2_w = {30'b0, token2_proj_quan_10, 40'b0};
            c_bank3_w = {30'b0, token3_proj_quan_10, 40'b0};
        end
        4: begin
            c_bank0_w = {40'b0, token0_proj_quan_10, 30'b0};
            c_bank1_w = {40'b0, token1_proj_quan_10, 30'b0};
            c_bank2_w = {40'b0, token2_proj_quan_10, 30'b0};
            c_bank3_w = {40'b0, token3_proj_quan_10, 30'b0};
        end
        5: begin
            c_bank0_w = {50'b0, token0_proj_quan_10, 20'b0};
            c_bank1_w = {50'b0, token1_proj_quan_10, 20'b0};
            c_bank2_w = {50'b0, token2_proj_quan_10, 20'b0};
            c_bank3_w = {50'b0, token3_proj_quan_10, 20'b0};
        end
        6: begin
            c_bank0_w = {60'b0, token0_proj_quan_10, 10'b0};
            c_bank1_w = {60'b0, token1_proj_quan_10, 10'b0};
            c_bank2_w = {60'b0, token2_proj_quan_10, 10'b0};
            c_bank3_w = {60'b0, token3_proj_quan_10, 10'b0};
        end
        7: begin
            c_bank0_w = {70'b0, token0_proj_quan_10};
            c_bank1_w = {70'b0, token1_proj_quan_10};
            c_bank2_w = {70'b0, token2_proj_quan_10};
            c_bank3_w = {70'b0, token3_proj_quan_10};
        end
        default: begin
            c_bank0_w = 80'b0;
            c_bank1_w = 80'b0;
            c_bank2_w = 80'b0;
            c_bank3_w = 80'b0;
        end
    endcase
end
assign sram_wdata_c0 = c_bank0_w;
assign sram_wdata_c1 = c_bank1_w;
assign sram_wdata_c2 = c_bank2_w;
assign sram_wdata_c3 = c_bank3_w;

// ===== 7. Read K projection and Q projection from SRAM C. ===== //
// In this part, we read the Head0 of Q and K ot to do matrix multiplicaiton
// Q_0 and K_0 is 64 by 8 matrix, to do Q_0 x K_0^T
// first we read each token(8 ch) of Q_0 and K_0, then multiply them,
// then we mulitiply the result by 1 / √chead.
// (000_0101101: 1-bit sign + 2-bit integer + 7-bit fraction) 

// SRAM C: 64@8ch x 3
// Q addr 0~15: 0~7ch, K addr 16~31: 0~7ch, V addr 32~47: 0~7ch
//               token0: {addr0_bank0}, 
//               token1: {addr0_bank1}, 
//               token2: {addr0_bank2}, 
//               token3: {addr0_bank3}
//
//               token4: {addr1_bank0}, 
//               token5: {addr1_bank1}, 
//               token6: {addr1_bank2}, 
//               token7: {addr1_bank3}
//
//               token8:  {addr2_bank0}, 
//               token9:  {addr2_bank1}, 
//               token10: {addr2_bank2}, 
//               token11: {addr2_bank3}
// ...
//               token60:  {addr15_bank0}, 
//               token61:  {addr15_bank1}, 
//               token62:  {addr15_bank2}, 
//               token63:  {addr15_bank3}

// each cycle we may read 4 token(32 ch) per matrix
// so we need 32 multiplier to finish the calculation in 1 cyle
// or we use less resource and increase ii to solve this problem

// if use 32 multiplier, totally need 64 token /4 token = 16 cycle
// if we use 8 multiplier, totally need 64 token/1 token = 64 cycle


// in this version, use 32 multiplier, since we can directly 
// use the 32 multiplier used in linear projection(to do later, now we use another 32 mul)

// since Q(addr 0-15), K(addr 16-31), V(addr 32-47) store in sram C
// the sram C reading sequence is(fist chunk):

// first 64 cycle
// Q token0 * K token 0~63
// addr0 -> addr16 -> addr17 -> addr18 -> ... -> addr31
// Q token1 * K token 0~63
// addr0 -> addr16 -> addr17 -> addr18 -> ... -> addr31
// Q token2 * K token 0~63
// addr0 -> addr16 -> addr17 -> addr18 -> ... -> addr31
// Q token3 * K token 0~63
// addr0 -> addr16 -> addr17 -> addr18 -> ... -> addr31

// second 64 cycle
// Q token4 * K token 0~63
// addr1 -> addr16 -> addr17 -> addr18 -> ... -> addr31
// Q token5 * K token 0~63
// addr1 -> addr16 -> addr17 -> addr18 -> ... -> addr31
// Q token6 * K token 0~63
// addr1 -> addr16 -> addr17 -> addr18 -> ... -> addr31
// Q token7 * K token 0~63
// addr1 -> addr16 -> addr17 -> addr18 -> ... -> addr31

// third 64 cycle
// Q token8  * K token 0~63
// addr2 -> addr16 -> addr17 -> addr18 -> ... -> addr31
// Q token9  * K token 0~63
// addr2 -> addr16 -> addr17 -> addr18 -> ... -> addr31
// Q token10 * K token 0~63
// addr2 -> addr16 -> addr17 -> addr18 -> ... -> addr31
// Q token11 * K token 0~63
// addr2 -> addr16 -> addr17 -> addr18 -> ... -> addr31

// fourth 64 cycle
// Q token12 * K token 0~63
// addr3 -> addr16 -> addr17 -> addr18 -> ... -> addr31
// Q token13 * K token 0~63
// addr3 -> addr16 -> addr17 -> addr18 -> ... -> addr31
// Q token14 * K token 0~63
// addr3 -> addr16 -> addr17 -> addr18 -> ... -> addr31
// Q token15 * K token 0~63
// addr3 -> addr16 -> addr17 -> addr18 -> ... -> addr31

// Totally 256 cycle finish 1 chunk, we have 4 chunk to finish
// first chunk (addr0 , 1 , 2 , 3)
// second chunk(addr4 , 5 , 6 , 7)
// third chunk (addr8 , 9 , 10, 11)
// fourth chunk(addr12, 13, 14, 15)
reg [4:0] sramc_addr_cnt;

// Q token sram access
// addr 0 ->1 ->...->15
reg [3:0] sramc_q_addr_cnt;
wire [4:0] sramc_q_addr;
reg [1:0] token_cnt;
always @(posedge clk) begin
    if (!srst_n) begin
        sramc_q_addr_cnt <= 0;
    end else if (top_state == R_SRAM_C) begin
        sramc_q_addr_cnt <= (sramc_addr == 6'b01_1111 && token_cnt == 2'b11)? sramc_q_addr_cnt + 1: sramc_q_addr_cnt;
    end 
end
assign sramc_q_addr = {1'b0, sramc_q_addr_cnt};

// count how many token Q consume, we need to consume 4 token then we can increment the addr of Q.
always @(posedge clk) begin
    if (top_state == R_SRAM_C) begin
        token_cnt <= (sramc_addr == 6'b01_1111)? token_cnt + 1: token_cnt;
    end else begin
        token_cnt <= 0;
    end
end
// K token sram access: 
// 0_0000 -> 0_0001 -> 0_0010 -> ... -> 0_1111
// addr 16->17->...->31
// 1_0000 -> 1_0001 -> 1_0010 -> ... -> 1_1111

always @(posedge clk) begin
    if (!srst_n) begin
        access_k <= 0;
    end else if (top_state == R_SRAM_C && sramc_addr[4] == 0) begin
        access_k <= 1;
    end else if (sramc_addr[4:0] == 5'b1_1111) begin
        access_k <= 0;
    end else if (top_state == R_SRAM_C) begin
        access_k <= access_k;
    end else begin
        access_k <= 0;
    end
end
always @(posedge clk) begin
    if (top_state == R_SRAM_C) begin
        sramc_k_addr_cnt <= ((access_k && sramc_k_addr_cnt!=0) | sramc_addr[4]==1'b0)? sramc_k_addr_cnt + 1: sramc_k_addr_cnt;
    end else begin
        sramc_k_addr_cnt <= 0;
    end
    sramc_k_addr_cnt_d <= sramc_k_addr_cnt;
end
assign sramc_k_addr = {1'b1, sramc_k_addr_cnt_d};

assign sramc_addr = (access_k)? sramc_k_addr: sramc_q_addr;

always @(*) begin
    // MSB-first ordering: [79:70], [69:60], ..., [9:0]
    c_bank0_dat[0] = sram_rdata_c0[79:70]; // ch0
    c_bank0_dat[1] = sram_rdata_c0[69:60]; // ch1
    c_bank0_dat[2] = sram_rdata_c0[59:50]; // ch2
    c_bank0_dat[3] = sram_rdata_c0[49:40]; // ch3
    c_bank0_dat[4] = sram_rdata_c0[39:30]; // ch4
    c_bank0_dat[5] = sram_rdata_c0[29:20]; // ch5
    c_bank0_dat[6] = sram_rdata_c0[19:10]; // ch6
    c_bank0_dat[7] = sram_rdata_c0[9:0];   // ch7

    c_bank1_dat[0] = sram_rdata_c1[79:70];
    c_bank1_dat[1] = sram_rdata_c1[69:60];
    c_bank1_dat[2] = sram_rdata_c1[59:50];
    c_bank1_dat[3] = sram_rdata_c1[49:40];
    c_bank1_dat[4] = sram_rdata_c1[39:30];
    c_bank1_dat[5] = sram_rdata_c1[29:20];
    c_bank1_dat[6] = sram_rdata_c1[19:10];
    c_bank1_dat[7] = sram_rdata_c1[9:0];

    c_bank2_dat[0] = sram_rdata_c2[79:70];
    c_bank2_dat[1] = sram_rdata_c2[69:60];
    c_bank2_dat[2] = sram_rdata_c2[59:50];
    c_bank2_dat[3] = sram_rdata_c2[49:40];
    c_bank2_dat[4] = sram_rdata_c2[39:30];
    c_bank2_dat[5] = sram_rdata_c2[29:20];
    c_bank2_dat[6] = sram_rdata_c2[19:10];
    c_bank2_dat[7] = sram_rdata_c2[9:0];

    c_bank3_dat[0] = sram_rdata_c3[79:70];
    c_bank3_dat[1] = sram_rdata_c3[69:60];
    c_bank3_dat[2] = sram_rdata_c3[59:50];
    c_bank3_dat[3] = sram_rdata_c3[49:40];
    c_bank3_dat[4] = sram_rdata_c3[39:30];
    c_bank3_dat[5] = sram_rdata_c3[29:20];
    c_bank3_dat[6] = sram_rdata_c3[19:10];
    c_bank3_dat[7] = sram_rdata_c3[9:0];
end

// ===== 8. Implement multiplication of attention head 0 first 16 rows results. ===== //

always @(posedge clk) begin
    sramc_addr_d <= sramc_addr[4];
end
always @(posedge clk) begin // onlt store 1 token of matrix Q
    if (sramc_addr_d==1'b0) begin // addr 0_xxxx -> matrix Q
        case (token_cnt)
            2'b00: begin
                for (k=0; k<8; k=k+1) begin
                    c_bank_dat_reg[k] <= c_bank0_dat[k];
                end
            end   
            2'b01: begin
                for (k=0; k<8; k=k+1) begin
                    c_bank_dat_reg[k] <= c_bank1_dat[k];
                end
            end
            2'b10: begin
                for (k=0; k<8; k=k+1) begin
                    c_bank_dat_reg[k] <= c_bank2_dat[k];
                end
            end
            2'b11: begin
                for (k=0; k<8; k=k+1) begin
                    c_bank_dat_reg[k] <= c_bank3_dat[k];
                end
            end
        endcase
    end
end

reg valid_6; // valid K token
reg valid_6_d1;
reg valid_6_d2;
always @(posedge clk) begin
    valid_6 <= access_k;
    valid_6_d1 <= valid_6; // wait for pipeline datapath
    valid_6_d2 <= valid_6_d1;
end

// Q token0 * K token0,1,2,3,
// need 32 multiplier and 32 adder since each token is 8ch
// we can directly use the projection part, there is resource we can reuse
// bank0_proj_mul_n, bank1_proj_mul_n, bank2_proj_mul_n, bank3_proj_mul_n, 
// bank0_proj_add_n, bank1_proj_add_n, bank2_proj_add_n, bank3_proj_add_n, 
// directly catch the 4 element of bankx_proj_add_n, then we get the result
// (1-bit sign + 3-bit integer + 6-bit fraction) * (1-bit sign + 3-bit integer + 6-bit fraction)
// result: (1-bit sign + 7-bit integer + 12-bit fraction)
reg signed[19:0] qk_result[0:3];
reg valid_7;
always @(posedge clk) begin
    qk_result[0] <= bank0_proj_add_n;
    qk_result[1] <= bank1_proj_add_n;
    qk_result[2] <= bank2_proj_add_n;
    qk_result[3] <= bank3_proj_add_n;
    valid_7 <= valid_6_d2;
end
// ===== 9. Multiply each result with 1 / √chead ===== //
// / √chead. (000_0101101: 1-bit sign + 2-bit integer + 7-bit fraction) 
// The multiply result is (1-bit sign + 10-bit integer + 19-bit fraction)
reg signed [29:0] qk_result_head[0:3];
reg valid_8;
always @(posedge clk) begin
    qk_result_head[0] <= qk_result[0] * 10'sb00001_01101;
    qk_result_head[1] <= qk_result[1] * 10'sb00001_01101;
    qk_result_head[2] <= qk_result[2] * 10'sb00001_01101;
    qk_result_head[3] <= qk_result[3] * 10'sb00001_01101;
    valid_8 <= valid_7;
end

// ===== 10. Quantize the result to 10-bits and write the result to SRAM D. ===== //

// since the accumalated output have 19-bit fraction(18-0), but we only want 
// 6-bit fraction, thus we need to find rounding output. That is, if the 
// (12-0) fraction bit is > 1_0000_0000_0000 than + 1 to (18-13) fraction
// to implement this, we add 1_0000_0000_0000 to accumulated output, so if the last13 bit 
// of original accumulated output > 1_0000_0000_0000 it will add 1 to (18-3) fraction

reg signed [29:0] qk_rounding_output[0:3];
always @(*) begin
    for (k=0; k<4; k=k+1) begin
        qk_rounding_output[k] = qk_result_head[k] + 13'b1_0000_0000_0000;
    end
end

reg signed [16:0] qk_quan[0:3];
// quantize output (30-bit - 13-bit = 17-bit)
// 1-bit sign + 10-bit integer + 6-bit fraction
always @(*) begin
    for (k=0; k<4; k=k+1) begin
        qk_quan[k] = qk_rounding_output[k][29:13];
    end
end

// quantize to 10-bit
// if quantized output > 511 (10-bit sign number max), then quantized output = 511
// if quantized output < -512(10-bit sign number min), then quantized output = -512
reg signed [9:0] qk_quan_10[0:3];

always @(*) begin
    for (k=0; k<4; k=k+1) begin
        if (qk_quan[k] > 17'sd511) begin
            qk_quan_10[k] = 10'sd511;
        end else if (qk_quan[k] < -17'sd512) begin
            qk_quan_10[k] = -10'sd512;
        end else begin
            qk_quan_10[k] = qk_quan[k][9:0];
        end
    end
end

// ----- write SRAM D ----- //
// since Q*K^T is a 16 by 64 matrix, we store in the 
// SRAM D(addr 32~63). one addr have 4 bank, 8ch / bank
// so a sram addr storage is 4*8=32ch, we need two address(entry)
// to store 1 row of matrix (64 ch), the memory allocate as following:

// ----- row 1(64 element, ch)
// addr32: 
// bank0{ch0 , ch1 , ..., ch7}
// bank1{ch8 , ch9 , ..., ch15}
// bank2{ch16, ch17, ..., ch23}
// bank3{ch24, ch25, ..., ch31}
// addr33: 
// bank0{ch32, ch33, ..., ch39}
// bank1{ch40, ch41, ..., ch47}
// bank2{ch48, ch49, ..., ch55}
// bank3{ch56, ch57, ..., ch63}
// ----- row 2
// addr34: 
// bank0{ch0 , ch1 , ..., ch7}
// bank1{ch8 , ch9 , ..., ch15}
// bank2{ch16, ch17, ..., ch23}
// bank3{ch24, ch25, ..., ch31}
// addr35: 
// bank0{ch32, ch33, ..., ch39}
// bank1{ch40, ch41, ..., ch47}
// bank2{ch48, ch49, ..., ch55}
// bank3{ch56, ch57, ..., ch63}
// ...
// ----- row 16
// addr62: 
// bank0{ch0 , ch1 , ..., ch7}
// bank1{ch8 , ch9 , ..., ch15}
// bank2{ch16, ch17, ..., ch23}
// bank3{ch24, ch25, ..., ch31}
// addr63: 
// bank0{ch32, ch33, ..., ch39}
// bank1{ch40, ch41, ..., ch47}
// bank2{ch48, ch49, ..., ch55}
// bank3{ch56, ch57, ..., ch63}

// sram D access sequnce
// since we get 4ch / per cycle, each addr have 32 ch, so we 
// stall at 1 addr 8 cycle, then increment to next addr:
// addr32 -> addr33 -> addr34 -> ... -> addr63
// 10_0000 -> 10_0001 -> 10_0010 -> ... -> 11_1111
// use {1'b1, 5-bit counter}

// sramwordmask sequnce
// since only 4ch is valid per cycle, we only write 4 ch into
// sram every cycle, the other should be block, the sramwordmask
// is as following: 
// ----- cycle 1
// sram_wordmask_d0 00001111 
// sram_wordmask_d1 11111111
// sram_wordmask_d2 11111111
// sram_wordmask_d3 11111111
// ----- cycle 2
// sram_wordmask_d0 11110000 
// sram_wordmask_d1 11111111
// sram_wordmask_d2 11111111
// sram_wordmask_d3 11111111
// ----- cycle 3
// sram_wordmask_d0 11111111 
// sram_wordmask_d1 00001111
// sram_wordmask_d2 11111111
// sram_wordmask_d3 11111111
// ----- cycle 4
// sram_wordmask_d0 11111111 
// sram_wordmask_d1 11110000
// sram_wordmask_d2 11111111
// sram_wordmask_d3 11111111
// ----- cycle 5
// sram_wordmask_d0 11111111 
// sram_wordmask_d1 11111111
// sram_wordmask_d2 00001111
// sram_wordmask_d3 11111111
// ----- cycle 6
// sram_wordmask_d0 11111111 
// sram_wordmask_d1 11111111
// sram_wordmask_d2 11110000
// sram_wordmask_d3 11111111
// ----- cycle 7
// sram_wordmask_d0 11111111 
// sram_wordmask_d1 11111111
// sram_wordmask_d2 11111111
// sram_wordmask_d3 00001111
// ----- cycle 8
// sram_wordmask_d0 11111111 
// sram_wordmask_d1 11111111
// sram_wordmask_d2 11111111
// sram_wordmask_d3 11110000
// and so on ...

always @(posedge clk) begin
    if (valid_8) begin
        qk_cnt8 <= qk_cnt8 + 1;
    end else begin
        qk_cnt8 <= 0;
    end
end

reg [4:0] sram_waddr_cnt_d;
always @(posedge clk) begin
    if (qk_cnt8 == 3'd7) begin
        sram_waddr_cnt_d <= sram_waddr_cnt_d + 1;
    end else if (top_state == R_SRAM_C | top_state == R_SRAM_C_T) begin
        sram_waddr_cnt_d <= sram_waddr_cnt_d;
    end else begin
        sram_waddr_cnt_d <= 0;
    end
end


assign sramd_waddr = {1'b1, sram_waddr_cnt_d};

always @(*) begin
    case (top_state)
        R_SRAM_C, R_SRAM_C_T: begin // QK
            sram_addr_d0 = sramd_waddr;
            sram_addr_d1 = sramd_waddr;
            sram_addr_d2 = sramd_waddr;
            sram_addr_d3 = sramd_waddr;
        end
        SOFTMAX: begin
            sram_addr_d0 = sramd_raddr;
            sram_addr_d1 = sramd_raddr;
            sram_addr_d2 = sramd_raddr;
            sram_addr_d3 = sramd_raddr;
        end
        V_PROJ, V_PROJ_T: begin
            sram_addr_d0 = vproj_sramd_waddr;
            sram_addr_d1 = vproj_sramd_waddr;
            sram_addr_d2 = vproj_sramd_waddr;
            sram_addr_d3 = vproj_sramd_waddr;
        end
        O_PROJ, O_PROJ_T: begin
            sram_addr_d0 = {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};;
            sram_addr_d1 = {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};;
            sram_addr_d2 = {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};;
            sram_addr_d3 = {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};;
        end
        default: begin
            sram_addr_d0 = 0;
            sram_addr_d1 = 0;
            sram_addr_d2 = 0;
            sram_addr_d3 = 0;
        end
    endcase
end

wire [79:0]sramd_wdata_1;
wire [79:0]sramd_wdata_2;
assign sramd_wdata_1 = {qk_quan_10[0], qk_quan_10[1], qk_quan_10[2], qk_quan_10[3], 40'b0};
assign sramd_wdata_2 = {40'b0, qk_quan_10[0], qk_quan_10[1], qk_quan_10[2], qk_quan_10[3]};

always @(*) begin
    case (top_state)
        R_SRAM_C, R_SRAM_C_T: begin
            sram_wdata_d0 = (qk_cnt8[0]==0)? sramd_wdata_1: sramd_wdata_2;
            sram_wdata_d1 = (qk_cnt8[0]==0)? sramd_wdata_1: sramd_wdata_2;
            sram_wdata_d2 = (qk_cnt8[0]==0)? sramd_wdata_1: sramd_wdata_2;
            sram_wdata_d3 = (qk_cnt8[0]==0)? sramd_wdata_1: sramd_wdata_2;
        end
        V_PROJ, V_PROJ_T: begin
            sram_wdata_d0 = vproj_wdata;
            sram_wdata_d1 = vproj_wdata;
            sram_wdata_d2 = vproj_wdata;
            sram_wdata_d3 = vproj_wdata;
        end
        default: begin
            sram_wdata_d0 = 0;
            sram_wdata_d1 = 0;
            sram_wdata_d2 = 0;
            sram_wdata_d3 = 0;
        end
    endcase
end

reg [7:0]qk_wordmask_d0;
reg [7:0]qk_wordmask_d1;
reg [7:0]qk_wordmask_d2;
reg [7:0]qk_wordmask_d3;

always @(*) begin
    case (top_state)
        R_SRAM_C, R_SRAM_C_T: begin
            sram_wordmask_d0 = qk_wordmask_d0;
            sram_wordmask_d1 = qk_wordmask_d1;
            sram_wordmask_d2 = qk_wordmask_d2;
            sram_wordmask_d3 = qk_wordmask_d3;
        end
        V_PROJ, V_PROJ_T: begin
            sram_wordmask_d0 = demask_all;
            sram_wordmask_d1 = demask_all;
            sram_wordmask_d2 = demask_all;
            sram_wordmask_d3 = demask_all;
        end
        default: begin
            sram_wordmask_d0 = mask_all;
            sram_wordmask_d1 = mask_all;
            sram_wordmask_d2 = mask_all;
            sram_wordmask_d3 = mask_all;
        end
    endcase
end
always @(*) begin
    case (qk_cnt8)
    0: begin
        qk_wordmask_d0 = demask_h;
        qk_wordmask_d1 = mask_all;
        qk_wordmask_d2 = mask_all;
        qk_wordmask_d3 = mask_all;
    end
    1: begin
        qk_wordmask_d0 = demask_l;
        qk_wordmask_d1 = mask_all;
        qk_wordmask_d2 = mask_all;
        qk_wordmask_d3 = mask_all;
    end
    2: begin
        qk_wordmask_d0 = mask_all;
        qk_wordmask_d1 = demask_h;
        qk_wordmask_d2 = mask_all;
        qk_wordmask_d3 = mask_all;
    end
    3: begin
        qk_wordmask_d0 = mask_all;
        qk_wordmask_d1 = demask_l;
        qk_wordmask_d2 = mask_all;
        qk_wordmask_d3 = mask_all;
    end
    4: begin
        qk_wordmask_d0 = mask_all;
        qk_wordmask_d1 = mask_all;
        qk_wordmask_d2 = demask_h;
        qk_wordmask_d3 = mask_all;
    end
    5: begin
        qk_wordmask_d0 = mask_all;
        qk_wordmask_d1 = mask_all;
        qk_wordmask_d2 = demask_l;
        qk_wordmask_d3 = mask_all;
    end
    6: begin
        qk_wordmask_d0 = mask_all;
        qk_wordmask_d1 = mask_all;
        qk_wordmask_d2 = mask_all;
        qk_wordmask_d3 = demask_h;
    end
    7: begin
        qk_wordmask_d0 = mask_all;
        qk_wordmask_d1 = mask_all;
        qk_wordmask_d2 = mask_all;
        qk_wordmask_d3 = demask_l;
    end
    endcase
end

always @(*) begin
    case (top_state)
        R_SRAM_C, R_SRAM_C_T: begin
            sram_wen_d0 = !valid_8;
            sram_wen_d1 = !valid_8;
            sram_wen_d2 = !valid_8;
            sram_wen_d3 = !valid_8;
        end
        V_PROJ, V_PROJ_T: begin
            sram_wen_d0 = (accum_done && vproj_wcnt[1:0]==2'b00)? 0:1;
            sram_wen_d1 = (accum_done && vproj_wcnt[1:0]==2'b01)? 0:1;
            sram_wen_d2 = (accum_done && vproj_wcnt[1:0]==2'b10)? 0:1;
            sram_wen_d3 = (accum_done && vproj_wcnt[1:0]==2'b11)? 0:1;
        end
        default: begin
            sram_wen_d0 = 1'b1;
            sram_wen_d1 = 1'b1;
            sram_wen_d2 = 1'b1;
            sram_wen_d3 = 1'b1;
        end
    endcase
end

// ===== 11. Read the attention data form SRAM D. ===== //
// In the exponential part, since we use the taylor series 
// expansion around chosen point(in exp_lut.v), we can use LUT to find
// the exponential value of these lut point, than use these enponential value
// to calculate other number by taylor expansion

// for example, if we want to get exp(7.0625), we use LUT to find exp(7)
// then calculate the taylor series by:
// exp(7) + (exp(7)/1)*(7.0625-7) + (exp(7)/2!)*(7.0625-7)^2 + ..

// The data store in sram D (1-bit sign + 3-bit integer + 6-bit fraction)
// so the integer range from -8~+7, we chosen 64 lut point for this exp(lut point)
// then we use taylor series to get exp(some number around lut point)

// note that we need to determine which lut point we choose in LUT, 
// the lut point should as close as possible to our sram D data
// so that the taylor series high order term may converge faster, thus we can 
// reduce the term we need to calculate (ignore high order term ) if we choose 
// better lut point.

// The method is, choose lut point to map in LUT, we can choose 
// ex: 1, 1.25, 1.5, 1.75, 2, ... so the LUT point and the fixed point number 
// may be closer, the taylor series result may be more precise 

// In this part, we read from sram D to get eack row of 16x64 matrix QK^T
// then implement the softmax function for each row element (64ch)
// each cycle we read out 32ch(half of exp), but only compute 8 ch
// so we need to stall at one addr 8 cycle for a row compute,
// totally 16 row need to do softmax(8*16 cycle for read)
// For the whole process(2 head, each have 4 chunk), we need 256 cycle

// ----- Taylor series re-arrangement ----- //
// let the lut point call a, the taylor expansion of 
// exp(x) can be expand around a by
// exp(x) = exp(a) + exp(a)(x-a) + exp(a)/2*(x-a)^2 + exp(a)/6*(x-a)^3 + exp(a)/24*(x-a)^4 + ... 
// = exp(a) [1 + (x-a)(1+(x-a)(1/2+(x-a)(1/6+(x-a)*1/24)))]
// The dataflow is arrange by following(each stage may be pipeline, totally 8 stage):
// x-a -> *1/24 -> +1/6 -> *(x-a) -> +1/2 -> *(x-a) -> +1 -> *(x-a) -> +1 -> *exp(a) = exp(x)
// The datapath read 32 data from sram D and compute 8 parallel every cycle

// the sram D access sequence is 
// addr32 -> addr33 -> addr34 -> addr35 -> .... -> addr62 -> addr63
// 10_0000 -> 10_0001 -> 10_0010 -> ... -> 11_1111
// each addr stall 4 cycle


always @(posedge clk) begin
    if (top_state == SOFTMAX) begin
        sramd_raddr_cnt <= (sramd_cnt == 2'b11)? sramd_raddr_cnt + 1: sramd_raddr_cnt;
        sramd_cnt <= sramd_cnt + 1;
    end else begin
        sramd_raddr_cnt <= 0;
        sramd_cnt <= 0;
    end
end

assign sramd_raddr = {1'b1, sramd_raddr_cnt};

always @(*) begin
    // MSB-first ordering: [79:70], [69:60], ..., [9:0]
    d_bank0_dat[0] = sram_rdata_d0[79:70]; // ch0
    d_bank0_dat[1] = sram_rdata_d0[69:60]; // ch1
    d_bank0_dat[2] = sram_rdata_d0[59:50]; // ch2
    d_bank0_dat[3] = sram_rdata_d0[49:40]; // ch3
    d_bank0_dat[4] = sram_rdata_d0[39:30]; // ch4
    d_bank0_dat[5] = sram_rdata_d0[29:20]; // ch5
    d_bank0_dat[6] = sram_rdata_d0[19:10]; // ch6
    d_bank0_dat[7] = sram_rdata_d0[9:0];   // ch7

    d_bank1_dat[0] = sram_rdata_d1[79:70];
    d_bank1_dat[1] = sram_rdata_d1[69:60];
    d_bank1_dat[2] = sram_rdata_d1[59:50];
    d_bank1_dat[3] = sram_rdata_d1[49:40];
    d_bank1_dat[4] = sram_rdata_d1[39:30];
    d_bank1_dat[5] = sram_rdata_d1[29:20];
    d_bank1_dat[6] = sram_rdata_d1[19:10];
    d_bank1_dat[7] = sram_rdata_d1[9:0];

    d_bank2_dat[0] = sram_rdata_d2[79:70];
    d_bank2_dat[1] = sram_rdata_d2[69:60];
    d_bank2_dat[2] = sram_rdata_d2[59:50];
    d_bank2_dat[3] = sram_rdata_d2[49:40];
    d_bank2_dat[4] = sram_rdata_d2[39:30];
    d_bank2_dat[5] = sram_rdata_d2[29:20];
    d_bank2_dat[6] = sram_rdata_d2[19:10];
    d_bank2_dat[7] = sram_rdata_d2[9:0];

    d_bank3_dat[0] = sram_rdata_d3[79:70];
    d_bank3_dat[1] = sram_rdata_d3[69:60];
    d_bank3_dat[2] = sram_rdata_d3[59:50];
    d_bank3_dat[3] = sram_rdata_d3[49:40];
    d_bank3_dat[4] = sram_rdata_d3[39:30];
    d_bank3_dat[5] = sram_rdata_d3[29:20];
    d_bank3_dat[6] = sram_rdata_d3[19:10];
    d_bank3_dat[7] = sram_rdata_d3[9:0];
end

reg valid_9;
always @(posedge clk) begin
    if (top_state == SOFTMAX) begin
        valid_9 <= 1;
    end else begin
        valid_9 <= 0;
    end
end

// ===== 12. Implement Softmax. ===== //
// lut point {6-bit origin data + 4'b0} < 10-bit original data
// this is expansion point a
reg [9:0]d_bank0_lut[0:7];
reg [9:0]d_bank1_lut[0:7];
reg [9:0]d_bank2_lut[0:7];
reg [9:0]d_bank3_lut[0:7];

reg [9:0]d_bank_lut_sel[0:7];
always @(*) begin
    for (k=0; k<8; k=k+1) begin
        case (sramd_cnt)
            1: begin
                d_bank_lut_sel[k] = d_bank0_dat[k];
            end
            2: begin
                d_bank_lut_sel[k] = d_bank1_dat[k];
            end
            3: begin
                d_bank_lut_sel[k] = d_bank2_dat[k];
            end
            0: begin
                d_bank_lut_sel[k] = d_bank3_dat[k];
            end
        endcase
    end
end

// in this version, I try to use only 20-bit fraction for lut exponential
// use lut_d7 input to exp_lut
// exp(x): 14-bit integer + 20-bit fraction
wire [33:0] exp_n[0:7];
reg  [33:0] exp[0:7];

genvar f;
generate
    for (f=0; f<8; f=f+1) begin : EXP_LUT_ARRAY
        exp_lut exp_lut_stage8 (
            .lut_idx(d_bank_lut_sel[f]),
            .exp_val(exp_n[f])
        );
    end
endgenerate


reg valid_10;
always @(posedge clk) begin
    for (i=0; i<8; i=i+1) begin
        exp[i] <= exp_n[i];
    end
    valid_10 <= valid_9;
end

reg [2:0] exp_cnt;
always @(posedge clk) begin
    if (valid_10) begin
        exp_cnt <= exp_cnt + 1;
    end else begin
        exp_cnt <= 0;
    end
end

// since we need to sum 64 exponential
// each exp(x) is 14-bit integer + 20-bit fraction
// so the sum will be 20-bit integer + 20-bit fraction
wire [39:0]sel_exp; 
reg [39:0] sum_exp_n;
reg [39:0] sum_exp;
wire valid_11;
reg valid_10_d1;
always @(*) begin
    sum_exp_n = exp[0] + exp[1] + exp[2] + exp[3] + exp[4] + exp[5] + exp[6] + exp[7] + sel_exp;
end

always @(posedge clk) begin
    sum_exp <= sum_exp_n;
    valid_10_d1 <= valid_10;
end
assign valid_11 = (valid_10_d1 && exp_cnt == 3'b0)? 1:0;

// feedback the exp_sum of 8 term back to previous stage
// so we can accumulate 64 term every 8 cyle
assign sel_exp = (exp_cnt != 0)? sum_exp: 0;


always @(posedge clk) begin
    if (valid_11) begin
        exp_sum_reg <= sum_exp;
    end
end

// we may contruct 8 parallel shift register with depth = 10
// write 8 exponential value in this shift register every cycle
// since the exp_sum reg is ready every 8 cycle, if correspond to the 
// first 8 ch exp, it delay 10 cycle write into the exp_sum_reg
// so if we want divide exp / exp_sum, the exp should be pipeline 10 stage
// note that exp is one stage

always @(posedge clk) begin
    for (i=0; i<8; i=i+1) begin
        exp_shift_1[i] <= exp[i];
        exp_shift_2[i] <= exp_shift_1[i];
        exp_shift_3[i] <= exp_shift_2[i];
        exp_shift_4[i] <= exp_shift_3[i];
        exp_shift_5[i] <= exp_shift_4[i];
        exp_shift_6[i] <= exp_shift_5[i];
        exp_shift_7[i] <= exp_shift_6[i];
        exp_shift_8[i] <= exp_shift_7[i];
        exp_shift_9[i] <= exp_shift_8[i];
    end
end
reg valid_12_d7;
// The softmax divider re-use the divider we put in Layernorm stage
always @(posedge clk) begin
    if (valid_11) begin
        valid_12 <= 1;
    end else if (top_state == SOFTMAX_T && sramb_waddr_softmax == 5'd30 && sramb_wcnt == 2'b01) begin
        valid_12 <= 0;
    end else if (top_state == SOFTMAX || top_state == SOFTMAX_T) begin
        valid_12 <= valid_12;
    end else begin
        valid_12 <= 0;
    end

    valid_12_d1 <= valid_12;
    valid_12_d2 <= valid_12_d1;
    valid_12_d3 <= valid_12_d2;
    valid_12_d4 <= valid_12_d3;
    valid_12_d5 <= valid_12_d4;
    valid_12_d6 <= valid_12_d5;
    valid_12_d7 <= valid_12_d6;
end

// ===== 13. Quantize the result to 10-bits and write the result to SRAM B. ===== //
 // since the softmax function output range in 0~1, the fraction bit is cut beforre
 // data go in the divider, sp we dont need to quantize here, just take the lower 10-bit 
 // of token_nor[k][9:0] and write into the sram B.

 // The throught put of the softmax is 8 ch / per cycle, that is, we access each
 // bank one cycle, stall at an sram B entry(address) 4 cycle to write 4 bank.
 always @(posedge clk) begin
    if (valid_12_d7) begin
        sramb_wcnt <= sramb_wcnt + 1;
    end else begin
        sramb_wcnt <= 0;
    end
 end

 always @(posedge clk) begin
    if (sramb_wcnt==2'b11 && valid_12_d7) begin
        sramb_waddr_softmax <= sramb_waddr_softmax + 1;
    end else if (top_state == SOFTMAX || top_state == SOFTMAX_T) begin
        sramb_waddr_softmax <= sramb_waddr_softmax;
    end else begin
        sramb_waddr_softmax <= 0;
    end
 end


always @(*) begin
    for (i=0; i<8; i=i+1) begin
        softmax_wdata_ch[i] = token_nor_reg[i][9:0];
    end
end

always @(*) begin
    softmax_wdata = {softmax_wdata_ch[0], softmax_wdata_ch[1], softmax_wdata_ch[2], softmax_wdata_ch[3]
    , softmax_wdata_ch[4], softmax_wdata_ch[5], softmax_wdata_ch[6], softmax_wdata_ch[7]};
end

// implement an 1024 point LUT to map 10-bit fixed point number to exp
// then calculated the softmax
// exp (unsigned + 14-bit integer + 14-bit fraction)
// (14-bit integer + 14-bit fraction)
// softmax(x_i) = exp(x_i) / Σ exp(x_i)
// the divide result (1-bit sign + 14-bit integer + 6-bit fraction)
// since we need to preserve the fraction 6-bit the softmax is implemnet by
// softmax(x_i) = ({exp(x_i), 6'b0})/Σ exp(x_i)

// ===== 14. Read V projection from SRAM C and softmax result from SRAM B. ===== //
// In this part, we read sram C for matrix V(64x8 matrix)
// and sram B for sortmax result(16x64 matrix)

// sram B and sram C access
// addr0: addr32 -> ... -> add39
// addr1: addr40 -> ... -> addr47
// addr2: addr32 -> ... -> add39
// addr3: addr40 -> ... -> addr47
// ...
// addr30: addr32 -> ... -> add39
// addr31: addr40 -> ... -> addr47

// each sram B addr stall 8 cycle
// sram B:
// addr32 -> addr33 -> addr34 -> ... -> addr62 -> addr63
// 0_0000 -> 0_0001 -> 0_0010 -> ... -> 1_1110 -> 1_1111
// sram C: 
// addr32 -> addr33 -> ... -> addr47
// 10_0000 -> 10_0001 -> ... -> 10_1111


always @(posedge clk) begin
    if (top_state == V_PROJ) begin
        sramb_rcnt <= sramb_rcnt + 1;
        valid_13 <= 1;
    end else begin
        sramb_rcnt <= 0;
        valid_13 <= 0;
    end
end
always @(posedge clk) begin
    if (sramb_rcnt == 3'b111) begin
        sramb_addr_vproj_cnt <= sramb_addr_vproj_cnt + 1;
    end else if (top_state == V_PROJ) begin
        sramb_addr_vproj_cnt <= sramb_addr_vproj_cnt;
    end else begin
        sramb_addr_vproj_cnt <= 0;
    end
end
assign sramb_addr_vproj = {sramb_addr_vproj_cnt};

always @(posedge clk) begin
    if (top_state == V_PROJ || top_state == V_PROJ_T) begin
        sramc_addr_vproj_cnt <= sramc_addr_vproj_cnt + 1;
    end else begin
        sramc_addr_vproj_cnt <= 0;
    end
end
assign sramc_addr_vproj = {2'b10, sramc_addr_vproj_cnt};

// 15. Implement multiplication of attention head 0 first 16 rows results.
// each cycle, sram B(softmax) read out 4-bank, 32 ch, we only sel 4 ch / per cycle
// bank0 ch0~3 -> bank0 ch4~7 -> bank1 ch0~3 -> bank1 ch4~7 -> ... -> bank3 ch0~3 -> bank3 ch4~7
// each cycle, sram C(matrix V) read out 4-bank(4 token), each have 8ch

// sramb_addr = 0
// cycle 1:
// bank0 ch0 * token0 ch0-7
// bank0 ch1 * token1 ch0-7
// bank0 ch2 * token2 ch0-7
// bank0 ch3 * token3 ch0-7
// cycle 2:
// bank0 ch4 * token4 ch0-7
// bank0 ch5 * token5 ch0-7
// bank0 ch6 * token6 ch0-7
// bank0 ch7 * token7 ch0-7
// cycle 3:
// bank1 ch0 * token8  ch0-7
// bank1 ch1 * token9  ch0-7
// bank1 ch2 * token10 ch0-7
// bank1 ch3 * token11 ch0-7
// cycle 4:
// bank1 ch4 * token12 ch0-7
// bank1 ch5 * token13 ch0-7
// bank1 ch6 * token14 ch0-7
// bank1 ch7 * token15 ch0-7
// ...
// cycle 8:
// bank3 ch4 * token28 ch0-7
// bank3 ch5 * token29 ch0-7
// bank3 ch6 * token30 ch0-7
// bank3 ch7 * token31 ch0-7
// sramb_addr = 1
// cycle 9:
// bank0 ch0 * token32 ch0-7
// bank0 ch1 * token33 ch0-7
// bank0 ch2 * token34 ch0-7
// bank0 ch3 * token35 ch0-7
// cycle 10:
// bank0 ch4 * token36 ch0-7
// bank0 ch5 * token37 ch0-7
// bank0 ch6 * token38 ch0-7
// bank0 ch7 * token39 ch0-7
// cycle 11:
// bank1 ch0 * token40 ch0-7
// bank1 ch1 * token41 ch0-7
// bank1 ch2 * token42 ch0-7
// bank1 ch3 * token43 ch0-7
// cycle 12:
// bank1 ch4 * token44 ch0-7
// bank1 ch5 * token45 ch0-7
// bank1 ch6 * token46 ch0-7
// bank1 ch7 * token47 ch0-7
// ...
// cycle 16:
// bank3 ch4 * token60 ch0-7
// bank3 ch5 * token61 ch0-7
// bank3 ch6 * token62 ch0-7
// bank3 ch7 * token63 ch0-7
wire [3:0] vproj_cnt16 = sramc_addr_vproj_cnt[3:0];
assign vproj_cnt8 = sramc_addr_vproj_cnt[2:0];
always @(*) begin
    case (vproj_cnt8)
        3'd1: begin
            sramb_dat_vproj[0] = b_bank0_dat[0];
            sramb_dat_vproj[1] = b_bank0_dat[1];
            sramb_dat_vproj[2] = b_bank0_dat[2];
            sramb_dat_vproj[3] = b_bank0_dat[3];
        end
        3'd2: begin
            sramb_dat_vproj[0] = b_bank0_dat[4];
            sramb_dat_vproj[1] = b_bank0_dat[5];
            sramb_dat_vproj[2] = b_bank0_dat[6];
            sramb_dat_vproj[3] = b_bank0_dat[7]; 
        end
        3'd3: begin
            sramb_dat_vproj[0] = b_bank1_dat[0];
            sramb_dat_vproj[1] = b_bank1_dat[1];
            sramb_dat_vproj[2] = b_bank1_dat[2];
            sramb_dat_vproj[3] = b_bank1_dat[3];
        end
        3'd4: begin
            sramb_dat_vproj[0] = b_bank1_dat[4];
            sramb_dat_vproj[1] = b_bank1_dat[5];
            sramb_dat_vproj[2] = b_bank1_dat[6];
            sramb_dat_vproj[3] = b_bank1_dat[7];
        end
        3'd5: begin
            sramb_dat_vproj[0] = b_bank2_dat[0];
            sramb_dat_vproj[1] = b_bank2_dat[1];
            sramb_dat_vproj[2] = b_bank2_dat[2];
            sramb_dat_vproj[3] = b_bank2_dat[3];
        end
        3'd6: begin
            sramb_dat_vproj[0] = b_bank2_dat[4];
            sramb_dat_vproj[1] = b_bank2_dat[5];
            sramb_dat_vproj[2] = b_bank2_dat[6];
            sramb_dat_vproj[3] = b_bank2_dat[7];
        end
        3'd7: begin
            sramb_dat_vproj[0] = b_bank3_dat[0];
            sramb_dat_vproj[1] = b_bank3_dat[1];
            sramb_dat_vproj[2] = b_bank3_dat[2];
            sramb_dat_vproj[3] = b_bank3_dat[3];
        end
        3'd0: begin
            sramb_dat_vproj[0] = b_bank3_dat[4];
            sramb_dat_vproj[1] = b_bank3_dat[5];
            sramb_dat_vproj[2] = b_bank3_dat[6];
            sramb_dat_vproj[3] = b_bank3_dat[7];
        end
    endcase
end

// accumulated 64 ch multiply result
// since the multiply is 
// (1-bit sign + 3-bit integer + 6-bit fraction) * (1-bit sign + 3-bit integer + 6-bit fraction) 
// the multiply result is (1-bit sign + 7-bit integer + 12-bit fraction)
// for addition 64 mul result, the result is:
// 1-bit sign + 13-bit integer + 12-bit fraction
reg signed[21:0] vproj_add_n[0:7];
reg signed[25:0] vproj_add[0:7];
reg signed[25:0] vproj_add_sel[0:7];
reg valid_14_d1;
reg valid_14_d2;
always @(*) begin
    for (i=0; i<8; i=i+1) begin // the result may delay 1 cycle
        vproj_add_n[i] = bank0_proj_mul_n[i] + bank1_proj_mul_n[i] + bank2_proj_mul_n[i] + bank3_proj_mul_n[i] + vproj_add_sel[i];
    end
end
always @(posedge clk) begin
    for (i=0; i<8; i=i+1) begin
        if ((top_state == V_PROJ || top_state == V_PROJ_T) && valid_14_d1) begin
            vproj_add[i] <= vproj_add_n[i];
        end else begin
            vproj_add[i] <= 0;
        end
    end
    valid_14 <= valid_13;
    valid_14_d1 <= valid_14;
    valid_14_d2 <= valid_14_d1;
end

// high if accumulation is done, write into sram D
assign accum_done = (valid_14_d2 && vproj_cnt16==3)? 1:0;
always @(*) begin
    for (i=0; i<8; i=i+1) begin
        vproj_add_sel[i] = (!valid_14_d1 || accum_done)? 0: vproj_add[i];
    end
end

// 16. Quantize the result to 10-bits and write the result to SRAM D
// The accumulation result is 1-bit sign + 13-bit integer + 12-bit fraction
// we need to quantize to 1-bit sign + 3-bit integer + 6-bit fraction

// since the accumalated output have 12-bit fraction(11-0), but we only want 
// 6-bit fraction, thus we need to find rounding output. That is, if the 
// (5-0) fraction bit is > 10_0000 than + 1 to (11-6) fraction
// to implement this, we add 10_0000 to accumulated output, so if the last 6 bit 
// of original accumulated output > 10_0000 it will add 1 to (12-6) fraction
reg signed [25:0] vproj_rounding_output [0:7];
always @(*) begin
    for (i=0; i<8; i=i+1) begin
        vproj_rounding_output[i] = vproj_add[i] + 6'b10_0000;
    end
end
reg signed [19:0] vproj_quan[0:7];
always @(*) begin
    for (i=0; i<8; i=i+1) begin
        // truncate last 6-bit after rounding
        vproj_quan[i] = vproj_rounding_output[i][25:6];
    end
end
// quantize to 10-bit
// if quantized output > 511 (10-bit sign number max), then quantized output = 511
// if quantized output < -512(10-bit sign number min), then quantized output = -512
reg [9:0] vproj_quan_10[0:7];
always @(*) begin
    for (k=0; k<8; k=k+1) begin
        if (vproj_quan[k] > 13'sd511) begin
            vproj_quan_10[k] = 10'sd511;
        end else if (vproj_quan[k] < -13'sd512) begin
            vproj_quan_10[k] = -10'sd512;
        end else begin
            vproj_quan_10[k] = vproj_quan[k][9:0];
        end
    end
end

assign vproj_wdata = {vproj_quan_10[0], vproj_quan_10[1], vproj_quan_10[2], vproj_quan_10[3], 
                      vproj_quan_10[4], vproj_quan_10[5], vproj_quan_10[6], vproj_quan_10[7]};


// ----- write the result into sram D ----- //
// since the VPROJ state will produce 8 ch(1 token) when 
// accume_done is high, we write 1 bank every write
// the sram D access sequence is 
// chunk1(128 cycle)
// addr0 : bank0 -> bank1 -> bank2 -> bank3
// addr1 : bank0 -> bank1 -> bank2 -> bank3
// addr2 : bank0 -> bank1 -> bank2 -> bank3
// addr3 : bank0 -> bank1 -> bank2 -> bank3
// chunk2(128 cycle)
// addr4 : bank0 -> bank1 -> bank2 -> bank3
// addr5 : bank0 -> bank1 -> bank2 -> bank3
// addr6 : bank0 -> bank1 -> bank2 -> bank3
// addr7 : bank0 -> bank1 -> bank2 -> bank3
// chunk3(128 cycle)
// addr8 : bank0 -> bank1 -> bank2 -> bank3
// addr9 : bank0 -> bank1 -> bank2 -> bank3
// addr10: bank0 -> bank1 -> bank2 -> bank3
// addr11: bank0 -> bank1 -> bank2 -> bank3
// chunk4(128 cycle)
// addr12: bank0 -> bank1 -> bank2 -> bank3
// addr13: bank0 -> bank1 -> bank2 -> bank3
// addr14: bank0 -> bank1 -> bank2 -> bank3
// addr15: bank0 -> bank1 -> bank2 -> bank3
// we write sram D only if accum_done is high

// controll write enable of each bank
always @(posedge clk) begin
    if (!srst_n) begin
        vproj_wcnt <= 0;
    end else if (accum_done) begin
        vproj_wcnt <= vproj_wcnt + 1;
    end else if (top_state == V_PROJ || top_state == V_PROJ_T) begin
        vproj_wcnt <= vproj_wcnt;
    end 
end

// sram D addr 0 -> 31
always @(posedge clk) begin
    if (!srst_n) begin
        vproj_sramd_waddr <= 0;
    end else if (accum_done && vproj_wcnt[1:0] == 2'b11) begin
        vproj_sramd_waddr <= vproj_sramd_waddr + 1;
    end else if (top_state == V_PROJ || top_state == V_PROJ_T || top_state == SOFTMAX) begin
        vproj_sramd_waddr <= vproj_sramd_waddr;
    end 
end

// 19. Read V softmax multiplication result from SRAM D.
// V softmax multiplication result is store in sram D(addr0~31, 4-bank, 8ch/bank)
// Head0(64x8) Head1(64x8)
// ----- Head0 ----- //
// addr0
// bank0: head0-token0
// bank1: head0-token1
// bank2: head0-token2
// bank3: head0-token3
// addr1
// bank0: head0-token4
// bank1: head0-token5
// bank2: head0-token6
// bank3: head0-token7
// ...
// addr15
// bank0: head0-token60
// bank1: head0-token61
// bank2: head0-token62
// bank3: head0-token63
// ----- Head 1 ----- //
// addr16
// bank0: head1-token0
// bank1: head1-token1
// bank2: head1-token2
// bank3: head1-token3
// addr17
// bank0: head1-token4
// bank1: head1-token5
// bank2: head1-token6
// bank3: head1-token7
// ...
// addr31
// bank0: head1-token60
// bank1: head1-token61
// bank2: head1-token62
// bank3: head1-token63

// The V softmax matrix:
// token0 : {head0-token0 , head1-token0}
// token1 : {head0-token1 , head1-token1}
// token2 : {head0-token2 , head1-token2}
// ... 
// token63: {head0-token63, head1-token63}
// address access sequence:
// addr0 -> addr16 -> addr1 -> addr17 -> ... -> addr15 -> addr31

// The O projection matrix
// each column have 4-ch
// addr0  -> col0 
// addr1  -> col1
// ...
// addr15 -> col15
// addr0 -> addr1 -> ... -> addr15
// each addr stall 2 cycle

// 20. Implement O projection. 
// 21. Quantize the result to 10-bit and write the result to SRAM C. 
// The datapath is implement by the projection datapath

// 22. Read O projection from SRAM C and patch embedded data from SRAM A. 
// In this part, we dont read from SRAM C, we use different datapath.
// When we write o projection data into sram C, we parallel read sram A and
// add the residual, so these two process (write sram C and add residual) will 
// be parallel

// pipeline the o projection wdata result
reg [9:0] o_proj_wdat_d1[0:3];
reg [2:0] sram_c_ch_cnt_d1;
reg signed [9:0] add_in1[0:3];
reg signed [9:0] add_in2[0:3];
always @(posedge clk) begin
    o_proj_wdat_d1[0] <= token0_proj_quan_10;
    o_proj_wdat_d1[1] <= token1_proj_quan_10;
    o_proj_wdat_d1[2] <= token2_proj_quan_10;
    o_proj_wdat_d1[3] <= token3_proj_quan_10;
    sram_c_ch_cnt_d1 <= sram_c_ch_cnt;
end

always @(*) begin
    for (i=0; i<4; i=i+1) begin
        add_in1[i] = o_proj_wdat_d1[i];
    end
end
// 23. Implement residual add 
always @(*) begin
    case (sram_c_ch_cnt_d1)
        3'd0: begin
            add_in2[0] = a_bank0_dat[0];
            add_in2[1] = a_bank1_dat[0];
            add_in2[2] = a_bank2_dat[0];
            add_in2[3] = a_bank3_dat[0];
        end
        3'd1: begin
            add_in2[0] = a_bank0_dat[1];
            add_in2[1] = a_bank1_dat[1];
            add_in2[2] = a_bank2_dat[1];
            add_in2[3] = a_bank3_dat[1];
        end
        3'd2: begin
            add_in2[0] = a_bank0_dat[2];
            add_in2[1] = a_bank1_dat[2];
            add_in2[2] = a_bank2_dat[2];
            add_in2[3] = a_bank3_dat[2];
        end
        3'd3: begin
            add_in2[0] = a_bank0_dat[3];
            add_in2[1] = a_bank1_dat[3];
            add_in2[2] = a_bank2_dat[3];
            add_in2[3] = a_bank3_dat[3];
        end
        3'd4: begin
            add_in2[0] = a_bank0_dat[4];
            add_in2[1] = a_bank1_dat[4];
            add_in2[2] = a_bank2_dat[4];
            add_in2[3] = a_bank3_dat[4];
        end
        3'd5: begin
            add_in2[0] = a_bank0_dat[5];
            add_in2[1] = a_bank1_dat[5];
            add_in2[2] = a_bank2_dat[5];
            add_in2[3] = a_bank3_dat[5];
        end
        3'd6: begin
            add_in2[0] = a_bank0_dat[6];
            add_in2[1] = a_bank1_dat[6];
            add_in2[2] = a_bank2_dat[6];
            add_in2[3] = a_bank3_dat[6];
        end
        3'd7: begin
            add_in2[0] = a_bank0_dat[7];
            add_in2[1] = a_bank1_dat[7];
            add_in2[2] = a_bank2_dat[7];
            add_in2[3] = a_bank3_dat[7];
        end
    endcase
end
// add_in1(1-bit sign + 3-bit integer + 6-bit fraction)
// add_in2(1-bit sign + 3-bit integer + 6-bit fraction)
// result (1-bit sign + 4-bit integer + 6-bit fraction)
reg [10:0] add_result[0:3];
reg [9:0]  residual_quan_10[0:3];
reg valid_15;
always @(*) begin
    for (i=0; i<4; i=i+1) begin
        add_result[i] = add_in1[i] + add_in2[i];
    end
end
// 24. Quantize the result to 10-bit and store the result to SRAM B. 
// the write address and enable can get from the pipeline control signal of sram C

always @(*) begin
    for (i=0; i<4; i=i+1) begin
        residual_quan_10[i] = add_result[i][9:0];
    end
end
always @(posedge clk) begin
    if ((top_state == O_PROJ||top_state==O_PROJ_T) && !sram_wen_c0) begin
        valid_15 <= 1;
    end else begin
        valid_15 <= 0;
    end
end
always @(posedge clk) begin
    sramb_addr_res <= sram_addr_cnt_c;
    sramb_wordmask_res <= wordmask_c;
end
assign sramb_wen_res = (valid_15)? 0:1; // low active write enable

always @(*) begin
    // the token_proj_quan10 will locate at different location
    case (sram_c_ch_cnt_d1)
        0: begin
            b_bank0_w = {residual_quan_10[0], 70'b0};
            b_bank1_w = {residual_quan_10[1], 70'b0};
            b_bank2_w = {residual_quan_10[2], 70'b0};
            b_bank3_w = {residual_quan_10[3], 70'b0};
        end
        1: begin
            b_bank0_w = {10'b0, residual_quan_10[0], 60'b0};
            b_bank1_w = {10'b0, residual_quan_10[1], 60'b0};
            b_bank2_w = {10'b0, residual_quan_10[2], 60'b0};
            b_bank3_w = {10'b0, residual_quan_10[3], 60'b0};
        end
        2: begin
            b_bank0_w = {20'b0, residual_quan_10[0], 50'b0};
            b_bank1_w = {20'b0, residual_quan_10[1], 50'b0};
            b_bank2_w = {20'b0, residual_quan_10[2], 50'b0};
            b_bank3_w = {20'b0, residual_quan_10[3], 50'b0};
        end
        3: begin
            b_bank0_w = {30'b0, residual_quan_10[0], 40'b0};
            b_bank1_w = {30'b0, residual_quan_10[1], 40'b0};
            b_bank2_w = {30'b0, residual_quan_10[2], 40'b0};
            b_bank3_w = {30'b0, residual_quan_10[3], 40'b0};
        end
        4: begin
            b_bank0_w = {40'b0, residual_quan_10[0], 30'b0};
            b_bank1_w = {40'b0, residual_quan_10[1], 30'b0};
            b_bank2_w = {40'b0, residual_quan_10[2], 30'b0};
            b_bank3_w = {40'b0, residual_quan_10[3], 30'b0};
        end
        5: begin
            b_bank0_w = {50'b0, residual_quan_10[0], 20'b0};
            b_bank1_w = {50'b0, residual_quan_10[1], 20'b0};
            b_bank2_w = {50'b0, residual_quan_10[2], 20'b0};
            b_bank3_w = {50'b0, residual_quan_10[3], 20'b0};
        end
        6: begin
            b_bank0_w = {60'b0, residual_quan_10[0], 10'b0};
            b_bank1_w = {60'b0, residual_quan_10[1], 10'b0};
            b_bank2_w = {60'b0, residual_quan_10[2], 10'b0};
            b_bank3_w = {60'b0, residual_quan_10[3], 10'b0};
        end
        7: begin
            b_bank0_w = {70'b0, residual_quan_10[0]};
            b_bank1_w = {70'b0, residual_quan_10[1]};
            b_bank2_w = {70'b0, residual_quan_10[2]};
            b_bank3_w = {70'b0, residual_quan_10[3]};
        end
        default: begin
            b_bank0_w = 80'b0;
            b_bank1_w = 80'b0;
            b_bank2_w = 80'b0;
            b_bank3_w = 80'b0;
        end
    endcase
end



endmodule


// module div #(
//     parameter N = 39,
//     parameter M = 39,
//     parameter N_ACT = M+N-1
// )(
//     input clk,
//     input [N-1:0] dividend,
//     input [M-1:0] divisor,
//     output [N-1:0] merchant,
//     output [M-1:0] remainder
// );

// // Restoring divider with pipeline registers arranged as |4|4|4|4|4|4

// // Layernorm need 24-bit dividend / 18-bit divisor
// // The result merchant may be 24-bit 
// // we find from the msb of merchant to lsb of merchant
// // Softmax need 39-bit dividend / 39-bit divisor
// // The result merchant may only 6-bit(from golden pattern)
// // so we dont need to find the merchant from msb for softmax
// // we can find directly find merchant bit-23 ~ bit0
// // so the dividend may not start from msb of dividend
// // start from [39:23]

// localparam integer PIPE_DEPTH = 23;
// localparam MAX_WIDTH = 24;

// reg [N_ACT-M-1:0] dividend_t [N_ACT-M:0];
// reg [M-1:0]       divisor_t  [N_ACT-M:0];
// reg [M-1:0]       remainder_t[N_ACT-M:0];
// reg [N_ACT-M:0]   merchant_t [N_ACT-M:0];

// wire [M:0] stage0_dividend = {22'b0, dividend[N-1:MAX_WIDTH-1]};//[39:23]
// wire [M-1:0] stage0_divisor = divisor;
// wire [N_ACT-M:0] stage0_merchant_ci = {(N_ACT-M+1){1'b0}};
// wire [N_ACT-M-1:0] stage0_dividend_ci = dividend[N_ACT-M-1:0];

// wire [M:0] stage_sub_0 = stage0_dividend - {1'b0, stage0_divisor};
// always @(posedge clk) begin
//     divisor_t[0]  <= stage0_divisor;
//     dividend_t[0] <= stage0_dividend_ci;
//     if (!stage_sub_0[M]) begin
//         merchant_t[0]  <= {stage0_merchant_ci[N_ACT-M-1:0], 1'b1};
//         remainder_t[0] <= stage_sub_0[M-1:0];
//     end else begin
//         merchant_t[0]  <= {stage0_merchant_ci[N_ACT-M-1:0], 1'b0};
//         remainder_t[0] <= stage0_dividend[M-1:0];
//     end
// end

// wire [M:0] stage_sub_1 = {{remainder_t[0], dividend_t[0][MAX_WIDTH-2]}} - {1'b0, divisor_t[0]};
// always @(*) begin
//     divisor_t[1]  = divisor_t[0];
//     dividend_t[1] = dividend_t[0];
//     if (!stage_sub_1[M]) begin
//         merchant_t[1]  = {merchant_t[0][N_ACT-M-1:0], 1'b1};
//         remainder_t[1] = stage_sub_1[M-1:0];
//     end else begin
//         merchant_t[1]  = {merchant_t[0][N_ACT-M-1:0], 1'b0};
//         remainder_t[1] = {remainder_t[0], dividend_t[0][MAX_WIDTH-2]};
//     end
// end
// wire [M:0] stage_sub_2 = {{remainder_t[1], dividend_t[1][MAX_WIDTH-3]}} - {1'b0, divisor_t[1]};

// always @(*) begin
//     divisor_t[2]  = divisor_t[1];
//     dividend_t[2] = dividend_t[1];
//     if (!stage_sub_2[M]) begin
//         merchant_t[2]  = {merchant_t[1][N_ACT-M-1:0], 1'b1};
//         remainder_t[2] = stage_sub_2[M-1:0];
//     end else begin
//         merchant_t[2]  = {merchant_t[1][N_ACT-M-1:0], 1'b0};
//         remainder_t[2] = {remainder_t[1], dividend_t[1][MAX_WIDTH-3]};
//     end
// end
// wire [M:0] stage_sub_3 = {{remainder_t[2], dividend_t[2][MAX_WIDTH-4]}} - {1'b0, divisor_t[2]};

// always @(*) begin
//     divisor_t[3]  = divisor_t[2];
//     dividend_t[3] = dividend_t[2];
//     if (!stage_sub_3[M]) begin
//         merchant_t[3]  = {merchant_t[2][N_ACT-M-1:0], 1'b1};
//         remainder_t[3] = stage_sub_3[M-1:0];
//     end else begin
//         merchant_t[3]  = {merchant_t[2][N_ACT-M-1:0], 1'b0};
//         remainder_t[3] = {remainder_t[2], dividend_t[2][MAX_WIDTH-4]};
//     end
// end
// wire [M:0] stage_sub_4 = {{remainder_t[3], dividend_t[3][MAX_WIDTH-5]}} - {1'b0, divisor_t[3]};

// always @(posedge clk) begin
//     divisor_t[4]  <= divisor_t[3];
//     dividend_t[4] <= dividend_t[3];
//     if (!stage_sub_4[M]) begin
//         merchant_t[4]  <= {merchant_t[3][N_ACT-M-1:0], 1'b1};
//         remainder_t[4] <= stage_sub_4[M-1:0];
//     end else begin
//         merchant_t[4]  <= {merchant_t[3][N_ACT-M-1:0], 1'b0};
//         remainder_t[4] <= {remainder_t[3], dividend_t[3][MAX_WIDTH-5]};
//     end
// end
// wire [M:0] stage_sub_5 = {{remainder_t[4], dividend_t[4][MAX_WIDTH-6]}} - {1'b0, divisor_t[4]};

// always @(*) begin
//     divisor_t[5]  = divisor_t[4];
//     dividend_t[5] = dividend_t[4];
//     if (!stage_sub_5[M]) begin
//         merchant_t[5]  = {merchant_t[4][N_ACT-M-1:0], 1'b1};
//         remainder_t[5] = stage_sub_5[M-1:0];
//     end else begin
//         merchant_t[5]  = {merchant_t[4][N_ACT-M-1:0], 1'b0};
//         remainder_t[5] = {remainder_t[4], dividend_t[4][MAX_WIDTH-6]};
//     end
// end
// wire [M:0] stage_sub_6 = {{remainder_t[5], dividend_t[5][MAX_WIDTH-7]}} - {1'b0, divisor_t[5]};

// always @(*) begin
//     divisor_t[6]  = divisor_t[5];
//     dividend_t[6] = dividend_t[5];
//     if (!stage_sub_6[M]) begin
//         merchant_t[6]  = {merchant_t[5][N_ACT-M-1:0], 1'b1};
//         remainder_t[6] = stage_sub_6[M-1:0];
//     end else begin
//         merchant_t[6]  = {merchant_t[5][N_ACT-M-1:0], 1'b0};
//         remainder_t[6] = {remainder_t[5], dividend_t[5][MAX_WIDTH-7]};
//     end
// end
// wire [M:0] stage_sub_7 = {{remainder_t[6], dividend_t[6][MAX_WIDTH-8]}} - {1'b0, divisor_t[6]};

// always @(*) begin
//     divisor_t[7]  = divisor_t[6];
//     dividend_t[7] = dividend_t[6];
//     if (!stage_sub_7[M]) begin
//         merchant_t[7]  = {merchant_t[6][N_ACT-M-1:0], 1'b1};
//         remainder_t[7] = stage_sub_7[M-1:0];
//     end else begin
//         merchant_t[7]  = {merchant_t[6][N_ACT-M-1:0], 1'b0};
//         remainder_t[7] = {remainder_t[6], dividend_t[6][MAX_WIDTH-8]};
//     end
// end
// wire [M:0] stage_sub_8 = {{remainder_t[7], dividend_t[7][MAX_WIDTH-9]}} - {1'b0, divisor_t[7]};

// always @(posedge clk) begin
//     divisor_t[8]  <= divisor_t[7];
//     dividend_t[8] <= dividend_t[7];
//     if (!stage_sub_8[M]) begin
//         merchant_t[8]  <= {merchant_t[7][N_ACT-M-1:0], 1'b1};
//         remainder_t[8] <= stage_sub_8[M-1:0];
//     end else begin
//         merchant_t[8]  <= {merchant_t[7][N_ACT-M-1:0], 1'b0};
//         remainder_t[8] <= {remainder_t[7], dividend_t[7][MAX_WIDTH-9]};
//     end
// end
// wire [M:0] stage_sub_9 = {{remainder_t[8], dividend_t[8][MAX_WIDTH-10]}} - {1'b0, divisor_t[8]};

// always @(*) begin
//     divisor_t[9]  = divisor_t[8];
//     dividend_t[9] = dividend_t[8];
//     if (!stage_sub_9[M]) begin
//         merchant_t[9]  = {merchant_t[8][N_ACT-M-1:0], 1'b1};
//         remainder_t[9] = stage_sub_9[M-1:0];
//     end else begin
//         merchant_t[9]  = {merchant_t[8][N_ACT-M-1:0], 1'b0};
//         remainder_t[9] = {remainder_t[8], dividend_t[8][MAX_WIDTH-10]};
//     end
// end
// wire [M:0] stage_sub_10 = {{remainder_t[9], dividend_t[9][MAX_WIDTH-11]}} - {1'b0, divisor_t[9]};

// always @(*) begin
//     divisor_t[10]  = divisor_t[9];
//     dividend_t[10] = dividend_t[9];
//     if (!stage_sub_10[M]) begin
//         merchant_t[10]  = {merchant_t[9][N_ACT-M-1:0], 1'b1};
//         remainder_t[10] = stage_sub_10[M-1:0];
//     end else begin
//         merchant_t[10]  = {merchant_t[9][N_ACT-M-1:0], 1'b0};
//         remainder_t[10] = {remainder_t[9], dividend_t[9][MAX_WIDTH-11]};
//     end
// end
// wire [M:0] stage_sub_11 = {{remainder_t[10], dividend_t[10][MAX_WIDTH-12]}} - {1'b0, divisor_t[10]};

// always @(*) begin
//     divisor_t[11]  = divisor_t[10];
//     dividend_t[11] = dividend_t[10];
//     if (!stage_sub_11[M]) begin
//         merchant_t[11]  = {merchant_t[10][N_ACT-M-1:0], 1'b1};
//         remainder_t[11] = stage_sub_11[M-1:0];
//     end else begin
//         merchant_t[11]  = {merchant_t[10][N_ACT-M-1:0], 1'b0};
//         remainder_t[11] = {remainder_t[10], dividend_t[10][MAX_WIDTH-12]};
//     end
// end
// wire [M:0] stage_sub_12 = {{remainder_t[11], dividend_t[11][MAX_WIDTH-13]}} - {1'b0, divisor_t[11]};

// always @(posedge clk) begin
//     divisor_t[12]  <= divisor_t[11];
//     dividend_t[12] <= dividend_t[11];
//     if (!stage_sub_12[M]) begin
//         merchant_t[12]  <= {merchant_t[11][N_ACT-M-1:0], 1'b1};
//         remainder_t[12] <= stage_sub_12[M-1:0];
//     end else begin
//         merchant_t[12]  <= {merchant_t[11][N_ACT-M-1:0], 1'b0};
//         remainder_t[12] <= {remainder_t[11], dividend_t[11][MAX_WIDTH-13]};
//     end
// end
// wire [M:0] stage_sub_13 = {{remainder_t[12], dividend_t[12][MAX_WIDTH-14]}} - {1'b0, divisor_t[12]};

// always @(*) begin
//     divisor_t[13]  = divisor_t[12];
//     dividend_t[13] = dividend_t[12];
//     if (!stage_sub_13[M]) begin
//         merchant_t[13]  = {merchant_t[12][N_ACT-M-1:0], 1'b1};
//         remainder_t[13] = stage_sub_13[M-1:0];
//     end else begin
//         merchant_t[13]  = {merchant_t[12][N_ACT-M-1:0], 1'b0};
//         remainder_t[13] = {remainder_t[12], dividend_t[12][MAX_WIDTH-14]};
//     end
// end
// wire [M:0] stage_sub_14 = {{remainder_t[13], dividend_t[13][MAX_WIDTH-15]}} - {1'b0, divisor_t[13]};

// always @(*) begin
//     divisor_t[14]  = divisor_t[13];
//     dividend_t[14] = dividend_t[13];
//     if (!stage_sub_14[M]) begin
//         merchant_t[14]  = {merchant_t[13][N_ACT-M-1:0], 1'b1};
//         remainder_t[14] = stage_sub_14[M-1:0];
//     end else begin
//         merchant_t[14]  = {merchant_t[13][N_ACT-M-1:0], 1'b0};
//         remainder_t[14] = {remainder_t[13], dividend_t[13][MAX_WIDTH-15]};
//     end
// end
// wire [M:0] stage_sub_15 = {{remainder_t[14], dividend_t[14][MAX_WIDTH-16]}} - {1'b0, divisor_t[14]};

// always @(*) begin
//     divisor_t[15]  = divisor_t[14];
//     dividend_t[15] = dividend_t[14];
//     if (!stage_sub_15[M]) begin
//         merchant_t[15]  = {merchant_t[14][N_ACT-M-1:0], 1'b1};
//         remainder_t[15] = stage_sub_15[M-1:0];
//     end else begin
//         merchant_t[15]  = {merchant_t[14][N_ACT-M-1:0], 1'b0};
//         remainder_t[15] = {remainder_t[14], dividend_t[14][MAX_WIDTH-16]};
//     end
// end
// wire [M:0] stage_sub_16 = {{remainder_t[15], dividend_t[15][MAX_WIDTH-17]}} - {1'b0, divisor_t[15]};

// always @(posedge clk) begin
//     divisor_t[16]  <= divisor_t[15];
//     dividend_t[16] <= dividend_t[15];
//     if (!stage_sub_16[M]) begin
//         merchant_t[16]  <= {merchant_t[15][N_ACT-M-1:0], 1'b1};
//         remainder_t[16] <= stage_sub_16[M-1:0];
//     end else begin
//         merchant_t[16]  <= {merchant_t[15][N_ACT-M-1:0], 1'b0};
//         remainder_t[16] <= {remainder_t[15], dividend_t[15][MAX_WIDTH-17]};
//     end
// end
// wire [M:0] stage_sub_17 = {{remainder_t[16], dividend_t[16][MAX_WIDTH-18]}} - {1'b0, divisor_t[16]};

// always @(*) begin
//     divisor_t[17]  = divisor_t[16];
//     dividend_t[17] = dividend_t[16];
//     if (!stage_sub_17[M]) begin
//         merchant_t[17]  = {merchant_t[16][N_ACT-M-1:0], 1'b1};
//         remainder_t[17] = stage_sub_17[M-1:0];
//     end else begin
//         merchant_t[17]  = {merchant_t[16][N_ACT-M-1:0], 1'b0};
//         remainder_t[17] = {remainder_t[16], dividend_t[16][MAX_WIDTH-18]};
//     end
// end
// wire [M:0] stage_sub_18 = {{remainder_t[17], dividend_t[17][MAX_WIDTH-19]}} - {1'b0, divisor_t[17]};

// always @(*) begin
//     divisor_t[18]  = divisor_t[17];
//     dividend_t[18] = dividend_t[17];
//     if (!stage_sub_18[M]) begin
//         merchant_t[18]  = {merchant_t[17][N_ACT-M-1:0], 1'b1};
//         remainder_t[18] = stage_sub_18[M-1:0];
//     end else begin
//         merchant_t[18]  = {merchant_t[17][N_ACT-M-1:0], 1'b0};
//         remainder_t[18] = {remainder_t[17], dividend_t[17][MAX_WIDTH-19]};
//     end
// end
// wire [M:0] stage_sub_19 = {{remainder_t[18], dividend_t[18][MAX_WIDTH-20]}} - {1'b0, divisor_t[18]};

// always @(*) begin
//     divisor_t[19]  = divisor_t[18];
//     dividend_t[19] = dividend_t[18];
//     if (!stage_sub_19[M]) begin
//         merchant_t[19]  = {merchant_t[18][N_ACT-M-1:0], 1'b1};
//         remainder_t[19] = stage_sub_19[M-1:0];
//     end else begin
//         merchant_t[19]  = {merchant_t[18][N_ACT-M-1:0], 1'b0};
//         remainder_t[19] = {remainder_t[18], dividend_t[18][MAX_WIDTH-20]};
//     end
// end
// wire [M:0] stage_sub_20 = {{remainder_t[19], dividend_t[19][MAX_WIDTH-21]}} - {1'b0, divisor_t[19]};

// always @(posedge clk) begin
//     divisor_t[20]  <= divisor_t[19];
//     dividend_t[20] <= dividend_t[19];
//     if (!stage_sub_20[M]) begin
//         merchant_t[20]  <= {merchant_t[19][N_ACT-M-1:0], 1'b1};
//         remainder_t[20] <= stage_sub_20[M-1:0];
//     end else begin
//         merchant_t[20]  <= {merchant_t[19][N_ACT-M-1:0], 1'b0};
//         remainder_t[20] <= {remainder_t[19], dividend_t[19][MAX_WIDTH-21]};
//     end
// end
// wire [M:0] stage_sub_21 = {{remainder_t[20], dividend_t[20][MAX_WIDTH-22]}} - {1'b0, divisor_t[20]};

// always @(*) begin
//     divisor_t[21]  = divisor_t[20];
//     dividend_t[21] = dividend_t[20];
//     if (!stage_sub_21[M]) begin
//         merchant_t[21]  = {merchant_t[20][N_ACT-M-1:0], 1'b1};
//         remainder_t[21] = stage_sub_21[M-1:0];
//     end else begin
//         merchant_t[21]  = {merchant_t[20][N_ACT-M-1:0], 1'b0};
//         remainder_t[21] = {remainder_t[20], dividend_t[20][MAX_WIDTH-22]};
//     end
// end
// wire [M:0] stage_sub_22 = {{remainder_t[21], dividend_t[21][MAX_WIDTH-23]}} - {1'b0, divisor_t[21]};

// always @(*) begin
//     divisor_t[22]  = divisor_t[21];
//     dividend_t[22] = dividend_t[21];
//     if (!stage_sub_22[M]) begin
//         merchant_t[22]  = {merchant_t[21][N_ACT-M-1:0], 1'b1};
//         remainder_t[22] = stage_sub_22[M-1:0];
//     end else begin
//         merchant_t[22]  = {merchant_t[21][N_ACT-M-1:0], 1'b0};
//         remainder_t[22] = {remainder_t[21], dividend_t[21][MAX_WIDTH-23]};
//     end
// end
// wire [M:0] stage_sub_23 = {{remainder_t[22], dividend_t[22][MAX_WIDTH-24]}} - {1'b0, divisor_t[22]};

// always @(*) begin
//     divisor_t[23]  = divisor_t[22];
//     dividend_t[23] = dividend_t[22];
//     if (!stage_sub_23[M]) begin
//         merchant_t[23]  = {merchant_t[22][N_ACT-M-1:0], 1'b1};
//         remainder_t[23] = stage_sub_23[M-1:0];
//     end else begin
//         merchant_t[23]  = {merchant_t[22][N_ACT-M-1:0], 1'b0};
//         remainder_t[23] = {remainder_t[22], dividend_t[22][MAX_WIDTH-24]};
//     end
// end
// assign merchant  = merchant_t[PIPE_DEPTH];
// assign remainder = remainder_t[PIPE_DEPTH];

// endmodule // div


module div #(
    parameter N = 39,
    parameter M = 39,
    parameter N_ACT = M+N-1
)(
    input clk,
    input [N-1:0] dividend,
    input [M-1:0] divisor,
    input mode_sel, // 0: Layernorm 1: Softmax
    output [N-1:0] merchant,
    output [M-1:0] remainder
);

// Restoring divider with pipeline registers arranged as |4|4|4|4|4|4

// Layernorm need 24-bit dividend / 18-bit divisor
// The result merchant may be 24-bit 
// we find from the msb of merchant to lsb of merchant
// Softmax need 39-bit dividend / 39-bit divisor
// The result merchant may only 6-bit(from golden pattern)
// so we dont need to find the merchant from msb for softmax
// we can find directly find merchant bit-5 ~ bit0
// so the dividend may not start from msb of dividend
// start from [39:5]

// The divider have 24 stage
// The first 6 stage need to be 39-bit width(FF or sub), to compute the 
// 24-bit dividend or 39-bit dividend
// the last 18 stage only need 24-bit width(FF or sub), since the softmax 
// output will be only 6-bit merchant, we can use the 6-stage 
// to compute. 
// The merchant of layernorm may be up to 24-bit, so we use 24-stage 
// to compute it's merchant.

localparam integer PIPE_DEPTH = 23;
localparam MAX_WIDTH = 24;

reg [N_ACT-M-1:0] dividend_t [N_ACT-M:0];
reg [M-1:0]       divisor_t  [N_ACT-M:0];
reg [M-1:0]       remainder_t[N_ACT-M:0];
reg [N_ACT-M:0]   merchant_t [N_ACT-M:0];
reg [PIPE_DEPTH:0]mode_sel_t;
reg               dividend_sel[PIPE_DEPTH:0];
reg [M:0]         stage_sub_0, stage_sub_1, stage_sub_2, stage_sub_3, stage_sub_4, stage_sub_5;
reg [MAX_WIDTH:0] stage_sub_6, stage_sub_7, stage_sub_8, stage_sub_9, stage_sub_10, stage_sub_11;
reg [MAX_WIDTH:0] stage_sub_12, stage_sub_13, stage_sub_14, stage_sub_15, stage_sub_16, stage_sub_17;
reg [MAX_WIDTH:0] stage_sub_18, stage_sub_19, stage_sub_20, stage_sub_21, stage_sub_22, stage_sub_23;

wire [M-1:0] stage0_divisor = divisor;
wire [N_ACT-M:0] stage0_merchant_ci = {(N_ACT-M+1){1'b0}};
wire [N_ACT-M-1:0] stage0_dividend_ci = dividend[N_ACT-M-1:0];
wire stage0_mode_sel = mode_sel;

                                        // Softmax[39:5]        : Layernorm[39:23]
wire [M:0] stage0_dividend = (mode_sel)? {{(M+1-(N-5)){1'b0}}, dividend[N-1:5]}: {{(M+1-MAX_WIDTH){1'b0}}, dividend[N-1:MAX_WIDTH-1]};// zero-extend to full width
always @(*) begin
    stage_sub_0 = stage0_dividend - {1'b0, stage0_divisor};
end
always @(posedge clk) begin
    divisor_t[0]  <= stage0_divisor;
    dividend_t[0] <= stage0_dividend_ci;
    mode_sel_t[0] <= stage0_mode_sel;
    if (!stage_sub_0[M]) begin
        merchant_t[0]  <= {stage0_merchant_ci[N_ACT-M-1:0], 1'b1};
        remainder_t[0] <= stage_sub_0[M-1:0];
    end else begin
        merchant_t[0]  <= {stage0_merchant_ci[N_ACT-M-1:0], 1'b0};
        remainder_t[0] <= stage0_dividend[M-1:0];
    end
end

always @(*) begin
    dividend_sel[0] = (mode_sel_t[0])? dividend_t[0][4]: dividend_t[0][22];
    stage_sub_1     = {{remainder_t[0], dividend_sel[0]}} - {1'b0, divisor_t[0]};
end
always @(*) begin
    divisor_t[1]  = divisor_t[0];
    dividend_t[1] = dividend_t[0];
    mode_sel_t[1] = mode_sel_t[0];
    if (!stage_sub_1[M]) begin
        merchant_t[1]  = {merchant_t[0][N_ACT-M-1:0], 1'b1};
        remainder_t[1] = stage_sub_1[M-1:0];
    end else begin
        merchant_t[1]  = {merchant_t[0][N_ACT-M-1:0], 1'b0};
        remainder_t[1] = {remainder_t[0][M-2:0], dividend_sel[0]};
    end
end

always @(*) begin
    dividend_sel[1] = (mode_sel_t[1])? dividend_t[1][3]: dividend_t[1][21];
    stage_sub_2     = {{remainder_t[1], dividend_sel[1]}} - {1'b0, divisor_t[1]};
end

always @(*) begin
    divisor_t[2]  = divisor_t[1];
    dividend_t[2] = dividend_t[1];
    mode_sel_t[2] = mode_sel_t[1];
    if (!stage_sub_2[M]) begin
        merchant_t[2]  = {merchant_t[1][N_ACT-M-1:0], 1'b1};
        remainder_t[2] = stage_sub_2[M-1:0];
    end else begin
        merchant_t[2]  = {merchant_t[1][N_ACT-M-1:0], 1'b0};
        remainder_t[2] = {remainder_t[1][M-2:0], dividend_sel[1]};
    end
end

always @(*) begin
    dividend_sel[2] = (mode_sel_t[2])? dividend_t[2][2]: dividend_t[2][20];
    stage_sub_3     = {{remainder_t[2], dividend_sel[2]}} - {1'b0, divisor_t[2]};
end

always @(*) begin
    divisor_t[3]  = divisor_t[2];
    dividend_t[3] = dividend_t[2];
    mode_sel_t[3] = mode_sel_t[2];
    if (!stage_sub_3[M]) begin
        merchant_t[3]  = {merchant_t[2][N_ACT-M-1:0], 1'b1};
        remainder_t[3] = stage_sub_3[M-1:0];
    end else begin
        merchant_t[3]  = {merchant_t[2][N_ACT-M-1:0], 1'b0};
        remainder_t[3] = {remainder_t[2][M-2:0], dividend_sel[2]};
    end
end

always @(*) begin
    dividend_sel[3] = (mode_sel_t[3])? dividend_t[3][1]: dividend_t[3][19];
    stage_sub_4     = {{remainder_t[3],dividend_sel[3]}} - {1'b0, divisor_t[3]};
end

always @(posedge clk) begin
    divisor_t[4]  <= divisor_t[3];
    dividend_t[4] <= dividend_t[3];
    mode_sel_t[4] <= mode_sel_t[3];
    if (!stage_sub_4[M]) begin
        merchant_t[4]  <= {merchant_t[3][N_ACT-M-1:0], 1'b1};
        remainder_t[4] <= stage_sub_4[M-1:0];
    end else begin
        merchant_t[4]  <= {merchant_t[3][N_ACT-M-1:0], 1'b0};
        remainder_t[4] <= {remainder_t[3][M-2:0], dividend_sel[3]};
    end
end

always @(*) begin
    dividend_sel[4] = (mode_sel_t[4])? dividend_t[4][0]: dividend_t[4][18];
    stage_sub_5     = {{remainder_t[4], dividend_sel[4]}} - {1'b0, divisor_t[4]};
end

always @(*) begin
    divisor_t[5]  = divisor_t[4];
    dividend_t[5] = dividend_t[4];
    mode_sel_t[5] = mode_sel_t[4];
    if (!stage_sub_5[M]) begin
        merchant_t[5]  = {merchant_t[4][N_ACT-M-1:0], 1'b1};
        remainder_t[5] = stage_sub_5[M-1:0];
    end else begin
        merchant_t[5]  = {merchant_t[4][N_ACT-M-1:0], 1'b0};
        remainder_t[5] = {remainder_t[4][M-2:0], dividend_sel[4]};
    end
end

// for layernorm, we need subtract; for softmax (mode_sel=1), bypass remaining stages.
// From stage6 onward, explicit 24-bit (MAX_WIDTH) data-path for remainder/subtractor.
always @(*) begin
    stage_sub_6 = {{remainder_t[5][MAX_WIDTH-1:0], dividend_t[5][MAX_WIDTH-7]}} - {1'b0, divisor_t[5][MAX_WIDTH-1:0]};
end

always @(*) begin
    divisor_t[6]  = divisor_t[5];
    dividend_t[6] = dividend_t[5];
    mode_sel_t[6] = mode_sel_t[5];
    if (mode_sel_t[5]) begin
        merchant_t[6]  = merchant_t[5];
        remainder_t[6] = remainder_t[5];
    end else if (!stage_sub_6[MAX_WIDTH]) begin
        merchant_t[6]  = {merchant_t[5][N_ACT-M-1:0], 1'b1};
        remainder_t[6] = {{(M-MAX_WIDTH){1'b0}}, stage_sub_6[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[6]  = {merchant_t[5][N_ACT-M-1:0], 1'b0};
        remainder_t[6] = {{(M-MAX_WIDTH){1'b0}}, remainder_t[5][MAX_WIDTH-2:0], dividend_t[5][MAX_WIDTH-7]};
    end
end

always @(*) begin
    stage_sub_7 = {{remainder_t[6][MAX_WIDTH-1:0], dividend_t[6][MAX_WIDTH-8]}} - {1'b0, divisor_t[6][MAX_WIDTH-1:0]};
end

always @(*) begin
    divisor_t[7]  = divisor_t[6];
    dividend_t[7] = dividend_t[6];
    mode_sel_t[7] = mode_sel_t[6];
    if (mode_sel_t[6]) begin
        merchant_t[7]  = merchant_t[6];
        remainder_t[7] = remainder_t[6];
    end else if (!stage_sub_7[MAX_WIDTH]) begin
        merchant_t[7]  = {merchant_t[6][N_ACT-M-1:0], 1'b1};
        remainder_t[7] = {{(M-MAX_WIDTH){1'b0}}, stage_sub_7[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[7]  = {merchant_t[6][N_ACT-M-1:0], 1'b0};
        remainder_t[7] = {{(M-MAX_WIDTH){1'b0}}, remainder_t[6][MAX_WIDTH-2:0], dividend_t[6][MAX_WIDTH-8]};
    end
end

always @(*) begin
    stage_sub_8 = {{remainder_t[7][MAX_WIDTH-1:0], dividend_t[7][MAX_WIDTH-9]}} - {1'b0, divisor_t[7][MAX_WIDTH-1:0]};
end

always @(posedge clk) begin
    divisor_t[8]  <= divisor_t[7];
    dividend_t[8] <= dividend_t[7];
    mode_sel_t[8] <= mode_sel_t[7];
    if (mode_sel_t[7]) begin
        merchant_t[8]  <= merchant_t[7];
        remainder_t[8] <= remainder_t[7];
    end else if (!stage_sub_8[MAX_WIDTH]) begin
        merchant_t[8]  <= {merchant_t[7][N_ACT-M-1:0], 1'b1};
        remainder_t[8] <= {{(M-MAX_WIDTH){1'b0}}, stage_sub_8[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[8]  <= {merchant_t[7][N_ACT-M-1:0], 1'b0};
        remainder_t[8] <= {{(M-MAX_WIDTH){1'b0}}, remainder_t[7][MAX_WIDTH-2:0], dividend_t[7][MAX_WIDTH-9]};
    end
end

always @(*) begin
    stage_sub_9 = {{remainder_t[8][MAX_WIDTH-1:0], dividend_t[8][MAX_WIDTH-10]}} - {1'b0, divisor_t[8][MAX_WIDTH-1:0]};
end

always @(*) begin
    divisor_t[9]  = divisor_t[8];
    dividend_t[9] = dividend_t[8];
    mode_sel_t[9] = mode_sel_t[8];
    if (mode_sel_t[8]) begin
        merchant_t[9]  = merchant_t[8];
        remainder_t[9]  = remainder_t[8];
    end else if (!stage_sub_9[MAX_WIDTH]) begin
        merchant_t[9]  = {merchant_t[8][N_ACT-M-1:0], 1'b1};
        remainder_t[9] = {{(M-MAX_WIDTH){1'b0}}, stage_sub_9[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[9]  = {merchant_t[8][N_ACT-M-1:0], 1'b0};
        remainder_t[9] = {{(M-MAX_WIDTH){1'b0}}, remainder_t[8][MAX_WIDTH-2:0], dividend_t[8][MAX_WIDTH-10]};
    end
end

always @(*) begin
    stage_sub_10 = {{remainder_t[9][MAX_WIDTH-1:0], dividend_t[9][MAX_WIDTH-11]}} - {1'b0, divisor_t[9][MAX_WIDTH-1:0]};
end

always @(*) begin
    divisor_t[10]  = divisor_t[9];
    dividend_t[10] = dividend_t[9];
    mode_sel_t[10] = mode_sel_t[9];
    if (mode_sel_t[9]) begin
        merchant_t[10]  = merchant_t[9];
        remainder_t[10] = remainder_t[9];
    end else if (!stage_sub_10[MAX_WIDTH]) begin
        merchant_t[10]  = {merchant_t[9][N_ACT-M-1:0], 1'b1};
        remainder_t[10] = {{(M-MAX_WIDTH){1'b0}}, stage_sub_10[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[10]  = {merchant_t[9][N_ACT-M-1:0], 1'b0};
        remainder_t[10] = {{(M-MAX_WIDTH){1'b0}}, remainder_t[9][MAX_WIDTH-2:0], dividend_t[9][MAX_WIDTH-11]};
    end
end

always @(*) begin
    stage_sub_11 = {{remainder_t[10][MAX_WIDTH-1:0], dividend_t[10][MAX_WIDTH-12]}} - {1'b0, divisor_t[10][MAX_WIDTH-1:0]};
end

always @(*) begin
    divisor_t[11]  = divisor_t[10];
    dividend_t[11] = dividend_t[10];
    mode_sel_t[11] = mode_sel_t[10];
    if (mode_sel_t[10]) begin
        merchant_t[11]  = merchant_t[10];
        remainder_t[11] = remainder_t[10];
    end else if (!stage_sub_11[MAX_WIDTH]) begin
        merchant_t[11]  = {merchant_t[10][N_ACT-M-1:0], 1'b1};
        remainder_t[11] = {{(M-MAX_WIDTH){1'b0}}, stage_sub_11[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[11]  = {merchant_t[10][N_ACT-M-1:0], 1'b0};
        remainder_t[11] = {{(M-MAX_WIDTH){1'b0}}, remainder_t[10][MAX_WIDTH-2:0], dividend_t[10][MAX_WIDTH-12]};
    end
end

always @(*) begin
    stage_sub_12 = {{remainder_t[11][MAX_WIDTH-1:0], dividend_t[11][MAX_WIDTH-13]}} - {1'b0, divisor_t[11][MAX_WIDTH-1:0]};
end

always @(posedge clk) begin
    divisor_t[12]  <= divisor_t[11];
    dividend_t[12] <= dividend_t[11];
    mode_sel_t[12] <= mode_sel_t[11];
    if (mode_sel_t[11]) begin
        merchant_t[12]  <= merchant_t[11];
        remainder_t[12] <= remainder_t[11];
    end else if (!stage_sub_12[MAX_WIDTH]) begin
        merchant_t[12]  <= {merchant_t[11][N_ACT-M-1:0], 1'b1};
        remainder_t[12] <= {{(M-MAX_WIDTH){1'b0}}, stage_sub_12[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[12]  <= {merchant_t[11][N_ACT-M-1:0], 1'b0};
        remainder_t[12] <= {{(M-MAX_WIDTH){1'b0}}, remainder_t[11][MAX_WIDTH-2:0], dividend_t[11][MAX_WIDTH-13]};
    end
end

always @(*) begin
    stage_sub_13 = {{remainder_t[12][MAX_WIDTH-1:0], dividend_t[12][MAX_WIDTH-14]}} - {1'b0, divisor_t[12][MAX_WIDTH-1:0]};
end

always @(*) begin
    divisor_t[13]  = divisor_t[12];
    dividend_t[13] = dividend_t[12];
    mode_sel_t[13] = mode_sel_t[12];
    if (mode_sel_t[12]) begin
        merchant_t[13]  = merchant_t[12];
        remainder_t[13] = remainder_t[12];
    end else if (!stage_sub_13[MAX_WIDTH]) begin
        merchant_t[13]  = {merchant_t[12][N_ACT-M-1:0], 1'b1};
        remainder_t[13] = {{(M-MAX_WIDTH){1'b0}}, stage_sub_13[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[13]  = {merchant_t[12][N_ACT-M-1:0], 1'b0};
        remainder_t[13] = {{(M-MAX_WIDTH){1'b0}}, remainder_t[12][MAX_WIDTH-2:0], dividend_t[12][MAX_WIDTH-14]};
    end
end

always @(*) begin
    stage_sub_14 = {{remainder_t[13][MAX_WIDTH-1:0], dividend_t[13][MAX_WIDTH-15]}} - {1'b0, divisor_t[13][MAX_WIDTH-1:0]};
end

always @(*) begin
    divisor_t[14]  = divisor_t[13];
    dividend_t[14] = dividend_t[13];
    mode_sel_t[14] = mode_sel_t[13];
    if (mode_sel_t[13]) begin
        merchant_t[14]  = merchant_t[13];
        remainder_t[14] = remainder_t[13];
    end else if (!stage_sub_14[MAX_WIDTH]) begin
        merchant_t[14]  = {merchant_t[13][N_ACT-M-1:0], 1'b1};
        remainder_t[14] = {{(M-MAX_WIDTH){1'b0}}, stage_sub_14[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[14]  = {merchant_t[13][N_ACT-M-1:0], 1'b0};
        remainder_t[14] = {{(M-MAX_WIDTH){1'b0}}, remainder_t[13][MAX_WIDTH-2:0], dividend_t[13][MAX_WIDTH-15]};
    end
end

always @(*) begin
    stage_sub_15 = {{remainder_t[14][MAX_WIDTH-1:0], dividend_t[14][MAX_WIDTH-16]}} - {1'b0, divisor_t[14][MAX_WIDTH-1:0]};
end

always @(*) begin
    divisor_t[15]  = divisor_t[14];
    dividend_t[15] = dividend_t[14];
    mode_sel_t[15] = mode_sel_t[14];
    if (mode_sel_t[14]) begin
        merchant_t[15]  = merchant_t[14];
        remainder_t[15] = remainder_t[14];
    end else if (!stage_sub_15[MAX_WIDTH]) begin
        merchant_t[15]  = {merchant_t[14][N_ACT-M-1:0], 1'b1};
        remainder_t[15] = {{(M-MAX_WIDTH){1'b0}}, stage_sub_15[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[15]  = {merchant_t[14][N_ACT-M-1:0], 1'b0};
        remainder_t[15] = {{(M-MAX_WIDTH){1'b0}}, remainder_t[14][MAX_WIDTH-2:0], dividend_t[14][MAX_WIDTH-16]};
    end
end

always @(*) begin
    stage_sub_16 = {{remainder_t[15][MAX_WIDTH-1:0], dividend_t[15][MAX_WIDTH-17]}} - {1'b0, divisor_t[15][MAX_WIDTH-1:0]};
end

always @(posedge clk) begin
    divisor_t[16]  <= divisor_t[15];
    dividend_t[16] <= dividend_t[15];
    mode_sel_t[16] <= mode_sel_t[15];
    if (mode_sel_t[15]) begin
        merchant_t[16]  <= merchant_t[15];
        remainder_t[16] <= remainder_t[15];
    end else if (!stage_sub_16[MAX_WIDTH]) begin
        merchant_t[16]  <= {merchant_t[15][N_ACT-M-1:0], 1'b1};
        remainder_t[16] <= {{(M-MAX_WIDTH){1'b0}}, stage_sub_16[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[16]  <= {merchant_t[15][N_ACT-M-1:0], 1'b0};
        remainder_t[16] <= {{(M-MAX_WIDTH){1'b0}}, remainder_t[15][MAX_WIDTH-2:0], dividend_t[15][MAX_WIDTH-17]};
    end
end

always @(*) begin
    stage_sub_17 = {{remainder_t[16][MAX_WIDTH-1:0], dividend_t[16][MAX_WIDTH-18]}} - {1'b0, divisor_t[16][MAX_WIDTH-1:0]};
end

always @(*) begin
    divisor_t[17]  = divisor_t[16];
    dividend_t[17] = dividend_t[16];
    mode_sel_t[17] = mode_sel_t[16];
    if (mode_sel_t[16]) begin
        merchant_t[17]  = merchant_t[16];
        remainder_t[17] = remainder_t[16];
    end else if (!stage_sub_17[MAX_WIDTH]) begin
        merchant_t[17]  = {merchant_t[16][N_ACT-M-1:0], 1'b1};
        remainder_t[17] = {{(M-MAX_WIDTH){1'b0}}, stage_sub_17[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[17]  = {merchant_t[16][N_ACT-M-1:0], 1'b0};
        remainder_t[17] = {{(M-MAX_WIDTH){1'b0}}, remainder_t[16][MAX_WIDTH-2:0], dividend_t[16][MAX_WIDTH-18]};
    end
end

always @(*) begin
    stage_sub_18 = {{remainder_t[17][MAX_WIDTH-1:0], dividend_t[17][MAX_WIDTH-19]}} - {1'b0, divisor_t[17][MAX_WIDTH-1:0]};
end

always @(*) begin
    divisor_t[18]  = divisor_t[17];
    dividend_t[18] = dividend_t[17];
    mode_sel_t[18] = mode_sel_t[17];
    if (mode_sel_t[17]) begin
        merchant_t[18]  = merchant_t[17];
        remainder_t[18] = remainder_t[17];
    end else if (!stage_sub_18[MAX_WIDTH]) begin
        merchant_t[18]  = {merchant_t[17][N_ACT-M-1:0], 1'b1};
        remainder_t[18] = {{(M-MAX_WIDTH){1'b0}}, stage_sub_18[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[18]  = {merchant_t[17][N_ACT-M-1:0], 1'b0};
        remainder_t[18] = {{(M-MAX_WIDTH){1'b0}}, remainder_t[17][MAX_WIDTH-2:0], dividend_t[17][MAX_WIDTH-19]};
    end
end

always @(*) begin
    stage_sub_19 = {{remainder_t[18][MAX_WIDTH-1:0], dividend_t[18][MAX_WIDTH-20]}} - {1'b0, divisor_t[18][MAX_WIDTH-1:0]};
end

always @(*) begin
    divisor_t[19]  = divisor_t[18];
    dividend_t[19] = dividend_t[18];
    mode_sel_t[19] = mode_sel_t[18];
    if (mode_sel_t[18]) begin
        merchant_t[19]  = merchant_t[18];
        remainder_t[19] = remainder_t[18];
    end else if (!stage_sub_19[MAX_WIDTH]) begin
        merchant_t[19]  = {merchant_t[18][N_ACT-M-1:0], 1'b1};
        remainder_t[19] = {{(M-MAX_WIDTH){1'b0}}, stage_sub_19[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[19]  = {merchant_t[18][N_ACT-M-1:0], 1'b0};
        remainder_t[19] = {{(M-MAX_WIDTH){1'b0}}, remainder_t[18][MAX_WIDTH-2:0], dividend_t[18][MAX_WIDTH-20]};
    end
end

always @(*) begin
    stage_sub_20 = {{remainder_t[19][MAX_WIDTH-1:0], dividend_t[19][MAX_WIDTH-21]}} - {1'b0, divisor_t[19][MAX_WIDTH-1:0]};
end

always @(posedge clk) begin
    divisor_t[20]  <= divisor_t[19];
    dividend_t[20] <= dividend_t[19];
    mode_sel_t[20] <= mode_sel_t[19];
    if (mode_sel_t[19]) begin
        merchant_t[20]  <= merchant_t[19];
        remainder_t[20] <= remainder_t[19];
    end else if (!stage_sub_20[MAX_WIDTH]) begin
        merchant_t[20]  <= {merchant_t[19][N_ACT-M-1:0], 1'b1};
        remainder_t[20] <= {{(M-MAX_WIDTH){1'b0}}, stage_sub_20[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[20]  <= {merchant_t[19][N_ACT-M-1:0], 1'b0};
        remainder_t[20] <= {{(M-MAX_WIDTH){1'b0}}, remainder_t[19][MAX_WIDTH-2:0], dividend_t[19][MAX_WIDTH-21]};
    end
end

always @(*) begin
    stage_sub_21 = {{remainder_t[20][MAX_WIDTH-1:0], dividend_t[20][MAX_WIDTH-22]}} - {1'b0, divisor_t[20][MAX_WIDTH-1:0]};
end

always @(*) begin
    divisor_t[21]  = divisor_t[20];
    dividend_t[21] = dividend_t[20];
    mode_sel_t[21] = mode_sel_t[20];
    if (mode_sel_t[20]) begin
        merchant_t[21]  = merchant_t[20];
        remainder_t[21] = remainder_t[20];
    end else if (!stage_sub_21[MAX_WIDTH]) begin
        merchant_t[21]  = {merchant_t[20][N_ACT-M-1:0], 1'b1};
        remainder_t[21] = {{(M-MAX_WIDTH){1'b0}}, stage_sub_21[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[21]  = {merchant_t[20][N_ACT-M-1:0], 1'b0};
        remainder_t[21] = {{(M-MAX_WIDTH){1'b0}}, remainder_t[20][MAX_WIDTH-2:0], dividend_t[20][MAX_WIDTH-22]};
    end
end

always @(*) begin
    stage_sub_22 = {{remainder_t[21][MAX_WIDTH-1:0], dividend_t[21][MAX_WIDTH-23]}} - {1'b0, divisor_t[21][MAX_WIDTH-1:0]};
end

always @(*) begin
    divisor_t[22]  = divisor_t[21];
    dividend_t[22] = dividend_t[21];
    mode_sel_t[22] = mode_sel_t[21];
    if (mode_sel_t[21]) begin
        merchant_t[22]  = merchant_t[21];
        remainder_t[22] = remainder_t[21];
    end else if (!stage_sub_22[MAX_WIDTH]) begin
        merchant_t[22]  = {merchant_t[21][N_ACT-M-1:0], 1'b1};
        remainder_t[22] = {{(M-MAX_WIDTH){1'b0}}, stage_sub_22[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[22]  = {merchant_t[21][N_ACT-M-1:0], 1'b0};
        remainder_t[22] = {{(M-MAX_WIDTH){1'b0}}, remainder_t[21][MAX_WIDTH-2:0], dividend_t[21][MAX_WIDTH-23]};
    end
end

always @(*) begin
    stage_sub_23 = {{remainder_t[22][MAX_WIDTH-1:0], dividend_t[22][MAX_WIDTH-24]}} - {1'b0, divisor_t[22][MAX_WIDTH-1:0]};
end

always @(*) begin
    divisor_t[23]  = divisor_t[22];
    dividend_t[23] = dividend_t[22];
    mode_sel_t[23] = mode_sel_t[22];
    if (mode_sel_t[22]) begin
        merchant_t[23]  = merchant_t[22];
        remainder_t[23] = remainder_t[22];
    end else if (!stage_sub_23[MAX_WIDTH]) begin
        merchant_t[23]  = {merchant_t[22][N_ACT-M-1:0], 1'b1};
        remainder_t[23] = {{(M-MAX_WIDTH){1'b0}}, stage_sub_23[MAX_WIDTH-1:0]};
    end else begin
        merchant_t[23]  = {merchant_t[22][N_ACT-M-1:0], 1'b0};
        remainder_t[23] = {{(M-MAX_WIDTH){1'b0}}, remainder_t[22][MAX_WIDTH-2:0], dividend_t[22][MAX_WIDTH-24]};
    end
end
assign merchant  = {{(N-(PIPE_DEPTH+1)){1'b0}}, merchant_t[PIPE_DEPTH][PIPE_DEPTH:0]};
assign remainder = remainder_t[PIPE_DEPTH];

endmodule // div_new
