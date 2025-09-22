//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module lab2_alu(
  //clock and control signals
  input clk,
  input rst_n,
  //input
  input [7:0] inputA, inputB,
  input [3:0] instruction,
  //output
  output reg [7:0] alu_out
);
reg [7:0] A_reg;
reg [7:0] B_reg;
reg [3:0] I_reg;
localparam addition = 4'b0000;
localparam subtraction = 4'b0001;
localparam inversion_b = 4'b0010;
localparam AND = 4'b0011;
localparam OR = 4'b0100;

always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    A_reg[7:0] <= 8'b0;
    B_reg[7:0] <= 0;
    I_reg[3:0] <= 0;
  end else begin
    A_reg[7:0] <= inputA;
    B_reg[7:0] <= inputB;
    I_reg[3:0] <= instruction;
  end
end

reg [7:0]out;
always @(*) begin
  case (I_reg[3:0])
    addition: begin
      out = A_reg + B_reg;
    end
    subtraction: begin
      out = A_reg - B_reg;
    end
    inversion_b: begin
      out = ~B_reg;
    end
    AND: begin
      out = A_reg & B_reg;
    end
    OR: begin
      out = A_reg | B_reg;
    end
    default : begin
      out = A_reg ^ B_reg;
    end
  endcase
end

always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    alu_out <= 0;
  end else begin
    alu_out <= out;
  end
end

endmodule



