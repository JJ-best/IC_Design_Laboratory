module div #(
    parameter N = 39,
    parameter M = 39,
    parameter N_ACT = M+N-1
)(
    input clk,
    input [N-1:0] dividend,
    input [M-1:0] divisor,
    output [N-1:0] merchant,
    output [M-1:0] remainder
);

// Restoring divider with pipeline registers arranged as |6|7|7|7|6|6

localparam integer PIPE_DEPTH = N_ACT - M;

reg [N_ACT-M-1:0] dividend_t [N_ACT-M:0];
reg [M-1:0]       divisor_t  [N_ACT-M:0];
reg [M-1:0]       remainder_t[N_ACT-M:0];
reg [N_ACT-M:0]   merchant_t [N_ACT-M:0];

wire [M:0] stage0_dividend = {{(M){1'b0}}, dividend[N-1]};
wire [M-1:0] stage0_divisor = divisor;
wire [N_ACT-M:0] stage0_merchant_ci = {(N_ACT-M+1){1'b0}};
wire [N_ACT-M-1:0] stage0_dividend_ci = dividend[N_ACT-M-1:0];
wire [M:0] stage_sub_0 = stage0_dividend - {1'b0, stage0_divisor};

always @(posedge clk) begin
    divisor_t[0]  <= stage0_divisor;
    dividend_t[0] <= stage0_dividend_ci;
    if (!stage_sub_0[M]) begin
        merchant_t[0]  <= {stage0_merchant_ci[N_ACT-M-1:0], 1'b1};
        remainder_t[0] <= stage_sub_0[M-1:0];
    end else begin
        merchant_t[0]  <= {stage0_merchant_ci[N_ACT-M-1:0], 1'b0};
        remainder_t[0] <= stage0_dividend[M-1:0];
    end
end

wire [M:0] stage_sub_1 = {{remainder_t[0], dividend_t[0][N_ACT-M-1]}} - {1'b0, divisor_t[0]};
always @(*) begin
    divisor_t[1]  = divisor_t[0];
    dividend_t[1] = dividend_t[0];
    if (!stage_sub_1[M]) begin
        merchant_t[1]  = {merchant_t[0][N_ACT-M-1:0], 1'b1};
        remainder_t[1] = stage_sub_1[M-1:0];
    end else begin
        merchant_t[1]  = {merchant_t[0][N_ACT-M-1:0], 1'b0};
        remainder_t[1] = {remainder_t[0], dividend_t[0][N_ACT-M-1]};
    end
end

wire [M:0] stage_sub_2 = {{remainder_t[1], dividend_t[1][N_ACT-M-2]}} - {1'b0, divisor_t[1]};
always @(*) begin
    divisor_t[2]  = divisor_t[1];
    dividend_t[2] = dividend_t[1];
    if (!stage_sub_2[M]) begin
        merchant_t[2]  = {merchant_t[1][N_ACT-M-1:0], 1'b1};
        remainder_t[2] = stage_sub_2[M-1:0];
    end else begin
        merchant_t[2]  = {merchant_t[1][N_ACT-M-1:0], 1'b0};
        remainder_t[2] = {remainder_t[1], dividend_t[1][N_ACT-M-2]};
    end
end

wire [M:0] stage_sub_3 = {{remainder_t[2], dividend_t[2][N_ACT-M-3]}} - {1'b0, divisor_t[2]};
always @(*) begin
    divisor_t[3]  = divisor_t[2];
    dividend_t[3] = dividend_t[2];
    if (!stage_sub_3[M]) begin
        merchant_t[3]  = {merchant_t[2][N_ACT-M-1:0], 1'b1};
        remainder_t[3] = stage_sub_3[M-1:0];
    end else begin
        merchant_t[3]  = {merchant_t[2][N_ACT-M-1:0], 1'b0};
        remainder_t[3] = {remainder_t[2], dividend_t[2][N_ACT-M-3]};
    end
end

wire [M:0] stage_sub_4 = {{remainder_t[3], dividend_t[3][N_ACT-M-4]}} - {1'b0, divisor_t[3]};
always @(*) begin
    divisor_t[4]  = divisor_t[3];
    dividend_t[4] = dividend_t[3];
    if (!stage_sub_4[M]) begin
        merchant_t[4]  = {merchant_t[3][N_ACT-M-1:0], 1'b1};
        remainder_t[4] = stage_sub_4[M-1:0];
    end else begin
        merchant_t[4]  = {merchant_t[3][N_ACT-M-1:0], 1'b0};
        remainder_t[4] = {remainder_t[3], dividend_t[3][N_ACT-M-4]};
    end
end

wire [M:0] stage_sub_5 = {{remainder_t[4], dividend_t[4][N_ACT-M-5]}} - {1'b0, divisor_t[4]};
always @(*) begin
    divisor_t[5]  = divisor_t[4];
    dividend_t[5] = dividend_t[4];
    if (!stage_sub_5[M]) begin
        merchant_t[5]  = {merchant_t[4][N_ACT-M-1:0], 1'b1};
        remainder_t[5] = stage_sub_5[M-1:0];
    end else begin
        merchant_t[5]  = {merchant_t[4][N_ACT-M-1:0], 1'b0};
        remainder_t[5] = {remainder_t[4], dividend_t[4][N_ACT-M-5]};
    end
end

wire [M:0] stage_sub_6 = {{remainder_t[5], dividend_t[5][N_ACT-M-6]}} - {1'b0, divisor_t[5]};
always @(*) begin
    divisor_t[6]  = divisor_t[5];
    dividend_t[6] = dividend_t[5];
    if (!stage_sub_6[M]) begin
        merchant_t[6]  = {merchant_t[5][N_ACT-M-1:0], 1'b1};
        remainder_t[6] = stage_sub_6[M-1:0];
    end else begin
        merchant_t[6]  = {merchant_t[5][N_ACT-M-1:0], 1'b0};
        remainder_t[6] = {remainder_t[5], dividend_t[5][N_ACT-M-6]};
    end
end

wire [M:0] stage_sub_7 = {{remainder_t[6], dividend_t[6][N_ACT-M-7]}} - {1'b0, divisor_t[6]};
always @(posedge clk) begin
    divisor_t[7]  <= divisor_t[6];
    dividend_t[7] <= dividend_t[6];
    if (!stage_sub_7[M]) begin
        merchant_t[7]  <= {merchant_t[6][N_ACT-M-1:0], 1'b1};
        remainder_t[7] <= stage_sub_7[M-1:0];
    end else begin
        merchant_t[7]  <= {merchant_t[6][N_ACT-M-1:0], 1'b0};
        remainder_t[7] <= {remainder_t[6], dividend_t[6][N_ACT-M-7]};
    end
end

wire [M:0] stage_sub_8 = {{remainder_t[7], dividend_t[7][N_ACT-M-8]}} - {1'b0, divisor_t[7]};
always @(*) begin
    divisor_t[8]  = divisor_t[7];
    dividend_t[8] = dividend_t[7];
    if (!stage_sub_8[M]) begin
        merchant_t[8]  = {merchant_t[7][N_ACT-M-1:0], 1'b1};
        remainder_t[8] = stage_sub_8[M-1:0];
    end else begin
        merchant_t[8]  = {merchant_t[7][N_ACT-M-1:0], 1'b0};
        remainder_t[8] = {remainder_t[7], dividend_t[7][N_ACT-M-8]};
    end
end

wire [M:0] stage_sub_9 = {{remainder_t[8], dividend_t[8][N_ACT-M-9]}} - {1'b0, divisor_t[8]};
always @(*) begin
    divisor_t[9]  = divisor_t[8];
    dividend_t[9] = dividend_t[8];
    if (!stage_sub_9[M]) begin
        merchant_t[9]  = {merchant_t[8][N_ACT-M-1:0], 1'b1};
        remainder_t[9] = stage_sub_9[M-1:0];
    end else begin
        merchant_t[9]  = {merchant_t[8][N_ACT-M-1:0], 1'b0};
        remainder_t[9] = {remainder_t[8], dividend_t[8][N_ACT-M-9]};
    end
end

wire [M:0] stage_sub_10 = {{remainder_t[9], dividend_t[9][N_ACT-M-10]}} - {1'b0, divisor_t[9]};
always @(*) begin
    divisor_t[10]  = divisor_t[9];
    dividend_t[10] = dividend_t[9];
    if (!stage_sub_10[M]) begin
        merchant_t[10]  = {merchant_t[9][N_ACT-M-1:0], 1'b1};
        remainder_t[10] = stage_sub_10[M-1:0];
    end else begin
        merchant_t[10]  = {merchant_t[9][N_ACT-M-1:0], 1'b0};
        remainder_t[10] = {remainder_t[9], dividend_t[9][N_ACT-M-10]};
    end
end

wire [M:0] stage_sub_11 = {{remainder_t[10], dividend_t[10][N_ACT-M-11]}} - {1'b0, divisor_t[10]};
always @(*) begin
    divisor_t[11]  = divisor_t[10];
    dividend_t[11] = dividend_t[10];
    if (!stage_sub_11[M]) begin
        merchant_t[11]  = {merchant_t[10][N_ACT-M-1:0], 1'b1};
        remainder_t[11] = stage_sub_11[M-1:0];
    end else begin
        merchant_t[11]  = {merchant_t[10][N_ACT-M-1:0], 1'b0};
        remainder_t[11] = {remainder_t[10], dividend_t[10][N_ACT-M-11]};
    end
end

wire [M:0] stage_sub_12 = {{remainder_t[11], dividend_t[11][N_ACT-M-12]}} - {1'b0, divisor_t[11]};
always @(*) begin
    divisor_t[12]  = divisor_t[11];
    dividend_t[12] = dividend_t[11];
    if (!stage_sub_12[M]) begin
        merchant_t[12]  = {merchant_t[11][N_ACT-M-1:0], 1'b1};
        remainder_t[12] = stage_sub_12[M-1:0];
    end else begin
        merchant_t[12]  = {merchant_t[11][N_ACT-M-1:0], 1'b0};
        remainder_t[12] = {remainder_t[11], dividend_t[11][N_ACT-M-12]};
    end
end

wire [M:0] stage_sub_13 = {{remainder_t[12], dividend_t[12][N_ACT-M-13]}} - {1'b0, divisor_t[12]};
always @(*) begin
    divisor_t[13]  = divisor_t[12];
    dividend_t[13] = dividend_t[12];
    if (!stage_sub_13[M]) begin
        merchant_t[13]  = {merchant_t[12][N_ACT-M-1:0], 1'b1};
        remainder_t[13] = stage_sub_13[M-1:0];
    end else begin
        merchant_t[13]  = {merchant_t[12][N_ACT-M-1:0], 1'b0};
        remainder_t[13] = {remainder_t[12], dividend_t[12][N_ACT-M-13]};
    end
end

wire [M:0] stage_sub_14 = {{remainder_t[13], dividend_t[13][N_ACT-M-14]}} - {1'b0, divisor_t[13]};
always @(posedge clk) begin
    divisor_t[14]  <= divisor_t[13];
    dividend_t[14] <= dividend_t[13];
    if (!stage_sub_14[M]) begin
        merchant_t[14]  <= {merchant_t[13][N_ACT-M-1:0], 1'b1};
        remainder_t[14] <= stage_sub_14[M-1:0];
    end else begin
        merchant_t[14]  <= {merchant_t[13][N_ACT-M-1:0], 1'b0};
        remainder_t[14] <= {remainder_t[13], dividend_t[13][N_ACT-M-14]};
    end
end

wire [M:0] stage_sub_15 = {{remainder_t[14], dividend_t[14][N_ACT-M-15]}} - {1'b0, divisor_t[14]};
always @(*) begin
    divisor_t[15]  = divisor_t[14];
    dividend_t[15] = dividend_t[14];
    if (!stage_sub_15[M]) begin
        merchant_t[15]  = {merchant_t[14][N_ACT-M-1:0], 1'b1};
        remainder_t[15] = stage_sub_15[M-1:0];
    end else begin
        merchant_t[15]  = {merchant_t[14][N_ACT-M-1:0], 1'b0};
        remainder_t[15] = {remainder_t[14], dividend_t[14][N_ACT-M-15]};
    end
end

wire [M:0] stage_sub_16 = {{remainder_t[15], dividend_t[15][N_ACT-M-16]}} - {1'b0, divisor_t[15]};
always @(*) begin
    divisor_t[16]  = divisor_t[15];
    dividend_t[16] = dividend_t[15];
    if (!stage_sub_16[M]) begin
        merchant_t[16]  = {merchant_t[15][N_ACT-M-1:0], 1'b1};
        remainder_t[16] = stage_sub_16[M-1:0];
    end else begin
        merchant_t[16]  = {merchant_t[15][N_ACT-M-1:0], 1'b0};
        remainder_t[16] = {remainder_t[15], dividend_t[15][N_ACT-M-16]};
    end
end

wire [M:0] stage_sub_17 = {{remainder_t[16], dividend_t[16][N_ACT-M-17]}} - {1'b0, divisor_t[16]};
always @(*) begin
    divisor_t[17]  = divisor_t[16];
    dividend_t[17] = dividend_t[16];
    if (!stage_sub_17[M]) begin
        merchant_t[17]  = {merchant_t[16][N_ACT-M-1:0], 1'b1};
        remainder_t[17] = stage_sub_17[M-1:0];
    end else begin
        merchant_t[17]  = {merchant_t[16][N_ACT-M-1:0], 1'b0};
        remainder_t[17] = {remainder_t[16], dividend_t[16][N_ACT-M-17]};
    end
end

wire [M:0] stage_sub_18 = {{remainder_t[17], dividend_t[17][N_ACT-M-18]}} - {1'b0, divisor_t[17]};
always @(*) begin
    divisor_t[18]  = divisor_t[17];
    dividend_t[18] = dividend_t[17];
    if (!stage_sub_18[M]) begin
        merchant_t[18]  = {merchant_t[17][N_ACT-M-1:0], 1'b1};
        remainder_t[18] = stage_sub_18[M-1:0];
    end else begin
        merchant_t[18]  = {merchant_t[17][N_ACT-M-1:0], 1'b0};
        remainder_t[18] = {remainder_t[17], dividend_t[17][N_ACT-M-18]};
    end
end

wire [M:0] stage_sub_19 = {{remainder_t[18], dividend_t[18][N_ACT-M-19]}} - {1'b0, divisor_t[18]};
always @(*) begin
    divisor_t[19]  = divisor_t[18];
    dividend_t[19] = dividend_t[18];
    if (!stage_sub_19[M]) begin
        merchant_t[19]  = {merchant_t[18][N_ACT-M-1:0], 1'b1};
        remainder_t[19] = stage_sub_19[M-1:0];
    end else begin
        merchant_t[19]  = {merchant_t[18][N_ACT-M-1:0], 1'b0};
        remainder_t[19] = {remainder_t[18], dividend_t[18][N_ACT-M-19]};
    end
end

wire [M:0] stage_sub_20 = {{remainder_t[19], dividend_t[19][N_ACT-M-20]}} - {1'b0, divisor_t[19]};
always @(*) begin
    divisor_t[20]  = divisor_t[19];
    dividend_t[20] = dividend_t[19];
    if (!stage_sub_20[M]) begin
        merchant_t[20]  = {merchant_t[19][N_ACT-M-1:0], 1'b1};
        remainder_t[20] = stage_sub_20[M-1:0];
    end else begin
        merchant_t[20]  = {merchant_t[19][N_ACT-M-1:0], 1'b0};
        remainder_t[20] = {remainder_t[19], dividend_t[19][N_ACT-M-20]};
    end
end

wire [M:0] stage_sub_21 = {{remainder_t[20], dividend_t[20][N_ACT-M-21]}} - {1'b0, divisor_t[20]};
always @(posedge clk) begin
    divisor_t[21]  <= divisor_t[20];
    dividend_t[21] <= dividend_t[20];
    if (!stage_sub_21[M]) begin
        merchant_t[21]  <= {merchant_t[20][N_ACT-M-1:0], 1'b1};
        remainder_t[21] <= stage_sub_21[M-1:0];
    end else begin
        merchant_t[21]  <= {merchant_t[20][N_ACT-M-1:0], 1'b0};
        remainder_t[21] <= {remainder_t[20], dividend_t[20][N_ACT-M-21]};
    end
end

wire [M:0] stage_sub_22 = {{remainder_t[21], dividend_t[21][N_ACT-M-22]}} - {1'b0, divisor_t[21]};
always @(*) begin
    divisor_t[22]  = divisor_t[21];
    dividend_t[22] = dividend_t[21];
    if (!stage_sub_22[M]) begin
        merchant_t[22]  = {merchant_t[21][N_ACT-M-1:0], 1'b1};
        remainder_t[22] = stage_sub_22[M-1:0];
    end else begin
        merchant_t[22]  = {merchant_t[21][N_ACT-M-1:0], 1'b0};
        remainder_t[22] = {remainder_t[21], dividend_t[21][N_ACT-M-22]};
    end
end

wire [M:0] stage_sub_23 = {{remainder_t[22], dividend_t[22][N_ACT-M-23]}} - {1'b0, divisor_t[22]};
always @(*) begin
    divisor_t[23]  = divisor_t[22];
    dividend_t[23] = dividend_t[22];
    if (!stage_sub_23[M]) begin
        merchant_t[23]  = {merchant_t[22][N_ACT-M-1:0], 1'b1};
        remainder_t[23] = stage_sub_23[M-1:0];
    end else begin
        merchant_t[23]  = {merchant_t[22][N_ACT-M-1:0], 1'b0};
        remainder_t[23] = {remainder_t[22], dividend_t[22][N_ACT-M-23]};
    end
end

wire [M:0] stage_sub_24 = {{remainder_t[23], dividend_t[23][N_ACT-M-24]}} - {1'b0, divisor_t[23]};
always @(*) begin
    divisor_t[24]  = divisor_t[23];
    dividend_t[24] = dividend_t[23];
    if (!stage_sub_24[M]) begin
        merchant_t[24]  = {merchant_t[23][N_ACT-M-1:0], 1'b1};
        remainder_t[24] = stage_sub_24[M-1:0];
    end else begin
        merchant_t[24]  = {merchant_t[23][N_ACT-M-1:0], 1'b0};
        remainder_t[24] = {remainder_t[23], dividend_t[23][N_ACT-M-24]};
    end
end

wire [M:0] stage_sub_25 = {{remainder_t[24], dividend_t[24][N_ACT-M-25]}} - {1'b0, divisor_t[24]};
always @(*) begin
    divisor_t[25]  = divisor_t[24];
    dividend_t[25] = dividend_t[24];
    if (!stage_sub_25[M]) begin
        merchant_t[25]  = {merchant_t[24][N_ACT-M-1:0], 1'b1};
        remainder_t[25] = stage_sub_25[M-1:0];
    end else begin
        merchant_t[25]  = {merchant_t[24][N_ACT-M-1:0], 1'b0};
        remainder_t[25] = {remainder_t[24], dividend_t[24][N_ACT-M-25]};
    end
end

wire [M:0] stage_sub_26 = {{remainder_t[25], dividend_t[25][N_ACT-M-26]}} - {1'b0, divisor_t[25]};
always @(*) begin
    divisor_t[26]  = divisor_t[25];
    dividend_t[26] = dividend_t[25];
    if (!stage_sub_26[M]) begin
        merchant_t[26]  = {merchant_t[25][N_ACT-M-1:0], 1'b1};
        remainder_t[26] = stage_sub_26[M-1:0];
    end else begin
        merchant_t[26]  = {merchant_t[25][N_ACT-M-1:0], 1'b0};
        remainder_t[26] = {remainder_t[25], dividend_t[25][N_ACT-M-26]};
    end
end

wire [M:0] stage_sub_27 = {{remainder_t[26], dividend_t[26][N_ACT-M-27]}} - {1'b0, divisor_t[26]};
always @(posedge clk) begin
    divisor_t[27]  <= divisor_t[26];
    dividend_t[27] <= dividend_t[26];
    if (!stage_sub_27[M]) begin
        merchant_t[27]  <= {merchant_t[26][N_ACT-M-1:0], 1'b1};
        remainder_t[27] <= stage_sub_27[M-1:0];
    end else begin
        merchant_t[27]  <= {merchant_t[26][N_ACT-M-1:0], 1'b0};
        remainder_t[27] <= {remainder_t[26], dividend_t[26][N_ACT-M-27]};
    end
end

wire [M:0] stage_sub_28 = {{remainder_t[27], dividend_t[27][N_ACT-M-28]}} - {1'b0, divisor_t[27]};
always @(*) begin
    divisor_t[28]  = divisor_t[27];
    dividend_t[28] = dividend_t[27];
    if (!stage_sub_28[M]) begin
        merchant_t[28]  = {merchant_t[27][N_ACT-M-1:0], 1'b1};
        remainder_t[28] = stage_sub_28[M-1:0];
    end else begin
        merchant_t[28]  = {merchant_t[27][N_ACT-M-1:0], 1'b0};
        remainder_t[28] = {remainder_t[27], dividend_t[27][N_ACT-M-28]};
    end
end

wire [M:0] stage_sub_29 = {{remainder_t[28], dividend_t[28][N_ACT-M-29]}} - {1'b0, divisor_t[28]};
always @(*) begin
    divisor_t[29]  = divisor_t[28];
    dividend_t[29] = dividend_t[28];
    if (!stage_sub_29[M]) begin
        merchant_t[29]  = {merchant_t[28][N_ACT-M-1:0], 1'b1};
        remainder_t[29] = stage_sub_29[M-1:0];
    end else begin
        merchant_t[29]  = {merchant_t[28][N_ACT-M-1:0], 1'b0};
        remainder_t[29] = {remainder_t[28], dividend_t[28][N_ACT-M-29]};
    end
end

wire [M:0] stage_sub_30 = {{remainder_t[29], dividend_t[29][N_ACT-M-30]}} - {1'b0, divisor_t[29]};
always @(*) begin
    divisor_t[30]  = divisor_t[29];
    dividend_t[30] = dividend_t[29];
    if (!stage_sub_30[M]) begin
        merchant_t[30]  = {merchant_t[29][N_ACT-M-1:0], 1'b1};
        remainder_t[30] = stage_sub_30[M-1:0];
    end else begin
        merchant_t[30]  = {merchant_t[29][N_ACT-M-1:0], 1'b0};
        remainder_t[30] = {remainder_t[29], dividend_t[29][N_ACT-M-30]};
    end
end

wire [M:0] stage_sub_31 = {{remainder_t[30], dividend_t[30][N_ACT-M-31]}} - {1'b0, divisor_t[30]};
always @(*) begin
    divisor_t[31]  = divisor_t[30];
    dividend_t[31] = dividend_t[30];
    if (!stage_sub_31[M]) begin
        merchant_t[31]  = {merchant_t[30][N_ACT-M-1:0], 1'b1};
        remainder_t[31] = stage_sub_31[M-1:0];
    end else begin
        merchant_t[31]  = {merchant_t[30][N_ACT-M-1:0], 1'b0};
        remainder_t[31] = {remainder_t[30], dividend_t[30][N_ACT-M-31]};
    end
end

wire [M:0] stage_sub_32 = {{remainder_t[31], dividend_t[31][N_ACT-M-32]}} - {1'b0, divisor_t[31]};
always @(*) begin
    divisor_t[32]  = divisor_t[31];
    dividend_t[32] = dividend_t[31];
    if (!stage_sub_32[M]) begin
        merchant_t[32]  = {merchant_t[31][N_ACT-M-1:0], 1'b1};
        remainder_t[32] = stage_sub_32[M-1:0];
    end else begin
        merchant_t[32]  = {merchant_t[31][N_ACT-M-1:0], 1'b0};
        remainder_t[32] = {remainder_t[31], dividend_t[31][N_ACT-M-32]};
    end
end

wire [M:0] stage_sub_33 = {{remainder_t[32], dividend_t[32][N_ACT-M-33]}} - {1'b0, divisor_t[32]};
always @(posedge clk) begin
    divisor_t[33]  <= divisor_t[32];
    dividend_t[33] <= dividend_t[32];
    if (!stage_sub_33[M]) begin
        merchant_t[33]  <= {merchant_t[32][N_ACT-M-1:0], 1'b1};
        remainder_t[33] <= stage_sub_33[M-1:0];
    end else begin
        merchant_t[33]  <= {merchant_t[32][N_ACT-M-1:0], 1'b0};
        remainder_t[33] <= {remainder_t[32], dividend_t[32][N_ACT-M-33]};
    end
end

wire [M:0] stage_sub_34 = {{remainder_t[33], dividend_t[33][N_ACT-M-34]}} - {1'b0, divisor_t[33]};
always @(*) begin
    divisor_t[34]  = divisor_t[33];
    dividend_t[34] = dividend_t[33];
    if (!stage_sub_34[M]) begin
        merchant_t[34]  = {merchant_t[33][N_ACT-M-1:0], 1'b1};
        remainder_t[34] = stage_sub_34[M-1:0];
    end else begin
        merchant_t[34]  = {merchant_t[33][N_ACT-M-1:0], 1'b0};
        remainder_t[34] = {remainder_t[33], dividend_t[33][N_ACT-M-34]};
    end
end

wire [M:0] stage_sub_35 = {{remainder_t[34], dividend_t[34][N_ACT-M-35]}} - {1'b0, divisor_t[34]};
always @(*) begin
    divisor_t[35]  = divisor_t[34];
    dividend_t[35] = dividend_t[34];
    if (!stage_sub_35[M]) begin
        merchant_t[35]  = {merchant_t[34][N_ACT-M-1:0], 1'b1};
        remainder_t[35] = stage_sub_35[M-1:0];
    end else begin
        merchant_t[35]  = {merchant_t[34][N_ACT-M-1:0], 1'b0};
        remainder_t[35] = {remainder_t[34], dividend_t[34][N_ACT-M-35]};
    end
end

wire [M:0] stage_sub_36 = {{remainder_t[35], dividend_t[35][N_ACT-M-36]}} - {1'b0, divisor_t[35]};
always @(*) begin
    divisor_t[36]  = divisor_t[35];
    dividend_t[36] = dividend_t[35];
    if (!stage_sub_36[M]) begin
        merchant_t[36]  = {merchant_t[35][N_ACT-M-1:0], 1'b1};
        remainder_t[36] = stage_sub_36[M-1:0];
    end else begin
        merchant_t[36]  = {merchant_t[35][N_ACT-M-1:0], 1'b0};
        remainder_t[36] = {remainder_t[35], dividend_t[35][N_ACT-M-36]};
    end
end

wire [M:0] stage_sub_37 = {{remainder_t[36], dividend_t[36][N_ACT-M-37]}} - {1'b0, divisor_t[36]};
always @(*) begin
    divisor_t[37]  = divisor_t[36];
    dividend_t[37] = dividend_t[36];
    if (!stage_sub_37[M]) begin
        merchant_t[37]  = {merchant_t[36][N_ACT-M-1:0], 1'b1};
        remainder_t[37] = stage_sub_37[M-1:0];
    end else begin
        merchant_t[37]  = {merchant_t[36][N_ACT-M-1:0], 1'b0};
        remainder_t[37] = {remainder_t[36], dividend_t[36][N_ACT-M-37]};
    end
end

wire [M:0] stage_sub_38 = {{remainder_t[37], dividend_t[37][N_ACT-M-38]}} - {1'b0, divisor_t[37]};
always @(*) begin
    divisor_t[38]  = divisor_t[37];
    dividend_t[38] = dividend_t[37];
    if (!stage_sub_38[M]) begin
        merchant_t[38]  = {merchant_t[37][N_ACT-M-1:0], 1'b1};
        remainder_t[38] = stage_sub_38[M-1:0];
    end else begin
        merchant_t[38]  = {merchant_t[37][N_ACT-M-1:0], 1'b0};
        remainder_t[38] = {remainder_t[37], dividend_t[37][N_ACT-M-38]};
    end
end

assign merchant  = merchant_t[PIPE_DEPTH];
assign remainder = remainder_t[PIPE_DEPTH];

endmodule // div
