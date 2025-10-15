//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2025 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================


module enigma(clk, srst_n, load, encrypt, crypt_mode, table_idx, code_in, code_out, code_valid);
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
output reg [6-1:0] code_out;   // encrypted code word 
output reg code_valid;         // 0: non-valid code_out; 1: valid code_out 

localparam pRotorA_LEN = 64;
localparam pPLUG_LEN = 32;
localparam pData_LEN = 6;

// ----- plugboard declare -----//
reg [(pData_LEN-1):0] plugboard_reg [0:(pPLUG_LEN-1)];
wire [(pPLUG_LEN-1):0]plug_xor_i;
wire [(pPLUG_LEN-1):0]plug_xor_o;
wire [(pData_LEN-1):0]plug_forward_o;
reg [(pData_LEN-1):0]plug_forward_o_reg;
wire [(pData_LEN-1):0]plug_inverse_i;
reg [(pData_LEN-1):0]plug_inverse_i_reg;
wire [4:0]plug_pair_i;
wire [4:0]plug_pair_o;
wire [4:0]plug_mux_sel_i;
wire [4:0]plug_mux_sel_o;
wire plug_forward_valid_i; // encoder valid
wire plug_forward_valid_o;
reg plug_forward_valid; //pipeline valid
reg plug_inverse_valid;
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

// ----- input buffer ----- //
reg srst_n_reg;
reg load_reg;
reg encrypt_reg;
reg crypt_mode_reg;
reg [1:0]table_idx_reg;
reg [5:0]code_in_reg;
always @(posedge clk) begin
  srst_n_reg <= srst_n;
  load_reg <= load;
  encrypt_reg <=encrypt;
  crypt_mode_reg <= crypt_mode;
  table_idx_reg <= table_idx;
  code_in_reg <= code_in;
end
// ----- input buffer ----- //

// ----- plugboard ----- //
integer i;
always @(posedge clk) begin
	for (i=31; i>=0; i=i-1) begin
		if (i == 31) begin
		  plugboard_reg[i] <= (load_reg == 1 && table_idx_reg == 2'b01)? code_in_reg : plugboard_reg[i];
		end else begin
		  plugboard_reg[i] <= (load_reg == 1 && table_idx_reg == 2'b01)? plugboard_reg[i+1] : plugboard_reg[i];
		end
	end
end
genvar m;
generate
	for (m = 31; m >= 0; m = m - 1) begin : GEN_PLUG_IN
	  assign  plug_xor_i[m] = ~|(code_in_reg ^ plugboard_reg[m]);
	end
endgenerate
genvar l;
generate
	for (l = 31; l >= 0; l = l - 1) begin : GEN_PLUG_OUT
	  assign  plug_xor_o[l] = ~|(plug_inverse_i_reg ^ plugboard_reg[l]);
	end
endgenerate

onehot2binary_32 encoder32_i(
	.onehot_i(plug_xor_i),
	.binary_o(plug_mux_sel_i),
	.valid_o(plug_forward_valid_i)
);
assign plug_pair_i = plug_mux_sel_i ^ 5'b00001;
assign plug_forward_o = (plug_forward_valid_i)? plugboard_reg[plug_pair_i] : code_in_reg;
// plug forward out pipeline

always @(posedge clk) begin
  plug_forward_o_reg <= plug_forward_o;
  plug_forward_valid <= encrypt_reg;
end


onehot2binary_32 encoder32_o(
	.onehot_i(plug_xor_o),
	.binary_o(plug_mux_sel_o),
	.valid_o(plug_forward_valid_o)
);
assign plug_pair_o = plug_mux_sel_o ^ 5'b00001; // this may be optimize by other method



// plug inverse in pipeline

// output buffer
always @(posedge clk) begin
  code_out <= (plug_forward_valid_o)? plugboard_reg[plug_pair_o] : plug_inverse_i_reg;
  code_valid <= plug_inverse_valid;
end
// ----- plugboard ----- //


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
      .shift_i (code_in_reg),
      .load_i  (load_reg),
      .encrypt_i(plug_forward_valid),
      .clk     (clk),
      .shift_value_i(shift_value_t),  
	  .table_idx(table_idx_reg),
      .shift_o (link[k])
    );
	end else begin : G_OTHER
	  RotorA_cell u_cellk (
      .param1_i(link[ (k+0) % pRotorA_LEN ]), 
	  .param2_i(link[ (k+1) % pRotorA_LEN ]), 
	  .param3_i(link[ (k+2) % pRotorA_LEN ]), 
	  .param4_i(link[ (k+3) % pRotorA_LEN ]), 
      .shift_i (link[k+1]),
      .load_i  (load_reg),
      .encrypt_i(plug_forward_valid),
      .clk     (clk),
      .shift_value_i(shift_value_t),  
	  .table_idx(table_idx_reg),
      .shift_o (link[k])
    );
	end
  end
endgenerate

// this mux may use other optimize method for synthesis.
assign RotorA_forward_o = link[plug_forward_o_reg];

assign shift_value_t = (crypt_mode_reg == 1'b0)? RotorA_forward_o[1:0] : RotorA_inverse_i[1:0];

// --- inverpath ---
// bitwise and to detect equality between xor_o and each link[j]
// generate a one-hot code
genvar j;
generate
	for (j = 0; j < pRotorA_LEN; j = j + 1) begin : GEN_MATCH
	  assign bitwise_and_o[j] = ~|(RotorA_inverse_i ^ link[j]);
	end
endgenerate

onehot2binary_64 encoder64_A(
	.onehot_i(bitwise_and_o),
	.binary_o(plug_inverse_i)
);
always @(posedge clk) begin
  plug_inverse_i_reg <= plug_inverse_i;
  plug_inverse_valid <= plug_forward_valid;
end
// --- inverpath ---
// ----- Rotor A ----- //


// ----- Bit switching ----- //
always @(posedge clk) begin
	if (!srst_n_reg) begin
	  mode_bitswitch <= 0; 
	end else if (plug_forward_valid) begin
	  mode_bitswitch <= mode_bitswitch_next;
	end else begin
	  mode_bitswitch <= mode_bitswitch;
	end
end
assign mode_bitswitch_next[1:0] = (crypt_mode_reg == 1'b0)? bitswitch_forward_o[1:0] : bitswitch_inverse_i[1:0];


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

// ----- Rotor B -----//
wire [(pData_LEN-1):0] RotorB_forward_o;
wire [(pData_LEN-1):0] RotorB_inverse_i;
wire [(pData_LEN-1):0] RotorB_reg [0:(pRotorA_LEN-1)];
wire [1:0] shift_value_b;
wire [(pRotorA_LEN-1):0] bitwise_and_b;
wire [(pData_LEN-1):0] RotorB_mux [0:(pRotorA_LEN-1)];
RotorB_cell U63(
	.param1_i(RotorB_reg[63]), .param2_i(RotorB_reg[62]),
	.param3_i(RotorB_reg[61]), .param4_i(RotorB_reg[60]),
	.shift_i(code_in_reg),
	.load_i(load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
	.shift_value_i(shift_value_b), .table_idx(table_idx_reg),
	.mux_i(RotorB_mux[33]), .shift_o(RotorB_reg[63]), .mux_o(RotorB_mux[63])
);

RotorB_cell U62(
	.param1_i(RotorB_reg[62]), .param2_i(RotorB_reg[63]),
	.param3_i(RotorB_reg[60]), .param4_i(RotorB_reg[61]),
	.shift_i(RotorB_reg[63]),
	.load_i(load_reg), .encrypt_i(plug_forward_valid), .clk(clk), 
	.shift_value_i(shift_value_b), .table_idx(table_idx_reg),
	.mux_i(RotorB_mux[0]), .shift_o(RotorB_reg[62]), .mux_o(RotorB_mux[62])
);

RotorB_cell U61(
	.param1_i(RotorB_reg[61]), .param2_i(RotorB_reg[60]),
	.param3_i(RotorB_reg[63]), .param4_i(RotorB_reg[62]),
	.shift_i(RotorB_reg[62]),
	.load_i(load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
	.shift_value_i(shift_value_b), .table_idx(table_idx_reg),
	.mux_i(RotorB_mux[20]), .shift_o(RotorB_reg[61]), .mux_o(RotorB_mux[61])
);

RotorB_cell U60(
	.param1_i(RotorB_reg[60]), .param2_i(RotorB_reg[61]),
	.param3_i(RotorB_reg[62]), .param4_i(RotorB_reg[63]),
	.shift_i(RotorB_reg[61]),
	.load_i(load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
	.shift_value_i(shift_value_b), .table_idx(table_idx_reg),
	.mux_i(RotorB_mux[41]), .shift_o(RotorB_reg[60]), .mux_o(RotorB_mux[60])
);

// group top = 59
RotorB_cell U59(
  .param1_i(RotorB_reg[59]), .param2_i(RotorB_reg[58]),
  .param3_i(RotorB_reg[57]), .param4_i(RotorB_reg[56]),
  .shift_i (RotorB_reg[60]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[27]), .shift_o(RotorB_reg[59]), .mux_o(RotorB_mux[59])
);

RotorB_cell U58(
  .param1_i(RotorB_reg[58]), .param2_i(RotorB_reg[59]),
  .param3_i(RotorB_reg[56]), .param4_i(RotorB_reg[57]),
  .shift_i (RotorB_reg[59]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[31]), .shift_o(RotorB_reg[58]), .mux_o(RotorB_mux[58])
);

RotorB_cell U57(
  .param1_i(RotorB_reg[57]), .param2_i(RotorB_reg[56]),
  .param3_i(RotorB_reg[59]), .param4_i(RotorB_reg[58]),
  .shift_i (RotorB_reg[58]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[45]), .shift_o(RotorB_reg[57]), .mux_o(RotorB_mux[57])
);

RotorB_cell U56(
  .param1_i(RotorB_reg[56]), .param2_i(RotorB_reg[57]),
  .param3_i(RotorB_reg[58]), .param4_i(RotorB_reg[59]),
  .shift_i (RotorB_reg[57]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[12]), .shift_o(RotorB_reg[56]), .mux_o(RotorB_mux[56])
);

// group top = 55
RotorB_cell U55(
  .param1_i(RotorB_reg[55]), .param2_i(RotorB_reg[54]),
  .param3_i(RotorB_reg[53]), .param4_i(RotorB_reg[52]),
  .shift_i (RotorB_reg[56]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[7]), .shift_o(RotorB_reg[55]), .mux_o(RotorB_mux[55])
);

RotorB_cell U54(
  .param1_i(RotorB_reg[54]), .param2_i(RotorB_reg[55]),
  .param3_i(RotorB_reg[52]), .param4_i(RotorB_reg[53]),
  .shift_i (RotorB_reg[55]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[37]), .shift_o(RotorB_reg[54]), .mux_o(RotorB_mux[54])
);

RotorB_cell U53(
  .param1_i(RotorB_reg[53]), .param2_i(RotorB_reg[52]),
  .param3_i(RotorB_reg[55]), .param4_i(RotorB_reg[54]),
  .shift_i (RotorB_reg[54]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[1]), .shift_o(RotorB_reg[53]), .mux_o(RotorB_mux[53])
);

RotorB_cell U52(
  .param1_i(RotorB_reg[52]), .param2_i(RotorB_reg[53]),
  .param3_i(RotorB_reg[54]), .param4_i(RotorB_reg[55]),
  .shift_i (RotorB_reg[53]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[62]), .shift_o(RotorB_reg[52]), .mux_o(RotorB_mux[52])
);

// group top = 51
RotorB_cell U51(
  .param1_i(RotorB_reg[51]), .param2_i(RotorB_reg[50]),
  .param3_i(RotorB_reg[49]), .param4_i(RotorB_reg[48]),
  .shift_i (RotorB_reg[52]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[52]), .shift_o(RotorB_reg[51]), .mux_o(RotorB_mux[51])
);

RotorB_cell U50(
  .param1_i(RotorB_reg[50]), .param2_i(RotorB_reg[51]),
  .param3_i(RotorB_reg[48]), .param4_i(RotorB_reg[49]),
  .shift_i (RotorB_reg[51]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[35]), .shift_o(RotorB_reg[50]), .mux_o(RotorB_mux[50])
);

RotorB_cell U49(
  .param1_i(RotorB_reg[49]), .param2_i(RotorB_reg[48]),
  .param3_i(RotorB_reg[51]), .param4_i(RotorB_reg[50]),
  .shift_i (RotorB_reg[50]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[19]), .shift_o(RotorB_reg[49]), .mux_o(RotorB_mux[49])
);

RotorB_cell U48(
  .param1_i(RotorB_reg[48]), .param2_i(RotorB_reg[49]),
  .param3_i(RotorB_reg[50]), .param4_i(RotorB_reg[51]),
  .shift_i (RotorB_reg[49]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[50]), .shift_o(RotorB_reg[48]), .mux_o(RotorB_mux[48])
);

// group top = 47
RotorB_cell U47(
  .param1_i(RotorB_reg[47]), .param2_i(RotorB_reg[46]),
  .param3_i(RotorB_reg[45]), .param4_i(RotorB_reg[44]),
  .shift_i (RotorB_reg[48]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[59]), .shift_o(RotorB_reg[47]), .mux_o(RotorB_mux[47])
);

RotorB_cell U46(
  .param1_i(RotorB_reg[46]), .param2_i(RotorB_reg[47]),
  .param3_i(RotorB_reg[44]), .param4_i(RotorB_reg[45]),
  .shift_i (RotorB_reg[47]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[36]), .shift_o(RotorB_reg[46]), .mux_o(RotorB_mux[46])
);

RotorB_cell U45(
  .param1_i(RotorB_reg[45]), .param2_i(RotorB_reg[44]),
  .param3_i(RotorB_reg[47]), .param4_i(RotorB_reg[46]),
  .shift_i (RotorB_reg[46]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[4]), .shift_o(RotorB_reg[45]), .mux_o(RotorB_mux[45])
);

RotorB_cell U44(
  .param1_i(RotorB_reg[44]), .param2_i(RotorB_reg[45]),
  .param3_i(RotorB_reg[46]), .param4_i(RotorB_reg[47]),
  .shift_i (RotorB_reg[45]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[15]), .shift_o(RotorB_reg[44]), .mux_o(RotorB_mux[44])
);

// group top = 43
RotorB_cell U43(
  .param1_i(RotorB_reg[43]), .param2_i(RotorB_reg[42]),
  .param3_i(RotorB_reg[41]), .param4_i(RotorB_reg[40]),
  .shift_i (RotorB_reg[44]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[11]), .shift_o(RotorB_reg[43]), .mux_o(RotorB_mux[43])
);

RotorB_cell U42(
  .param1_i(RotorB_reg[42]), .param2_i(RotorB_reg[43]),
  .param3_i(RotorB_reg[40]), .param4_i(RotorB_reg[41]),
  .shift_i (RotorB_reg[43]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[30]), .shift_o(RotorB_reg[42]), .mux_o(RotorB_mux[42])
);

RotorB_cell U41(
  .param1_i(RotorB_reg[41]), .param2_i(RotorB_reg[40]),
  .param3_i(RotorB_reg[43]), .param4_i(RotorB_reg[42]),
  .shift_i (RotorB_reg[42]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[39]), .shift_o(RotorB_reg[41]), .mux_o(RotorB_mux[41])
);

RotorB_cell U40(
  .param1_i(RotorB_reg[40]), .param2_i(RotorB_reg[41]),
  .param3_i(RotorB_reg[42]), .param4_i(RotorB_reg[43]),
  .shift_i (RotorB_reg[41]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[51]), .shift_o(RotorB_reg[40]), .mux_o(RotorB_mux[40])
);

// group top = 39
RotorB_cell U39(
  .param1_i(RotorB_reg[39]), .param2_i(RotorB_reg[38]),
  .param3_i(RotorB_reg[37]), .param4_i(RotorB_reg[36]),
  .shift_i (RotorB_reg[40]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[46]), .shift_o(RotorB_reg[39]), .mux_o(RotorB_mux[39])
);

RotorB_cell U38(
  .param1_i(RotorB_reg[38]), .param2_i(RotorB_reg[39]),
  .param3_i(RotorB_reg[36]), .param4_i(RotorB_reg[37]),
  .shift_i (RotorB_reg[39]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[53]), .shift_o(RotorB_reg[38]), .mux_o(RotorB_mux[38])
);

RotorB_cell U37(
  .param1_i(RotorB_reg[37]), .param2_i(RotorB_reg[36]),
  .param3_i(RotorB_reg[39]), .param4_i(RotorB_reg[38]),
  .shift_i (RotorB_reg[38]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[3]), .shift_o(RotorB_reg[37]), .mux_o(RotorB_mux[37])
);

RotorB_cell U36(
  .param1_i(RotorB_reg[36]), .param2_i(RotorB_reg[37]),
  .param3_i(RotorB_reg[38]), .param4_i(RotorB_reg[39]),
  .shift_i (RotorB_reg[37]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[5]), .shift_o(RotorB_reg[36]), .mux_o(RotorB_mux[36])
);

// group top = 35
RotorB_cell U35(
  .param1_i(RotorB_reg[35]), .param2_i(RotorB_reg[34]),
  .param3_i(RotorB_reg[33]), .param4_i(RotorB_reg[32]),
  .shift_i (RotorB_reg[36]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[44]), .shift_o(RotorB_reg[35]), .mux_o(RotorB_mux[35])
);

RotorB_cell U34(
  .param1_i(RotorB_reg[34]), .param2_i(RotorB_reg[35]),
  .param3_i(RotorB_reg[32]), .param4_i(RotorB_reg[33]),
  .shift_i (RotorB_reg[35]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[9]), .shift_o(RotorB_reg[34]), .mux_o(RotorB_mux[34])
);

RotorB_cell U33(
  .param1_i(RotorB_reg[33]), .param2_i(RotorB_reg[32]),
  .param3_i(RotorB_reg[35]), .param4_i(RotorB_reg[34]),
  .shift_i (RotorB_reg[34]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[16]), .shift_o(RotorB_reg[33]), .mux_o(RotorB_mux[33])
);

RotorB_cell U32(
  .param1_i(RotorB_reg[32]), .param2_i(RotorB_reg[33]),
  .param3_i(RotorB_reg[34]), .param4_i(RotorB_reg[35]),
  .shift_i (RotorB_reg[33]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[49]), .shift_o(RotorB_reg[32]), .mux_o(RotorB_mux[32])
);

// group top = 31
RotorB_cell U31(
  .param1_i(RotorB_reg[31]), .param2_i(RotorB_reg[30]),
  .param3_i(RotorB_reg[29]), .param4_i(RotorB_reg[28]),
  .shift_i (RotorB_reg[32]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[55]), .shift_o(RotorB_reg[31]), .mux_o(RotorB_mux[31])
);

RotorB_cell U30(
  .param1_i(RotorB_reg[30]), .param2_i(RotorB_reg[31]),
  .param3_i(RotorB_reg[28]), .param4_i(RotorB_reg[29]),
  .shift_i (RotorB_reg[31]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[60]), .shift_o(RotorB_reg[30]), .mux_o(RotorB_mux[30])
);

RotorB_cell U29(
  .param1_i(RotorB_reg[29]), .param2_i(RotorB_reg[28]),
  .param3_i(RotorB_reg[31]), .param4_i(RotorB_reg[30]),
  .shift_i (RotorB_reg[30]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[34]), .shift_o(RotorB_reg[29]), .mux_o(RotorB_mux[29])
);

RotorB_cell U28(
  .param1_i(RotorB_reg[28]), .param2_i(RotorB_reg[29]),
  .param3_i(RotorB_reg[30]), .param4_i(RotorB_reg[31]),
  .shift_i (RotorB_reg[29]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[14]), .shift_o(RotorB_reg[28]), .mux_o(RotorB_mux[28])
);

// group top = 27
RotorB_cell U27(
  .param1_i(RotorB_reg[27]), .param2_i(RotorB_reg[26]),
  .param3_i(RotorB_reg[25]), .param4_i(RotorB_reg[24]),
  .shift_i (RotorB_reg[28]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[63]), .shift_o(RotorB_reg[27]), .mux_o(RotorB_mux[27])
);

RotorB_cell U26(
  .param1_i(RotorB_reg[26]), .param2_i(RotorB_reg[27]),
  .param3_i(RotorB_reg[24]), .param4_i(RotorB_reg[25]),
  .shift_i (RotorB_reg[27]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[32]), .shift_o(RotorB_reg[26]), .mux_o(RotorB_mux[26])
);

RotorB_cell U25(
  .param1_i(RotorB_reg[25]), .param2_i(RotorB_reg[24]),
  .param3_i(RotorB_reg[27]), .param4_i(RotorB_reg[26]),
  .shift_i (RotorB_reg[26]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[2]), .shift_o(RotorB_reg[25]), .mux_o(RotorB_mux[25])
);

RotorB_cell U24(
  .param1_i(RotorB_reg[24]), .param2_i(RotorB_reg[25]),
  .param3_i(RotorB_reg[26]), .param4_i(RotorB_reg[27]),
  .shift_i (RotorB_reg[25]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[54]), .shift_o(RotorB_reg[24]), .mux_o(RotorB_mux[24])
);

// group top = 23
RotorB_cell U23(
  .param1_i(RotorB_reg[23]), .param2_i(RotorB_reg[22]),
  .param3_i(RotorB_reg[21]), .param4_i(RotorB_reg[20]),
  .shift_i (RotorB_reg[24]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[40]), .shift_o(RotorB_reg[23]), .mux_o(RotorB_mux[23])
);

RotorB_cell U22(
  .param1_i(RotorB_reg[22]), .param2_i(RotorB_reg[23]),
  .param3_i(RotorB_reg[20]), .param4_i(RotorB_reg[21]),
  .shift_i (RotorB_reg[23]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[8]), .shift_o(RotorB_reg[22]), .mux_o(RotorB_mux[22])
);

RotorB_cell U21(
  .param1_i(RotorB_reg[21]), .param2_i(RotorB_reg[20]),
  .param3_i(RotorB_reg[23]), .param4_i(RotorB_reg[22]),
  .shift_i (RotorB_reg[22]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[47]), .shift_o(RotorB_reg[21]), .mux_o(RotorB_mux[21])
);

RotorB_cell U20(
  .param1_i(RotorB_reg[20]), .param2_i(RotorB_reg[21]),
  .param3_i(RotorB_reg[22]), .param4_i(RotorB_reg[23]),
  .shift_i (RotorB_reg[21]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[22]), .shift_o(RotorB_reg[20]), .mux_o(RotorB_mux[20])
);

// group top = 19
RotorB_cell U19(
  .param1_i(RotorB_reg[19]), .param2_i(RotorB_reg[18]),
  .param3_i(RotorB_reg[17]), .param4_i(RotorB_reg[16]),
  .shift_i (RotorB_reg[20]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[6]), .shift_o(RotorB_reg[19]), .mux_o(RotorB_mux[19])
);

RotorB_cell U18(
  .param1_i(RotorB_reg[18]), .param2_i(RotorB_reg[19]),
  .param3_i(RotorB_reg[16]), .param4_i(RotorB_reg[17]),
  .shift_i (RotorB_reg[19]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[57]), .shift_o(RotorB_reg[18]), .mux_o(RotorB_mux[18])
);

RotorB_cell U17(
  .param1_i(RotorB_reg[17]), .param2_i(RotorB_reg[16]),
  .param3_i(RotorB_reg[19]), .param4_i(RotorB_reg[18]),
  .shift_i (RotorB_reg[18]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[13]), .shift_o(RotorB_reg[17]), .mux_o(RotorB_mux[17])
);

RotorB_cell U16(
  .param1_i(RotorB_reg[16]), .param2_i(RotorB_reg[17]),
  .param3_i(RotorB_reg[18]), .param4_i(RotorB_reg[19]),
  .shift_i (RotorB_reg[17]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[26]), .shift_o(RotorB_reg[16]), .mux_o(RotorB_mux[16])
);

// group top = 15
RotorB_cell U15(
  .param1_i(RotorB_reg[15]), .param2_i(RotorB_reg[14]),
  .param3_i(RotorB_reg[13]), .param4_i(RotorB_reg[12]),
  .shift_i (RotorB_reg[16]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[38]), .shift_o(RotorB_reg[15]), .mux_o(RotorB_mux[15])
);

RotorB_cell U14(
  .param1_i(RotorB_reg[14]), .param2_i(RotorB_reg[15]),
  .param3_i(RotorB_reg[12]), .param4_i(RotorB_reg[13]),
  .shift_i (RotorB_reg[15]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[18]), .shift_o(RotorB_reg[14]), .mux_o(RotorB_mux[14])
);

RotorB_cell U13(
  .param1_i(RotorB_reg[13]), .param2_i(RotorB_reg[12]),
  .param3_i(RotorB_reg[15]), .param4_i(RotorB_reg[14]),
  .shift_i (RotorB_reg[14]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[29]), .shift_o(RotorB_reg[13]), .mux_o(RotorB_mux[13])
);

RotorB_cell U12(
  .param1_i(RotorB_reg[12]), .param2_i(RotorB_reg[13]),
  .param3_i(RotorB_reg[14]), .param4_i(RotorB_reg[15]),
  .shift_i (RotorB_reg[13]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[21]), .shift_o(RotorB_reg[12]), .mux_o(RotorB_mux[12])
);

// group top = 11
RotorB_cell U11(
  .param1_i(RotorB_reg[11]), .param2_i(RotorB_reg[10]),
  .param3_i(RotorB_reg[9 ]), .param4_i(RotorB_reg[8 ]),
  .shift_i (RotorB_reg[12]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[24]), .shift_o(RotorB_reg[11]), .mux_o(RotorB_mux[11])
);

RotorB_cell U10(
  .param1_i(RotorB_reg[10]), .param2_i(RotorB_reg[11]),
  .param3_i(RotorB_reg[8 ]), .param4_i(RotorB_reg[9 ]),
  .shift_i (RotorB_reg[11]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[58]), .shift_o(RotorB_reg[10]), .mux_o(RotorB_mux[10])
);

RotorB_cell U9(
  .param1_i(RotorB_reg[9 ]), .param2_i(RotorB_reg[8 ]),
  .param3_i(RotorB_reg[11]), .param4_i(RotorB_reg[10]),
  .shift_i (RotorB_reg[10]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[28]), .shift_o(RotorB_reg[9]), .mux_o(RotorB_mux[9])
);

RotorB_cell U8(
  .param1_i(RotorB_reg[8 ]), .param2_i(RotorB_reg[9 ]),
  .param3_i(RotorB_reg[10]), .param4_i(RotorB_reg[11]),
  .shift_i (RotorB_reg[9]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[10]), .shift_o(RotorB_reg[8]), .mux_o(RotorB_mux[8])
);

// group top = 7
RotorB_cell U7(
  .param1_i(RotorB_reg[7 ]), .param2_i(RotorB_reg[6 ]),
  .param3_i(RotorB_reg[5 ]), .param4_i(RotorB_reg[4 ]),
  .shift_i (RotorB_reg[8]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[43]), .shift_o(RotorB_reg[7]), .mux_o(RotorB_mux[7])
);

RotorB_cell U6(
  .param1_i(RotorB_reg[6 ]), .param2_i(RotorB_reg[7 ]),
  .param3_i(RotorB_reg[4 ]), .param4_i(RotorB_reg[5 ]),
  .shift_i (RotorB_reg[7]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[23]), .shift_o(RotorB_reg[6]), .mux_o(RotorB_mux[6])
);

RotorB_cell U5(
  .param1_i(RotorB_reg[5 ]), .param2_i(RotorB_reg[4 ]),
  .param3_i(RotorB_reg[7 ]), .param4_i(RotorB_reg[6 ]),
  .shift_i (RotorB_reg[6]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[48]), .shift_o(RotorB_reg[5]), .mux_o(RotorB_mux[5])
);

RotorB_cell U4(
  .param1_i(RotorB_reg[4 ]), .param2_i(RotorB_reg[5 ]),
  .param3_i(RotorB_reg[6 ]), .param4_i(RotorB_reg[7 ]),
  .shift_i (RotorB_reg[5]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[42]), .shift_o(RotorB_reg[4]), .mux_o(RotorB_mux[4])
);

// group top = 3
RotorB_cell U3(
  .param1_i(RotorB_reg[3 ]), .param2_i(RotorB_reg[2 ]),
  .param3_i(RotorB_reg[1 ]), .param4_i(RotorB_reg[0 ]),
  .shift_i (RotorB_reg[4]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[17]), .shift_o(RotorB_reg[3]), .mux_o(RotorB_mux[3])
);

RotorB_cell U2(
  .param1_i(RotorB_reg[2 ]), .param2_i(RotorB_reg[3 ]),
  .param3_i(RotorB_reg[0 ]), .param4_i(RotorB_reg[1 ]),
  .shift_i (RotorB_reg[3]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[25]), .shift_o(RotorB_reg[2]), .mux_o(RotorB_mux[2])
);

RotorB_cell U1(
  .param1_i(RotorB_reg[1 ]), .param2_i(RotorB_reg[0 ]),
  .param3_i(RotorB_reg[3 ]), .param4_i(RotorB_reg[2 ]),
  .shift_i (RotorB_reg[2]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[61]), .shift_o(RotorB_reg[1]), .mux_o(RotorB_mux[1])
);

RotorB_cell U0(
  .param1_i(RotorB_reg[0 ]), .param2_i(RotorB_reg[1 ]),
  .param3_i(RotorB_reg[2 ]), .param4_i(RotorB_reg[3 ]),
  .shift_i (RotorB_reg[1]),
  .load_i  (load_reg), .encrypt_i(plug_forward_valid), .clk(clk),
  .shift_value_i(shift_value_b), .table_idx(table_idx_reg),
  .mux_i(RotorB_mux[56]), .shift_o(RotorB_reg[0]), .mux_o(RotorB_mux[0])
);



// this mux may use other optimize method for synthesis.
assign RotorB_forward_o = RotorB_reg[bitswitch_forward_o];

assign shift_value_b = (crypt_mode_reg == 1'b0)? RotorB_forward_o[1:0] : RotorB_inverse_i[1:0];

// --- inverpath ---
// bitwise and to detect equality between xor_o and each link[j]
// generate a one-hot code
genvar t;
generate
	for (t = 0; t < pRotorA_LEN; t = t + 1) begin : GEN_BMATCH
	  assign bitwise_and_b[t] = ~|(RotorB_inverse_i ^ RotorB_reg[t]);
	end
endgenerate

onehot2binary_64 encoder64_B(
	.onehot_i(bitwise_and_b),
	.binary_o(bitswitch_inverse_i)
);

// ----- Rotor B -----//

// ----- XOR ----- //
always @(posedge clk) begin
	if (!srst_n_reg) begin
	  lfsr_reg <=  6'b00_0001;
	end else if (plug_forward_valid) begin
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
assign xor_o = lfsr_reg ^ RotorB_forward_o;
assign RotorB_inverse_i = xor_o;
// ----- XOR ----- //

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
	if (table_idx == 2'b00 || encrypt_i == 1) begin
	  shift_o <= reg_i;
	end else begin
	  shift_o <= shift_o;
	end
	
end

endmodule

// ----- Rotor B submodule -----//
module RotorB_cell # (
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
	input [(pData_LEN-1):0] mux_i,
	output reg [(pData_LEN-1):0] shift_o,
	output reg [(pData_LEN-1):0] mux_o
);

always @(*) begin
	case (shift_value_i) // synopsys parallel_case
	2'b00: mux_o = param1_i;
	2'b01: mux_o = param2_i;
	2'b10: mux_o = param3_i;
	2'b11: mux_o = param4_i;
	endcase
end

reg [(pData_LEN-1):0] reg_i;
always @(*) begin
	case ({load_i, encrypt_i}) // synopsys parallel_case
	2'b01: reg_i = mux_i;
	2'b10: reg_i = shift_i;
	default: reg_i = shift_o;
	endcase
end

always @(posedge clk) begin
	if (table_idx == 2'b10 || encrypt_i == 1) begin
	  shift_o <= reg_i;
	end else begin
	  shift_o <= shift_o;
	end
	
end

endmodule

// ----- one-hot to binary encoder ----- //
module onehot2binary_64 #(
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

// ----- one-hot to binary encoder ----- //
module onehot2binary_32 (
  input  [31:0] onehot_i,
  output [4:0]  binary_o,
  output        valid_o
);

assign valid_o   = |onehot_i;

// MSB
assign binary_o[4] = |onehot_i[31:16];

assign binary_o[3] = |{ onehot_i[31:24], onehot_i[15:8] };

assign binary_o[2] = |{ onehot_i[31:28], onehot_i[23:20],
                        onehot_i[15:12], onehot_i[7:4] };

assign binary_o[1] = |{ onehot_i[31:30], onehot_i[27:26],
                        onehot_i[23:22], onehot_i[19:18],
                        onehot_i[15:14], onehot_i[11:10],
                        onehot_i[7:6],   onehot_i[3:2] };

assign binary_o[0] = |{ onehot_i[31], onehot_i[29], onehot_i[27], onehot_i[25],
                        onehot_i[23], onehot_i[21], onehot_i[19], onehot_i[17],
                        onehot_i[15], onehot_i[13], onehot_i[11], onehot_i[9],
                        onehot_i[7],  onehot_i[5],  onehot_i[3],  onehot_i[1] };

endmodule

