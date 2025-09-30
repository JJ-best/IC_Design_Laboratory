//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

/*********************************************************************
*  saed_mc : SRAM256x32s Verilog description                       *
*  ---------------------------------------------------------------   *
*  Filename      : /home/faculty/chaotsung/memory_test/mc_sram256x32_singlelp/SRAM256x32s.v                         *
*  SRAM name     : SRAM256x32s                                       *
*  Word width    : 256   bits                                        *
*  Word number   : 32                                                *
*  Adress width  : 5     bits                                        *
*  ---------------------------------------------------------------   *
*  Creation date : Mon March 03 2014                                 *
*********************************************************************/

`timescale 1ns/100fs

module SRAM256x32s (A,CE,WEB,OEB,CSB,I,O);
parameter numAddr = 8;
parameter numWords = 256;
parameter wordLength = 32;

input         CE; // posedge clk
input         WEB;// write enable, active low
input         OEB;// output enable, active low
input         CSB;// chip select, active low

input  [numAddr-1:0]    A; // read/write address
input  [wordLength-1:0] I; // input data bus
output [wordLength-1:0] O; // output data bus

reg    [wordLength-1:0] memory[numWords-1:0];
reg    [wordLength-1:0] data_out1;
reg    [wordLength-1:0] O;

wire         RE;
wire         WE;

and u1 (RE, ~CSB,  WEB);
and u2 (WE, ~CSB, ~WEB);

always @ (posedge CE)
  if (RE)
    data_out1 = memory[A];
  else
    if (WE)
      memory[A] = I;

always @ (data_out1 or OEB)
  if (!OEB)
    O = data_out1;
  else
    O = {wordLength{1'bz}};

endmodule
