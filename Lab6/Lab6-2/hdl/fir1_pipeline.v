//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module fir1_pipeline
#(parameter N=32)
(
input      clk,
input      rst_n,
input      enable,
input      [N-1:0]x,
output reg busy,
output reg valid,
output reg [N-1:0]y
);
localparam IDLE = 0,
           EVA  = 1;

wire [N-1:0] y_n;

reg [5:0] state, state_n;
reg [5:0] cnt, cnt_n;
reg valid_n;
reg busy_n;
reg valid_n_reg[0:1];

always@(posedge clk)
begin
  if(~rst_n)begin
    state <= IDLE;
    cnt   <= 0;
    valid <= 0;
    busy  <= 0;
    y     <= 1534;
  end
  else begin
    state <= state_n;
    cnt   <= cnt_n;
    valid <= valid_n_reg[1];
    busy  <= busy_n;
    y     <= y_n >> 16;
  end
end

always@*
begin
  case(state)
    IDLE : state_n = enable ? EVA : IDLE;
    EVA  : state_n = enable ? EVA : IDLE;
    default : state_n = IDLE;
  endcase
end

always@*
begin
  if(state == EVA)
    if(cnt == 16)
      cnt_n = cnt;
    else
      cnt_n = cnt + 1;
  else
    cnt_n = 0;
end

always@*
begin
  if((state == EVA) & (cnt == 16))
    valid_n = 1;
  else
    valid_n = 0;
end



always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    valid_n_reg[0] <= 0;
    valid_n_reg[1] <= 0;
  end else begin
    valid_n_reg[0] <= valid_n;
    valid_n_reg[1] <= valid_n_reg[0];
  end
end

always@*
begin
  if(state == EVA)
    busy_n = 0;
  else
    busy_n = 0;
end

reg [(N-1):0] DFF [0:15];
reg [(N-1):0] DFF_reg[0:1];
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    DFF[0] <= 0;
    DFF[1] <= 0;
    DFF[2] <= 0;
    DFF[3] <= 0;
    DFF[4] <= 0;
    DFF_reg[0] <= 0;
    DFF[5] <= 0;
    DFF[6] <= 0;
    DFF[7] <= 0;
    DFF[8] <= 0;
    DFF[9] <= 0;
    DFF_reg[1] <= 0;
    DFF[10] <= 0;
    DFF[11] <= 0;
    DFF[12] <= 0;
    DFF[13] <= 0;
    DFF[14] <= 0;
    DFF[15] <= 0;
  end else begin
    DFF[0] <= x;
    DFF[1] <= DFF[0];
    DFF[2] <= DFF[1];
    DFF[3] <= DFF[2];
    DFF[4] <= DFF[3];
    DFF[5] <= DFF[4];
    DFF_reg[0] <= DFF[5];
    DFF[6] <= DFF_reg[0];
    DFF[7] <= DFF[6];
    DFF[8] <= DFF[7];
    DFF[9] <= DFF[8];
    DFF[10] <= DFF[9];
    DFF_reg[1] <= DFF[10];
    DFF[11] <= DFF_reg[1];
    DFF[12] <= DFF[11];
    DFF[13] <= DFF[12];
    DFF[14] <= DFF[13];
    DFF[15] <= DFF[14];
  end
end

localparam a0 = -32'd157;
localparam a1 = 32'd380;
localparam a2 = -32'd399;
localparam a3 = -32'd838;
localparam a4 = 32'd3466;
localparam a5 = -32'd4548;
localparam a6 = -32'd1987;
localparam a7 = 32'd36857;
localparam a8 = 32'd36857;
localparam a9 = -32'd1987;
localparam a10 = -32'd4548;
localparam a11 = 32'd3466;
localparam a12 = -32'd838;
localparam a13 = -32'd399;
localparam a14 = 32'd380;
localparam a15 = -32'd157;

wire [(N-1):0] num[0:15];

assign num[0]  = a0;
assign num[1]  = a1;
assign num[2]  = a2;
assign num[3]  = a3;
assign num[4]  = a4;
assign num[5]  = a5;
assign num[6]  = a6;
assign num[7]  = a7;
assign num[8]  = a8;
assign num[9]  = a9;
assign num[10] = a10;
assign num[11] = a11;
assign num[12] = a12;
assign num[13] = a13;
assign num[14] = a14;
assign num[15] = a15;

reg [(N-1):0] pipe_reg[0:1];
reg [(N-1):0] pipe_wire[0:15];

always @* begin
  pipe_wire[0] = (DFF[0] * num[0]) + (DFF[1] * num[1]);
  pipe_wire[1] = pipe_wire[0] + (DFF[2] * num[2]);
  pipe_wire[2] = pipe_wire[1] + (DFF[3] * num[3]);
  pipe_wire[3] = pipe_wire[2] + (DFF[4] * num[4]);
  pipe_wire[4] = pipe_wire[3] + (DFF[5] * num[5]);

  pipe_wire[5] = pipe_reg[0] + (DFF[6] * num[6]);
  pipe_wire[6] = pipe_wire[5] + (DFF[7] * num[7]);
  pipe_wire[7] = pipe_wire[6] + (DFF[8] * num[8]);
  pipe_wire[8] = pipe_wire[7] + (DFF[9] * num[9]);
  pipe_wire[9] = pipe_wire[8] + (DFF[10] * num[10]);

  pipe_wire[10] = pipe_reg[1] + (DFF[11] * num[11]);
  pipe_wire[11] = pipe_wire[10] + (DFF[12] * num[12]);
  pipe_wire[12] = pipe_wire[11] + (DFF[13] * num[13]);
  pipe_wire[13] = pipe_wire[12] + (DFF[14] * num[14]);
  pipe_wire[14] = pipe_wire[13] + (DFF[15] * num[15]);
  pipe_wire[15] = pipe_wire[14];
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pipe_reg[0] <= 0;
      pipe_reg[1] <= 0;
    end else begin
      pipe_reg[0] <= pipe_wire[4];
      pipe_reg[1] <= pipe_wire[9];
    end
end

assign y_n = pipe_wire[15];
endmodule
