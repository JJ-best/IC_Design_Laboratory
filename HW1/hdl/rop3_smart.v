/*
* Module      : rop3_smart
* Description : Implement this module using the bit-hack technique mentioned in the assignment handout.
*               This module should support all the possible modes of ROP3.
* Notes       : Please remember to
*               (1) make the bit-length of {din, result} parameterizable
*               (2) make the input/output to be a register
*/

module rop3_smart
#(
  parameter N = 8
)
(
  input clk,
  input din_valid,
  input [4*N-1:0] din,
  input [4:0] sel,
  input [7:0] mode,
  output reg dout_valid,
  output reg [N-1:0] result
);

// ----- stage 1 start -----//
reg stage1_din_valid;
reg [4*N-1 : 0]stage1_din;
reg [4:0]stage1_sel;
reg [7:0]stage1_mode;

always @(posedge clk) begin
  stage1_din_valid <= din_valid;
  stage1_din <= din;
  stage1_sel <= sel;
  stage1_mode <= mode;
end
// ----- stage 1 end -----//

// ----- Combinational Logic ----- //
reg [N-1:0]P;
reg [N-1:0]S;
reg [N-1:0]D;
wire [N-1:0]Wd, Xd, Yd, Zd;
assign Wd = stage1_din[4*N-1:3*N];
assign Xd = stage1_din[3*N-1:2*N];
assign Yd = stage1_din[2*N-1:1*N];
assign Zd = stage1_din[N-1:0];
always @(*) begin
  case (stage1_sel)
    5'd0: begin
      P = Wd;
      S = Xd;
      D = Yd;
    end
    5'd1: begin
      P = Wd;
      S = Yd;
      D = Xd;
    end
    5'd2: begin
      P = Xd;
      S = Wd;
      D = Yd;
    end
    5'd3: begin
      P = Yd;
      S = Wd;
      D = Xd;
    end
    5'd4: begin
      P = Xd;
      S = Yd;
      D = Wd;
    end
    5'd5: begin
      P = Yd;
      S = Xd;
      D = Wd;
    end
    5'd6: begin
      P = Wd;
      S = Xd;
      D = Zd;
    end
    5'd7: begin
      P = Wd;
      S = Zd;
      D = Xd;
    end
    5'd8: begin
      P = Xd;
      S = Wd;
      D = Zd;
    end
    5'd9: begin
      P = Zd;
      S = Wd;
      D = Xd;
    end
    5'd10: begin
      P = Xd;
      S = Zd;
      D = Wd;
    end
    5'd11: begin
      P = Zd;
      S = Xd;
      D = Wd;
    end
    5'd12: begin
      P = Wd;
      S = Yd;
      D = Zd;
    end
    5'd13: begin
      P = Wd;
      S = Zd;
      D = Yd;
    end
    5'd14: begin
      P = Yd;
      S = Wd;
      D = Zd;
    end
    5'd15: begin
      P = Zd;
      S = Wd;
      D = Yd;
    end
    5'd16: begin
      P = Yd;
      S = Zd;
      D = Wd;
    end
    5'd17: begin
      P = Zd;
      S = Yd;
      D = Wd;
    end
    5'd18: begin
      P = Xd;
      S = Yd;
      D = Zd;
    end
    5'd19: begin
      P = Xd;
      S = Zd;
      D = Yd;
    end
    5'd20: begin
      P = Yd;
      S = Xd;
      D = Zd;
    end
    5'd21: begin
      P = Zd;
      S = Xd;
      D = Yd;
    end
    5'd22: begin
      P = Yd;
      S = Zd;
      D = Xd;
    end
    5'd23: begin
      P = Zd;
      S = Yd;
      D = Xd;
    end
    default : begin
      P = 0;
      S = 0;
      D = 0;
    end
  endcase
end

reg [N-1:0]out;
reg [7:0]tmp1[0:N-1];
reg [7:0]tmp2[0:N-1];
integer i;
always @(*) begin
  for (i = 0; i < N; i = i + 1) begin
    tmp1[i] = 8'h1 << {P[i], S[i], D[i]};
    tmp2[i] = tmp1[i] & stage1_mode;
    out[i] = |tmp2[i];
  end
end
// ----- Combinational Logic ----- //

// ----- stage 2 start -----//
always @(posedge clk) begin
  dout_valid <= stage1_din_valid;
  result <= out;
end
// ----- stage 2 end -----//


endmodule