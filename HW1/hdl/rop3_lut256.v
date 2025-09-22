/*
* Module      : rop3_lut256
* Description : Implement this module using the look-up table (LUT) 
*               This module should support all the possible modes of ROP3.
* Notes       : Please remember to
*               (1) make the bit-length of {din, result} parameterizable
*               (2) make the input/output to be a register
*/

module rop3_lut256
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
always @(*) begin
  case (stage1_mode)
      8'h00: out = 0;
    8'h01: out = (~P&~S&~D);
    8'h02: out = (~P&~S&D);
    8'h03: out = (~P&~S&~D) | (~P&~S&D);
    8'h04: out = (~P&S&~D);
    8'h05: out = (~P&~S&~D) | (~P&S&~D);
    8'h06: out = (~P&~S&D) | (~P&S&~D);
    8'h07: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D);
    8'h08: out = (~P&S&D);
    8'h09: out = (~P&~S&~D) | (~P&S&D);
    8'h0A: out = (~P&~S&D) | (~P&S&D);
    8'h0B: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D);
    8'h0C: out = (~P&S&~D) | (~P&S&D);
    8'h0D: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D);
    8'h0E: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D);
    8'h0F: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D);
    8'h10: out = (P&~S&~D);
    8'h11: out = (~P&~S&~D) | (P&~S&~D);
    8'h12: out = (~P&~S&D) | (P&~S&~D);
    8'h13: out = (~P&~S&~D) | (~P&~S&D) | (P&~S&~D);
    8'h14: out = (~P&S&~D) | (P&~S&~D);
    8'h15: out = (~P&~S&~D) | (~P&S&~D) | (P&~S&~D);
    8'h16: out = (~P&~S&D) | (~P&S&~D) | (P&~S&~D);
    8'h17: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&~S&~D);
    8'h18: out = (~P&S&D) | (P&~S&~D);
    8'h19: out = (~P&~S&~D) | (~P&S&D) | (P&~S&~D);
    8'h1A: out = (~P&~S&D) | (~P&S&D) | (P&~S&~D);
    8'h1B: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&~S&~D);
    8'h1C: out = (~P&S&~D) | (~P&S&D) | (P&~S&~D);
    8'h1D: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D);
    8'h1E: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D);
    8'h1F: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D);
    8'h20: out = (P&~S&D);
    8'h21: out = (~P&~S&~D) | (P&~S&D);
    8'h22: out = (~P&~S&D) | (P&~S&D);
    8'h23: out = (~P&~S&~D) | (~P&~S&D) | (P&~S&D);
    8'h24: out = (~P&S&~D) | (P&~S&D);
    8'h25: out = (~P&~S&~D) | (~P&S&~D) | (P&~S&D);
    8'h26: out = (~P&~S&D) | (~P&S&~D) | (P&~S&D);
    8'h27: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&~S&D);
    8'h28: out = (~P&S&D) | (P&~S&D);
    8'h29: out = (~P&~S&~D) | (~P&S&D) | (P&~S&D);
    8'h2A: out = (~P&~S&D) | (~P&S&D) | (P&~S&D);
    8'h2B: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&~S&D);
    8'h2C: out = (~P&S&~D) | (~P&S&D) | (P&~S&D);
    8'h2D: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&~S&D);
    8'h2E: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&D);
    8'h2F: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&D);
    8'h30: out = (P&~S&~D) | (P&~S&D);
    8'h31: out = (~P&~S&~D) | (P&~S&~D) | (P&~S&D);
    8'h32: out = (~P&~S&D) | (P&~S&~D) | (P&~S&D);
    8'h33: out = (~P&~S&~D) | (~P&~S&D) | (P&~S&~D) | (P&~S&D);
    8'h34: out = (~P&S&~D) | (P&~S&~D) | (P&~S&D);
    8'h35: out = (~P&~S&~D) | (~P&S&~D) | (P&~S&~D) | (P&~S&D);
    8'h36: out = (~P&~S&D) | (~P&S&~D) | (P&~S&~D) | (P&~S&D);
    8'h37: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&~S&~D) | (P&~S&D);
    8'h38: out = (~P&S&D) | (P&~S&~D) | (P&~S&D);
    8'h39: out = (~P&~S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D);
    8'h3A: out = (~P&~S&D) | (~P&S&D) | (P&~S&~D) | (P&~S&D);
    8'h3B: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&~S&~D) | (P&~S&D);
    8'h3C: out = (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D);
    8'h3D: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D);
    8'h3E: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D);
    8'h3F: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D);
    8'h40: out = (P&S&~D);
    8'h41: out = (~P&~S&~D) | (P&S&~D);
    8'h42: out = (~P&~S&D) | (P&S&~D);
    8'h43: out = (~P&~S&~D) | (~P&~S&D) | (P&S&~D);
    8'h44: out = (~P&S&~D) | (P&S&~D);
    8'h45: out = (~P&~S&~D) | (~P&S&~D) | (P&S&~D);
    8'h46: out = (~P&~S&D) | (~P&S&~D) | (P&S&~D);
    8'h47: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&S&~D);
    8'h48: out = (~P&S&D) | (P&S&~D);
    8'h49: out = (~P&~S&~D) | (~P&S&D) | (P&S&~D);
    8'h4A: out = (~P&~S&D) | (~P&S&D) | (P&S&~D);
    8'h4B: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&S&~D);
    8'h4C: out = (~P&S&~D) | (~P&S&D) | (P&S&~D);
    8'h4D: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&S&~D);
    8'h4E: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&S&~D);
    8'h4F: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&S&~D);
    8'h50: out = (P&~S&~D) | (P&S&~D);
    8'h51: out = (~P&~S&~D) | (P&~S&~D) | (P&S&~D);
    8'h52: out = (~P&~S&D) | (P&~S&~D) | (P&S&~D);
    8'h53: out = (~P&~S&~D) | (~P&~S&D) | (P&~S&~D) | (P&S&~D);
    8'h54: out = (~P&S&~D) | (P&~S&~D) | (P&S&~D);
    8'h55: out = (~P&~S&~D) | (~P&S&~D) | (P&~S&~D) | (P&S&~D);
    8'h56: out = (~P&~S&D) | (~P&S&~D) | (P&~S&~D) | (P&S&~D);
    8'h57: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&~S&~D) | (P&S&~D);
    8'h58: out = (~P&S&D) | (P&~S&~D) | (P&S&~D);
    8'h59: out = (~P&~S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&~D);
    8'h5A: out = (~P&~S&D) | (~P&S&D) | (P&~S&~D) | (P&S&~D);
    8'h5B: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&~S&~D) | (P&S&~D);
    8'h5C: out = (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&~D);
    8'h5D: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&~D);
    8'h5E: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&~D);
    8'h5F: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&~D);
    8'h60: out = (P&~S&D) | (P&S&~D);
    8'h61: out = (~P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h62: out = (~P&~S&D) | (P&~S&D) | (P&S&~D);
    8'h63: out = (~P&~S&~D) | (~P&~S&D) | (P&~S&D) | (P&S&~D);
    8'h64: out = (~P&S&~D) | (P&~S&D) | (P&S&~D);
    8'h65: out = (~P&~S&~D) | (~P&S&~D) | (P&~S&D) | (P&S&~D);
    8'h66: out = (~P&~S&D) | (~P&S&~D) | (P&~S&D) | (P&S&~D);
    8'h67: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&~S&D) | (P&S&~D);
    8'h68: out = (~P&S&D) | (P&~S&D) | (P&S&~D);
    8'h69: out = (~P&~S&~D) | (~P&S&D) | (P&~S&D) | (P&S&~D);
    8'h6A: out = (~P&~S&D) | (~P&S&D) | (P&~S&D) | (P&S&~D);
    8'h6B: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&~S&D) | (P&S&~D);
    8'h6C: out = (~P&S&~D) | (~P&S&D) | (P&~S&D) | (P&S&~D);
    8'h6D: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&~S&D) | (P&S&~D);
    8'h6E: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&D) | (P&S&~D);
    8'h6F: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&D) | (P&S&~D);
    8'h70: out = (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h71: out = (~P&~S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h72: out = (~P&~S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h73: out = (~P&~S&~D) | (~P&~S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h74: out = (~P&S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h75: out = (~P&~S&~D) | (~P&S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h76: out = (~P&~S&D) | (~P&S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h77: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h78: out = (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h79: out = (~P&~S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h7A: out = (~P&~S&D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h7B: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h7C: out = (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h7D: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h7E: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h7F: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D);
    8'h80: out = (P&S&D);
    8'h81: out = (~P&~S&~D) | (P&S&D);
    8'h82: out = (~P&~S&D) | (P&S&D);
    8'h83: out = (~P&~S&~D) | (~P&~S&D) | (P&S&D);
    8'h84: out = (~P&S&~D) | (P&S&D);
    8'h85: out = (~P&~S&~D) | (~P&S&~D) | (P&S&D);
    8'h86: out = (~P&~S&D) | (~P&S&~D) | (P&S&D);
    8'h87: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&S&D);
    8'h88: out = (~P&S&D) | (P&S&D);
    8'h89: out = (~P&~S&~D) | (~P&S&D) | (P&S&D);
    8'h8A: out = (~P&~S&D) | (~P&S&D) | (P&S&D);
    8'h8B: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&S&D);
    8'h8C: out = (~P&S&~D) | (~P&S&D) | (P&S&D);
    8'h8D: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&S&D);
    8'h8E: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&S&D);
    8'h8F: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&S&D);
    8'h90: out = (P&~S&~D) | (P&S&D);
    8'h91: out = (~P&~S&~D) | (P&~S&~D) | (P&S&D);
    8'h92: out = (~P&~S&D) | (P&~S&~D) | (P&S&D);
    8'h93: out = (~P&~S&~D) | (~P&~S&D) | (P&~S&~D) | (P&S&D);
    8'h94: out = (~P&S&~D) | (P&~S&~D) | (P&S&D);
    8'h95: out = (~P&~S&~D) | (~P&S&~D) | (P&~S&~D) | (P&S&D);
    8'h96: out = (~P&~S&D) | (~P&S&~D) | (P&~S&~D) | (P&S&D);
    8'h97: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&~S&~D) | (P&S&D);
    8'h98: out = (~P&S&D) | (P&~S&~D) | (P&S&D);
    8'h99: out = (~P&~S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&D);
    8'h9A: out = (~P&~S&D) | (~P&S&D) | (P&~S&~D) | (P&S&D);
    8'h9B: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&~S&~D) | (P&S&D);
    8'h9C: out = (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&D);
    8'h9D: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&D);
    8'h9E: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&D);
    8'h9F: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&D);
    8'hA0: out = (P&~S&D) | (P&S&D);
    8'hA1: out = (~P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hA2: out = (~P&~S&D) | (P&~S&D) | (P&S&D);
    8'hA3: out = (~P&~S&~D) | (~P&~S&D) | (P&~S&D) | (P&S&D);
    8'hA4: out = (~P&S&~D) | (P&~S&D) | (P&S&D);
    8'hA5: out = (~P&~S&~D) | (~P&S&~D) | (P&~S&D) | (P&S&D);
    8'hA6: out = (~P&~S&D) | (~P&S&~D) | (P&~S&D) | (P&S&D);
    8'hA7: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&~S&D) | (P&S&D);
    8'hA8: out = (~P&S&D) | (P&~S&D) | (P&S&D);
    8'hA9: out = (~P&~S&~D) | (~P&S&D) | (P&~S&D) | (P&S&D);
    8'hAA: out = (~P&~S&D) | (~P&S&D) | (P&~S&D) | (P&S&D);
    8'hAB: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&~S&D) | (P&S&D);
    8'hAC: out = (~P&S&~D) | (~P&S&D) | (P&~S&D) | (P&S&D);
    8'hAD: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&~S&D) | (P&S&D);
    8'hAE: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&D) | (P&S&D);
    8'hAF: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&D) | (P&S&D);
    8'hB0: out = (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hB1: out = (~P&~S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hB2: out = (~P&~S&D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hB3: out = (~P&~S&~D) | (~P&~S&D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hB4: out = (~P&S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hB5: out = (~P&~S&~D) | (~P&S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hB6: out = (~P&~S&D) | (~P&S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hB7: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hB8: out = (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hB9: out = (~P&~S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hBA: out = (~P&~S&D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hBB: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hBC: out = (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hBD: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hBE: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hBF: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&D);
    8'hC0: out = (P&S&~D) | (P&S&D);
    8'hC1: out = (~P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hC2: out = (~P&~S&D) | (P&S&~D) | (P&S&D);
    8'hC3: out = (~P&~S&~D) | (~P&~S&D) | (P&S&~D) | (P&S&D);
    8'hC4: out = (~P&S&~D) | (P&S&~D) | (P&S&D);
    8'hC5: out = (~P&~S&~D) | (~P&S&~D) | (P&S&~D) | (P&S&D);
    8'hC6: out = (~P&~S&D) | (~P&S&~D) | (P&S&~D) | (P&S&D);
    8'hC7: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&S&~D) | (P&S&D);
    8'hC8: out = (~P&S&D) | (P&S&~D) | (P&S&D);
    8'hC9: out = (~P&~S&~D) | (~P&S&D) | (P&S&~D) | (P&S&D);
    8'hCA: out = (~P&~S&D) | (~P&S&D) | (P&S&~D) | (P&S&D);
    8'hCB: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&S&~D) | (P&S&D);
    8'hCC: out = (~P&S&~D) | (~P&S&D) | (P&S&~D) | (P&S&D);
    8'hCD: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&S&~D) | (P&S&D);
    8'hCE: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&S&~D) | (P&S&D);
    8'hCF: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&S&~D) | (P&S&D);
    8'hD0: out = (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hD1: out = (~P&~S&~D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hD2: out = (~P&~S&D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hD3: out = (~P&~S&~D) | (~P&~S&D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hD4: out = (~P&S&~D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hD5: out = (~P&~S&~D) | (~P&S&~D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hD6: out = (~P&~S&D) | (~P&S&~D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hD7: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hD8: out = (~P&S&D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hD9: out = (~P&~S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hDA: out = (~P&~S&D) | (~P&S&D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hDB: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hDC: out = (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hDD: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hDE: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hDF: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&S&~D) | (P&S&D);
    8'hE0: out = (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hE1: out = (~P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hE2: out = (~P&~S&D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hE3: out = (~P&~S&~D) | (~P&~S&D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hE4: out = (~P&S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hE5: out = (~P&~S&~D) | (~P&S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hE6: out = (~P&~S&D) | (~P&S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hE7: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hE8: out = (~P&S&D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hE9: out = (~P&~S&~D) | (~P&S&D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hEA: out = (~P&~S&D) | (~P&S&D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hEB: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hEC: out = (~P&S&~D) | (~P&S&D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hED: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hEE: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hEF: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hF0: out = (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hF1: out = (~P&~S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hF2: out = (~P&~S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hF3: out = (~P&~S&~D) | (~P&~S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hF4: out = (~P&S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hF5: out = (~P&~S&~D) | (~P&S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hF6: out = (~P&~S&D) | (~P&S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hF7: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hF8: out = (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hF9: out = (~P&~S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hFA: out = (~P&~S&D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hFB: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hFC: out = (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hFD: out = (~P&~S&~D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hFE: out = (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
    8'hFF: out = (~P&~S&~D) | (~P&~S&D) | (~P&S&~D) | (~P&S&D) | (P&~S&~D) | (P&~S&D) | (P&S&~D) | (P&S&D);
  endcase
end
// ----- Combinational Logic ----- //

// ----- stage 2 start -----//
always @(posedge clk) begin
  dout_valid <= stage1_din_valid;
  result <= out;
end
// ----- stage 2 end -----//



endmodule