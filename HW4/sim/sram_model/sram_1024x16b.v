//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

// Behavior model of SRAM 1024x16b

module sram_1024x16b(
	input clk,
	input csb,           // chip enable (low-active)
	
	input wsb,           // write enable (low-active)
	input wdata,         // write data
	input [10-1:0] waddr,  // write address

	input [10-1:0] raddr,  // read address

	output reg [15:0] rdata     // read data
);

reg [16-1:0] mem [64*64-1:0];

// write
always@(negedge clk) begin
  	if(~csb && ~wsb)
    	mem[waddr] <= wdata;
end

// read
always@(negedge clk) begin
  	if(~csb)
    	rdata <= mem[raddr];
end


//-------------------- task --------------------
// load QR Code (.bmp) into SRAM
task bmp2sram;
	input [31:0] pat_no;
	input [7:0] RANK;

	reg [128*8-1:0] bmp_filepath;
	reg [7:0] char_in;
	integer i, j;
	integer file_in;


	begin
		if(RANK == "A") begin
			bmp_filepath = "./pat/rank_A/pat_000.bmp";
			// hundreds digit
			bmp_filepath[7*8-1:6*8] = (pat_no / 100) + 48;
		end
		else if(RANK == "B") begin
			bmp_filepath = "./pat/rank_B/pat_000.bmp";
			// hundreds digit
			bmp_filepath[7*8-1:6*8] = (pat_no / 100) + 48;
		end
		else if(RANK == "C") begin
			bmp_filepath = "./pat/rank_C/pat_000.bmp";
			// hundreds digit
			bmp_filepath[7*8-1:6*8] = (pat_no / 100) + 48;
		end
		else if(RANK == "D")
			bmp_filepath = "./pat/rank_D/pat_000.bmp";

		// tens digit
		bmp_filepath[6*8-1:5*8] = (pat_no % 100 / 10) + 48;
		// units digit
		bmp_filepath[5*8-1:4*8] = (pat_no % 100 % 10) + 48;
		$display("Loading pattern from %0s", bmp_filepath);
		
		file_in = $fopen(bmp_filepath, "rb");
		
		// skip header
		for(i=0; i<1078; i=i+1) begin
			char_in = $fgetc(file_in);
		end

		// read 128x128 bmp
		for(i=128-1; i>=0; i=i-1) begin // since bmp's row starts from the bottom row
			for(j=0; j<128; j=j+1) begin
				char_in = $fgetc(file_in);
				if(char_in === 8'hff)
					mem[{i[6:2], j[6:2]}][{i[1:0], j[1:0]}] = 1'b0;  // 0 denotes white
				else if(char_in === 8'h00)
					mem[{i[6:2], j[6:2]}][{i[1:0], j[1:0]}] = 1'b1;  // 1 denotes black
				else
					$display("Something wrong in the bmp file !!!");
			end
		end

		$fclose(file_in);
	end
endtask

// display the content inside SRAM
task display_sram;
	integer i, j;
  	begin
		for(i=0; i<128; i=i+1) begin
			for(j=0; j<128; j=j+1) begin
				$write("%b", mem[{i[6:2], j[6:2]}][{i[1:0], j[1:0]}]);
			end
			$write("\n");
		end
  	end
endtask

endmodule