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