

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

// Restoring divider with pipeline registers arranged as |4|4|4|4|4|4

// Layernorm need 24-bit dividend / 18-bit divisor
// The result merchant may be 24-bit 
// we find from the msb of merchant to lsb of merchant
// Softmax need 39-bit dividend / 39-bit divisor
// The result merchant may only 6-bit(from golden pattern)
// so we dont need to find the merchant from msb for softmax
// we can find directly find merchant bit-23 ~ bit0
// so the dividend may not start from msb of dividend
// start from [39:23]

localparam integer PIPE_DEPTH = 23;
localparam MAX_WIDTH = 24;

reg [N_ACT-M-1:0] dividend_t [N_ACT-M:0];
reg [M-1:0]       divisor_t  [N_ACT-M:0];
reg [M-1:0]       remainder_t[N_ACT-M:0];
reg [N_ACT-M:0]   merchant_t [N_ACT-M:0];

wire [M:0] stage0_dividend = {22'b0, dividend[N-1:MAX_WIDTH-1]};//[39:23]
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

wire [M:0] stage_sub_1 = {{remainder_t[0], dividend_t[0][MAX_WIDTH-2]}} - {1'b0, divisor_t[0]};
always @(*) begin
    divisor_t[1]  = divisor_t[0];
    dividend_t[1] = dividend_t[0];
    if (!stage_sub_1[M]) begin
        merchant_t[1]  = {merchant_t[0][N_ACT-M-1:0], 1'b1};
        remainder_t[1] = stage_sub_1[M-1:0];
    end else begin
        merchant_t[1]  = {merchant_t[0][N_ACT-M-1:0], 1'b0};
        remainder_t[1] = {remainder_t[0], dividend_t[0][MAX_WIDTH-2]};
    end
end
wire [M:0] stage_sub_2 = {{remainder_t[1], dividend_t[1][MAX_WIDTH-3]}} - {1'b0, divisor_t[1]};

always @(*) begin
    divisor_t[2]  = divisor_t[1];
    dividend_t[2] = dividend_t[1];
    if (!stage_sub_2[M]) begin
        merchant_t[2]  = {merchant_t[1][N_ACT-M-1:0], 1'b1};
        remainder_t[2] = stage_sub_2[M-1:0];
    end else begin
        merchant_t[2]  = {merchant_t[1][N_ACT-M-1:0], 1'b0};
        remainder_t[2] = {remainder_t[1], dividend_t[1][MAX_WIDTH-3]};
    end
end
wire [M:0] stage_sub_3 = {{remainder_t[2], dividend_t[2][MAX_WIDTH-4]}} - {1'b0, divisor_t[2]};

always @(*) begin
    divisor_t[3]  = divisor_t[2];
    dividend_t[3] = dividend_t[2];
    if (!stage_sub_3[M]) begin
        merchant_t[3]  = {merchant_t[2][N_ACT-M-1:0], 1'b1};
        remainder_t[3] = stage_sub_3[M-1:0];
    end else begin
        merchant_t[3]  = {merchant_t[2][N_ACT-M-1:0], 1'b0};
        remainder_t[3] = {remainder_t[2], dividend_t[2][MAX_WIDTH-4]};
    end
end
wire [M:0] stage_sub_4 = {{remainder_t[3], dividend_t[3][MAX_WIDTH-5]}} - {1'b0, divisor_t[3]};

always @(posedge clk) begin
    divisor_t[4]  <= divisor_t[3];
    dividend_t[4] <= dividend_t[3];
    if (!stage_sub_4[M]) begin
        merchant_t[4]  <= {merchant_t[3][N_ACT-M-1:0], 1'b1};
        remainder_t[4] <= stage_sub_4[M-1:0];
    end else begin
        merchant_t[4]  <= {merchant_t[3][N_ACT-M-1:0], 1'b0};
        remainder_t[4] <= {remainder_t[3], dividend_t[3][MAX_WIDTH-5]};
    end
end
wire [M:0] stage_sub_5 = {{remainder_t[4], dividend_t[4][MAX_WIDTH-6]}} - {1'b0, divisor_t[4]};

always @(*) begin
    divisor_t[5]  = divisor_t[4];
    dividend_t[5] = dividend_t[4];
    if (!stage_sub_5[M]) begin
        merchant_t[5]  = {merchant_t[4][N_ACT-M-1:0], 1'b1};
        remainder_t[5] = stage_sub_5[M-1:0];
    end else begin
        merchant_t[5]  = {merchant_t[4][N_ACT-M-1:0], 1'b0};
        remainder_t[5] = {remainder_t[4], dividend_t[4][MAX_WIDTH-6]};
    end
end
wire [M:0] stage_sub_6 = {{remainder_t[5], dividend_t[5][MAX_WIDTH-7]}} - {1'b0, divisor_t[5]};

always @(*) begin
    divisor_t[6]  = divisor_t[5];
    dividend_t[6] = dividend_t[5];
    if (!stage_sub_6[M]) begin
        merchant_t[6]  = {merchant_t[5][N_ACT-M-1:0], 1'b1};
        remainder_t[6] = stage_sub_6[M-1:0];
    end else begin
        merchant_t[6]  = {merchant_t[5][N_ACT-M-1:0], 1'b0};
        remainder_t[6] = {remainder_t[5], dividend_t[5][MAX_WIDTH-7]};
    end
end
wire [M:0] stage_sub_7 = {{remainder_t[6], dividend_t[6][MAX_WIDTH-8]}} - {1'b0, divisor_t[6]};

always @(*) begin
    divisor_t[7]  = divisor_t[6];
    dividend_t[7] = dividend_t[6];
    if (!stage_sub_7[M]) begin
        merchant_t[7]  = {merchant_t[6][N_ACT-M-1:0], 1'b1};
        remainder_t[7] = stage_sub_7[M-1:0];
    end else begin
        merchant_t[7]  = {merchant_t[6][N_ACT-M-1:0], 1'b0};
        remainder_t[7] = {remainder_t[6], dividend_t[6][MAX_WIDTH-8]};
    end
end
wire [M:0] stage_sub_8 = {{remainder_t[7], dividend_t[7][MAX_WIDTH-9]}} - {1'b0, divisor_t[7]};

always @(posedge clk) begin
    divisor_t[8]  <= divisor_t[7];
    dividend_t[8] <= dividend_t[7];
    if (!stage_sub_8[M]) begin
        merchant_t[8]  <= {merchant_t[7][N_ACT-M-1:0], 1'b1};
        remainder_t[8] <= stage_sub_8[M-1:0];
    end else begin
        merchant_t[8]  <= {merchant_t[7][N_ACT-M-1:0], 1'b0};
        remainder_t[8] <= {remainder_t[7], dividend_t[7][MAX_WIDTH-9]};
    end
end
wire [M:0] stage_sub_9 = {{remainder_t[8], dividend_t[8][MAX_WIDTH-10]}} - {1'b0, divisor_t[8]};

always @(*) begin
    divisor_t[9]  = divisor_t[8];
    dividend_t[9] = dividend_t[8];
    if (!stage_sub_9[M]) begin
        merchant_t[9]  = {merchant_t[8][N_ACT-M-1:0], 1'b1};
        remainder_t[9] = stage_sub_9[M-1:0];
    end else begin
        merchant_t[9]  = {merchant_t[8][N_ACT-M-1:0], 1'b0};
        remainder_t[9] = {remainder_t[8], dividend_t[8][MAX_WIDTH-10]};
    end
end
wire [M:0] stage_sub_10 = {{remainder_t[9], dividend_t[9][MAX_WIDTH-11]}} - {1'b0, divisor_t[9]};

always @(*) begin
    divisor_t[10]  = divisor_t[9];
    dividend_t[10] = dividend_t[9];
    if (!stage_sub_10[M]) begin
        merchant_t[10]  = {merchant_t[9][N_ACT-M-1:0], 1'b1};
        remainder_t[10] = stage_sub_10[M-1:0];
    end else begin
        merchant_t[10]  = {merchant_t[9][N_ACT-M-1:0], 1'b0};
        remainder_t[10] = {remainder_t[9], dividend_t[9][MAX_WIDTH-11]};
    end
end
wire [M:0] stage_sub_11 = {{remainder_t[10], dividend_t[10][MAX_WIDTH-12]}} - {1'b0, divisor_t[10]};

always @(*) begin
    divisor_t[11]  = divisor_t[10];
    dividend_t[11] = dividend_t[10];
    if (!stage_sub_11[M]) begin
        merchant_t[11]  = {merchant_t[10][N_ACT-M-1:0], 1'b1};
        remainder_t[11] = stage_sub_11[M-1:0];
    end else begin
        merchant_t[11]  = {merchant_t[10][N_ACT-M-1:0], 1'b0};
        remainder_t[11] = {remainder_t[10], dividend_t[10][MAX_WIDTH-12]};
    end
end
wire [M:0] stage_sub_12 = {{remainder_t[11], dividend_t[11][MAX_WIDTH-13]}} - {1'b0, divisor_t[11]};

always @(posedge clk) begin
    divisor_t[12]  <= divisor_t[11];
    dividend_t[12] <= dividend_t[11];
    if (!stage_sub_12[M]) begin
        merchant_t[12]  <= {merchant_t[11][N_ACT-M-1:0], 1'b1};
        remainder_t[12] <= stage_sub_12[M-1:0];
    end else begin
        merchant_t[12]  <= {merchant_t[11][N_ACT-M-1:0], 1'b0};
        remainder_t[12] <= {remainder_t[11], dividend_t[11][MAX_WIDTH-13]};
    end
end
wire [M:0] stage_sub_13 = {{remainder_t[12], dividend_t[12][MAX_WIDTH-14]}} - {1'b0, divisor_t[12]};

always @(*) begin
    divisor_t[13]  = divisor_t[12];
    dividend_t[13] = dividend_t[12];
    if (!stage_sub_13[M]) begin
        merchant_t[13]  = {merchant_t[12][N_ACT-M-1:0], 1'b1};
        remainder_t[13] = stage_sub_13[M-1:0];
    end else begin
        merchant_t[13]  = {merchant_t[12][N_ACT-M-1:0], 1'b0};
        remainder_t[13] = {remainder_t[12], dividend_t[12][MAX_WIDTH-14]};
    end
end
wire [M:0] stage_sub_14 = {{remainder_t[13], dividend_t[13][MAX_WIDTH-15]}} - {1'b0, divisor_t[13]};

always @(*) begin
    divisor_t[14]  = divisor_t[13];
    dividend_t[14] = dividend_t[13];
    if (!stage_sub_14[M]) begin
        merchant_t[14]  = {merchant_t[13][N_ACT-M-1:0], 1'b1};
        remainder_t[14] = stage_sub_14[M-1:0];
    end else begin
        merchant_t[14]  = {merchant_t[13][N_ACT-M-1:0], 1'b0};
        remainder_t[14] = {remainder_t[13], dividend_t[13][MAX_WIDTH-15]};
    end
end
wire [M:0] stage_sub_15 = {{remainder_t[14], dividend_t[14][MAX_WIDTH-16]}} - {1'b0, divisor_t[14]};

always @(*) begin
    divisor_t[15]  = divisor_t[14];
    dividend_t[15] = dividend_t[14];
    if (!stage_sub_15[M]) begin
        merchant_t[15]  = {merchant_t[14][N_ACT-M-1:0], 1'b1};
        remainder_t[15] = stage_sub_15[M-1:0];
    end else begin
        merchant_t[15]  = {merchant_t[14][N_ACT-M-1:0], 1'b0};
        remainder_t[15] = {remainder_t[14], dividend_t[14][MAX_WIDTH-16]};
    end
end
wire [M:0] stage_sub_16 = {{remainder_t[15], dividend_t[15][MAX_WIDTH-17]}} - {1'b0, divisor_t[15]};

always @(posedge clk) begin
    divisor_t[16]  <= divisor_t[15];
    dividend_t[16] <= dividend_t[15];
    if (!stage_sub_16[M]) begin
        merchant_t[16]  <= {merchant_t[15][N_ACT-M-1:0], 1'b1};
        remainder_t[16] <= stage_sub_16[M-1:0];
    end else begin
        merchant_t[16]  <= {merchant_t[15][N_ACT-M-1:0], 1'b0};
        remainder_t[16] <= {remainder_t[15], dividend_t[15][MAX_WIDTH-17]};
    end
end
wire [M:0] stage_sub_17 = {{remainder_t[16], dividend_t[16][MAX_WIDTH-18]}} - {1'b0, divisor_t[16]};

always @(*) begin
    divisor_t[17]  = divisor_t[16];
    dividend_t[17] = dividend_t[16];
    if (!stage_sub_17[M]) begin
        merchant_t[17]  = {merchant_t[16][N_ACT-M-1:0], 1'b1};
        remainder_t[17] = stage_sub_17[M-1:0];
    end else begin
        merchant_t[17]  = {merchant_t[16][N_ACT-M-1:0], 1'b0};
        remainder_t[17] = {remainder_t[16], dividend_t[16][MAX_WIDTH-18]};
    end
end
wire [M:0] stage_sub_18 = {{remainder_t[17], dividend_t[17][MAX_WIDTH-19]}} - {1'b0, divisor_t[17]};

always @(*) begin
    divisor_t[18]  = divisor_t[17];
    dividend_t[18] = dividend_t[17];
    if (!stage_sub_18[M]) begin
        merchant_t[18]  = {merchant_t[17][N_ACT-M-1:0], 1'b1};
        remainder_t[18] = stage_sub_18[M-1:0];
    end else begin
        merchant_t[18]  = {merchant_t[17][N_ACT-M-1:0], 1'b0};
        remainder_t[18] = {remainder_t[17], dividend_t[17][MAX_WIDTH-19]};
    end
end
wire [M:0] stage_sub_19 = {{remainder_t[18], dividend_t[18][MAX_WIDTH-20]}} - {1'b0, divisor_t[18]};

always @(*) begin
    divisor_t[19]  = divisor_t[18];
    dividend_t[19] = dividend_t[18];
    if (!stage_sub_19[M]) begin
        merchant_t[19]  = {merchant_t[18][N_ACT-M-1:0], 1'b1};
        remainder_t[19] = stage_sub_19[M-1:0];
    end else begin
        merchant_t[19]  = {merchant_t[18][N_ACT-M-1:0], 1'b0};
        remainder_t[19] = {remainder_t[18], dividend_t[18][MAX_WIDTH-20]};
    end
end
wire [M:0] stage_sub_20 = {{remainder_t[19], dividend_t[19][MAX_WIDTH-21]}} - {1'b0, divisor_t[19]};

always @(posedge clk) begin
    divisor_t[20]  <= divisor_t[19];
    dividend_t[20] <= dividend_t[19];
    if (!stage_sub_20[M]) begin
        merchant_t[20]  <= {merchant_t[19][N_ACT-M-1:0], 1'b1};
        remainder_t[20] <= stage_sub_20[M-1:0];
    end else begin
        merchant_t[20]  <= {merchant_t[19][N_ACT-M-1:0], 1'b0};
        remainder_t[20] <= {remainder_t[19], dividend_t[19][MAX_WIDTH-21]};
    end
end
wire [M:0] stage_sub_21 = {{remainder_t[20], dividend_t[20][MAX_WIDTH-22]}} - {1'b0, divisor_t[20]};

always @(*) begin
    divisor_t[21]  = divisor_t[20];
    dividend_t[21] = dividend_t[20];
    if (!stage_sub_21[M]) begin
        merchant_t[21]  = {merchant_t[20][N_ACT-M-1:0], 1'b1};
        remainder_t[21] = stage_sub_21[M-1:0];
    end else begin
        merchant_t[21]  = {merchant_t[20][N_ACT-M-1:0], 1'b0};
        remainder_t[21] = {remainder_t[20], dividend_t[20][MAX_WIDTH-22]};
    end
end
wire [M:0] stage_sub_22 = {{remainder_t[21], dividend_t[21][MAX_WIDTH-23]}} - {1'b0, divisor_t[21]};

always @(*) begin
    divisor_t[22]  = divisor_t[21];
    dividend_t[22] = dividend_t[21];
    if (!stage_sub_22[M]) begin
        merchant_t[22]  = {merchant_t[21][N_ACT-M-1:0], 1'b1};
        remainder_t[22] = stage_sub_22[M-1:0];
    end else begin
        merchant_t[22]  = {merchant_t[21][N_ACT-M-1:0], 1'b0};
        remainder_t[22] = {remainder_t[21], dividend_t[21][MAX_WIDTH-23]};
    end
end
wire [M:0] stage_sub_23 = {{remainder_t[22], dividend_t[22][MAX_WIDTH-24]}} - {1'b0, divisor_t[22]};

always @(*) begin
    divisor_t[23]  = divisor_t[22];
    dividend_t[23] = dividend_t[22];
    if (!stage_sub_23[M]) begin
        merchant_t[23]  = {merchant_t[22][N_ACT-M-1:0], 1'b1};
        remainder_t[23] = stage_sub_23[M-1:0];
    end else begin
        merchant_t[23]  = {merchant_t[22][N_ACT-M-1:0], 1'b0};
        remainder_t[23] = {remainder_t[22], dividend_t[22][MAX_WIDTH-24]};
    end
end
assign merchant  = merchant_t[PIPE_DEPTH];
assign remainder = remainder_t[PIPE_DEPTH];

endmodule // div
