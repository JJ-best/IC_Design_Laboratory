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



endmodule