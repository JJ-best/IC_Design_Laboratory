//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module fir1
#(parameter N=32)
(
input      clk,
input      rst_n,
input      enable, // input valid
input      [N-1:0]x, // input data
output reg busy,
output reg valid, // output valid
output wire [N-1:0]y // output data
);
localparam IDLE = 0, // idle
           LOAD = 1, // load first 16 data
           EVA  = 2, // evaluation sum
           DONE = 3; // output result and load new one data

reg [N-1:0] y_n;

reg [5:0] state, state_n;
reg [5:0] cnt, cnt_n;
reg valid_n;
reg busy_n;

// ===== finite state machine ===== //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    state <= IDLE;
  end else begin
    state <= state_n;
  end
end

always @(*) begin
  case (state)
  IDLE: begin
    state_n = (enable)? LOAD : IDLE;
  end
  LOAD: begin
    state_n = (state == LOAD && cnt == 16)? EVA : LOAD;
  end
  EVA: begin
    state_n = (state == EVA && cnt == 15)? DONE : EVA;
  end
  DONE: begin
    state_n = (enable)? EVA : IDLE;
  end
  endcase
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cnt <= 0;
  end else begin
    cnt <= cnt_n;
  end
end

always @(*) begin
  if (state == LOAD && cnt == 16) begin
    cnt_n = 0;
  end else if (state == DONE) begin
    cnt_n = 0;
  end else if (state == EVA) begin
    cnt_n = cnt + 1; 
  end else if (enable) begin
    cnt_n = cnt + 1;
  end else begin
    cnt_n = cnt;
  end
end

// control signal
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    busy <= 0;
    valid <= 0;
  end else begin
    busy <= busy_n;
    valid <= valid_n;
  end
end
always @(*) begin
  if (state == LOAD && cnt == 16) begin
    busy_n = 1;
  end else if (state == EVA && cnt != 15) begin
    busy_n = 1;
  end else if (state == DONE) begin
    busy_n = 1;
  end else begin
    busy_n = 0;
  end

  if (state == EVA && cnt == 15) begin
    valid_n = 1;
  end else begin
    valid_n = 0;
  end
end
// ===== finite state machine ===== //


reg [(N-1):0] DFF [0:15];
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    DFF[0] <= 0;
    DFF[1] <= 0;
    DFF[2] <= 0;
    DFF[3] <= 0;
    DFF[4] <= 0;
    DFF[5] <= 0;
    DFF[6] <= 0;
    DFF[7] <= 0;
    DFF[8] <= 0;
    DFF[9] <= 0;
    DFF[10] <= 0;
    DFF[11] <= 0;
    DFF[12] <= 0;
    DFF[13] <= 0;
    DFF[14] <= 0;
    DFF[15] <= 0;
  end else if (!busy) begin
    DFF[0] <= x; // input data
    DFF[1] <= DFF[0];
    DFF[2] <= DFF[1];
    DFF[3] <= DFF[2];
    DFF[4] <= DFF[3];
    DFF[5] <= DFF[4];
    DFF[6] <= DFF[5];
    DFF[7] <= DFF[6];
    DFF[8] <= DFF[7];
    DFF[9] <= DFF[8];
    DFF[10] <= DFF[9];
    DFF[11] <= DFF[10];
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

reg [(N-1):0] sel_param;
reg [(N-1):0] sel_data;
always @(*) begin
  case (cnt)
  0: begin
    sel_param = num[0];
    sel_data = DFF[0];
  end
  1: begin
    sel_param = num[1];
    sel_data = DFF[1];
  end
  2: begin
    sel_param = num[2];
    sel_data = DFF[2];
  end
  3: begin
    sel_param = num[3];
    sel_data = DFF[3];
  end
  4: begin
    sel_param = num[4];
    sel_data = DFF[4];
  end
  5: begin
    sel_param = num[5];
    sel_data = DFF[5];
  end
  6: begin
    sel_param = num[6];
    sel_data = DFF[6];
  end
  7: begin
    sel_param = num[7];
    sel_data = DFF[7];
  end
  8: begin
    sel_param = num[8];
    sel_data = DFF[8];
  end
  9: begin
    sel_param = num[9];
    sel_data = DFF[9];
  end
  10: begin
    sel_param = num[10];
    sel_data = DFF[10];
  end
  11: begin
    sel_param = num[11];
    sel_data = DFF[11];
  end
  12: begin
    sel_param = num[12];
    sel_data = DFF[12];
  end
  13: begin
    sel_param = num[13];
    sel_data = DFF[13];
  end
  14: begin
    sel_param = num[14];
    sel_data = DFF[14];
  end
  15: begin
    sel_param = num[15];
    sel_data = DFF[15];
  end
  endcase
end

reg [(N-1):0] y_reg;

always @* begin
  y_n = sel_data * sel_param + y_reg;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    y_reg <= 0;
  end else if (state == DONE) begin
    y_reg <= 0;
  end else if (state == EVA)  begin
    y_reg <= y_n;
  end else begin
    y_reg <= 0;
  end
end
assign y = y_reg >> 16;;

endmodule
