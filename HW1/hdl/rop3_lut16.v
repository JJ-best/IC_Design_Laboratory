/*
* Module      : rop3_lut16
* Description : Implement this module using the look-up table (LUT) 
*               This module should support all the 15-modes listed in table-1
*               For modes not in the table-1, set the Result to 0
* Notes       : Please remember to
*               (1) make the bit-length of {din, result} parameterizable
*               (2) make the input/output to be a register 
*/

module rop3_lut16
#(
  parameter N = 8
)
(
  input clk,
  input din_valid,
  input [4*N-1:0] din,// din = {W, X, Y, Z}
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
  8'h00: begin
    out = 0;
  end
  8'h11: begin
    out = ~(D|S);
  end
  8'h33: begin
    out = ~S;
  end
  8'h44: begin
    out = S & ~D;
  end
  8'h55: begin
    out = ~D;
  end
  8'h5A: begin
    out = D ^ P;
  end
  8'h66: begin
    out = D ^ S;
  end
  8'h88: begin
    out = D & S;
  end
  8'hBB: begin
    out = D | ~S;
  end
  8'hC0: begin
    out = P & S;
  end
  8'hCC: begin
    out = S;
  end
  8'hEE: begin
    out = D | S;
  end
  8'hF0: begin
    out = P;
  end
  8'hFB: begin
    out = D | P | ~ S;
  end
  8'hFF: begin
    out = {N{1'b1}};
  end
  default : begin
    out = 0;
  end
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