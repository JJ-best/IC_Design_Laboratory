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
    output wire [5-1:0] sram_addr_a0,
    output wire [5-1:0] sram_addr_a1,
    output wire [5-1:0] sram_addr_a2,
    output wire [5-1:0] sram_addr_a3,
    output wire [5-1:0] sram_addr_b0,
    output wire [5-1:0] sram_addr_b1,
    output wire [5-1:0] sram_addr_b2,
    output wire [5-1:0] sram_addr_b3,
    output wire [6-1:0] sram_addr_c0,
    output wire [6-1:0] sram_addr_c1,
    output wire [6-1:0] sram_addr_c2,
    output wire [6-1:0] sram_addr_c3,
    output wire [6-1:0] sram_addr_d0,
    output wire [6-1:0] sram_addr_d1,
    output wire [6-1:0] sram_addr_d2,
    output wire [6-1:0] sram_addr_d3,
    output wire [8-1:0] sram_raddr_weight,
    output wire [7-1:0] sram_raddr_bias,

    // SRAM write enable outputs (low active)
    output wire sram_wen_a0,
    output wire sram_wen_a1,
    output wire sram_wen_a2,
    output wire sram_wen_a3,
    output wire sram_wen_b0,
    output wire sram_wen_b1,
    output wire sram_wen_b2,
    output wire sram_wen_b3,
    output wire sram_wen_c0,
    output wire sram_wen_c1,
    output wire sram_wen_c2,
    output wire sram_wen_c3,
    output wire sram_wen_d0,
    output wire sram_wen_d1,
    output wire sram_wen_d2,
    output wire sram_wen_d3,

    // SRAM word mask outputs
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a0,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a1,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a2,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a3,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b0,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b1,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b2,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b3,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_c0,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_c1,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_c2,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_c3,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_d0,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_d1,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_d2,
    output wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_d3,

    // SRAM write data outputs
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a0,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a1,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a2,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a3,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b0,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b1,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b2,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b3,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_c0,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_c1,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_c2,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_c3,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_d0,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_d1,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_d2,
    output wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_d3
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
// ===== Top Level Finite State Machine ===== //
localparam IDLE     = 5'd0;
localparam R_BIAS_A = 5'd1;
localparam NORMAL   = 5'd2;
localparam NORMAL_T = 5'd3;
localparam PROJ     = 5'd4;
localparam PROJ_T   = 5'd5;
localparam R_SRAM_C = 5'd6;
localparam PROJ2= 5'd10;

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
            if (sram_b_wen_cnt == 3'd7) begin
                top_state_n = PROJ;
            end else begin
                top_state_n = NORMAL_T;
            end
        end
        PROJ: begin
            if (sram_raddr_weight == 8'd40 && sram_addr_cnt_b == 5'd31) begin
                top_state_n = PROJ_T;
            end else begin
                top_state_n = PROJ;
            end
        end
        PROJ_T: begin
            if (sram_wen_c0 == 0) begin
                top_state_n = R_SRAM_C;
            end else begin
                top_state_n = PROJ_T;
            end
        end
        R_SRAM_C: begin
            top_state_n = R_SRAM_C;
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
    end else if (top_state == PROJ_T)begin
        tmp_cnt <= tmp_cnt + 1;
    end
end
// should be 1 for correct answer
assign valid = (tmp_cnt == 4'b1111)? 0:0;

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

assign sram_addr_a0 = {sram_addr_cnt_a[0], sram_addr_cnt_a[4:1]};
assign sram_addr_a1 = {sram_addr_cnt_a[0], sram_addr_cnt_a[4:1]};
assign sram_addr_a2 = {sram_addr_cnt_a[0], sram_addr_cnt_a[4:1]};
assign sram_addr_a3 = {sram_addr_cnt_a[0], sram_addr_cnt_a[4:1]};

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
    case (cnt8)
        3: begin
            for (k=0; k<8; k=k+1) begin
                a_bank_dat[k] = a_bank0_reg_h[k];
            end
            for (k=8; k<16; k=k+1) begin
                a_bank_dat[k] = a_bank0_reg_l[k-8];
            end
        end
        4: begin
            for (k=0; k<8; k=k+1) begin
                a_bank_dat[k] = a_bank0_reg_h[k];
            end
            for (k=8; k<16; k=k+1) begin
                a_bank_dat[k] = a_bank0_reg_l[k-8];
            end
        end
        5: begin
            for (k=0; k<8; k=k+1) begin
                a_bank_dat[k] = a_bank1_reg_h[k];
            end
            for (k=8; k<16; k=k+1) begin
                a_bank_dat[k] = a_bank1_reg_l[k-8];
            end
        end
        6: begin
            for (k=0; k<8; k=k+1) begin
                a_bank_dat[k] = a_bank1_reg_h[k];
            end
            for (k=8; k<16; k=k+1) begin
                a_bank_dat[k] = a_bank1_reg_l[k-8];
            end
        end
        7: begin
            for (k=0; k<8; k=k+1) begin
                a_bank_dat[k] = a_bank2_reg_h[k];
            end
            for (k=8; k<16; k=k+1) begin
                a_bank_dat[k] = a_bank2_reg_l[k-8];
            end
        end
        8: begin
            for (k=0; k<8; k=k+1) begin
                a_bank_dat[k] = a_bank2_reg_h[k];
            end
            for (k=8; k<16; k=k+1) begin
                a_bank_dat[k] = a_bank2_reg_l[k-8];
            end
        end
        0: begin
            for (k=0; k<8; k=k+1) begin
                a_bank_dat[k] = a_bank3_reg_h[k];
            end
            for (k=8; k<16; k=k+1) begin
                a_bank_dat[k] = a_bank3_reg_l[k-8];
            end
        end
        1: begin
            for (k=0; k<8; k=k+1) begin
                a_bank_dat[k] = a_bank3_reg_h[k];
            end
            for (k=8; k<16; k=k+1) begin
                a_bank_dat[k] = a_bank3_reg_l[k-8];
            end
        end
        default: begin
            for (k=0; k<16; k=k+1) begin
                a_bank_dat[k] = 0;
            end
            
        end
    endcase
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
   case (cnt8)
    4: begin
        for (k=0; k<8; k=k+1) begin
            a_bank_minux_x[k] = {a_bank0_reg_h[k], 4'b0};
        end
        for (k=8; k<16; k=k+1) begin
            a_bank_minux_x[k] = {a_bank0_reg_l[k-8], 4'b0};
        end
    end
    5: begin
        for (k=0; k<8; k=k+1) begin
            a_bank_minux_x[k] = {a_bank0_reg_h[k], 4'b0};
        end
        for (k=8; k<16; k=k+1) begin
            a_bank_minux_x[k] = {a_bank0_reg_l[k-8], 4'b0};
        end
    end
    6: begin
        for (k=0; k<8; k=k+1) begin
            a_bank_minux_x[k] = {a_bank1_reg_h[k], 4'b0};
        end
        for (k=8; k<16; k=k+1) begin
            a_bank_minux_x[k] = {a_bank1_reg_l[k-8], 4'b0};
        end
    end
    7: begin
        for (k=0; k<8; k=k+1) begin
            a_bank_minux_x[k] = {a_bank1_reg_h[k], 4'b0};
        end
        for (k=8; k<16; k=k+1) begin
            a_bank_minux_x[k] = {a_bank1_reg_l[k-8], 4'b0};
        end
    end
    8: begin
        for (k=0; k<8; k=k+1) begin
            a_bank_minux_x[k] = {a_bank2_reg_h[k], 4'b0};
        end
        for (k=8; k<16; k=k+1) begin
            a_bank_minux_x[k] = {a_bank2_reg_l[k-8], 4'b0};
        end
    end
    0: begin
        for (k=0; k<8; k=k+1) begin
            a_bank_minux_x[k] = {a_bank2_reg_h[k], 4'b0};
        end
        for (k=8; k<16; k=k+1) begin
            a_bank_minux_x[k] = {a_bank2_reg_l[k-8], 4'b0};
        end
    end
    1: begin
        for (k=0; k<8; k=k+1) begin
            a_bank_minux_x[k] = {a_bank3_reg_h[k], 4'b0};
        end
        for (k=8; k<16; k=k+1) begin
            a_bank_minux_x[k] = {a_bank3_reg_l[k-8], 4'b0};
        end
    end
    2: begin
        for (k=0; k<8; k=k+1) begin
            a_bank_minux_x[k] = {a_bank_reg_h_d[k], 4'b0};
        end
        for (k=8; k<16; k=k+1) begin
            a_bank_minux_x[k] = {a_bank3_reg_l[k-8], 4'b0};
        end
    end
    default: begin
        for (k=0; k<16; k=k+1) begin
            a_bank_minux_x[k] = 0;
        end
    end
        
   endcase 
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

    token_mae = a_bank_abs[0]  + a_bank_abs[1]  + a_bank_abs[2]  + a_bank_abs[3]  + 
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

wire signed[17:0] token_mae_abs;
wire [23:0] token_nor[0:7];
reg signed[BW_PER_ACT-1:0] token_nor_t[0:7];
reg [BW_PER_ACT-1:0] token_nor_reg[0:7];
reg signed[13:0] a_bank_abs_sel[0:7];
reg sel_toggle; // this signal toggle when valid_2 is high
reg valid_2_d1;
reg valid_2_d2;
reg valid_2_d3;
reg valid_2_d4;
reg a_bank_minus_sign_d1[0:15];
reg a_bank_minus_sign_d2[0:15];
reg a_bank_minus_sign_d3[0:15];
reg a_bank_minus_sign_d4[0:15];
reg token_mae_sign_d1;
reg token_mae_sign_d2;
reg token_mae_sign_d3;
reg token_mae_sign_d4;
reg sel_toggle_d1;
reg sel_toggle_d2;
reg sel_toggle_d3;
reg sel_toggle_d4;

always @(posedge clk) begin
    if (valid_2) begin
        sel_toggle <= ~sel_toggle;
    end else begin
        sel_toggle <= 0;
    end
end

// divider pipelien 4-stage, delay 3 cycle
always @(posedge clk) begin
    valid_2_d1 <= valid_2;
    valid_2_d2 <= valid_2_d1;
    valid_2_d3 <= valid_2_d2;
    valid_2_d4 <= valid_2_d3;
    for (k=0; k<16; k=k+1) begin
        a_bank_minus_sign_d1[k] <= a_bank_minus[k][13];
        a_bank_minus_sign_d2[k] <= a_bank_minus_sign_d1[k];
        a_bank_minus_sign_d3[k] <= a_bank_minus_sign_d2[k];
        a_bank_minus_sign_d4[k] <= a_bank_minus_sign_d3[k];
    end
    token_mae_sign_d1 <= token_mae[17];
    token_mae_sign_d2 <= token_mae_sign_d1;
    token_mae_sign_d3 <= token_mae_sign_d2;
    token_mae_sign_d4 <= token_mae_sign_d3;
    sel_toggle_d1 <= sel_toggle;
    sel_toggle_d2 <= sel_toggle_d1;
    sel_toggle_d3 <= sel_toggle_d2;
    sel_toggle_d4 <= sel_toggle_d3;
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

assign token_mae_abs = (token_mae[17])? ~token_mae + 1: token_mae;

DW_div_pipe_inst div0(
    .clk(clk), 
    .inst_rst_n(1'b0),     // non rst mode
    .inst_en(1'b0),        // non en  mode
    .inst_a({a_bank_abs_sel[0], 4'b0, 6'b0}), 
    .inst_b(token_mae_abs),
    .quotient_inst(token_nor[0]),   
    .remainder_inst(),  // non used
    .divide_by_0_inst() // non used
);

DW_div_pipe_inst div1(
    .clk(clk), 
    .inst_rst_n(1'b0),     // non rst mode
    .inst_en(1'b0),        // non en  mode
    .inst_a({a_bank_abs_sel[1], 4'b0, 6'b0}), 
    .inst_b(token_mae_abs),
    .quotient_inst(token_nor[1]),   
    .remainder_inst(),  // non used
    .divide_by_0_inst() // non used
);

DW_div_pipe_inst div2(
    .clk(clk), 
    .inst_rst_n(1'b0),     // non rst mode
    .inst_en(1'b0),        // non en  mode
    .inst_a({a_bank_abs_sel[2], 4'b0, 6'b0}), 
    .inst_b(token_mae_abs),
    .quotient_inst(token_nor[2]),   
    .remainder_inst(),  // non used
    .divide_by_0_inst() // non used
);

DW_div_pipe_inst div3(
    .clk(clk), 
    .inst_rst_n(1'b0),     // non rst mode
    .inst_en(1'b0),        // non en  mode
    .inst_a({a_bank_abs_sel[3], 4'b0, 6'b0}), 
    .inst_b(token_mae_abs),
    .quotient_inst(token_nor[3]),   
    .remainder_inst(),  // non used
    .divide_by_0_inst() // non used
);

DW_div_pipe_inst div4(
    .clk(clk), 
    .inst_rst_n(1'b0),     // non rst mode
    .inst_en(1'b0),        // non en  mode
    .inst_a({a_bank_abs_sel[4], 4'b0, 6'b0}), 
    .inst_b(token_mae_abs),
    .quotient_inst(token_nor[4]),   
    .remainder_inst(),  // non used
    .divide_by_0_inst() // non used
);

DW_div_pipe_inst div5(
    .clk(clk), 
    .inst_rst_n(1'b0),     // non rst mode
    .inst_en(1'b0),        // non en  mode
    .inst_a({a_bank_abs_sel[5], 4'b0, 6'b0}), 
    .inst_b(token_mae_abs),
    .quotient_inst(token_nor[5]),   
    .remainder_inst(),  // non used
    .divide_by_0_inst() // non used
);

DW_div_pipe_inst div6(
    .clk(clk), 
    .inst_rst_n(1'b0),     // non rst mode
    .inst_en(1'b0),        // non en  mode
    .inst_a({a_bank_abs_sel[6], 4'b0, 6'b0}), 
    .inst_b(token_mae_abs),
    .quotient_inst(token_nor[6]),   
    .remainder_inst(),  // non used
    .divide_by_0_inst() // non used
);

DW_div_pipe_inst div7(
    .clk(clk), 
    .inst_rst_n(1'b0),     // non rst mode
    .inst_en(1'b0),        // non en  mode
    .inst_a({a_bank_abs_sel[7], 4'b0, 6'b0}), 
    .inst_b(token_mae_abs),
    .quotient_inst(token_nor[7]),   
    .remainder_inst(),  // non used
    .divide_by_0_inst() // non used
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
        if (!sel_toggle_d4) begin
            token_nor_t[k] = (!a_bank_minus_sign_d4[k] && !token_mae_sign_d4)? token_nor_reg[k]: ~token_nor_reg[k]+1'b1;
        end else begin
            token_nor_t[k] = (!a_bank_minus_sign_d4[k+8] && !token_mae_sign_d4)? token_nor_reg[k]: ~token_nor_reg[k]+1'b1;
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
        if (!sel_toggle_d4) begin
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
        if (!sel_toggle_d4) begin
             token_x_nor_result[k] <= token_x_nor_weight[k] + {{4{bias_reg[k][BW_PER_ACT-1]}}, bias_reg[k], 6'b0};
        end else begin
            token_x_nor_result[k] <= token_x_nor_weight[k] + {{4{bias_reg[k+8][BW_PER_ACT-1]}}, bias_reg[k+8], 6'b0};
        end
    end
    valid_3 <= valid_2_d4;
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
assign sram_wdata_b0 = b_bank_w;
assign sram_wdata_b1 = b_bank_w;
assign sram_wdata_b2 = b_bank_w;
assign sram_wdata_b3 = b_bank_w;

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
assign b_msb_addr = ~sel_toggle_d4;
always @(posedge clk) begin
    if (!srst_n) begin
        b_base_addr_cnt_b <= 0;
    end else if (!valid_3 && top_state == NORMAL && (sram_addr_cnt_a != 5'd1) && (sram_addr_cnt_a != 5'd0)) begin
        b_base_addr_cnt_b <= b_base_addr_cnt_b + 1;
    end else if (top_state == NORMAL | top_state == NORMAL_T) begin
        b_base_addr_cnt_b <= b_base_addr_cnt_b;
    end else begin
        b_base_addr_cnt_b <= 0;
    end
end
assign b_addr_norm = {b_msb_addr, b_base_addr_cnt_b};
assign sram_addr_b0 = (top_state == NORMAL || top_state == NORMAL_T)? b_addr_norm: {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};
assign sram_addr_b1 = (top_state == NORMAL || top_state == NORMAL_T)? b_addr_norm: {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};
assign sram_addr_b2 = (top_state == NORMAL || top_state == NORMAL_T)? b_addr_norm: {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};
assign sram_addr_b3 = (top_state == NORMAL || top_state == NORMAL_T)? b_addr_norm: {sram_addr_cnt_b[0], sram_addr_cnt_b[4:1]};

// SRAM B can be write if valid_3, low active write

always @(posedge clk) begin
    if (valid_3) begin
        sram_b_wen_cnt <= sram_b_wen_cnt + 1;
    end else begin
        sram_b_wen_cnt <= 0;
    end
end
assign sram_wen_b0 = !(valid_3 && sram_b_wen_cnt[2:1]==2'b00);
assign sram_wen_b1 = !(valid_3 && sram_b_wen_cnt[2:1]==2'b01);
assign sram_wen_b2 = !(valid_3 && sram_b_wen_cnt[2:1]==2'b10);
assign sram_wen_b3 = !(valid_3 && sram_b_wen_cnt[2:1]==2'b11);
assign sram_wordmask_b0 = 8'b0;
assign sram_wordmask_b1 = 8'b0;
assign sram_wordmask_b2 = 8'b0;
assign sram_wordmask_b3 = 8'b0;



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
    if (top_state == PROJ) begin
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

reg [4:0]col_cnt;
reg phase;
always @(posedge clk) begin
    if (!srst_n) begin
        weight_addr_cnt <= 1;
    end else if (phase && col_cnt==5'd31) begin
        weight_addr_cnt <= weight_addr_cnt_n;
    end
end
always @(*) begin
    if (top_state == PROJ) begin
        case (weight_addr_cnt)
            8'd8:    weight_addr_cnt_n = 8'd17;
            8'd24:   weight_addr_cnt_n = 8'd33;
            8'd40:   weight_addr_cnt_n = 8'd0 ;
            default: weight_addr_cnt_n = weight_addr_cnt + 1;
        endcase
    end else if (top_state == PROJ2) begin
        case (weight_addr_cnt)
            8'd16:   weight_addr_cnt_n = 8'd25;
            8'd32:   weight_addr_cnt_n = 8'd41;
            8'd48:   weight_addr_cnt_n = 8'd0 ;
            default: weight_addr_cnt_n = weight_addr_cnt + 1;
        endcase
    end else begin
        weight_addr_cnt_n = 0;
    end
end


always @(posedge clk) begin
    if (!srst_n) begin
        col_cnt <= 0;
    end else if (top_state == PROJ) begin
        col_cnt <= col_cnt + 1;
    end else begin
        col_cnt <= 0;
    end
end
always @(posedge clk) begin
    if (!srst_n) begin
        phase <= 0;
    end else if (top_state == PROJ) begin
        phase <= ~phase;
    end else begin
        phase <= 0;
    end
end
assign sram_raddr_weight = (top_state==PROJ)? weight_addr_cnt:0;



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

// 32 multiplier, this part may use sram A multiplier to optimize resource using
// do optimize later
always @(*) begin
    for (i=0; i<8; i=i+1) begin
        bank0_proj_mul_n[i] = b_bank0_dat[i] * weight_sel[i];
        bank1_proj_mul_n[i] = b_bank1_dat[i] * weight_sel[i];
        bank2_proj_mul_n[i] = b_bank2_dat[i] * weight_sel[i];
        bank3_proj_mul_n[i] = b_bank3_dat[i] * weight_sel[i];
    end
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
    if (phase) begin
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
        valid_4 <= phase;
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

wire[5:0] sram_addr_cnt_c;
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
    end
end

assign sram_addr_cnt_c = sram_c_proj_base + sram_c_block_cnt;

assign sram_addr_c0 = (top_state == PROJ | top_state == PROJ_T)? sram_addr_cnt_c: sramc_addr;
assign sram_addr_c1 = (top_state == PROJ | top_state == PROJ_T)? sram_addr_cnt_c: sramc_addr;
assign sram_addr_c2 = (top_state == PROJ | top_state == PROJ_T)? sram_addr_cnt_c: sramc_addr;
assign sram_addr_c3 = (top_state == PROJ | top_state == PROJ_T)? sram_addr_cnt_c: sramc_addr;

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

// since Q(addr 0-15), K(addr 16-32), V(addr 33-47) store in sram C
// the sram C reading sequence is(fist chunk):

// first 64 cycle
// Q token0 * K token 0~63
// addr0 -> addr16 -> addr17 -> addr18 -> ... -> addr32
// Q token1 * K token 0~63
// addr0 -> addr16 -> addr17 -> addr18 -> ... -> addr32
// Q token2 * K token 0~63
// addr0 -> addr16 -> addr17 -> addr18 -> ... -> addr32
// Q token3 * K token 0~63
// addr0 -> addr16 -> addr17 -> addr18 -> ... -> addr32

// second 64 cycle
// Q token4 * K token 0~63
// addr1 -> addr16 -> addr17 -> addr18 -> ... -> addr32
// Q token5 * K token 0~63
// addr1 -> addr16 -> addr17 -> addr18 -> ... -> addr32
// Q token6 * K token 0~63
// addr1 -> addr16 -> addr17 -> addr18 -> ... -> addr32
// Q token7 * K token 0~63
// addr1 -> addr16 -> addr17 -> addr18 -> ... -> addr32

// third 64 cycle
// Q token8  * K token 0~63
// addr2 -> addr16 -> addr17 -> addr18 -> ... -> addr32
// Q token9  * K token 0~63
// addr2 -> addr16 -> addr17 -> addr18 -> ... -> addr32
// Q token10 * K token 0~63
// addr2 -> addr16 -> addr17 -> addr18 -> ... -> addr32
// Q token11 * K token 0~63
// addr2 -> addr16 -> addr17 -> addr18 -> ... -> addr32

// fourth 64 cycle
// Q token12 * K token 0~63
// addr3 -> addr16 -> addr17 -> addr18 -> ... -> addr32
// Q token13 * K token 0~63
// addr3 -> addr16 -> addr17 -> addr18 -> ... -> addr32
// Q token14 * K token 0~63
// addr3 -> addr16 -> addr17 -> addr18 -> ... -> addr32
// Q token15 * K token 0~63
// addr3 -> addr16 -> addr17 -> addr18 -> ... -> addr32

// Totally 256 cycle finish 1 chunk, we have 4 chunk to finish
// first chunk (addr0 , 1 , 2 , 3)
// second chunk(addr4 , 5 , 6 , 7)
// third chunk (addr8 , 9 , 10, 11)
// fourth chunk(addr12, 13, 14, 15)
reg [4:0] sramc_addr_cnt;

always @(posedge clk) begin
    if (!srst_n) begin
        sramc_addr_cnt <= 0;
    end else if (top_state == R_SRAM_C) begin
        sramc_addr_cnt <= sramc_addr_cnt + 1;
    end else begin
        sramc_addr_cnt <= 0;
    end
end
assign sramc_addr = {sramc_addr_cnt[0], sramc_addr_cnt[4:1]};


reg signed[(BW_PER_ACT-1):0] c_bank0_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] c_bank1_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] c_bank2_dat[0:(CH_NUM-1)];
reg signed[(BW_PER_ACT-1):0] c_bank3_dat[0:(CH_NUM-1)];

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
reg signed [9:0] c_bank0_dat_reg[0:7];
reg signed [9:0] c_bank1_dat_reg[0:7];
reg signed [9:0] c_bank2_dat_reg[0:7];
reg signed [9:0] c_bank3_dat_reg[0:7];
always @(posedge clk) begin
    if (sramc_addr[4]) begin // only store matrix Q
        for (k=0; k<8; k=k+1) begin
            c_bank0_dat_reg[k] <= c_bank0_dat[k];
            c_bank1_dat_reg[k] <= c_bank1_dat[k];
            c_bank2_dat_reg[k] <= c_bank2_dat[k];
            c_bank3_dat_reg[k] <= c_bank3_dat[k];
        end
    end
end

reg valid_6;
reg valid_6_d;
always @(posedge clk) begin
    if (top_state == R_SRAM_C) begin
        valid_6 <= ~valid_6;
    end else begin
        valid_6 <= 0;
    end
end
always @(posedge clk) begin
    valid_6_d <= valid_6;
end


// ===== 9. Multiply each result with 1 / √chead ===== //
// ===== 10. Quantize the result to 10-bits and write the result to SRAM D. ===== //


endmodule



module DW_div_pipe_inst(clk, inst_rst_n, inst_en, inst_a, inst_b,
                        quotient_inst, remainder_inst, divide_by_0_inst );

  parameter inst_a_width = 24;
  parameter inst_b_width = 18;
  parameter inst_tc_mode = 0; // signed: 1 unsigned: 0
  parameter inst_rem_mode = 1;
  parameter inst_num_stages = 4;
  parameter inst_stall_mode = 0;
  parameter inst_rst_mode = 0;
  parameter inst_op_iso_mode = 0;

  input clk;
  input inst_rst_n;
  input inst_en;
  input [inst_a_width-1 : 0] inst_a;
  input [inst_b_width-1 : 0] inst_b;
  output [inst_a_width-1 : 0] quotient_inst;
  output [inst_b_width-1 : 0] remainder_inst;
  output divide_by_0_inst;

  // Instance of DW_div_pipe
  DW_div_pipe #(inst_a_width,   inst_b_width,   inst_tc_mode,  inst_rem_mode,
                inst_num_stages,   inst_stall_mode,   inst_rst_mode,   inst_op_iso_mode) 
    U1 (.clk(clk),   .rst_n(inst_rst_n),   .en(inst_en),
        .a(inst_a),   .b(inst_b),   .quotient(quotient_inst),
        .remainder(remainder_inst),   .divide_by_0(divide_by_0_inst) );
endmodule
