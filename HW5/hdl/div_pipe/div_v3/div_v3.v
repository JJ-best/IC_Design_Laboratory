module div_v3 #(
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
// Stage0~5 : wide path (M-bit)
// Stage6~23: narrow path (explicit 25-bit) for area saving

localparam integer PIPE_DEPTH = 23;
localparam integer MAX_WIDTH  = 24;
localparam integer NAR_WIDTH  = 25; // remainder/divisor width for stage6+

// wide path registers (stage 0~5)
reg [M-1:0]         divisor_w   [0:5];
reg [M-1:0]         remainder_w [0:5];
reg [MAX_WIDTH-1:0] dividend_w  [0:5];

// narrow path registers (stage 6~23)
reg [NAR_WIDTH-1:0] divisor_n   [6:PIPE_DEPTH];
reg [NAR_WIDTH-1:0] remainder_n [6:PIPE_DEPTH];
reg [NAR_WIDTH-1:0] dividend_n  [6:PIPE_DEPTH];

// merchant only needs 25 bits (layernorm <=24b, softmax <=6b)
reg [NAR_WIDTH-1:0] merchant_t [0:PIPE_DEPTH];
reg [PIPE_DEPTH:0]  mode_sel_t;
reg                 dividend_sel[0:PIPE_DEPTH];

reg [M:0]            stage_sub_w[0:5];
reg [NAR_WIDTH:0]    stage_sub_n[6:PIPE_DEPTH];

//---------------- stage 0 ----------------
wire [M:0] stage0_dividend = (mode_sel)?
                             {{(M+1-(N-5)){1'b0}}, dividend[N-1:5]} :               // Softmax uses [39:5]
                             {{(M+1-MAX_WIDTH){1'b0}}, dividend[N-1:MAX_WIDTH-1]};  // Layernorm uses [39:23]
wire [M-1:0] stage0_divisor = divisor;

always @(*) begin
    stage_sub_w[0] = stage0_dividend - {1'b0, stage0_divisor};
end

always @(posedge clk) begin
    divisor_w[0]   <= stage0_divisor;
    dividend_w[0]  <= dividend[MAX_WIDTH-1:0];
    mode_sel_t[0]  <= mode_sel;
    if (!stage_sub_w[0][M]) begin
        merchant_t[0]  <= {merchant_t[0][NAR_WIDTH-1:1], 1'b1};
        remainder_w[0] <= stage_sub_w[0][M-1:0];
    end else begin
        merchant_t[0]  <= {NAR_WIDTH{1'b0}};
        remainder_w[0] <= stage0_dividend[M-1:0];
    end
end

//---------------- stage 1 ----------------
always @(*) begin
    dividend_sel[0] = (mode_sel_t[0])? dividend_w[0][4] : dividend_w[0][22];
    stage_sub_w[1]  = {{remainder_w[0], dividend_sel[0]}} - {1'b0, divisor_w[0]};
end
always @(*) begin
    divisor_w[1]  = divisor_w[0];
    dividend_w[1] = dividend_w[0];
    mode_sel_t[1] = mode_sel_t[0];
    if (!stage_sub_w[1][M]) begin
        merchant_t[1]  = {merchant_t[0][NAR_WIDTH-2:0], 1'b1};
        remainder_w[1] = stage_sub_w[1][M-1:0];
    end else begin
        merchant_t[1]  = {merchant_t[0][NAR_WIDTH-2:0], 1'b0};
        remainder_w[1] = {remainder_w[0][M-2:0], dividend_sel[0]};
    end
end

//---------------- stage 2 ----------------
always @(*) begin
    dividend_sel[1] = (mode_sel_t[1])? dividend_w[1][3] : dividend_w[1][21];
    stage_sub_w[2]  = {{remainder_w[1], dividend_sel[1]}} - {1'b0, divisor_w[1]};
end
always @(*) begin
    divisor_w[2]  = divisor_w[1];
    dividend_w[2] = dividend_w[1];
    mode_sel_t[2] = mode_sel_t[1];
    if (!stage_sub_w[2][M]) begin
        merchant_t[2]  = {merchant_t[1][NAR_WIDTH-2:0], 1'b1};
        remainder_w[2] = stage_sub_w[2][M-1:0];
    end else begin
        merchant_t[2]  = {merchant_t[1][NAR_WIDTH-2:0], 1'b0};
        remainder_w[2] = {remainder_w[1][M-2:0], dividend_sel[1]};
    end
end

//---------------- stage 3 ----------------
always @(*) begin
    dividend_sel[2] = (mode_sel_t[2])? dividend_w[2][2] : dividend_w[2][20];
    stage_sub_w[3]  = {{remainder_w[2], dividend_sel[2]}} - {1'b0, divisor_w[2]};
end
always @(*) begin
    divisor_w[3]  = divisor_w[2];
    dividend_w[3] = dividend_w[2];
    mode_sel_t[3] = mode_sel_t[2];
    if (!stage_sub_w[3][M]) begin
        merchant_t[3]  = {merchant_t[2][NAR_WIDTH-2:0], 1'b1};
        remainder_w[3] = stage_sub_w[3][M-1:0];
    end else begin
        merchant_t[3]  = {merchant_t[2][NAR_WIDTH-2:0], 1'b0};
        remainder_w[3] = {remainder_w[2][M-2:0], dividend_sel[2]};
    end
end

//---------------- stage 4 ----------------
always @(*) begin
    dividend_sel[3] = (mode_sel_t[3])? dividend_w[3][1] : dividend_w[3][19];
    stage_sub_w[4]  = {{remainder_w[3], dividend_sel[3]}} - {1'b0, divisor_w[3]};
end
always @(posedge clk) begin
    divisor_w[4]  <= divisor_w[3];
    dividend_w[4] <= dividend_w[3];
    mode_sel_t[4] <= mode_sel_t[3];
    if (!stage_sub_w[4][M]) begin
        merchant_t[4]  <= {merchant_t[3][NAR_WIDTH-2:0], 1'b1};
        remainder_w[4] <= stage_sub_w[4][M-1:0];
    end else begin
        merchant_t[4]  <= {merchant_t[3][NAR_WIDTH-2:0], 1'b0};
        remainder_w[4] <= {remainder_w[3][M-2:0], dividend_sel[3]};
    end
end

//---------------- stage 5 ----------------
always @(*) begin
    dividend_sel[4] = (mode_sel_t[4])? dividend_w[4][0] : dividend_w[4][18];
    stage_sub_w[5]  = {{remainder_w[4], dividend_sel[4]}} - {1'b0, divisor_w[4]};
end
always @(*) begin
    divisor_w[5]  = divisor_w[4];
    dividend_w[5] = dividend_w[4];
    mode_sel_t[5] = mode_sel_t[4];
    if (!stage_sub_w[5][M]) begin
        merchant_t[5]  = {merchant_t[4][NAR_WIDTH-2:0], 1'b1};
        remainder_w[5] = stage_sub_w[5][M-1:0];
    end else begin
        merchant_t[5]  = {merchant_t[4][NAR_WIDTH-2:0], 1'b0};
        remainder_w[5] = {remainder_w[4][M-2:0], dividend_sel[4]};
    end
end

//---------------- stage 6 ----------------
always @(*) begin
    divisor_n[6]   = divisor_w[5][NAR_WIDTH-1:0];
    dividend_n[6]  = dividend_w[5];
    mode_sel_t[6]  = mode_sel_t[5];
    stage_sub_n[6] = {{remainder_w[5][NAR_WIDTH-1:0], dividend_n[6][MAX_WIDTH-7]}} - {1'b0, divisor_n[6]};
end
always @(*) begin
    if (mode_sel_t[5]) begin
        merchant_t[6]  = merchant_t[5];
        remainder_n[6] = remainder_w[5][NAR_WIDTH-1:0];
    end else if (!stage_sub_n[6][NAR_WIDTH]) begin
        merchant_t[6]  = {merchant_t[5][NAR_WIDTH-2:0], 1'b1};
        remainder_n[6] = stage_sub_n[6][NAR_WIDTH-1:0];
    end else begin
        merchant_t[6]  = {merchant_t[5][NAR_WIDTH-2:0], 1'b0};
        remainder_n[6] = {remainder_w[5][NAR_WIDTH-2:0], dividend_n[6][MAX_WIDTH-7]};
    end
end

//---------------- stage 7 ----------------
always @(*) begin
    divisor_n[7]   = divisor_n[6];
    dividend_n[7]  = dividend_n[6];
    mode_sel_t[7]  = mode_sel_t[6];
    stage_sub_n[7] = {{remainder_n[6], dividend_n[6][MAX_WIDTH-8]}} - {1'b0, divisor_n[6]};
end
always @(*) begin
    if (mode_sel_t[6]) begin
        merchant_t[7]  = merchant_t[6];
        remainder_n[7] = remainder_n[6];
    end else if (!stage_sub_n[7][NAR_WIDTH]) begin
        merchant_t[7]  = {merchant_t[6][NAR_WIDTH-2:0], 1'b1};
        remainder_n[7] = stage_sub_n[7][NAR_WIDTH-1:0];
    end else begin
        merchant_t[7]  = {merchant_t[6][NAR_WIDTH-2:0], 1'b0};
        remainder_n[7] = {remainder_n[6][NAR_WIDTH-2:0], dividend_n[6][MAX_WIDTH-8]};
    end
end

//---------------- stage 8 ----------------
always @(*) begin
    divisor_n[8]   = divisor_n[7];
    dividend_n[8]  = dividend_n[7];
    mode_sel_t[8]  = mode_sel_t[7];
    stage_sub_n[8] = {{remainder_n[7], dividend_n[7][MAX_WIDTH-9]}} - {1'b0, divisor_n[7]};
end
always @(posedge clk) begin
    if (mode_sel_t[7]) begin
        merchant_t[8]  <= merchant_t[7];
        remainder_n[8] <= remainder_n[7];
    end else if (!stage_sub_n[8][NAR_WIDTH]) begin
        merchant_t[8]  <= {merchant_t[7][NAR_WIDTH-2:0], 1'b1};
        remainder_n[8] <= stage_sub_n[8][NAR_WIDTH-1:0];
    end else begin
        merchant_t[8]  <= {merchant_t[7][NAR_WIDTH-2:0], 1'b0};
        remainder_n[8] <= {remainder_n[7][NAR_WIDTH-2:0], dividend_n[7][MAX_WIDTH-9]};
    end
end

//---------------- stage 9 ----------------
always @(*) begin
    divisor_n[9]   = divisor_n[8];
    dividend_n[9]  = dividend_n[8];
    mode_sel_t[9]  = mode_sel_t[8];
    stage_sub_n[9] = {{remainder_n[8], dividend_n[8][MAX_WIDTH-10]}} - {1'b0, divisor_n[8]};
end
always @(*) begin
    if (mode_sel_t[8]) begin
        merchant_t[9]  = merchant_t[8];
        remainder_n[9] = remainder_n[8];
    end else if (!stage_sub_n[9][NAR_WIDTH]) begin
        merchant_t[9]  = {merchant_t[8][NAR_WIDTH-2:0], 1'b1};
        remainder_n[9] = stage_sub_n[9][NAR_WIDTH-1:0];
    end else begin
        merchant_t[9]  = {merchant_t[8][NAR_WIDTH-2:0], 1'b0};
        remainder_n[9] = {remainder_n[8][NAR_WIDTH-2:0], dividend_n[8][MAX_WIDTH-10]};
    end
end

//---------------- stage 10 ----------------
always @(*) begin
    divisor_n[10]   = divisor_n[9];
    dividend_n[10]  = dividend_n[9];
    mode_sel_t[10]  = mode_sel_t[9];
    stage_sub_n[10] = {{remainder_n[9], dividend_n[9][MAX_WIDTH-11]}} - {1'b0, divisor_n[9]};
end
always @(*) begin
    if (mode_sel_t[9]) begin
        merchant_t[10]  = merchant_t[9];
        remainder_n[10] = remainder_n[9];
    end else if (!stage_sub_n[10][NAR_WIDTH]) begin
        merchant_t[10]  = {merchant_t[9][NAR_WIDTH-2:0], 1'b1};
        remainder_n[10] = stage_sub_n[10][NAR_WIDTH-1:0];
    end else begin
        merchant_t[10]  = {merchant_t[9][NAR_WIDTH-2:0], 1'b0};
        remainder_n[10] = {remainder_n[9][NAR_WIDTH-2:0], dividend_n[9][MAX_WIDTH-11]};
    end
end

//---------------- stage 11 ----------------
always @(*) begin
    divisor_n[11]   = divisor_n[10];
    dividend_n[11]  = dividend_n[10];
    mode_sel_t[11]  = mode_sel_t[10];
    stage_sub_n[11] = {{remainder_n[10], dividend_n[10][MAX_WIDTH-12]}} - {1'b0, divisor_n[10]};
end
always @(*) begin
    if (mode_sel_t[10]) begin
        merchant_t[11]  = merchant_t[10];
        remainder_n[11] = remainder_n[10];
    end else if (!stage_sub_n[11][NAR_WIDTH]) begin
        merchant_t[11]  = {merchant_t[10][NAR_WIDTH-2:0], 1'b1};
        remainder_n[11] = stage_sub_n[11][NAR_WIDTH-1:0];
    end else begin
        merchant_t[11]  = {merchant_t[10][NAR_WIDTH-2:0], 1'b0};
        remainder_n[11] = {remainder_n[10][NAR_WIDTH-2:0], dividend_n[10][MAX_WIDTH-12]};
    end
end

//---------------- stage 12 ----------------
always @(*) begin
    divisor_n[12]   = divisor_n[11];
    dividend_n[12]  = dividend_n[11];
    mode_sel_t[12]  = mode_sel_t[11];
    stage_sub_n[12] = {{remainder_n[11], dividend_n[11][MAX_WIDTH-13]}} - {1'b0, divisor_n[11]};
end
always @(posedge clk) begin
    if (mode_sel_t[11]) begin
        merchant_t[12]  <= merchant_t[11];
        remainder_n[12] <= remainder_n[11];
    end else if (!stage_sub_n[12][NAR_WIDTH]) begin
        merchant_t[12]  <= {merchant_t[11][NAR_WIDTH-2:0], 1'b1};
        remainder_n[12] <= stage_sub_n[12][NAR_WIDTH-1:0];
    end else begin
        merchant_t[12]  <= {merchant_t[11][NAR_WIDTH-2:0], 1'b0};
        remainder_n[12] <= {remainder_n[11][NAR_WIDTH-2:0], dividend_n[11][MAX_WIDTH-13]};
    end
end

//---------------- stage 13 ----------------
always @(*) begin
    divisor_n[13]   = divisor_n[12];
    dividend_n[13]  = dividend_n[12];
    mode_sel_t[13]  = mode_sel_t[12];
    stage_sub_n[13] = {{remainder_n[12], dividend_n[12][MAX_WIDTH-14]}} - {1'b0, divisor_n[12]};
end
always @(*) begin
    if (mode_sel_t[12]) begin
        merchant_t[13]  = merchant_t[12];
        remainder_n[13] = remainder_n[12];
    end else if (!stage_sub_n[13][NAR_WIDTH]) begin
        merchant_t[13]  = {merchant_t[12][NAR_WIDTH-2:0], 1'b1};
        remainder_n[13] = stage_sub_n[13][NAR_WIDTH-1:0];
    end else begin
        merchant_t[13]  = {merchant_t[12][NAR_WIDTH-2:0], 1'b0};
        remainder_n[13] = {remainder_n[12][NAR_WIDTH-2:0], dividend_n[12][MAX_WIDTH-14]};
    end
end

//---------------- stage 14 ----------------
always @(*) begin
    divisor_n[14]   = divisor_n[13];
    dividend_n[14]  = dividend_n[13];
    mode_sel_t[14]  = mode_sel_t[13];
    stage_sub_n[14] = {{remainder_n[13], dividend_n[13][MAX_WIDTH-15]}} - {1'b0, divisor_n[13]};
end
always @(*) begin
    if (mode_sel_t[13]) begin
        merchant_t[14]  = merchant_t[13];
        remainder_n[14] = remainder_n[13];
    end else if (!stage_sub_n[14][NAR_WIDTH]) begin
        merchant_t[14]  = {merchant_t[13][NAR_WIDTH-2:0], 1'b1};
        remainder_n[14] = stage_sub_n[14][NAR_WIDTH-1:0];
    end else begin
        merchant_t[14]  = {merchant_t[13][NAR_WIDTH-2:0], 1'b0};
        remainder_n[14] = {remainder_n[13][NAR_WIDTH-2:0], dividend_n[13][MAX_WIDTH-15]};
    end
end

//---------------- stage 15 ----------------
always @(*) begin
    divisor_n[15]   = divisor_n[14];
    dividend_n[15]  = dividend_n[14];
    mode_sel_t[15]  = mode_sel_t[14];
    stage_sub_n[15] = {{remainder_n[14], dividend_n[14][MAX_WIDTH-16]}} - {1'b0, divisor_n[14]};
end
always @(*) begin
    if (mode_sel_t[14]) begin
        merchant_t[15]  = merchant_t[14];
        remainder_n[15] = remainder_n[14];
    end else if (!stage_sub_n[15][NAR_WIDTH]) begin
        merchant_t[15]  = {merchant_t[14][NAR_WIDTH-2:0], 1'b1};
        remainder_n[15] = stage_sub_n[15][NAR_WIDTH-1:0];
    end else begin
        merchant_t[15]  = {merchant_t[14][NAR_WIDTH-2:0], 1'b0};
        remainder_n[15] = {remainder_n[14][NAR_WIDTH-2:0], dividend_n[14][MAX_WIDTH-16]};
    end
end

//---------------- stage 16 ----------------
always @(*) begin
    divisor_n[16]   = divisor_n[15];
    dividend_n[16]  = dividend_n[15];
    mode_sel_t[16]  = mode_sel_t[15];
    stage_sub_n[16] = {{remainder_n[15], dividend_n[15][MAX_WIDTH-17]}} - {1'b0, divisor_n[15]};
end
always @(posedge clk) begin
    if (mode_sel_t[15]) begin
        merchant_t[16]  <= merchant_t[15];
        remainder_n[16] <= remainder_n[15];
    end else if (!stage_sub_n[16][NAR_WIDTH]) begin
        merchant_t[16]  <= {merchant_t[15][NAR_WIDTH-2:0], 1'b1};
        remainder_n[16] <= stage_sub_n[16][NAR_WIDTH-1:0];
    end else begin
        merchant_t[16]  <= {merchant_t[15][NAR_WIDTH-2:0], 1'b0};
        remainder_n[16] <= {remainder_n[15][NAR_WIDTH-2:0], dividend_n[15][MAX_WIDTH-17]};
    end
end

//---------------- stage 17 ----------------
always @(*) begin
    divisor_n[17]   = divisor_n[16];
    dividend_n[17]  = dividend_n[16];
    mode_sel_t[17]  = mode_sel_t[16];
    stage_sub_n[17] = {{remainder_n[16], dividend_n[16][MAX_WIDTH-18]}} - {1'b0, divisor_n[16]};
end
always @(*) begin
    if (mode_sel_t[16]) begin
        merchant_t[17]  = merchant_t[16];
        remainder_n[17] = remainder_n[16];
    end else if (!stage_sub_n[17][NAR_WIDTH]) begin
        merchant_t[17]  = {merchant_t[16][NAR_WIDTH-2:0], 1'b1};
        remainder_n[17] = stage_sub_n[17][NAR_WIDTH-1:0];
    end else begin
        merchant_t[17]  = {merchant_t[16][NAR_WIDTH-2:0], 1'b0};
        remainder_n[17] = {remainder_n[16][NAR_WIDTH-2:0], dividend_n[16][MAX_WIDTH-18]};
    end
end

//---------------- stage 18 ----------------
always @(*) begin
    divisor_n[18]   = divisor_n[17];
    dividend_n[18]  = dividend_n[17];
    mode_sel_t[18]  = mode_sel_t[17];
    stage_sub_n[18] = {{remainder_n[17], dividend_n[17][MAX_WIDTH-19]}} - {1'b0, divisor_n[17]};
end
always @(*) begin
    if (mode_sel_t[17]) begin
        merchant_t[18]  = merchant_t[17];
        remainder_n[18] = remainder_n[17];
    end else if (!stage_sub_n[18][NAR_WIDTH]) begin
        merchant_t[18]  = {merchant_t[17][NAR_WIDTH-2:0], 1'b1};
        remainder_n[18] = stage_sub_n[18][NAR_WIDTH-1:0];
    end else begin
        merchant_t[18]  = {merchant_t[17][NAR_WIDTH-2:0], 1'b0};
        remainder_n[18] = {remainder_n[17][NAR_WIDTH-2:0], dividend_n[17][MAX_WIDTH-19]};
    end
end

//---------------- stage 19 ----------------
always @(*) begin
    divisor_n[19]   = divisor_n[18];
    dividend_n[19]  = dividend_n[18];
    mode_sel_t[19]  = mode_sel_t[18];
    stage_sub_n[19] = {{remainder_n[18], dividend_n[18][MAX_WIDTH-20]}} - {1'b0, divisor_n[18]};
end
always @(*) begin
    if (mode_sel_t[18]) begin
        merchant_t[19]  = merchant_t[18];
        remainder_n[19] = remainder_n[18];
    end else if (!stage_sub_n[19][NAR_WIDTH]) begin
        merchant_t[19]  = {merchant_t[18][NAR_WIDTH-2:0], 1'b1};
        remainder_n[19] = stage_sub_n[19][NAR_WIDTH-1:0];
    end else begin
        merchant_t[19]  = {merchant_t[18][NAR_WIDTH-2:0], 1'b0};
        remainder_n[19] = {remainder_n[18][NAR_WIDTH-2:0], dividend_n[18][MAX_WIDTH-20]};
    end
end

//---------------- stage 20 ----------------
always @(*) begin
    divisor_n[20]   = divisor_n[19];
    dividend_n[20]  = dividend_n[19];
    mode_sel_t[20]  = mode_sel_t[19];
    stage_sub_n[20] = {{remainder_n[19], dividend_n[19][MAX_WIDTH-21]}} - {1'b0, divisor_n[19]};
end
always @(posedge clk) begin
    if (mode_sel_t[19]) begin
        merchant_t[20]  <= merchant_t[19];
        remainder_n[20] <= remainder_n[19];
    end else if (!stage_sub_n[20][NAR_WIDTH]) begin
        merchant_t[20]  <= {merchant_t[19][NAR_WIDTH-2:0], 1'b1};
        remainder_n[20] <= stage_sub_n[20][NAR_WIDTH-1:0];
    end else begin
        merchant_t[20]  <= {merchant_t[19][NAR_WIDTH-2:0], 1'b0};
        remainder_n[20] <= {remainder_n[19][NAR_WIDTH-2:0], dividend_n[19][MAX_WIDTH-21]};
    end
end

//---------------- stage 21 ----------------
always @(*) begin
    divisor_n[21]   = divisor_n[20];
    dividend_n[21]  = dividend_n[20];
    mode_sel_t[21]  = mode_sel_t[20];
    stage_sub_n[21] = {{remainder_n[20], dividend_n[20][MAX_WIDTH-22]}} - {1'b0, divisor_n[20]};
end
always @(*) begin
    if (mode_sel_t[20]) begin
        merchant_t[21]  = merchant_t[20];
        remainder_n[21] = remainder_n[20];
    end else if (!stage_sub_n[21][NAR_WIDTH]) begin
        merchant_t[21]  = {merchant_t[20][NAR_WIDTH-2:0], 1'b1};
        remainder_n[21] = stage_sub_n[21][NAR_WIDTH-1:0];
    end else begin
        merchant_t[21]  = {merchant_t[20][NAR_WIDTH-2:0], 1'b0};
        remainder_n[21] = {remainder_n[20][NAR_WIDTH-2:0], dividend_n[20][MAX_WIDTH-22]};
    end
end

//---------------- stage 22 ----------------
always @(*) begin
    divisor_n[22]   = divisor_n[21];
    dividend_n[22]  = dividend_n[21];
    mode_sel_t[22]  = mode_sel_t[21];
    stage_sub_n[22] = {{remainder_n[21], dividend_n[21][MAX_WIDTH-23]}} - {1'b0, divisor_n[21]};
end
always @(*) begin
    if (mode_sel_t[21]) begin
        merchant_t[22]  = merchant_t[21];
        remainder_n[22] = remainder_n[21];
    end else if (!stage_sub_n[22][NAR_WIDTH]) begin
        merchant_t[22]  = {merchant_t[21][NAR_WIDTH-2:0], 1'b1};
        remainder_n[22] = stage_sub_n[22][NAR_WIDTH-1:0];
    end else begin
        merchant_t[22]  = {merchant_t[21][NAR_WIDTH-2:0], 1'b0};
        remainder_n[22] = {remainder_n[21][NAR_WIDTH-2:0], dividend_n[21][MAX_WIDTH-23]};
    end
end

//---------------- stage 23 ----------------
always @(*) begin
    divisor_n[23]   = divisor_n[22];
    dividend_n[23]  = dividend_n[22];
    mode_sel_t[23]  = mode_sel_t[22];
    stage_sub_n[23] = {{remainder_n[22], dividend_n[22][MAX_WIDTH-24]}} - {1'b0, divisor_n[22]};
end
always @(*) begin
    if (mode_sel_t[22]) begin
        merchant_t[23]  = merchant_t[22];
        remainder_n[23] = remainder_n[22];
    end else if (!stage_sub_n[23][NAR_WIDTH]) begin
        merchant_t[23]  = {merchant_t[22][NAR_WIDTH-2:0], 1'b1};
        remainder_n[23] = stage_sub_n[23][NAR_WIDTH-1:0];
    end else begin
        merchant_t[23]  = {merchant_t[22][NAR_WIDTH-2:0], 1'b0};
        remainder_n[23] = {remainder_n[22][NAR_WIDTH-2:0], dividend_n[22][MAX_WIDTH-24]};
    end
end

assign merchant  = {{(N-NAR_WIDTH){1'b0}}, merchant_t[PIPE_DEPTH]};
assign remainder = {{(M-NAR_WIDTH){1'b0}}, remainder_n[PIPE_DEPTH]};

endmodule // div_v3
