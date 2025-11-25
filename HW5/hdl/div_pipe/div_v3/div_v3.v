module div_new #(
    parameter N = 39,
    parameter M = 39,
    parameter N_ACT = M+N-1
)(
    input clk,
    input [N-1:0] dividend,
    input [M-1:0] divisor,
    input mode_sel, // 0: Layernorm, 1: Softmax
    output [N-1:0] merchant,
    output [M-1:0] remainder
);

// Restoring divider with pipeline registers arranged as |4|4|4|4|4|4
// Stage0~5 : keep wide path (divisor/remainder width = M)
// Stage6~23: narrow path (width = MAX_WIDTH = 24) to save area

localparam integer PIPE_DEPTH = 23;
localparam integer FRONT_STAGE = 6;
localparam integer MAX_WIDTH = 24;

// wide path (0~5)
reg [M-1:0]       divisor_w   [0:FRONT_STAGE-1];
reg [M-1:0]       remainder_w [0:FRONT_STAGE-1];
reg [MAX_WIDTH-1:0] dividend_w [0:FRONT_STAGE-1];

// narrow path (6~23)
reg [MAX_WIDTH-1:0] divisor_n   [FRONT_STAGE:PIPE_DEPTH];
reg [MAX_WIDTH-1:0] remainder_n [FRONT_STAGE:PIPE_DEPTH];
reg [MAX_WIDTH-1:0] dividend_n  [FRONT_STAGE:PIPE_DEPTH];

// merchant only needs 24 bits (Layernorm merchant <=24b, Softmax <=6b)
reg [MAX_WIDTH-1:0] merchant_t [0:PIPE_DEPTH];
reg [PIPE_DEPTH:0]  mode_sel_t;
reg                 dividend_sel [0:PIPE_DEPTH];

reg [M:0]         stage_sub_0, stage_sub_1, stage_sub_2, stage_sub_3, stage_sub_4, stage_sub_5;
reg [MAX_WIDTH:0] stage_sub_n [FRONT_STAGE:PIPE_DEPTH];

// ------------------- stage 0 -------------------
wire [M-1:0] stage0_divisor = divisor;
wire [M:0] stage0_dividend = (mode_sel)?
                              {{(M+1-(N-5)){1'b0}}, dividend[N-1:5]} : // Softmax uses [39:5]
                              {{(M+1-MAX_WIDTH){1'b0}}, dividend[N-1:MAX_WIDTH-1]}; // Layernorm uses [39:23]

always @(*) begin
    stage_sub_0 = stage0_dividend - {1'b0, stage0_divisor};
end

always @(posedge clk) begin
    divisor_w[0]    <= stage0_divisor;
    dividend_w[0]   <= dividend[MAX_WIDTH-1:0]; // keep low 24 bits for follow-up stages
    mode_sel_t[0]   <= mode_sel;
    if (!stage_sub_0[M]) begin
        merchant_t[0]  <= { {MAX_WIDTH-1{1'b0}}, 1'b1 };
        remainder_w[0] <= stage_sub_0[M-1:0];
    end else begin
        merchant_t[0]  <= {MAX_WIDTH{1'b0}};
        remainder_w[0] <= stage0_dividend[M-1:0];
    end
end

// ------------------- stage 1 -------------------
always @(*) begin
    dividend_sel[0] = (mode_sel_t[0])? dividend_w[0][4]  : dividend_w[0][22];
    stage_sub_1     = {{remainder_w[0], dividend_sel[0]}} - {1'b0, divisor_w[0]};
end
always @(*) begin
    divisor_w[1]  = divisor_w[0];
    dividend_w[1] = dividend_w[0];
    mode_sel_t[1] = mode_sel_t[0];
    if (!stage_sub_1[M]) begin
        merchant_t[1]  = {merchant_t[0][MAX_WIDTH-2:0], 1'b1};
        remainder_w[1] = stage_sub_1[M-1:0];
    end else begin
        merchant_t[1]  = {merchant_t[0][MAX_WIDTH-2:0], 1'b0};
        remainder_w[1] = {remainder_w[0][M-2:0], dividend_sel[0]};
    end
end

// ------------------- stage 2 -------------------
always @(*) begin
    dividend_sel[1] = (mode_sel_t[1])? dividend_w[1][3]  : dividend_w[1][21];
    stage_sub_2     = {{remainder_w[1], dividend_sel[1]}} - {1'b0, divisor_w[1]};
end
always @(*) begin
    divisor_w[2]  = divisor_w[1];
    dividend_w[2] = dividend_w[1];
    mode_sel_t[2] = mode_sel_t[1];
    if (!stage_sub_2[M]) begin
        merchant_t[2]  = {merchant_t[1][MAX_WIDTH-2:0], 1'b1};
        remainder_w[2] = stage_sub_2[M-1:0];
    end else begin
        merchant_t[2]  = {merchant_t[1][MAX_WIDTH-2:0], 1'b0};
        remainder_w[2] = {remainder_w[1][M-2:0], dividend_sel[1]};
    end
end

// ------------------- stage 3 -------------------
always @(*) begin
    dividend_sel[2] = (mode_sel_t[2])? dividend_w[2][2]  : dividend_w[2][20];
    stage_sub_3     = {{remainder_w[2], dividend_sel[2]}} - {1'b0, divisor_w[2]};
end
always @(*) begin
    divisor_w[3]  = divisor_w[2];
    dividend_w[3] = dividend_w[2];
    mode_sel_t[3] = mode_sel_t[2];
    if (!stage_sub_3[M]) begin
        merchant_t[3]  = {merchant_t[2][MAX_WIDTH-2:0], 1'b1};
        remainder_w[3] = stage_sub_3[M-1:0];
    end else begin
        merchant_t[3]  = {merchant_t[2][MAX_WIDTH-2:0], 1'b0};
        remainder_w[3] = {remainder_w[2][M-2:0], dividend_sel[2]};
    end
end

// ------------------- stage 4 -------------------
always @(*) begin
    dividend_sel[3] = (mode_sel_t[3])? dividend_w[3][1]  : dividend_w[3][19];
    stage_sub_4     = {{remainder_w[3], dividend_sel[3]}} - {1'b0, divisor_w[3]};
end
always @(posedge clk) begin
    divisor_w[4]  <= divisor_w[3];
    dividend_w[4] <= dividend_w[3];
    mode_sel_t[4] <= mode_sel_t[3];
    if (!stage_sub_4[M]) begin
        merchant_t[4]  <= {merchant_t[3][MAX_WIDTH-2:0], 1'b1};
        remainder_w[4] <= stage_sub_4[M-1:0];
    end else begin
        merchant_t[4]  <= {merchant_t[3][MAX_WIDTH-2:0], 1'b0};
        remainder_w[4] <= {remainder_w[3][M-2:0], dividend_sel[3]};
    end
end

// ------------------- stage 5 -------------------
always @(*) begin
    dividend_sel[4] = (mode_sel_t[4])? dividend_w[4][0]  : dividend_w[4][18];
    stage_sub_5     = {{remainder_w[4], dividend_sel[4]}} - {1'b0, divisor_w[4]};
end
always @(*) begin
    divisor_w[5]  = divisor_w[4];
    dividend_w[5] = dividend_w[4];
    mode_sel_t[5] = mode_sel_t[4];
    if (!stage_sub_5[M]) begin
        merchant_t[5]  = {merchant_t[4][MAX_WIDTH-2:0], 1'b1};
        remainder_w[5] = stage_sub_5[M-1:0];
    end else begin
        merchant_t[5]  = {merchant_t[4][MAX_WIDTH-2:0], 1'b0};
        remainder_w[5] = {remainder_w[4][M-2:0], dividend_sel[4]};
    end
end

// ------------------- boundary: load narrow path (stage 6 input) -------------------
always @(*) begin
    divisor_n[FRONT_STAGE]   = divisor_w[5][MAX_WIDTH-1:0];      // truncate to 24b
    dividend_n[FRONT_STAGE]  = dividend_w[5];
    mode_sel_t[FRONT_STAGE]  = mode_sel_t[5];
end

// ------------------- stages 6~23 (narrow, 24-bit) -------------------
genvar gi;
generate
    for (gi = FRONT_STAGE; gi <= PIPE_DEPTH; gi = gi + 1) begin : NARROW_STAGE
        wire next_bit = dividend_n[gi][MAX_WIDTH-(gi+1)]; // MAX_WIDTH-7 ... MAX_WIDTH-24
        always @(*) begin
            if (gi == FRONT_STAGE)
                stage_sub_n[gi] = {{remainder_w[5][MAX_WIDTH-1:0], next_bit}} - {1'b0, divisor_n[gi]};
            else
                stage_sub_n[gi] = {{remainder_n[gi-1], next_bit}} - {1'b0, divisor_n[gi]};
        end

        always @(*) begin
            // pipeline divisor/dividend/mode for this stage
            if (gi != FRONT_STAGE) begin
                divisor_n[gi]  = divisor_n[gi-1];
                dividend_n[gi] = dividend_n[gi-1];
                mode_sel_t[gi] = mode_sel_t[gi-1];
            end

            if (mode_sel_t[gi-1]) begin
                // softmax bypass
                merchant_t[gi]  = merchant_t[gi-1];
                if (gi == FRONT_STAGE)
                    remainder_n[gi] = remainder_w[5][MAX_WIDTH-1:0];
                else
                    remainder_n[gi] = remainder_n[gi-1];
            end else if (!stage_sub_n[gi][MAX_WIDTH]) begin
                merchant_t[gi]  = {merchant_t[gi-1][MAX_WIDTH-2:0], 1'b1};
                remainder_n[gi] = stage_sub_n[gi][MAX_WIDTH-1:0];
            end else begin
                merchant_t[gi]  = {merchant_t[gi-1][MAX_WIDTH-2:0], 1'b0};
                if (gi == FRONT_STAGE)
                    remainder_n[gi] = {remainder_w[5][MAX_WIDTH-2:0], next_bit};
                else
                    remainder_n[gi] = {remainder_n[gi-1][MAX_WIDTH-2:0], next_bit};
            end
        end
    end
endgenerate

assign merchant  = {{(N-MAX_WIDTH){1'b0}}, merchant_t[PIPE_DEPTH]};
assign remainder = (mode_sel_t[PIPE_DEPTH])?
                   {{(M-MAX_WIDTH){1'b0}}, remainder_n[PIPE_DEPTH]} :
                   remainder_n[PIPE_DEPTH];

endmodule // div_new
