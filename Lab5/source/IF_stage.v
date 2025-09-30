//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module IF_stage(
	input clk,
	input rst_n,
	input boot_up,
	input [7:0] boot_addr,
	input [31:0] boot_datai,
	input boot_web,
	input [15:0] Branch_in,
	input PCSrc,
	output [31:0] instn,
	output PC_run,
	output [15:0] PC_add
);

wire [9:0] PC_out;
wire [7:0] ins_addr;

PC PC(
	.clk(clk),
	.rst_n(rst_n),
  .boot_up(boot_up),
	.PCSrc(PCSrc),
	.PC_out(PC_add), // output
  .PC_run(PC_run),   // output
	.Branch_in(Branch_in)
);

assign ins_addr = PC_add[9:2];

wire icache_en_wr = PC_run ? 1'b1 : boot_web;
wire [7:0] icache_addr = PC_run ? ins_addr : boot_addr;


/* instantiate SRAM256x32s as icache here
 *   The I port of icache should take boot_datai as input
 * The O port of icache should drive instn for CPU as instruction
 * The read/write control signal is controlled by icache_en_wr
 */
SRAM256x32s icache(
	.CE(clk),
	.WEB(icache_en_wr), // write enable, active low
	.OEB(1'b0),			// output enable, active low
	.CSB(1'b0),			// chip select, active low
	.A(icache_addr),
	.I(boot_datai),
	.O(instn)
);


endmodule
