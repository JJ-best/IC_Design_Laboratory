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

// ===== Top Level Finite State Machine ===== //
localparam IDLE     = 5'd0;
localparam R_SRAM_A = 5'd1;
localparam NORM     = 5'd2;
localparam W_SRAM_B = 5'd3;

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
                top_state_n = R_SRAM_A;
            end else begin
                top_state_n = IDLE;
            end
        end
        R_SRAM_A: begin
            top_state_n = top_state;
        end
        default: begin
           top_state_n = IDLE; 
        end
    endcase
end

// ===== read the patched embedded from SRAM A ===== //
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

// SRAM A addr controller
reg [4:0] sram_addr_cnt_a;
// SRAM A is read only
assign sram_wen_a0 = 1'b1;
assign sram_wen_a1 = 1'b1;
assign sram_wen_a2 = 1'b1;
assign sram_wen_a3 = 1'b1;

always @(posedge clk) begin
    if (top_state == R_SRAM_A) begin
        sram_addr_cnt_a <= sram_addr_cnt_a + 1;
    end else begin
        sram_addr_cnt_a <= 0;
    end
end

assign sram_addr_a0 = {sram_addr_cnt_a[0], sram_addr_cnt_a[4:1]};
assign sram_addr_a1 = {sram_addr_cnt_a[0], sram_addr_cnt_a[4:1]};
assign sram_addr_a2 = {sram_addr_cnt_a[0], sram_addr_cnt_a[4:1]};
assign sram_addr_a3 = {sram_addr_cnt_a[0], sram_addr_cnt_a[4:1]};

// ----- debug signal ----- //
reg [(BW_PER_ACT-1):0] a_bank0_dat[0:(CH_NUM-1)];
reg [(BW_PER_ACT-1):0] a_bank1_dat[0:(CH_NUM-1)];
reg [(BW_PER_ACT-1):0] a_bank2_dat[0:(CH_NUM-1)];
reg [(BW_PER_ACT-1):0] a_bank3_dat[0:(CH_NUM-1)];


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
reg [BW_PER_ACT-1:0] a_bank0_reg_h [0:CH_NUM-1];
reg [BW_PER_ACT-1:0] a_bank1_reg_h [0:CH_NUM-1];
reg [BW_PER_ACT-1:0] a_bank2_reg_h [0:CH_NUM-1];
reg [BW_PER_ACT-1:0] a_bank3_reg_h [0:CH_NUM-1];
reg [BW_PER_ACT-1:0] a_bank0_reg_l [0:CH_NUM-1];
reg [BW_PER_ACT-1:0] a_bank1_reg_l [0:CH_NUM-1];
reg [BW_PER_ACT-1:0] a_bank2_reg_l [0:CH_NUM-1];
reg [BW_PER_ACT-1:0] a_bank3_reg_l [0:CH_NUM-1];

reg valid_1;

// ---- bank0 ---- //
always @(posedge clk) begin
    if (sram_addr_a0[4] == 1'b1) begin
        a_bank0_reg_h[0] <= a_bank0_dat[0];
        a_bank0_reg_h[1] <= a_bank0_dat[1];
        a_bank0_reg_h[2] <= a_bank0_dat[2];
        a_bank0_reg_h[3] <= a_bank0_dat[3];
        a_bank0_reg_h[4] <= a_bank0_dat[4];
        a_bank0_reg_h[5] <= a_bank0_dat[5];
        a_bank0_reg_h[6] <= a_bank0_dat[6];
        a_bank0_reg_h[7] <= a_bank0_dat[7];
        valid_1 <= 1;
    end
    if (sram_addr_a0[4] == 1'b0) begin
        a_bank0_reg_l[0] <= a_bank0_dat[0];
        a_bank0_reg_l[1] <= a_bank0_dat[1];
        a_bank0_reg_l[2] <= a_bank0_dat[2];
        a_bank0_reg_l[3] <= a_bank0_dat[3];
        a_bank0_reg_l[4] <= a_bank0_dat[4];
        a_bank0_reg_l[5] <= a_bank0_dat[5];
        a_bank0_reg_l[6] <= a_bank0_dat[6];
        a_bank0_reg_l[7] <= a_bank0_dat[7];
        valid_1 <= 0;
    end
end

// ---- bank1 ---- //
always @(posedge clk) begin
    if (sram_addr_a1[4] == 1'b1) begin
        a_bank1_reg_h[0] <= a_bank1_dat[0];
        a_bank1_reg_h[1] <= a_bank1_dat[1];
        a_bank1_reg_h[2] <= a_bank1_dat[2];
        a_bank1_reg_h[3] <= a_bank1_dat[3];
        a_bank1_reg_h[4] <= a_bank1_dat[4];
        a_bank1_reg_h[5] <= a_bank1_dat[5];
        a_bank1_reg_h[6] <= a_bank1_dat[6];
        a_bank1_reg_h[7] <= a_bank1_dat[7];
    end
    if (sram_addr_a1[4] == 1'b0) begin
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
    if (sram_addr_a2[4] == 1'b1) begin
        a_bank2_reg_h[0] <= a_bank2_dat[0];
        a_bank2_reg_h[1] <= a_bank2_dat[1];
        a_bank2_reg_h[2] <= a_bank2_dat[2];
        a_bank2_reg_h[3] <= a_bank2_dat[3];
        a_bank2_reg_h[4] <= a_bank2_dat[4];
        a_bank2_reg_h[5] <= a_bank2_dat[5];
        a_bank2_reg_h[6] <= a_bank2_dat[6];
        a_bank2_reg_h[7] <= a_bank2_dat[7];
    end
    if (sram_addr_a2[4] == 1'b0) begin
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
    if (sram_addr_a3[4] == 1'b1) begin
        a_bank3_reg_h[0] <= a_bank3_dat[0];
        a_bank3_reg_h[1] <= a_bank3_dat[1];
        a_bank3_reg_h[2] <= a_bank3_dat[2];
        a_bank3_reg_h[3] <= a_bank3_dat[3];
        a_bank3_reg_h[4] <= a_bank3_dat[4];
        a_bank3_reg_h[5] <= a_bank3_dat[5];
        a_bank3_reg_h[6] <= a_bank3_dat[6];
        a_bank3_reg_h[7] <= a_bank3_dat[7];
    end
    if (sram_addr_a3[4] == 1'b0) begin
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

// ===== normalization (computation per token) ===== //

// ----- token mean ----- //
// token_sum = Σ x_i,  i = 0~15 (8 from _dat + 8 from _reg)
// token_mean μ = token_sum / 16   // divide by 16

// in sram A, data(1-bit sign + 3-bit integer + 6-bit fraction)
// after addition 16 number, the sum is (1-bit sign + 7-bit integer + 6-bit fraction)
// then to get mean, view the sum as (1-bit sign + 3-bit integer + 10-bit fraction)
reg [BW_PER_ACT+3:0] token0_mean;
reg [BW_PER_ACT+3:0] token1_mean;
reg [BW_PER_ACT+3:0] token2_mean;
reg [BW_PER_ACT+3:0] token3_mean;
reg valid_2;

always @(posedge clk) begin
    if (valid_1) begin
        // token0 -> bank0
    token0_mean <= a_bank0_dat[0] + a_bank0_dat[1] + a_bank0_dat[2] + a_bank0_dat[3]
                + a_bank0_dat[4] + a_bank0_dat[5] + a_bank0_dat[6] + a_bank0_dat[7]
                + a_bank0_reg_h[0] + a_bank0_reg_h[1] + a_bank0_reg_h[2] + a_bank0_reg_h[3]
                + a_bank0_reg_h[4] + a_bank0_reg_h[5] + a_bank0_reg_h[6] + a_bank0_reg_h[7];

    // token1 -> bank1
    token1_mean <= a_bank1_dat[0] + a_bank1_dat[1] + a_bank1_dat[2] + a_bank1_dat[3]
                + a_bank1_dat[4] + a_bank1_dat[5] + a_bank1_dat[6] + a_bank1_dat[7]
                + a_bank1_reg_h[0] + a_bank1_reg_h[1] + a_bank1_reg_h[2] + a_bank1_reg_h[3]
                + a_bank1_reg_h[4] + a_bank1_reg_h[5] + a_bank1_reg_h[6] + a_bank1_reg_h[7];

    // token2 -> bank2
    token2_mean <= a_bank2_dat[0] + a_bank2_dat[1] + a_bank2_dat[2] + a_bank2_dat[3]
                + a_bank2_dat[4] + a_bank2_dat[5] + a_bank2_dat[6] + a_bank2_dat[7]
                + a_bank2_reg_h[0] + a_bank2_reg_h[1] + a_bank2_reg_h[2] + a_bank2_reg_h[3]
                + a_bank2_reg_h[4] + a_bank2_reg_h[5] + a_bank2_reg_h[6] + a_bank2_reg_h[7];

    // token3 -> bank3
    token3_mean <= a_bank3_dat[0] + a_bank3_dat[1] + a_bank3_dat[2] + a_bank3_dat[3]
                + a_bank3_dat[4] + a_bank3_dat[5] + a_bank3_dat[6] + a_bank3_dat[7]
                + a_bank3_reg_h[0] + a_bank3_reg_h[1] + a_bank3_reg_h[2] + a_bank3_reg_h[3]
                + a_bank3_reg_h[4] + a_bank3_reg_h[5] + a_bank3_reg_h[6] + a_bank3_reg_h[7];
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

reg [13:0] a_bank0_minus[0:15];
reg [13:0] a_bank1_minus[0:15];
reg [13:0] a_bank2_minus[0:15];
reg [13:0] a_bank3_minus[0:15];
reg [13:0] a_bank0_abs[0:15];
reg [13:0] a_bank1_abs[0:15];
reg [13:0] a_bank2_abs[0:15];
reg [13:0] a_bank3_abs[0:15];
reg [17:0]token0_mae;
reg [17:0]token1_mae;
reg [17:0]token2_mae;
reg [17:0]token3_mae;
always @(*) begin
    a_bank0_minus[0]  = {a_bank0_reg_h[0], 4'b0} - token0_mean; // ch0
    a_bank0_minus[1]  = {a_bank0_reg_h[1], 4'b0} - token0_mean; // ch1
    a_bank0_minus[2]  = {a_bank0_reg_h[2], 4'b0} - token0_mean; // ch2
    a_bank0_minus[3]  = {a_bank0_reg_h[3], 4'b0} - token0_mean; // ch3
    a_bank0_minus[4]  = {a_bank0_reg_h[4], 4'b0} - token0_mean; // ch4
    a_bank0_minus[5]  = {a_bank0_reg_h[5], 4'b0} - token0_mean; // ch5
    a_bank0_minus[6]  = {a_bank0_reg_h[6], 4'b0} - token0_mean; // ch6
    a_bank0_minus[7]  = {a_bank0_reg_h[7], 4'b0} - token0_mean; // ch7

    a_bank0_minus[8]  = {a_bank0_reg_l[0], 4'b0} - token0_mean; // ch8
    a_bank0_minus[9]  = {a_bank0_reg_l[1], 4'b0} - token0_mean; // ch9
    a_bank0_minus[10] = {a_bank0_reg_l[2], 4'b0} - token0_mean; // ch10
    a_bank0_minus[11] = {a_bank0_reg_l[3], 4'b0} - token0_mean; // ch11
    a_bank0_minus[12] = {a_bank0_reg_l[4], 4'b0} - token0_mean; // ch12
    a_bank0_minus[13] = {a_bank0_reg_l[5], 4'b0} - token0_mean; // ch13
    a_bank0_minus[14] = {a_bank0_reg_l[6], 4'b0} - token0_mean; // ch14
    a_bank0_minus[15] = {a_bank0_reg_l[7], 4'b0} - token0_mean; // ch15

    a_bank1_minus[0]  = {a_bank1_reg_h[0], 4'b0} - token1_mean;
    a_bank1_minus[1]  = {a_bank1_reg_h[1], 4'b0} - token1_mean;
    a_bank1_minus[2]  = {a_bank1_reg_h[2], 4'b0} - token1_mean;
    a_bank1_minus[3]  = {a_bank1_reg_h[3], 4'b0} - token1_mean;
    a_bank1_minus[4]  = {a_bank1_reg_h[4], 4'b0} - token1_mean;
    a_bank1_minus[5]  = {a_bank1_reg_h[5], 4'b0} - token1_mean;
    a_bank1_minus[6]  = {a_bank1_reg_h[6], 4'b0} - token1_mean;
    a_bank1_minus[7]  = {a_bank1_reg_h[7], 4'b0} - token1_mean;
    a_bank1_minus[8]  = {a_bank1_reg_l[0], 4'b0} - token1_mean;
    a_bank1_minus[9]  = {a_bank1_reg_l[1], 4'b0} - token1_mean;
    a_bank1_minus[10] = {a_bank1_reg_l[2], 4'b0} - token1_mean;
    a_bank1_minus[11] = {a_bank1_reg_l[3], 4'b0} - token1_mean;
    a_bank1_minus[12] = {a_bank1_reg_l[4], 4'b0} - token1_mean;
    a_bank1_minus[13] = {a_bank1_reg_l[5], 4'b0} - token1_mean;
    a_bank1_minus[14] = {a_bank1_reg_l[6], 4'b0} - token1_mean;
    a_bank1_minus[15] = {a_bank1_reg_l[7], 4'b0} - token1_mean;

    a_bank2_minus[0]  = {a_bank2_reg_h[0], 4'b0} - token2_mean;
    a_bank2_minus[1]  = {a_bank2_reg_h[1], 4'b0} - token2_mean;
    a_bank2_minus[2]  = {a_bank2_reg_h[2], 4'b0} - token2_mean;
    a_bank2_minus[3]  = {a_bank2_reg_h[3], 4'b0} - token2_mean;
    a_bank2_minus[4]  = {a_bank2_reg_h[4], 4'b0} - token2_mean;
    a_bank2_minus[5]  = {a_bank2_reg_h[5], 4'b0} - token2_mean;
    a_bank2_minus[6]  = {a_bank2_reg_h[6], 4'b0} - token2_mean;
    a_bank2_minus[7]  = {a_bank2_reg_h[7], 4'b0} - token2_mean;
    a_bank2_minus[8]  = {a_bank2_reg_l[0], 4'b0} - token2_mean;
    a_bank2_minus[9]  = {a_bank2_reg_l[1], 4'b0} - token2_mean;
    a_bank2_minus[10] = {a_bank2_reg_l[2], 4'b0} - token2_mean;
    a_bank2_minus[11] = {a_bank2_reg_l[3], 4'b0} - token2_mean;
    a_bank2_minus[12] = {a_bank2_reg_l[4], 4'b0} - token2_mean;
    a_bank2_minus[13] = {a_bank2_reg_l[5], 4'b0} - token2_mean;
    a_bank2_minus[14] = {a_bank2_reg_l[6], 4'b0} - token2_mean;
    a_bank2_minus[15] = {a_bank2_reg_l[7], 4'b0} - token2_mean;

    a_bank3_minus[0]  = {a_bank3_reg_h[0], 4'b0} - token3_mean;
    a_bank3_minus[1]  = {a_bank3_reg_h[1], 4'b0} - token3_mean;
    a_bank3_minus[2]  = {a_bank3_reg_h[2], 4'b0} - token3_mean;
    a_bank3_minus[3]  = {a_bank3_reg_h[3], 4'b0} - token3_mean;
    a_bank3_minus[4]  = {a_bank3_reg_h[4], 4'b0} - token3_mean;
    a_bank3_minus[5]  = {a_bank3_reg_h[5], 4'b0} - token3_mean;
    a_bank3_minus[6]  = {a_bank3_reg_h[6], 4'b0} - token3_mean;
    a_bank3_minus[7]  = {a_bank3_reg_h[7], 4'b0} - token3_mean;
    a_bank3_minus[8]  = {a_bank3_reg_l[0], 4'b0} - token3_mean;
    a_bank3_minus[9]  = {a_bank3_reg_l[1], 4'b0} - token3_mean;
    a_bank3_minus[10] = {a_bank3_reg_l[2], 4'b0} - token3_mean;
    a_bank3_minus[11] = {a_bank3_reg_l[3], 4'b0} - token3_mean;
    a_bank3_minus[12] = {a_bank3_reg_l[4], 4'b0} - token3_mean;
    a_bank3_minus[13] = {a_bank3_reg_l[5], 4'b0} - token3_mean;
    a_bank3_minus[14] = {a_bank3_reg_l[6], 4'b0} - token3_mean;
    a_bank3_minus[15] = {a_bank3_reg_l[7], 4'b0} - token3_mean;

    // absolute value: if the sign bit is 1, get 2's complement
    a_bank0_abs[0]  = a_bank0_minus[0][13]  ? (~a_bank0_minus[0]  + 1'b1) : a_bank0_minus[0];
    a_bank0_abs[1]  = a_bank0_minus[1][13]  ? (~a_bank0_minus[1]  + 1'b1) : a_bank0_minus[1];
    a_bank0_abs[2]  = a_bank0_minus[2][13]  ? (~a_bank0_minus[2]  + 1'b1) : a_bank0_minus[2];
    a_bank0_abs[3]  = a_bank0_minus[3][13]  ? (~a_bank0_minus[3]  + 1'b1) : a_bank0_minus[3];
    a_bank0_abs[4]  = a_bank0_minus[4][13]  ? (~a_bank0_minus[4]  + 1'b1) : a_bank0_minus[4];
    a_bank0_abs[5]  = a_bank0_minus[5][13]  ? (~a_bank0_minus[5]  + 1'b1) : a_bank0_minus[5];
    a_bank0_abs[6]  = a_bank0_minus[6][13]  ? (~a_bank0_minus[6]  + 1'b1) : a_bank0_minus[6];
    a_bank0_abs[7]  = a_bank0_minus[7][13]  ? (~a_bank0_minus[7]  + 1'b1) : a_bank0_minus[7];
    a_bank0_abs[8]  = a_bank0_minus[8][13]  ? (~a_bank0_minus[8]  + 1'b1) : a_bank0_minus[8];
    a_bank0_abs[9]  = a_bank0_minus[9][13]  ? (~a_bank0_minus[9]  + 1'b1) : a_bank0_minus[9];
    a_bank0_abs[10] = a_bank0_minus[10][13] ? (~a_bank0_minus[10] + 1'b1) : a_bank0_minus[10];
    a_bank0_abs[11] = a_bank0_minus[11][13] ? (~a_bank0_minus[11] + 1'b1) : a_bank0_minus[11];
    a_bank0_abs[12] = a_bank0_minus[12][13] ? (~a_bank0_minus[12] + 1'b1) : a_bank0_minus[12];
    a_bank0_abs[13] = a_bank0_minus[13][13] ? (~a_bank0_minus[13] + 1'b1) : a_bank0_minus[13];
    a_bank0_abs[14] = a_bank0_minus[14][13] ? (~a_bank0_minus[14] + 1'b1) : a_bank0_minus[14];
    a_bank0_abs[15] = a_bank0_minus[15][13] ? (~a_bank0_minus[15] + 1'b1) : a_bank0_minus[15];

    a_bank1_abs[0]  = a_bank1_minus[0][13]  ? (~a_bank1_minus[0]  + 1'b1) : a_bank1_minus[0];
    a_bank1_abs[1]  = a_bank1_minus[1][13]  ? (~a_bank1_minus[1]  + 1'b1) : a_bank1_minus[1];
    a_bank1_abs[2]  = a_bank1_minus[2][13]  ? (~a_bank1_minus[2]  + 1'b1) : a_bank1_minus[2];
    a_bank1_abs[3]  = a_bank1_minus[3][13]  ? (~a_bank1_minus[3]  + 1'b1) : a_bank1_minus[3];
    a_bank1_abs[4]  = a_bank1_minus[4][13]  ? (~a_bank1_minus[4]  + 1'b1) : a_bank1_minus[4];
    a_bank1_abs[5]  = a_bank1_minus[5][13]  ? (~a_bank1_minus[5]  + 1'b1) : a_bank1_minus[5];
    a_bank1_abs[6]  = a_bank1_minus[6][13]  ? (~a_bank1_minus[6]  + 1'b1) : a_bank1_minus[6];
    a_bank1_abs[7]  = a_bank1_minus[7][13]  ? (~a_bank1_minus[7]  + 1'b1) : a_bank1_minus[7];
    a_bank1_abs[8]  = a_bank1_minus[8][13]  ? (~a_bank1_minus[8]  + 1'b1) : a_bank1_minus[8];
    a_bank1_abs[9]  = a_bank1_minus[9][13]  ? (~a_bank1_minus[9]  + 1'b1) : a_bank1_minus[9];
    a_bank1_abs[10] = a_bank1_minus[10][13] ? (~a_bank1_minus[10] + 1'b1) : a_bank1_minus[10];
    a_bank1_abs[11] = a_bank1_minus[11][13] ? (~a_bank1_minus[11] + 1'b1) : a_bank1_minus[11];
    a_bank1_abs[12] = a_bank1_minus[12][13] ? (~a_bank1_minus[12] + 1'b1) : a_bank1_minus[12];
    a_bank1_abs[13] = a_bank1_minus[13][13] ? (~a_bank1_minus[13] + 1'b1) : a_bank1_minus[13];
    a_bank1_abs[14] = a_bank1_minus[14][13] ? (~a_bank1_minus[14] + 1'b1) : a_bank1_minus[14];
    a_bank1_abs[15] = a_bank1_minus[15][13] ? (~a_bank1_minus[15] + 1'b1) : a_bank1_minus[15];

    a_bank2_abs[0]  = a_bank2_minus[0][13]  ? (~a_bank2_minus[0]  + 1'b1) : a_bank2_minus[0];
    a_bank2_abs[1]  = a_bank2_minus[1][13]  ? (~a_bank2_minus[1]  + 1'b1) : a_bank2_minus[1];
    a_bank2_abs[2]  = a_bank2_minus[2][13]  ? (~a_bank2_minus[2]  + 1'b1) : a_bank2_minus[2];
    a_bank2_abs[3]  = a_bank2_minus[3][13]  ? (~a_bank2_minus[3]  + 1'b1) : a_bank2_minus[3];
    a_bank2_abs[4]  = a_bank2_minus[4][13]  ? (~a_bank2_minus[4]  + 1'b1) : a_bank2_minus[4];
    a_bank2_abs[5]  = a_bank2_minus[5][13]  ? (~a_bank2_minus[5]  + 1'b1) : a_bank2_minus[5];
    a_bank2_abs[6]  = a_bank2_minus[6][13]  ? (~a_bank2_minus[6]  + 1'b1) : a_bank2_minus[6];
    a_bank2_abs[7]  = a_bank2_minus[7][13]  ? (~a_bank2_minus[7]  + 1'b1) : a_bank2_minus[7];
    a_bank2_abs[8]  = a_bank2_minus[8][13]  ? (~a_bank2_minus[8]  + 1'b1) : a_bank2_minus[8];
    a_bank2_abs[9]  = a_bank2_minus[9][13]  ? (~a_bank2_minus[9]  + 1'b1) : a_bank2_minus[9];
    a_bank2_abs[10] = a_bank2_minus[10][13] ? (~a_bank2_minus[10] + 1'b1) : a_bank2_minus[10];
    a_bank2_abs[11] = a_bank2_minus[11][13] ? (~a_bank2_minus[11] + 1'b1) : a_bank2_minus[11];
    a_bank2_abs[12] = a_bank2_minus[12][13] ? (~a_bank2_minus[12] + 1'b1) : a_bank2_minus[12];
    a_bank2_abs[13] = a_bank2_minus[13][13] ? (~a_bank2_minus[13] + 1'b1) : a_bank2_minus[13];
    a_bank2_abs[14] = a_bank2_minus[14][13] ? (~a_bank2_minus[14] + 1'b1) : a_bank2_minus[14];
    a_bank2_abs[15] = a_bank2_minus[15][13] ? (~a_bank2_minus[15] + 1'b1) : a_bank2_minus[15];

    a_bank3_abs[0]  = a_bank3_minus[0][13]  ? (~a_bank3_minus[0]  + 1'b1) : a_bank3_minus[0];
    a_bank3_abs[1]  = a_bank3_minus[1][13]  ? (~a_bank3_minus[1]  + 1'b1) : a_bank3_minus[1];
    a_bank3_abs[2]  = a_bank3_minus[2][13]  ? (~a_bank3_minus[2]  + 1'b1) : a_bank3_minus[2];
    a_bank3_abs[3]  = a_bank3_minus[3][13]  ? (~a_bank3_minus[3]  + 1'b1) : a_bank3_minus[3];
    a_bank3_abs[4]  = a_bank3_minus[4][13]  ? (~a_bank3_minus[4]  + 1'b1) : a_bank3_minus[4];
    a_bank3_abs[5]  = a_bank3_minus[5][13]  ? (~a_bank3_minus[5]  + 1'b1) : a_bank3_minus[5];
    a_bank3_abs[6]  = a_bank3_minus[6][13]  ? (~a_bank3_minus[6]  + 1'b1) : a_bank3_minus[6];
    a_bank3_abs[7]  = a_bank3_minus[7][13]  ? (~a_bank3_minus[7]  + 1'b1) : a_bank3_minus[7];
    a_bank3_abs[8]  = a_bank3_minus[8][13]  ? (~a_bank3_minus[8]  + 1'b1) : a_bank3_minus[8];
    a_bank3_abs[9]  = a_bank3_minus[9][13]  ? (~a_bank3_minus[9]  + 1'b1) : a_bank3_minus[9];
    a_bank3_abs[10] = a_bank3_minus[10][13] ? (~a_bank3_minus[10] + 1'b1) : a_bank3_minus[10];
    a_bank3_abs[11] = a_bank3_minus[11][13] ? (~a_bank3_minus[11] + 1'b1) : a_bank3_minus[11];
    a_bank3_abs[12] = a_bank3_minus[12][13] ? (~a_bank3_minus[12] + 1'b1) : a_bank3_minus[12];
    a_bank3_abs[13] = a_bank3_minus[13][13] ? (~a_bank3_minus[13] + 1'b1) : a_bank3_minus[13];
    a_bank3_abs[14] = a_bank3_minus[14][13] ? (~a_bank3_minus[14] + 1'b1) : a_bank3_minus[14];
    a_bank3_abs[15] = a_bank3_minus[15][13] ? (~a_bank3_minus[15] + 1'b1) : a_bank3_minus[15];

    token0_mae = a_bank0_abs[0]  + a_bank0_abs[1]  + a_bank0_abs[2]  + a_bank0_abs[3]
                + a_bank0_abs[4]  + a_bank0_abs[5]  + a_bank0_abs[6]  + a_bank0_abs[7]
                + a_bank0_abs[8]  + a_bank0_abs[9]  + a_bank0_abs[10] + a_bank0_abs[11]
                + a_bank0_abs[12] + a_bank0_abs[13] + a_bank0_abs[14] + a_bank0_abs[15];
    token1_mae = a_bank1_abs[0]  + a_bank1_abs[1]  + a_bank1_abs[2]  + a_bank1_abs[3]
                + a_bank1_abs[4]  + a_bank1_abs[5]  + a_bank1_abs[6]  + a_bank1_abs[7]
                + a_bank1_abs[8]  + a_bank1_abs[9]  + a_bank1_abs[10] + a_bank1_abs[11]
                + a_bank1_abs[12] + a_bank1_abs[13] + a_bank1_abs[14] + a_bank1_abs[15];
    token2_mae = a_bank2_abs[0]  + a_bank2_abs[1]  + a_bank2_abs[2]  + a_bank2_abs[3]
                + a_bank2_abs[4]  + a_bank2_abs[5]  + a_bank2_abs[6]  + a_bank2_abs[7]
                + a_bank2_abs[8]  + a_bank2_abs[9]  + a_bank2_abs[10] + a_bank2_abs[11]
                + a_bank2_abs[12] + a_bank2_abs[13] + a_bank2_abs[14] + a_bank2_abs[15];
    token3_mae = a_bank3_abs[0]  + a_bank3_abs[1]  + a_bank3_abs[2]  + a_bank3_abs[3]
                + a_bank3_abs[4]  + a_bank3_abs[5]  + a_bank3_abs[6]  + a_bank3_abs[7]
                + a_bank3_abs[8]  + a_bank3_abs[9]  + a_bank3_abs[10] + a_bank3_abs[11]
                + a_bank3_abs[12] + a_bank3_abs[13] + a_bank3_abs[14] + a_bank3_abs[15];
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
reg [(BW_PER_ACT-1):0]token0_nor[0:15];
reg [(BW_PER_ACT-1):0]token1_nor[0:15];
reg [(BW_PER_ACT-1):0]token2_nor[0:15];
reg [(BW_PER_ACT-1):0]token3_nor[0:15];
reg [17:0] token0_mae_abs;
reg [17:0] token1_mae_abs;
reg [17:0] token2_mae_abs;
reg [17:0] token3_mae_abs;
reg [(BW_PER_ACT-1):0]token0_nor_reg[0:15];
reg [(BW_PER_ACT-1):0]token1_nor_reg[0:15];
reg [(BW_PER_ACT-1):0]token2_nor_reg[0:15];
reg [(BW_PER_ACT-1):0]token3_nor_reg[0:15];
reg valid_3;
always @(*) begin
    token0_mae_abs = (token0_mae[17])? ~token0_mae + 1: token0_mae;
    token1_mae_abs = (token1_mae[17])? ~token1_mae + 1: token1_mae;
    token2_mae_abs = (token2_mae[17])? ~token2_mae + 1: token2_mae;
    token3_mae_abs = (token3_mae[17])? ~token3_mae + 1: token3_mae; 

    token0_nor[0]  = {a_bank0_abs[0],  4'b0, 6'b0} / token0_mae_abs;
    token0_nor[1]  = {a_bank0_abs[1],  4'b0, 6'b0} / token0_mae_abs;
    token0_nor[2]  = {a_bank0_abs[2],  4'b0, 6'b0} / token0_mae_abs;
    token0_nor[3]  = {a_bank0_abs[3],  4'b0, 6'b0} / token0_mae_abs;
    token0_nor[4]  = {a_bank0_abs[4],  4'b0, 6'b0} / token0_mae_abs;
    token0_nor[5]  = {a_bank0_abs[5],  4'b0, 6'b0} / token0_mae_abs;
    token0_nor[6]  = {a_bank0_abs[6],  4'b0, 6'b0} / token0_mae_abs;
    token0_nor[7]  = {a_bank0_abs[7],  4'b0, 6'b0} / token0_mae_abs;
    token0_nor[8]  = {a_bank0_abs[8],  4'b0, 6'b0} / token0_mae_abs;
    token0_nor[9]  = {a_bank0_abs[9],  4'b0, 6'b0} / token0_mae_abs;
    token0_nor[10] = {a_bank0_abs[10], 4'b0, 6'b0} / token0_mae_abs;
    token0_nor[11] = {a_bank0_abs[11], 4'b0, 6'b0} / token0_mae_abs;
    token0_nor[12] = {a_bank0_abs[12], 4'b0, 6'b0} / token0_mae_abs;
    token0_nor[13] = {a_bank0_abs[13], 4'b0, 6'b0} / token0_mae_abs;
    token0_nor[14] = {a_bank0_abs[14], 4'b0, 6'b0} / token0_mae_abs;
    token0_nor[15] = {a_bank0_abs[15], 4'b0, 6'b0} / token0_mae_abs;

    token1_nor[0]  = {a_bank1_abs[0],  4'b0, 6'b0} / token1_mae_abs;
    token1_nor[1]  = {a_bank1_abs[1],  4'b0, 6'b0} / token1_mae_abs;
    token1_nor[2]  = {a_bank1_abs[2],  4'b0, 6'b0} / token1_mae_abs;
    token1_nor[3]  = {a_bank1_abs[3],  4'b0, 6'b0} / token1_mae_abs;
    token1_nor[4]  = {a_bank1_abs[4],  4'b0, 6'b0} / token1_mae_abs;
    token1_nor[5]  = {a_bank1_abs[5],  4'b0, 6'b0} / token1_mae_abs;
    token1_nor[6]  = {a_bank1_abs[6],  4'b0, 6'b0} / token1_mae_abs;
    token1_nor[7]  = {a_bank1_abs[7],  4'b0, 6'b0} / token1_mae_abs;
    token1_nor[8]  = {a_bank1_abs[8],  4'b0, 6'b0} / token1_mae_abs;
    token1_nor[9]  = {a_bank1_abs[9],  4'b0, 6'b0} / token1_mae_abs;
    token1_nor[10] = {a_bank1_abs[10], 4'b0, 6'b0} / token1_mae_abs;
    token1_nor[11] = {a_bank1_abs[11], 4'b0, 6'b0} / token1_mae_abs;
    token1_nor[12] = {a_bank1_abs[12], 4'b0, 6'b0} / token1_mae_abs;
    token1_nor[13] = {a_bank1_abs[13], 4'b0, 6'b0} / token1_mae_abs;
    token1_nor[14] = {a_bank1_abs[14], 4'b0, 6'b0} / token1_mae_abs;
    token1_nor[15] = {a_bank1_abs[15], 4'b0, 6'b0} / token1_mae_abs;

    token2_nor[0]  = {a_bank2_abs[0],  4'b0, 6'b0} / token2_mae_abs;
    token2_nor[1]  = {a_bank2_abs[1],  4'b0, 6'b0} / token2_mae_abs;
    token2_nor[2]  = {a_bank2_abs[2],  4'b0, 6'b0} / token2_mae_abs;
    token2_nor[3]  = {a_bank2_abs[3],  4'b0, 6'b0} / token2_mae_abs;
    token2_nor[4]  = {a_bank2_abs[4],  4'b0, 6'b0} / token2_mae_abs;
    token2_nor[5]  = {a_bank2_abs[5],  4'b0, 6'b0} / token2_mae_abs;
    token2_nor[6]  = {a_bank2_abs[6],  4'b0, 6'b0} / token2_mae_abs;
    token2_nor[7]  = {a_bank2_abs[7],  4'b0, 6'b0} / token2_mae_abs;
    token2_nor[8]  = {a_bank2_abs[8],  4'b0, 6'b0} / token2_mae_abs;
    token2_nor[9]  = {a_bank2_abs[9],  4'b0, 6'b0} / token2_mae_abs;
    token2_nor[10] = {a_bank2_abs[10], 4'b0, 6'b0} / token2_mae_abs;
    token2_nor[11] = {a_bank2_abs[11], 4'b0, 6'b0} / token2_mae_abs;
    token2_nor[12] = {a_bank2_abs[12], 4'b0, 6'b0} / token2_mae_abs;
    token2_nor[13] = {a_bank2_abs[13], 4'b0, 6'b0} / token2_mae_abs;
    token2_nor[14] = {a_bank2_abs[14], 4'b0, 6'b0} / token2_mae_abs;
    token2_nor[15] = {a_bank2_abs[15], 4'b0, 6'b0} / token2_mae_abs;

    token3_nor[0]  = {a_bank3_abs[0],  4'b0, 6'b0} / token3_mae_abs;
    token3_nor[1]  = {a_bank3_abs[1],  4'b0, 6'b0} / token3_mae_abs;
    token3_nor[2]  = {a_bank3_abs[2],  4'b0, 6'b0} / token3_mae_abs;
    token3_nor[3]  = {a_bank3_abs[3],  4'b0, 6'b0} / token3_mae_abs;
    token3_nor[4]  = {a_bank3_abs[4],  4'b0, 6'b0} / token3_mae_abs;
    token3_nor[5]  = {a_bank3_abs[5],  4'b0, 6'b0} / token3_mae_abs;
    token3_nor[6]  = {a_bank3_abs[6],  4'b0, 6'b0} / token3_mae_abs;
    token3_nor[7]  = {a_bank3_abs[7],  4'b0, 6'b0} / token3_mae_abs;
    token3_nor[8]  = {a_bank3_abs[8],  4'b0, 6'b0} / token3_mae_abs;
    token3_nor[9]  = {a_bank3_abs[9],  4'b0, 6'b0} / token3_mae_abs;
    token3_nor[10] = {a_bank3_abs[10], 4'b0, 6'b0} / token3_mae_abs;
    token3_nor[11] = {a_bank3_abs[11], 4'b0, 6'b0} / token3_mae_abs;
    token3_nor[12] = {a_bank3_abs[12], 4'b0, 6'b0} / token3_mae_abs;
    token3_nor[13] = {a_bank3_abs[13], 4'b0, 6'b0} / token3_mae_abs;
    token3_nor[14] = {a_bank3_abs[14], 4'b0, 6'b0} / token3_mae_abs;
    token3_nor[15] = {a_bank3_abs[15], 4'b0, 6'b0} / token3_mae_abs;
end 

// consider the sign of numerator and denominator, if both positive(0), then 
// the result preserve, else, take 2's complement
always @(posedge clk) begin
    if (valid_2) begin
        token0_nor_reg[0]  <= (!a_bank0_minus[0][13]  && !token0_mae[17]) ? token0_nor[0]  : (~token0_nor[0]  + 1'b1);
        token0_nor_reg[1]  <= (!a_bank0_minus[1][13]  && !token0_mae[17]) ? token0_nor[1]  : (~token0_nor[1]  + 1'b1);
        token0_nor_reg[2]  <= (!a_bank0_minus[2][13]  && !token0_mae[17]) ? token0_nor[2]  : (~token0_nor[2]  + 1'b1);
        token0_nor_reg[3]  <= (!a_bank0_minus[3][13]  && !token0_mae[17]) ? token0_nor[3]  : (~token0_nor[3]  + 1'b1);
        token0_nor_reg[4]  <= (!a_bank0_minus[4][13]  && !token0_mae[17]) ? token0_nor[4]  : (~token0_nor[4]  + 1'b1);
        token0_nor_reg[5]  <= (!a_bank0_minus[5][13]  && !token0_mae[17]) ? token0_nor[5]  : (~token0_nor[5]  + 1'b1);
        token0_nor_reg[6]  <= (!a_bank0_minus[6][13]  && !token0_mae[17]) ? token0_nor[6]  : (~token0_nor[6]  + 1'b1);
        token0_nor_reg[7]  <= (!a_bank0_minus[7][13]  && !token0_mae[17]) ? token0_nor[7]  : (~token0_nor[7]  + 1'b1);
        token0_nor_reg[8]  <= (!a_bank0_minus[8][13]  && !token0_mae[17]) ? token0_nor[8]  : (~token0_nor[8]  + 1'b1);
        token0_nor_reg[9]  <= (!a_bank0_minus[9][13]  && !token0_mae[17]) ? token0_nor[9]  : (~token0_nor[9]  + 1'b1);
        token0_nor_reg[10] <= (!a_bank0_minus[10][13] && !token0_mae[17]) ? token0_nor[10] : (~token0_nor[10] + 1'b1);
        token0_nor_reg[11] <= (!a_bank0_minus[11][13] && !token0_mae[17]) ? token0_nor[11] : (~token0_nor[11] + 1'b1);
        token0_nor_reg[12] <= (!a_bank0_minus[12][13] && !token0_mae[17]) ? token0_nor[12] : (~token0_nor[12] + 1'b1);
        token0_nor_reg[13] <= (!a_bank0_minus[13][13] && !token0_mae[17]) ? token0_nor[13] : (~token0_nor[13] + 1'b1);
        token0_nor_reg[14] <= (!a_bank0_minus[14][13] && !token0_mae[17]) ? token0_nor[14] : (~token0_nor[14] + 1'b1);
        token0_nor_reg[15] <= (!a_bank0_minus[15][13] && !token0_mae[17]) ? token0_nor[15] : (~token0_nor[15] + 1'b1);

        token1_nor_reg[0]  <= (!a_bank1_minus[0][13]  && !token1_mae[17]) ? token1_nor[0]  : (~token1_nor[0]  + 1'b1);
        token1_nor_reg[1]  <= (!a_bank1_minus[1][13]  && !token1_mae[17]) ? token1_nor[1]  : (~token1_nor[1]  + 1'b1);
        token1_nor_reg[2]  <= (!a_bank1_minus[2][13]  && !token1_mae[17]) ? token1_nor[2]  : (~token1_nor[2]  + 1'b1);
        token1_nor_reg[3]  <= (!a_bank1_minus[3][13]  && !token1_mae[17]) ? token1_nor[3]  : (~token1_nor[3]  + 1'b1);
        token1_nor_reg[4]  <= (!a_bank1_minus[4][13]  && !token1_mae[17]) ? token1_nor[4]  : (~token1_nor[4]  + 1'b1);
        token1_nor_reg[5]  <= (!a_bank1_minus[5][13]  && !token1_mae[17]) ? token1_nor[5]  : (~token1_nor[5]  + 1'b1);
        token1_nor_reg[6]  <= (!a_bank1_minus[6][13]  && !token1_mae[17]) ? token1_nor[6]  : (~token1_nor[6]  + 1'b1);
        token1_nor_reg[7]  <= (!a_bank1_minus[7][13]  && !token1_mae[17]) ? token1_nor[7]  : (~token1_nor[7]  + 1'b1);
        token1_nor_reg[8]  <= (!a_bank1_minus[8][13]  && !token1_mae[17]) ? token1_nor[8]  : (~token1_nor[8]  + 1'b1);
        token1_nor_reg[9]  <= (!a_bank1_minus[9][13]  && !token1_mae[17]) ? token1_nor[9]  : (~token1_nor[9]  + 1'b1);
        token1_nor_reg[10] <= (!a_bank1_minus[10][13] && !token1_mae[17]) ? token1_nor[10] : (~token1_nor[10] + 1'b1);
        token1_nor_reg[11] <= (!a_bank1_minus[11][13] && !token1_mae[17]) ? token1_nor[11] : (~token1_nor[11] + 1'b1);
        token1_nor_reg[12] <= (!a_bank1_minus[12][13] && !token1_mae[17]) ? token1_nor[12] : (~token1_nor[12] + 1'b1);
        token1_nor_reg[13] <= (!a_bank1_minus[13][13] && !token1_mae[17]) ? token1_nor[13] : (~token1_nor[13] + 1'b1);
        token1_nor_reg[14] <= (!a_bank1_minus[14][13] && !token1_mae[17]) ? token1_nor[14] : (~token1_nor[14] + 1'b1);
        token1_nor_reg[15] <= (!a_bank1_minus[15][13] && !token1_mae[17]) ? token1_nor[15] : (~token1_nor[15] + 1'b1);

        token2_nor_reg[0]  <= (!a_bank2_minus[0][13]  && !token2_mae[17]) ? token2_nor[0]  : (~token2_nor[0]  + 1'b1);
        token2_nor_reg[1]  <= (!a_bank2_minus[1][13]  && !token2_mae[17]) ? token2_nor[1]  : (~token2_nor[1]  + 1'b1);
        token2_nor_reg[2]  <= (!a_bank2_minus[2][13]  && !token2_mae[17]) ? token2_nor[2]  : (~token2_nor[2]  + 1'b1);
        token2_nor_reg[3]  <= (!a_bank2_minus[3][13]  && !token2_mae[17]) ? token2_nor[3]  : (~token2_nor[3]  + 1'b1);
        token2_nor_reg[4]  <= (!a_bank2_minus[4][13]  && !token2_mae[17]) ? token2_nor[4]  : (~token2_nor[4]  + 1'b1);
        token2_nor_reg[5]  <= (!a_bank2_minus[5][13]  && !token2_mae[17]) ? token2_nor[5]  : (~token2_nor[5]  + 1'b1);
        token2_nor_reg[6]  <= (!a_bank2_minus[6][13]  && !token2_mae[17]) ? token2_nor[6]  : (~token2_nor[6]  + 1'b1);
        token2_nor_reg[7]  <= (!a_bank2_minus[7][13]  && !token2_mae[17]) ? token2_nor[7]  : (~token2_nor[7]  + 1'b1);
        token2_nor_reg[8]  <= (!a_bank2_minus[8][13]  && !token2_mae[17]) ? token2_nor[8]  : (~token2_nor[8]  + 1'b1);
        token2_nor_reg[9]  <= (!a_bank2_minus[9][13]  && !token2_mae[17]) ? token2_nor[9]  : (~token2_nor[9]  + 1'b1);
        token2_nor_reg[10] <= (!a_bank2_minus[10][13] && !token2_mae[17]) ? token2_nor[10] : (~token2_nor[10] + 1'b1);
        token2_nor_reg[11] <= (!a_bank2_minus[11][13] && !token2_mae[17]) ? token2_nor[11] : (~token2_nor[11] + 1'b1);
        token2_nor_reg[12] <= (!a_bank2_minus[12][13] && !token2_mae[17]) ? token2_nor[12] : (~token2_nor[12] + 1'b1);
        token2_nor_reg[13] <= (!a_bank2_minus[13][13] && !token2_mae[17]) ? token2_nor[13] : (~token2_nor[13] + 1'b1);
        token2_nor_reg[14] <= (!a_bank2_minus[14][13] && !token2_mae[17]) ? token2_nor[14] : (~token2_nor[14] + 1'b1);
        token2_nor_reg[15] <= (!a_bank2_minus[15][13] && !token2_mae[17]) ? token2_nor[15] : (~token2_nor[15] + 1'b1);

        token3_nor_reg[0]  <= (!a_bank3_minus[0][13]  && !token3_mae[17]) ? token3_nor[0]  : (~token3_nor[0]  + 1'b1);
        token3_nor_reg[1]  <= (!a_bank3_minus[1][13]  && !token3_mae[17]) ? token3_nor[1]  : (~token3_nor[1]  + 1'b1);
        token3_nor_reg[2]  <= (!a_bank3_minus[2][13]  && !token3_mae[17]) ? token3_nor[2]  : (~token3_nor[2]  + 1'b1);
        token3_nor_reg[3]  <= (!a_bank3_minus[3][13]  && !token3_mae[17]) ? token3_nor[3]  : (~token3_nor[3]  + 1'b1);
        token3_nor_reg[4]  <= (!a_bank3_minus[4][13]  && !token3_mae[17]) ? token3_nor[4]  : (~token3_nor[4]  + 1'b1);
        token3_nor_reg[5]  <= (!a_bank3_minus[5][13]  && !token3_mae[17]) ? token3_nor[5]  : (~token3_nor[5]  + 1'b1);
        token3_nor_reg[6]  <= (!a_bank3_minus[6][13]  && !token3_mae[17]) ? token3_nor[6]  : (~token3_nor[6]  + 1'b1);
        token3_nor_reg[7]  <= (!a_bank3_minus[7][13]  && !token3_mae[17]) ? token3_nor[7]  : (~token3_nor[7]  + 1'b1);
        token3_nor_reg[8]  <= (!a_bank3_minus[8][13]  && !token3_mae[17]) ? token3_nor[8]  : (~token3_nor[8]  + 1'b1);
        token3_nor_reg[9]  <= (!a_bank3_minus[9][13]  && !token3_mae[17]) ? token3_nor[9]  : (~token3_nor[9]  + 1'b1);
        token3_nor_reg[10] <= (!a_bank3_minus[10][13] && !token3_mae[17]) ? token3_nor[10] : (~token3_nor[10] + 1'b1);
        token3_nor_reg[11] <= (!a_bank3_minus[11][13] && !token3_mae[17]) ? token3_nor[11] : (~token3_nor[11] + 1'b1);
        token3_nor_reg[12] <= (!a_bank3_minus[12][13] && !token3_mae[17]) ? token3_nor[12] : (~token3_nor[12] + 1'b1);
        token3_nor_reg[13] <= (!a_bank3_minus[13][13] && !token3_mae[17]) ? token3_nor[13] : (~token3_nor[13] + 1'b1);
        token3_nor_reg[14] <= (!a_bank3_minus[14][13] && !token3_mae[17]) ? token3_nor[14] : (~token3_nor[14] + 1'b1);
        token3_nor_reg[15] <= (!a_bank3_minus[15][13] && !token3_mae[17]) ? token3_nor[15] : (~token3_nor[15] + 1'b1);
    end
    valid_3 <= valid_2;
end

// ----- multiply with parameter and add bias ----- //
// result = weight * x_nor + bias
// x_normalize (1-sign + 3-bit integer + 6-bit fraction)
// weight and bias (1-bit sign + 2-bit integer + 7-bit fraction)

// There are weight-sram and bias-sram
// 1. weight-sram
// each addr store 16 weight(ch0(MSB) -> ch15(LSB)), 160-bit/addr
// 2. bias-sram
// each addr store 1 bias, 10-bit/addr

// ===== Quantize the result to 10-bit and write the result to SRAM B ===== //

endmodule


