module div #(
    parameter N = 24,
    parameter M = 18,
    parameter N_ACT = M+N-1
)(
    input clk,
    input [N-1:0] dividend,
    input [M-1:0] divisor,
    output [N-1:0] merchant,
    output [M-1:0] remainder
);
// 3-stage pipeline divider
// Signed inputs are converted to absolute values for unsigned division
reg [23:0] unsign_dividend;
reg [17:0] unsign_divisor;

localparam integer PIPE_DEPTH = N_ACT - M;

reg [N_ACT-M-1:0] dividend_t [N_ACT-M:0];
reg [M-1:0]       divisor_t  [N_ACT-M:0];
reg [M-1:0]       remainder_t[N_ACT-M:0];
reg [N_ACT-M:0]   merchant_t [N_ACT-M:0];

always @(*) begin
    unsign_dividend = (dividend[23] == 1'b1) ? ~dividend + 1'b1 : dividend;
    unsign_divisor  = (divisor[17]  == 1'b1) ? ~divisor  + 1'b1 : divisor;
end

wire [M:0] stage0_dividend = {{(M){1'b0}}, unsign_dividend[N-1]};
wire [M-1:0] stage0_divisor = unsign_divisor;
wire [N_ACT-M:0] stage0_merchant_ci = {(N_ACT-M+1){1'b0}};
wire [N_ACT-M-1:0] stage0_dividend_ci = unsign_dividend[N_ACT-M-1:0];

always @(posedge clk) begin
    divisor_t[0]  <= stage0_divisor;
    dividend_t[0] <= stage0_dividend_ci;
    if (stage0_dividend >= {1'b0, stage0_divisor}) begin
        merchant_t[0]  <= {stage0_merchant_ci[N_ACT-M-1:0], 1'b1};
        remainder_t[0] <= stage0_dividend - {1'b0, stage0_divisor};
    end else begin
        merchant_t[0]  <= {stage0_merchant_ci[N_ACT-M-1:0], 1'b0};
        remainder_t[0] <= stage0_dividend;
    end
end

always @(*) begin
    divisor_t[1]  = divisor_t[0];
    dividend_t[1] = dividend_t[0];
    if ({remainder_t[0], dividend_t[0][22]} >= {1'b0, divisor_t[0]}) begin
        merchant_t[1]  = {merchant_t[0][N_ACT-M-1:0], 1'b1};
        remainder_t[1] = {remainder_t[0], dividend_t[0][22]} - {1'b0, divisor_t[0]};
    end else begin
        merchant_t[1]  = {merchant_t[0][N_ACT-M-1:0], 1'b0};
        remainder_t[1] = {remainder_t[0], dividend_t[0][22]};
    end
end

always @(*) begin
    divisor_t[2]  = divisor_t[1];
    dividend_t[2] = dividend_t[1];
    if ({remainder_t[1], dividend_t[1][21]} >= {1'b0, divisor_t[1]}) begin
        merchant_t[2]  = {merchant_t[1][N_ACT-M-1:0], 1'b1};
        remainder_t[2] = {remainder_t[1], dividend_t[1][21]} - {1'b0, divisor_t[1]};
    end else begin
        merchant_t[2]  = {merchant_t[1][N_ACT-M-1:0], 1'b0};
        remainder_t[2] = {remainder_t[1], dividend_t[1][21]};
    end
end

always @(*) begin
    divisor_t[3]  = divisor_t[2];
    dividend_t[3] = dividend_t[2];
    if ({remainder_t[2], dividend_t[2][20]} >= {1'b0, divisor_t[2]}) begin
        merchant_t[3]  = {merchant_t[2][N_ACT-M-1:0], 1'b1};
        remainder_t[3] = {remainder_t[2], dividend_t[2][20]} - {1'b0, divisor_t[2]};
    end else begin
        merchant_t[3]  = {merchant_t[2][N_ACT-M-1:0], 1'b0};
        remainder_t[3] = {remainder_t[2], dividend_t[2][20]};
    end
end

always @(posedge clk) begin
    divisor_t[4]  <= divisor_t[3];
    dividend_t[4] <= dividend_t[3];
    if ({remainder_t[3], dividend_t[3][19]} >= {1'b0, divisor_t[3]}) begin
        merchant_t[4]  <= {merchant_t[3][N_ACT-M-1:0], 1'b1};
        remainder_t[4] <= {remainder_t[3], dividend_t[3][19]} - {1'b0, divisor_t[3]};
    end else begin
        merchant_t[4]  <= {merchant_t[3][N_ACT-M-1:0], 1'b0};
        remainder_t[4] <= {remainder_t[3], dividend_t[3][19]};
    end
end

always @(*) begin
    divisor_t[5]  = divisor_t[4];
    dividend_t[5] = dividend_t[4];
    if ({remainder_t[4], dividend_t[4][18]} >= {1'b0, divisor_t[4]}) begin
        merchant_t[5]  = {merchant_t[4][N_ACT-M-1:0], 1'b1};
        remainder_t[5] = {remainder_t[4], dividend_t[4][18]} - {1'b0, divisor_t[4]};
    end else begin
        merchant_t[5]  = {merchant_t[4][N_ACT-M-1:0], 1'b0};
        remainder_t[5] = {remainder_t[4], dividend_t[4][18]};
    end
end

always @(*) begin
    divisor_t[6]  = divisor_t[5];
    dividend_t[6] = dividend_t[5];
    if ({remainder_t[5], dividend_t[5][17]} >= {1'b0, divisor_t[5]}) begin
        merchant_t[6]  = {merchant_t[5][N_ACT-M-1:0], 1'b1};
        remainder_t[6] = {remainder_t[5], dividend_t[5][17]} - {1'b0, divisor_t[5]};
    end else begin
        merchant_t[6]  = {merchant_t[5][N_ACT-M-1:0], 1'b0};
        remainder_t[6] = {remainder_t[5], dividend_t[5][17]};
    end
end

always @(*) begin
    divisor_t[7]  = divisor_t[6];
    dividend_t[7] = dividend_t[6];
    if ({remainder_t[6], dividend_t[6][16]} >= {1'b0, divisor_t[6]}) begin
        merchant_t[7]  = {merchant_t[6][N_ACT-M-1:0], 1'b1};
        remainder_t[7] = {remainder_t[6], dividend_t[6][16]} - {1'b0, divisor_t[6]};
    end else begin
        merchant_t[7]  = {merchant_t[6][N_ACT-M-1:0], 1'b0};
        remainder_t[7] = {remainder_t[6], dividend_t[6][16]};
    end
end

always @(posedge clk) begin
    divisor_t[8]  <= divisor_t[7];
    dividend_t[8] <= dividend_t[7];
    if ({remainder_t[7], dividend_t[7][15]} >= {1'b0, divisor_t[7]}) begin
        merchant_t[8]  <= {merchant_t[7][N_ACT-M-1:0], 1'b1};
        remainder_t[8] <= {remainder_t[7], dividend_t[7][15]} - {1'b0, divisor_t[7]};
    end else begin
        merchant_t[8]  <= {merchant_t[7][N_ACT-M-1:0], 1'b0};
        remainder_t[8] <= {remainder_t[7], dividend_t[7][15]};
    end
end

always @(*) begin
    divisor_t[9]  = divisor_t[8];
    dividend_t[9] = dividend_t[8];
    if ({remainder_t[8], dividend_t[8][14]} >= {1'b0, divisor_t[8]}) begin
        merchant_t[9]  = {merchant_t[8][N_ACT-M-1:0], 1'b1};
        remainder_t[9] = {remainder_t[8], dividend_t[8][14]} - {1'b0, divisor_t[8]};
    end else begin
        merchant_t[9]  = {merchant_t[8][N_ACT-M-1:0], 1'b0};
        remainder_t[9] = {remainder_t[8], dividend_t[8][14]};
    end
end

always @(*) begin
    divisor_t[10]  = divisor_t[9];
    dividend_t[10] = dividend_t[9];
    if ({remainder_t[9], dividend_t[9][13]} >= {1'b0, divisor_t[9]}) begin
        merchant_t[10]  = {merchant_t[9][N_ACT-M-1:0], 1'b1};
        remainder_t[10] = {remainder_t[9], dividend_t[9][13]} - {1'b0, divisor_t[9]};
    end else begin
        merchant_t[10]  = {merchant_t[9][N_ACT-M-1:0], 1'b0};
        remainder_t[10] = {remainder_t[9], dividend_t[9][13]};
    end
end

always @(*) begin
    divisor_t[11]  = divisor_t[10];
    dividend_t[11] = dividend_t[10];
    if ({remainder_t[10], dividend_t[10][12]} >= {1'b0, divisor_t[10]}) begin
        merchant_t[11]  = {merchant_t[10][N_ACT-M-1:0], 1'b1};
        remainder_t[11] = {remainder_t[10], dividend_t[10][12]} - {1'b0, divisor_t[10]};
    end else begin
        merchant_t[11]  = {merchant_t[10][N_ACT-M-1:0], 1'b0};
        remainder_t[11] = {remainder_t[10], dividend_t[10][12]};
    end
end

always @(posedge clk) begin
    divisor_t[12]  <= divisor_t[11];
    dividend_t[12] <= dividend_t[11];
    if ({remainder_t[11], dividend_t[11][11]} >= {1'b0, divisor_t[11]}) begin
        merchant_t[12]  <= {merchant_t[11][N_ACT-M-1:0], 1'b1};
        remainder_t[12] <= {remainder_t[11], dividend_t[11][11]} - {1'b0, divisor_t[11]};
    end else begin
        merchant_t[12]  <= {merchant_t[11][N_ACT-M-1:0], 1'b0};
        remainder_t[12] <= {remainder_t[11], dividend_t[11][11]};
    end
end

always @(*) begin
    divisor_t[13]  = divisor_t[12];
    dividend_t[13] = dividend_t[12];
    if ({remainder_t[12], dividend_t[12][10]} >= {1'b0, divisor_t[12]}) begin
        merchant_t[13]  = {merchant_t[12][N_ACT-M-1:0], 1'b1};
        remainder_t[13] = {remainder_t[12], dividend_t[12][10]} - {1'b0, divisor_t[12]};
    end else begin
        merchant_t[13]  = {merchant_t[12][N_ACT-M-1:0], 1'b0};
        remainder_t[13] = {remainder_t[12], dividend_t[12][10]};
    end
end

always @(*) begin
    divisor_t[14]  = divisor_t[13];
    dividend_t[14] = dividend_t[13];
    if ({remainder_t[13], dividend_t[13][9]} >= {1'b0, divisor_t[13]}) begin
        merchant_t[14]  = {merchant_t[13][N_ACT-M-1:0], 1'b1};
        remainder_t[14] = {remainder_t[13], dividend_t[13][9]} - {1'b0, divisor_t[13]};
    end else begin
        merchant_t[14]  = {merchant_t[13][N_ACT-M-1:0], 1'b0};
        remainder_t[14] = {remainder_t[13], dividend_t[13][9]};
    end
end

always @(*) begin
    divisor_t[15]  = divisor_t[14];
    dividend_t[15] = dividend_t[14];
    if ({remainder_t[14], dividend_t[14][8]} >= {1'b0, divisor_t[14]}) begin
        merchant_t[15]  = {merchant_t[14][N_ACT-M-1:0], 1'b1};
        remainder_t[15] = {remainder_t[14], dividend_t[14][8]} - {1'b0, divisor_t[14]};
    end else begin
        merchant_t[15]  = {merchant_t[14][N_ACT-M-1:0], 1'b0};
        remainder_t[15] = {remainder_t[14], dividend_t[14][8]};
    end
end

always @(posedge clk) begin
    divisor_t[16]  <= divisor_t[15];
    dividend_t[16] <= dividend_t[15];
    if ({remainder_t[15], dividend_t[15][7]} >= {1'b0, divisor_t[15]}) begin
        merchant_t[16]  <= {merchant_t[15][N_ACT-M-1:0], 1'b1};
        remainder_t[16] <= {remainder_t[15], dividend_t[15][7]} - {1'b0, divisor_t[15]};
    end else begin
        merchant_t[16]  <= {merchant_t[15][N_ACT-M-1:0], 1'b0};
        remainder_t[16] <= {remainder_t[15], dividend_t[15][7]};
    end
end

always @(*) begin
    divisor_t[17]  = divisor_t[16];
    dividend_t[17] = dividend_t[16];
    if ({remainder_t[16], dividend_t[16][6]} >= {1'b0, divisor_t[16]}) begin
        merchant_t[17]  = {merchant_t[16][N_ACT-M-1:0], 1'b1};
        remainder_t[17] = {remainder_t[16], dividend_t[16][6]} - {1'b0, divisor_t[16]};
    end else begin
        merchant_t[17]  = {merchant_t[16][N_ACT-M-1:0], 1'b0};
        remainder_t[17] = {remainder_t[16], dividend_t[16][6]};
    end
end

always @(*) begin
    divisor_t[18]  = divisor_t[17];
    dividend_t[18] = dividend_t[17];
    if ({remainder_t[17], dividend_t[17][5]} >= {1'b0, divisor_t[17]}) begin
        merchant_t[18]  = {merchant_t[17][N_ACT-M-1:0], 1'b1};
        remainder_t[18] = {remainder_t[17], dividend_t[17][5]} - {1'b0, divisor_t[17]};
    end else begin
        merchant_t[18]  = {merchant_t[17][N_ACT-M-1:0], 1'b0};
        remainder_t[18] = {remainder_t[17], dividend_t[17][5]};
    end
end

always @(*) begin
    divisor_t[19]  = divisor_t[18];
    dividend_t[19] = dividend_t[18];
    if ({remainder_t[18], dividend_t[18][4]} >= {1'b0, divisor_t[18]}) begin
        merchant_t[19]  = {merchant_t[18][N_ACT-M-1:0], 1'b1};
        remainder_t[19] = {remainder_t[18], dividend_t[18][4]} - {1'b0, divisor_t[18]};
    end else begin
        merchant_t[19]  = {merchant_t[18][N_ACT-M-1:0], 1'b0};
        remainder_t[19] = {remainder_t[18], dividend_t[18][4]};
    end
end

always @(posedge clk) begin
    divisor_t[20]  <= divisor_t[19];
    dividend_t[20] <= dividend_t[19];
    if ({remainder_t[19], dividend_t[19][3]} >= {1'b0, divisor_t[19]}) begin
        merchant_t[20]  <= {merchant_t[19][N_ACT-M-1:0], 1'b1};
        remainder_t[20] <= {remainder_t[19], dividend_t[19][3]} - {1'b0, divisor_t[19]};
    end else begin
        merchant_t[20]  <= {merchant_t[19][N_ACT-M-1:0], 1'b0};
        remainder_t[20] <= {remainder_t[19], dividend_t[19][3]};
    end
end

always @(*) begin
    divisor_t[21]  = divisor_t[20];
    dividend_t[21] = dividend_t[20];
    if ({remainder_t[20], dividend_t[20][2]} >= {1'b0, divisor_t[20]}) begin
        merchant_t[21]  = {merchant_t[20][N_ACT-M-1:0], 1'b1};
        remainder_t[21] = {remainder_t[20], dividend_t[20][2]} - {1'b0, divisor_t[20]};
    end else begin
        merchant_t[21]  = {merchant_t[20][N_ACT-M-1:0], 1'b0};
        remainder_t[21] = {remainder_t[20], dividend_t[20][2]};
    end
end

always @(*) begin
    divisor_t[22]  = divisor_t[21];
    dividend_t[22] = dividend_t[21];
    if ({remainder_t[21], dividend_t[21][1]} >= {1'b0, divisor_t[21]}) begin
        merchant_t[22]  = {merchant_t[21][N_ACT-M-1:0], 1'b1};
        remainder_t[22] = {remainder_t[21], dividend_t[21][1]} - {1'b0, divisor_t[21]};
    end else begin
        merchant_t[22]  = {merchant_t[21][N_ACT-M-1:0], 1'b0};
        remainder_t[22] = {remainder_t[21], dividend_t[21][1]};
    end
end

always @(*) begin
    divisor_t[23]  = divisor_t[22];
    dividend_t[23] = dividend_t[22];
    if ({remainder_t[22], dividend_t[22][0]} >= {1'b0, divisor_t[22]}) begin
        merchant_t[23]  = {merchant_t[22][N_ACT-M-1:0], 1'b1};
        remainder_t[23] = {remainder_t[22], dividend_t[22][0]} - {1'b0, divisor_t[22]};
    end else begin
        merchant_t[23]  = {merchant_t[22][N_ACT-M-1:0], 1'b0};
        remainder_t[23] = {remainder_t[22], dividend_t[22][0]};
    end
end

assign merchant  = merchant_t[PIPE_DEPTH];
assign remainder = remainder_t[PIPE_DEPTH];

endmodule // div
