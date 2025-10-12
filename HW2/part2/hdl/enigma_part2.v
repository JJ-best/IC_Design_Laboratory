//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2025 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================


module enigma_part2(clk, srst_n, load, encrypt, crypt_mode, table_idx, code_in, code_out, code_valid);
input clk;         // clock 
input srst_n;      // synchronous reset (active low)
input load;        // load control signal (level sensitive). 0/1: inactive/active
input encrypt;     // encrypt control signal (level sensitive). 0/1: inactive/active
input crypt_mode;  // 0: encrypt; 1:decrypt;
input [2-1:0] table_idx; // table_idx indicates which rotor to be loaded
						             // 2'b00: rotorA
						             // 2'b01: plugboard
						             // 2'b10: rotorB
input [6-1:0] code_in;	// When load is active, then code_in is input of rotors. 
						// When encrypy is active, then code_in is input of code words.
output wire [6-1:0] code_out;   // encrypted code word 
output wire code_valid;         // 0: non-valid code_out; 1: valid code_out 

localparam pRotorA_LEN = 64;
localparam pData_LEN = 6;

// ----- Rotor A declare -----//
wire [(pData_LEN-1):0] link [0:(pRotorA_LEN-1)];
wire [1:0] shift_value_t;
wire [(pData_LEN-1):0] RotorA_forward_o;
reg [(pData_LEN-1):0] RotorA_inverse_i;
// ----- bitswitch declare -----//
reg [1:0]mode_bitswitch;
wire [1:0]mode_bitswitch_next;
reg [(pData_LEN-1):0]bitswitch_forward_o;
wire [(pData_LEN-1):0]bitswitch_inverse_i;
// ----- XOR declare -----//
reg [(pData_LEN-1):0]lfsr_reg;
wire [(pData_LEN-1):0]xor_o;
wire [(pRotorA_LEN-1):0]bitwise_and_o; // one-bit match flags
// ----- Rotor A ----- //
genvar k;
generate
  for (k=63; k>=0; k=k-1) begin : G_ROTOR
	if (k == 63) begin : G_FIRST
	  RotorA_cell u_cellk (
      .param1_i(link[ (k+0) % pRotorA_LEN ]), 
	  .param2_i(link[ (k+1) % pRotorA_LEN ]), 
	  .param3_i(link[ (k+2) % pRotorA_LEN ]), 
	  .param4_i(link[ (k+3) % pRotorA_LEN ]), 
      .shift_i (code_in),
      .load_i  (load),
      .encrypt_i(encrypt),
      .clk     (clk),
      .shift_value_i(shift_value_t),  
	  .table_idx(table_idx),
      .shift_o (link[k])
    );
	end else begin : G_OTHER
	  RotorA_cell u_cellk (
      .param1_i(link[ (k+0) % pRotorA_LEN ]), 
	  .param2_i(link[ (k+1) % pRotorA_LEN ]), 
	  .param3_i(link[ (k+2) % pRotorA_LEN ]), 
	  .param4_i(link[ (k+3) % pRotorA_LEN ]), 
      .shift_i (link[k+1]),
      .load_i  (load),
      .encrypt_i(encrypt),
      .clk     (clk),
      .shift_value_i(shift_value_t),  
	  .table_idx(table_idx),
      .shift_o (link[k])
    );
	end
  end
endgenerate

// this mux may use other optimize method for synthesis.
assign RotorA_forward_o = link[code_in];

assign shift_value_t = (crypt_mode == 1'b0)? RotorA_forward_o[1:0] : RotorA_inverse_i[1:0];

// --- inverpath ---
// bitwise and to detect equality between xor_o and each link[j]
// generate a one-hot code
genvar j;
generate
	for (j = 0; j < pRotorA_LEN; j = j + 1) begin : GEN_MATCH
	  assign bitwise_and_o[j] = ~|(RotorA_inverse_i ^ link[j]);
	end
endgenerate

onehot2binary encoder(
	.onehot_i(bitwise_and_o),
	.binary_o(code_out)
);
// --- inverpath ---
// ----- Rotor A ----- //


// ----- Bit switching ----- //
always @(posedge clk) begin
	if (!srst_n) begin
	  mode_bitswitch <= 0; 
	end else if (encrypt) begin
	  mode_bitswitch <= mode_bitswitch_next;
	end else begin
	  mode_bitswitch <= mode_bitswitch;
	end
end
assign mode_bitswitch_next[1:0] = (crypt_mode == 1'b0)? bitswitch_forward_o[1:0] : bitswitch_inverse_i[1:0];


always @(*) begin
	case (mode_bitswitch)
	2'b00: begin
	  bitswitch_forward_o[(pData_LEN-1):0] = ~RotorA_forward_o[(pData_LEN-1):0];
	  RotorA_inverse_i[(pData_LEN-1):0] = ~bitswitch_inverse_i[(pData_LEN-1):0];
	end
	2'b01: begin
	  bitswitch_forward_o[(pData_LEN-1):0] = {RotorA_forward_o[0], RotorA_forward_o[1], RotorA_forward_o[2], RotorA_forward_o[3], RotorA_forward_o[4], RotorA_forward_o[5]};
	  RotorA_inverse_i[(pData_LEN-1):0] = {bitswitch_inverse_i[0], bitswitch_inverse_i[1], bitswitch_inverse_i[2], bitswitch_inverse_i[3], bitswitch_inverse_i[4], bitswitch_inverse_i[5]};
	end
	2'b10: begin
	  bitswitch_forward_o[(pData_LEN-1):0] = {RotorA_forward_o[4], RotorA_forward_o[5], RotorA_forward_o[2], RotorA_forward_o[3], RotorA_forward_o[0], RotorA_forward_o[1]};
	  RotorA_inverse_i[(pData_LEN-1):0] = {bitswitch_inverse_i[4], bitswitch_inverse_i[5], bitswitch_inverse_i[2], bitswitch_inverse_i[3], bitswitch_inverse_i[0], bitswitch_inverse_i[1]};
	end
	2'b11: begin
	  bitswitch_forward_o[(pData_LEN-1):0] = {RotorA_forward_o[2], RotorA_forward_o[1], RotorA_forward_o[0], RotorA_forward_o[5], RotorA_forward_o[4], RotorA_forward_o[3]};
	  RotorA_inverse_i[(pData_LEN-1):0] = {bitswitch_inverse_i[2], bitswitch_inverse_i[1], bitswitch_inverse_i[0], bitswitch_inverse_i[5], bitswitch_inverse_i[4], bitswitch_inverse_i[3]};
	end
	endcase
end


// ----- Bit switching ----- //

// ----- XOR ----- //
always @(posedge clk) begin
	if (!srst_n) begin
	  lfsr_reg <=  6'b00_0001;
	end else if (encrypt) begin
	  lfsr_reg[5] <= lfsr_reg[4];
	  lfsr_reg[4] <= lfsr_reg[3];
	  lfsr_reg[3] <= lfsr_reg[2];
	  lfsr_reg[2] <= lfsr_reg[1];
	  lfsr_reg[1] <= lfsr_reg[0];
	  lfsr_reg[0] <= lfsr_reg[5] ^ lfsr_reg[4];
	end else begin
	  lfsr_reg <= lfsr_reg;
	end
end
assign xor_o = lfsr_reg ^ bitswitch_forward_o;
assign bitswitch_inverse_i = xor_o;
// ----- XOR ----- //



assign code_valid = encrypt;
endmodule


// ----- Rotor A submodule -----//
module RotorA_cell # (
	parameter pData_LEN = 6
)(
	input wire [(pData_LEN-1):0] param1_i,
	input wire [(pData_LEN-1):0] param2_i,
	input wire [(pData_LEN-1):0] param3_i,
	input wire [(pData_LEN-1):0] param4_i,
	input wire [(pData_LEN-1):0] shift_i, // previous stage output
	input load_i,
	input encrypt_i,
	input clk,
	input [1:0]shift_value_i,
	input [1:0]table_idx,
	output reg [(pData_LEN-1):0] shift_o
);

reg [(pData_LEN-1):0] shift_mux;
always @(*) begin
	case (shift_value_i) // synopsys parallel_case
	2'b00: shift_mux = param1_i;
	2'b01: shift_mux = param2_i;
	2'b10: shift_mux = param3_i;
	2'b11: shift_mux = param4_i;
	endcase
end

reg [(pData_LEN-1):0] reg_i;
always @(*) begin
	case ({load_i, encrypt_i}) // synopsys parallel_case
	2'b01: reg_i = shift_mux;
	2'b10: reg_i = shift_i;
	default: reg_i = shift_o;
	endcase
end

always @(posedge clk) begin
	if (table_idx == 2'b00 | encrypt_i == 1) begin
	  shift_o <= reg_i;
	end else begin
	  shift_o <= shift_o;
	end
	
end

endmodule

// ----- one-hot to binary encoder ----- //
module onehot2binary #(
  parameter ONEHOT_WIDTH = 64,
  parameter BIN_WIDTH    = 6
)(
  input      [ONEHOT_WIDTH-1 : 0] onehot_i,
  output     [BIN_WIDTH-1    : 0] binary_o  
);

assign binary_o[5] = |onehot_i[63:32];

assign binary_o[4] = |{ onehot_i[63:48], onehot_i[31:16] };

assign binary_o[3] = |{ onehot_i[63:56], onehot_i[47:40],
                        onehot_i[31:24], onehot_i[15:8] };

assign binary_o[2] = |{ onehot_i[63:60], onehot_i[55:52], onehot_i[47:44], onehot_i[39:36],
                        onehot_i[31:28], onehot_i[23:20], onehot_i[15:12], onehot_i[7:4] };

assign binary_o[1] = |{ onehot_i[63:62], onehot_i[59:58], onehot_i[55:54], onehot_i[51:50],
                        onehot_i[47:46], onehot_i[43:42], onehot_i[39:38], onehot_i[35:34],
                        onehot_i[31:30], onehot_i[27:26], onehot_i[23:22], onehot_i[19:18],
                        onehot_i[15:14], onehot_i[11:10], onehot_i[7:6],   onehot_i[3:2] };

assign binary_o[0] = |{ onehot_i[63], onehot_i[61], onehot_i[59], onehot_i[57],
                        onehot_i[55], onehot_i[53], onehot_i[51], onehot_i[49],
                        onehot_i[47], onehot_i[45], onehot_i[43], onehot_i[41],
                        onehot_i[39], onehot_i[37], onehot_i[35], onehot_i[33],
                        onehot_i[31], onehot_i[29], onehot_i[27], onehot_i[25],
                        onehot_i[23], onehot_i[21], onehot_i[19], onehot_i[17],
                        onehot_i[15], onehot_i[13], onehot_i[11], onehot_i[9],
                        onehot_i[7],  onehot_i[5],  onehot_i[3],  onehot_i[1] };

endmodule
