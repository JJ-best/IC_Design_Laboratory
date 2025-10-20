//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2025 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================
// Arthor: Jesse
// Version10: write plugboard mux as case, flatten rotorA, rotorB, write mux by case
// Area = 17683 Timing = 3.3

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
reg [(pData_LEN-1):0]plug_forward_o;
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

reg [(pData_LEN-1):0] plug_rd_i; // plugboard_reg[plug_pair_i]
reg [(pData_LEN-1):0] plug_rd_o; // plugboard_reg[plug_pair_o]

// ----- Rotor A declare -----//
reg [(pData_LEN-1):0] link [0:(pRotorA_LEN-1)];
wire [1:0] shift_value_t;
reg [(pData_LEN-1):0] RotorA_forward_o;
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

// onehot2binary_32 encoder32_i(
// 	.onehot_i(plug_xor_i),
// 	.binary_o(plug_mux_sel_i),
// 	.valid_o(plug_forward_valid_i)
// );
// === inline encoder32_i ===
assign plug_forward_valid_i = |plug_xor_i;

assign plug_mux_sel_i[4] = |plug_xor_i[31:16];
assign plug_mux_sel_i[3] = |{ plug_xor_i[31:24], plug_xor_i[15:8] };
assign plug_mux_sel_i[2] = |{ plug_xor_i[31:28], plug_xor_i[23:20],
                              plug_xor_i[15:12], plug_xor_i[7:4] };
assign plug_mux_sel_i[1] = |{ plug_xor_i[31:30], plug_xor_i[27:26],
                              plug_xor_i[23:22], plug_xor_i[19:18],
                              plug_xor_i[15:14], plug_xor_i[11:10],
                              plug_xor_i[7:6],   plug_xor_i[3:2] };
assign plug_mux_sel_i[0] = |{ plug_xor_i[31], plug_xor_i[29], plug_xor_i[27], plug_xor_i[25],
                              plug_xor_i[23], plug_xor_i[21], plug_xor_i[19], plug_xor_i[17],
                              plug_xor_i[15], plug_xor_i[13], plug_xor_i[11], plug_xor_i[9],
                              plug_xor_i[7],  plug_xor_i[5],  plug_xor_i[3],  plug_xor_i[1] };

assign plug_pair_i = plug_mux_sel_i ^ 5'b00001;
// --- plugboard read by index (input side) with case ---
always @(*) begin : PLUGBOARD_READ_I
  case (plug_pair_i) // synopsys full_case parallel_case
    5'd0 :  plug_rd_i = plugboard_reg[0 ];
    5'd1 :  plug_rd_i = plugboard_reg[1 ];
    5'd2 :  plug_rd_i = plugboard_reg[2 ];
    5'd3 :  plug_rd_i = plugboard_reg[3 ];
    5'd4 :  plug_rd_i = plugboard_reg[4 ];
    5'd5 :  plug_rd_i = plugboard_reg[5 ];
    5'd6 :  plug_rd_i = plugboard_reg[6 ];
    5'd7 :  plug_rd_i = plugboard_reg[7 ];
    5'd8 :  plug_rd_i = plugboard_reg[8 ];
    5'd9 :  plug_rd_i = plugboard_reg[9 ];
    5'd10:  plug_rd_i = plugboard_reg[10];
    5'd11:  plug_rd_i = plugboard_reg[11];
    5'd12:  plug_rd_i = plugboard_reg[12];
    5'd13:  plug_rd_i = plugboard_reg[13];
    5'd14:  plug_rd_i = plugboard_reg[14];
    5'd15:  plug_rd_i = plugboard_reg[15];
    5'd16:  plug_rd_i = plugboard_reg[16];
    5'd17:  plug_rd_i = plugboard_reg[17];
    5'd18:  plug_rd_i = plugboard_reg[18];
    5'd19:  plug_rd_i = plugboard_reg[19];
    5'd20:  plug_rd_i = plugboard_reg[20];
    5'd21:  plug_rd_i = plugboard_reg[21];
    5'd22:  plug_rd_i = plugboard_reg[22];
    5'd23:  plug_rd_i = plugboard_reg[23];
    5'd24:  plug_rd_i = plugboard_reg[24];
    5'd25:  plug_rd_i = plugboard_reg[25];
    5'd26:  plug_rd_i = plugboard_reg[26];
    5'd27:  plug_rd_i = plugboard_reg[27];
    5'd28:  plug_rd_i = plugboard_reg[28];
    5'd29:  plug_rd_i = plugboard_reg[29];
    5'd30:  plug_rd_i = plugboard_reg[30];
    5'd31:  plug_rd_i = plugboard_reg[31];
  endcase
end

always @(*) begin : PLUG_FWD_MUX
  case (plug_forward_valid_i) // synopsys full_case parallel_case
    1'b1: plug_forward_o = plug_rd_i;
    1'b0: plug_forward_o = code_in_reg;
  endcase
end

// assign plug_forward_o = (plug_forward_valid_i)? plugboard_reg[plug_pair_i] : code_in_reg;
// plug forward out pipeline

always @(posedge clk) begin
  plug_forward_o_reg <= plug_forward_o;
  plug_forward_valid <= encrypt_reg;
end

// inverse path
genvar l;
generate
	for (l = 31; l >= 0; l = l - 1) begin : GEN_PLUG_OUT
	  assign  plug_xor_o[l] = ~|(plug_inverse_i_reg ^ plugboard_reg[l]);
	end
endgenerate

// onehot2binary_32 encoder32_o(
// 	.onehot_i(plug_xor_o),
// 	.binary_o(plug_mux_sel_o),
// 	.valid_o(plug_forward_valid_o)
// );

// === inline encoder32_o ===
assign plug_forward_valid_o = |plug_xor_o;

assign plug_mux_sel_o[4] = |plug_xor_o[31:16];
assign plug_mux_sel_o[3] = |{ plug_xor_o[31:24], plug_xor_o[15:8] };
assign plug_mux_sel_o[2] = |{ plug_xor_o[31:28], plug_xor_o[23:20],
                              plug_xor_o[15:12], plug_xor_o[7:4] };
assign plug_mux_sel_o[1] = |{ plug_xor_o[31:30], plug_xor_o[27:26],
                              plug_xor_o[23:22], plug_xor_o[19:18],
                              plug_xor_o[15:14], plug_xor_o[11:10],
                              plug_xor_o[7:6],   plug_xor_o[3:2] };
assign plug_mux_sel_o[0] = |{ plug_xor_o[31], plug_xor_o[29], plug_xor_o[27], plug_xor_o[25],
                              plug_xor_o[23], plug_xor_o[21], plug_xor_o[19], plug_xor_o[17],
                              plug_xor_o[15], plug_xor_o[13], plug_xor_o[11], plug_xor_o[9],
                              plug_xor_o[7],  plug_xor_o[5],  plug_xor_o[3],  plug_xor_o[1] };


assign plug_pair_o = plug_mux_sel_o ^ 5'b00001; // this may be optimize by other method



// plug inverse in pipeline
// --- plugboard read by index (output side) with case ---
always @(*) begin : PLUGBOARD_READ_O
  case (plug_pair_o) // synopsys full_case parallel_case
    5'd0 :  plug_rd_o = plugboard_reg[0 ];
    5'd1 :  plug_rd_o = plugboard_reg[1 ];
    5'd2 :  plug_rd_o = plugboard_reg[2 ];
    5'd3 :  plug_rd_o = plugboard_reg[3 ];
    5'd4 :  plug_rd_o = plugboard_reg[4 ];
    5'd5 :  plug_rd_o = plugboard_reg[5 ];
    5'd6 :  plug_rd_o = plugboard_reg[6 ];
    5'd7 :  plug_rd_o = plugboard_reg[7 ];
    5'd8 :  plug_rd_o = plugboard_reg[8 ];
    5'd9 :  plug_rd_o = plugboard_reg[9 ];
    5'd10:  plug_rd_o = plugboard_reg[10];
    5'd11:  plug_rd_o = plugboard_reg[11];
    5'd12:  plug_rd_o = plugboard_reg[12];
    5'd13:  plug_rd_o = plugboard_reg[13];
    5'd14:  plug_rd_o = plugboard_reg[14];
    5'd15:  plug_rd_o = plugboard_reg[15];
    5'd16:  plug_rd_o = plugboard_reg[16];
    5'd17:  plug_rd_o = plugboard_reg[17];
    5'd18:  plug_rd_o = plugboard_reg[18];
    5'd19:  plug_rd_o = plugboard_reg[19];
    5'd20:  plug_rd_o = plugboard_reg[20];
    5'd21:  plug_rd_o = plugboard_reg[21];
    5'd22:  plug_rd_o = plugboard_reg[22];
    5'd23:  plug_rd_o = plugboard_reg[23];
    5'd24:  plug_rd_o = plugboard_reg[24];
    5'd25:  plug_rd_o = plugboard_reg[25];
    5'd26:  plug_rd_o = plugboard_reg[26];
    5'd27:  plug_rd_o = plugboard_reg[27];
    5'd28:  plug_rd_o = plugboard_reg[28];
    5'd29:  plug_rd_o = plugboard_reg[29];
    5'd30:  plug_rd_o = plugboard_reg[30];
    5'd31:  plug_rd_o = plugboard_reg[31];
  endcase
end
// output buffer
always @(posedge clk) begin
  case (plug_forward_valid_o) // synopsys full_case parallel_case
    1'b1: code_out <= plug_rd_o;
    1'b0: code_out <= plug_inverse_i_reg;
  endcase
  code_valid <= plug_inverse_valid;
end


// always @(posedge clk) begin
//   code_out <= (plug_forward_valid_o)? plugboard_reg[plug_pair_o] : plug_inverse_i_reg;
//   code_valid <= plug_inverse_valid;
// end
// ----- plugboard ----- //


// ----- Rotor A ----- //
// per-stage signals declared OUTSIDE generate
wire [(pData_LEN-1):0] param1   [0:(pRotorA_LEN-1)];
wire [(pData_LEN-1):0] param2   [0:(pRotorA_LEN-1)];
wire [(pData_LEN-1):0] param3   [0:(pRotorA_LEN-1)];
wire [(pData_LEN-1):0] param4   [0:(pRotorA_LEN-1)];
wire [(pData_LEN-1):0] shift_i  [0:(pRotorA_LEN-1)];
reg [(pData_LEN-1):0] shift_mux[0:(pRotorA_LEN-1)];
reg [(pData_LEN-1):0] reg_i    [0:(pRotorA_LEN-1)];

genvar k;
generate
  for (k = 63; k >= 0; k = k - 1) begin : G_ROTORA_FLAT

    assign param1[k] = link[(k+0) % pRotorA_LEN];
    assign param2[k] = link[(k+1) % pRotorA_LEN];
    assign param3[k] = link[(k+2) % pRotorA_LEN];
    assign param4[k] = link[(k+3) % pRotorA_LEN];

    if (k == 63) begin : G_FIRST
      assign shift_i[k] = code_in_reg;
    end else begin : G_OTHER
      assign shift_i[k] = link[k+1];
    end

	always @(*) begin
		case (shift_value_t) // synopsys parallel_case
		2'b00: begin
		  shift_mux[k] = param1[k];
		end
		2'b01: begin
		  shift_mux[k] = param2[k];
		end
		2'b10: begin
		  shift_mux[k] = param3[k];
		end
		2'b11: begin
		  shift_mux[k] = param4[k];
		end
		endcase
	end

	always @(*) begin
		case ({load_reg, plug_forward_valid}) // synopsys parallel_case
		2'b01: begin
		  reg_i[k] = shift_mux[k];
		end
		2'b10: begin
		  reg_i[k] = shift_i[k];
		end
		default: begin
		  reg_i[k] = link[k];
		end	
		endcase
	end

    always @(posedge clk) begin
      if (table_idx_reg == 2'b00 || plug_forward_valid) begin
        link[k] <= reg_i[k];
      end
    end
  end
endgenerate

// this mux may use other optimize method for synthesis.
always @(*) begin : RotorA_MUX
    case (plug_forward_o_reg) // synopsys parallel_case full_case
        6'd0 : RotorA_forward_o = link[0];
        6'd1 : RotorA_forward_o = link[1];
        6'd2 : RotorA_forward_o = link[2];
        6'd3 : RotorA_forward_o = link[3];
        6'd4 : RotorA_forward_o = link[4];
        6'd5 : RotorA_forward_o = link[5];
        6'd6 : RotorA_forward_o = link[6];
        6'd7 : RotorA_forward_o = link[7];
        6'd8 : RotorA_forward_o = link[8];
        6'd9 : RotorA_forward_o = link[9];
        6'd10: RotorA_forward_o = link[10];
        6'd11: RotorA_forward_o = link[11];
        6'd12: RotorA_forward_o = link[12];
        6'd13: RotorA_forward_o = link[13];
        6'd14: RotorA_forward_o = link[14];
        6'd15: RotorA_forward_o = link[15];
        6'd16: RotorA_forward_o = link[16];
        6'd17: RotorA_forward_o = link[17];
        6'd18: RotorA_forward_o = link[18];
        6'd19: RotorA_forward_o = link[19];
        6'd20: RotorA_forward_o = link[20];
        6'd21: RotorA_forward_o = link[21];
        6'd22: RotorA_forward_o = link[22];
        6'd23: RotorA_forward_o = link[23];
        6'd24: RotorA_forward_o = link[24];
        6'd25: RotorA_forward_o = link[25];
        6'd26: RotorA_forward_o = link[26];
        6'd27: RotorA_forward_o = link[27];
        6'd28: RotorA_forward_o = link[28];
        6'd29: RotorA_forward_o = link[29];
        6'd30: RotorA_forward_o = link[30];
        6'd31: RotorA_forward_o = link[31];
        6'd32: RotorA_forward_o = link[32];
        6'd33: RotorA_forward_o = link[33];
        6'd34: RotorA_forward_o = link[34];
        6'd35: RotorA_forward_o = link[35];
        6'd36: RotorA_forward_o = link[36];
        6'd37: RotorA_forward_o = link[37];
        6'd38: RotorA_forward_o = link[38];
        6'd39: RotorA_forward_o = link[39];
        6'd40: RotorA_forward_o = link[40];
        6'd41: RotorA_forward_o = link[41];
        6'd42: RotorA_forward_o = link[42];
        6'd43: RotorA_forward_o = link[43];
        6'd44: RotorA_forward_o = link[44];
        6'd45: RotorA_forward_o = link[45];
        6'd46: RotorA_forward_o = link[46];
        6'd47: RotorA_forward_o = link[47];
        6'd48: RotorA_forward_o = link[48];
        6'd49: RotorA_forward_o = link[49];
        6'd50: RotorA_forward_o = link[50];
        6'd51: RotorA_forward_o = link[51];
        6'd52: RotorA_forward_o = link[52];
        6'd53: RotorA_forward_o = link[53];
        6'd54: RotorA_forward_o = link[54];
        6'd55: RotorA_forward_o = link[55];
        6'd56: RotorA_forward_o = link[56];
        6'd57: RotorA_forward_o = link[57];
        6'd58: RotorA_forward_o = link[58];
        6'd59: RotorA_forward_o = link[59];
        6'd60: RotorA_forward_o = link[60];
        6'd61: RotorA_forward_o = link[61];
        6'd62: RotorA_forward_o = link[62];
        6'd63: RotorA_forward_o = link[63];
    endcase
end

// assign RotorA_forward_o = link[plug_forward_o_reg];

assign shift_value_t = (crypt_mode_reg == 1'b0)? RotorA_forward_o[1:0] : RotorA_inverse_i[1:0];

// --- inverpath ---
// bitwise and to detect equality between xor_o and each link[j]
// generate a one-hot code

//reg [(pData_LEN-1):0]RotorA_inverse_i_reg;
reg RotorA_inverse_i_valid;
always @(posedge clk) begin
  //RotorA_inverse_i_reg <= RotorA_inverse_i;
  RotorA_inverse_i_valid <= plug_forward_valid;
end

// reg [(pData_LEN-1):0]RotorA_reg[0:(pRotorA_LEN-1)];
// integer f;
// always @(posedge clk) begin
//   for (f=0; f<pRotorA_LEN; f=f+1) begin
//     RotorA_reg[f] <= link[f];
//   end
// end

reg [(pRotorA_LEN-1):0]RotorA_reg;
integer f;
always @(posedge clk) begin
  for (f=0; f<pRotorA_LEN; f=f+1) begin
    RotorA_reg[f] <= bitwise_and_o[f];
  end
end

genvar j;
generate
	for (j = 0; j < pRotorA_LEN; j = j + 1) begin : GEN_MATCH
	  assign bitwise_and_o[j] = ~|(RotorA_inverse_i ^ link[j]);
	end
endgenerate

onehot2binary_64 encoder64_A(
	.onehot_i(RotorA_reg),
	.binary_o(plug_inverse_i)
);
always @(posedge clk) begin
  plug_inverse_i_reg <= plug_inverse_i;
  plug_inverse_valid <= RotorA_inverse_i_valid;
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
	case (mode_bitswitch) // synopsys parallel_case 
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
reg  [(pData_LEN-1):0] RotorB_reg [0:(pRotorA_LEN-1)];
wire [1:0] shift_value_b;
wire [(pRotorA_LEN-1):0] bitwise_and_b;
reg [(pData_LEN-1):0] RotorB_mux [0:(pRotorA_LEN-1)];
// ---- RotorB flatten: per-stage signals (declare OUTSIDE generate) ----
wire [(pData_LEN-1):0] RB_param1   [0:(pRotorA_LEN-1)];
wire [(pData_LEN-1):0] RB_param2   [0:(pRotorA_LEN-1)];
wire [(pData_LEN-1):0] RB_param3   [0:(pRotorA_LEN-1)];
wire [(pData_LEN-1):0] RB_param4   [0:(pRotorA_LEN-1)];
wire [(pData_LEN-1):0] RB_shift_i  [0:(pRotorA_LEN-1)];
reg [(pData_LEN-1):0] RB_reg_i    [0:(pRotorA_LEN-1)];
// RotorB_mux 已存在於原始碼中：wire [(pData_LEN-1):0] RotorB_mux [0:(pRotorA_LEN-1)];
wire [(pData_LEN-1):0] RB_mux_i    [0:(pRotorA_LEN-1)];  // 每段的 mux_i（由你原本 Uxx 的連線表指定）
// ---- RotorB mux_i wiring table (exactly the same as your instances) ----
assign RB_mux_i[63] = RotorB_mux[33];
assign RB_mux_i[62] = RotorB_mux[0 ];
assign RB_mux_i[61] = RotorB_mux[20];
assign RB_mux_i[60] = RotorB_mux[41];

assign RB_mux_i[59] = RotorB_mux[27];
assign RB_mux_i[58] = RotorB_mux[31];
assign RB_mux_i[57] = RotorB_mux[45];
assign RB_mux_i[56] = RotorB_mux[12];

assign RB_mux_i[55] = RotorB_mux[7 ];
assign RB_mux_i[54] = RotorB_mux[37];
assign RB_mux_i[53] = RotorB_mux[1 ];
assign RB_mux_i[52] = RotorB_mux[62];

assign RB_mux_i[51] = RotorB_mux[52];
assign RB_mux_i[50] = RotorB_mux[35];
assign RB_mux_i[49] = RotorB_mux[19];
assign RB_mux_i[48] = RotorB_mux[50];

assign RB_mux_i[47] = RotorB_mux[59];
assign RB_mux_i[46] = RotorB_mux[36];
assign RB_mux_i[45] = RotorB_mux[4 ];
assign RB_mux_i[44] = RotorB_mux[15];

assign RB_mux_i[43] = RotorB_mux[11];
assign RB_mux_i[42] = RotorB_mux[30];
assign RB_mux_i[41] = RotorB_mux[39];
assign RB_mux_i[40] = RotorB_mux[51];

assign RB_mux_i[39] = RotorB_mux[46];
assign RB_mux_i[38] = RotorB_mux[53];
assign RB_mux_i[37] = RotorB_mux[3 ];
assign RB_mux_i[36] = RotorB_mux[5 ];

assign RB_mux_i[35] = RotorB_mux[44];
assign RB_mux_i[34] = RotorB_mux[9 ];
assign RB_mux_i[33] = RotorB_mux[16];
assign RB_mux_i[32] = RotorB_mux[49];

assign RB_mux_i[31] = RotorB_mux[55];
assign RB_mux_i[30] = RotorB_mux[60];
assign RB_mux_i[29] = RotorB_mux[34];
assign RB_mux_i[28] = RotorB_mux[14];

assign RB_mux_i[27] = RotorB_mux[63];
assign RB_mux_i[26] = RotorB_mux[32];
assign RB_mux_i[25] = RotorB_mux[2 ];
assign RB_mux_i[24] = RotorB_mux[54];

assign RB_mux_i[23] = RotorB_mux[40];
assign RB_mux_i[22] = RotorB_mux[8 ];
assign RB_mux_i[21] = RotorB_mux[47];
assign RB_mux_i[20] = RotorB_mux[22];

assign RB_mux_i[19] = RotorB_mux[6 ];
assign RB_mux_i[18] = RotorB_mux[57];
assign RB_mux_i[17] = RotorB_mux[13];
assign RB_mux_i[16] = RotorB_mux[26];

assign RB_mux_i[15] = RotorB_mux[38];
assign RB_mux_i[14] = RotorB_mux[18];
assign RB_mux_i[13] = RotorB_mux[29];
assign RB_mux_i[12] = RotorB_mux[21];

assign RB_mux_i[11] = RotorB_mux[24];
assign RB_mux_i[10] = RotorB_mux[58];
assign RB_mux_i[9 ] = RotorB_mux[28];
assign RB_mux_i[8 ] = RotorB_mux[10];

assign RB_mux_i[7 ] = RotorB_mux[43];
assign RB_mux_i[6 ] = RotorB_mux[23];
assign RB_mux_i[5 ] = RotorB_mux[48];
assign RB_mux_i[4 ] = RotorB_mux[42];

assign RB_mux_i[3 ] = RotorB_mux[17];
assign RB_mux_i[2 ] = RotorB_mux[25];
assign RB_mux_i[1 ] = RotorB_mux[61];
assign RB_mux_i[0 ] = RotorB_mux[56];
// ----- Rotor B (FLATTENED) -----//
// 參數多工器：等價於 RotorB_cell 的 comb mux_o
// 觀察到你的 Uxx 皆為 param1..4 = {k, k^1, k^2, k^3} 對應的 RotorB_reg
genvar bk;
generate
  for (bk = 63; bk >= 0; bk = bk - 1) begin : G_ROTORB_FLAT
    // ---- param1..4：依照你 Uxx 的群組規則（每 4 筆一組，top=4n+3）----
    if ((bk % 4) == 3) begin : GP3
      assign RB_param1[bk] = RotorB_reg[bk    ];
      assign RB_param2[bk] = RotorB_reg[bk-1  ];
      assign RB_param3[bk] = RotorB_reg[bk-2  ];
      assign RB_param4[bk] = RotorB_reg[bk-3  ];
    end else if ((bk % 4) == 2) begin : GP2
      assign RB_param1[bk] = RotorB_reg[bk    ];
      assign RB_param2[bk] = RotorB_reg[bk+1  ];
      assign RB_param3[bk] = RotorB_reg[bk-2  ];
      assign RB_param4[bk] = RotorB_reg[bk-1  ];
    end else if ((bk % 4) == 1) begin : GP1
      assign RB_param1[bk] = RotorB_reg[bk    ];
      assign RB_param2[bk] = RotorB_reg[bk-1  ];
      assign RB_param3[bk] = RotorB_reg[bk+2  ];
      assign RB_param4[bk] = RotorB_reg[bk+1  ];
    end else begin : GP0 // (bk % 4) == 0
      assign RB_param1[bk] = RotorB_reg[bk    ];
      assign RB_param2[bk] = RotorB_reg[bk+1  ];
      assign RB_param3[bk] = RotorB_reg[bk+2  ];
      assign RB_param4[bk] = RotorB_reg[bk+3  ];
    end

    // ---- mux_o：用 parallel_case，對應你 submodule 裡的 always@(*) case ----
    always @(*) begin
      case (shift_value_b) // synopsys parallel_case
        2'b00: RotorB_mux[bk] = RB_param1[bk];
        2'b01: RotorB_mux[bk] = RB_param2[bk];
        2'b10: RotorB_mux[bk] = RB_param3[bk];
        2'b11: RotorB_mux[bk] = RB_param4[bk];
      endcase
    end

    // ---- shift_i：第 63 段吃 code_in_reg，其餘吃下一段（與你原本一致、不越界）----
    if (bk == 63) begin : G_FIRST
      assign RB_shift_i[bk] = code_in_reg;
    end else begin : G_OTHER
      assign RB_shift_i[bk] = RotorB_reg[bk+1];
    end

    // ---- reg_i：用 parallel_case 寫成你 submodule 的 {load,encrypt} 邏輯 ----
    always @(*) begin
      case ({load_reg, plug_forward_valid}) // synopsys parallel_case
        2'b01: RB_reg_i[bk] = RB_mux_i[bk];
        2'b10: RB_reg_i[bk] = RB_shift_i[bk];
        default: RB_reg_i[bk] = RotorB_reg[bk];
      endcase
    end

    // ---- 時序寫入：與你原本完全相同 ----
    always @(posedge clk) begin
      if (table_idx_reg == 2'b10 || plug_forward_valid == 1'b1) begin
        RotorB_reg[bk] <= RB_reg_i[bk];
      end
    end
  end
endgenerate
// ----- Rotor B (FLATTENED) -----//




// this mux may use other optimize method for synthesis.
assign RotorB_forward_o = RotorB_reg[bitswitch_forward_o];


// always @(*) begin : RotorB_MUX
//     case (bitswitch_forward_o) // synopsys parallel_case full_case
//         6'd0 : RotorB_forward_o = RotorB_reg[0];
//         6'd1 : RotorB_forward_o = RotorB_reg[1];
//         6'd2 : RotorB_forward_o = RotorB_reg[2];
//         6'd3 : RotorB_forward_o = RotorB_reg[3];
//         6'd4 : RotorB_forward_o = RotorB_reg[4];
//         6'd5 : RotorB_forward_o = RotorB_reg[5];
//         6'd6 : RotorB_forward_o = RotorB_reg[6];
//         6'd7 : RotorB_forward_o = RotorB_reg[7];
//         6'd8 : RotorB_forward_o = RotorB_reg[8];
//         6'd9 : RotorB_forward_o = RotorB_reg[9];
//         6'd10: RotorB_forward_o = RotorB_reg[10];
//         6'd11: RotorB_forward_o = RotorB_reg[11];
//         6'd12: RotorB_forward_o = RotorB_reg[12];
//         6'd13: RotorB_forward_o = RotorB_reg[13];
//         6'd14: RotorB_forward_o = RotorB_reg[14];
//         6'd15: RotorB_forward_o = RotorB_reg[15];
//         6'd16: RotorB_forward_o = RotorB_reg[16];
//         6'd17: RotorB_forward_o = RotorB_reg[17];
//         6'd18: RotorB_forward_o = RotorB_reg[18];
//         6'd19: RotorB_forward_o = RotorB_reg[19];
//         6'd20: RotorB_forward_o = RotorB_reg[20];
//         6'd21: RotorB_forward_o = RotorB_reg[21];
//         6'd22: RotorB_forward_o = RotorB_reg[22];
//         6'd23: RotorB_forward_o = RotorB_reg[23];
//         6'd24: RotorB_forward_o = RotorB_reg[24];
//         6'd25: RotorB_forward_o = RotorB_reg[25];
//         6'd26: RotorB_forward_o = RotorB_reg[26];
//         6'd27: RotorB_forward_o = RotorB_reg[27];
//         6'd28: RotorB_forward_o = RotorB_reg[28];
//         6'd29: RotorB_forward_o = RotorB_reg[29];
//         6'd30: RotorB_forward_o = RotorB_reg[30];
//         6'd31: RotorB_forward_o = RotorB_reg[31];
//         6'd32: RotorB_forward_o = RotorB_reg[32];
//         6'd33: RotorB_forward_o = RotorB_reg[33];
//         6'd34: RotorB_forward_o = RotorB_reg[34];
//         6'd35: RotorB_forward_o = RotorB_reg[35];
//         6'd36: RotorB_forward_o = RotorB_reg[36];
//         6'd37: RotorB_forward_o = RotorB_reg[37];
//         6'd38: RotorB_forward_o = RotorB_reg[38];
//         6'd39: RotorB_forward_o = RotorB_reg[39];
//         6'd40: RotorB_forward_o = RotorB_reg[40];
//         6'd41: RotorB_forward_o = RotorB_reg[41];
//         6'd42: RotorB_forward_o = RotorB_reg[42];
//         6'd43: RotorB_forward_o = RotorB_reg[43];
//         6'd44: RotorB_forward_o = RotorB_reg[44];
//         6'd45: RotorB_forward_o = RotorB_reg[45];
//         6'd46: RotorB_forward_o = RotorB_reg[46];
//         6'd47: RotorB_forward_o = RotorB_reg[47];
//         6'd48: RotorB_forward_o = RotorB_reg[48];
//         6'd49: RotorB_forward_o = RotorB_reg[49];
//         6'd50: RotorB_forward_o = RotorB_reg[50];
//         6'd51: RotorB_forward_o = RotorB_reg[51];
//         6'd52: RotorB_forward_o = RotorB_reg[52];
//         6'd53: RotorB_forward_o = RotorB_reg[53];
//         6'd54: RotorB_forward_o = RotorB_reg[54];
//         6'd55: RotorB_forward_o = RotorB_reg[55];
//         6'd56: RotorB_forward_o = RotorB_reg[56];
//         6'd57: RotorB_forward_o = RotorB_reg[57];
//         6'd58: RotorB_forward_o = RotorB_reg[58];
//         6'd59: RotorB_forward_o = RotorB_reg[59];
//         6'd60: RotorB_forward_o = RotorB_reg[60];
//         6'd61: RotorB_forward_o = RotorB_reg[61];
//         6'd62: RotorB_forward_o = RotorB_reg[62];
//         6'd63: RotorB_forward_o = RotorB_reg[63];
//     endcase
// end


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
// always @(negedge clk) begin
//   xor_o <= lfsr_reg ^ RotorB_forward_o;
// end
assign xor_o = lfsr_reg ^ RotorB_forward_o;
assign RotorB_inverse_i = xor_o;
// ----- XOR ----- //

endmodule


// // ----- Rotor A submodule -----//
// module RotorA_cell # (
// 	parameter pData_LEN = 6
// )(
// 	input wire [(pData_LEN-1):0] param1_i,
// 	input wire [(pData_LEN-1):0] param2_i,
// 	input wire [(pData_LEN-1):0] param3_i,
// 	input wire [(pData_LEN-1):0] param4_i,
// 	input wire [(pData_LEN-1):0] shift_i, // previous stage output
// 	input load_i,
// 	input encrypt_i,
// 	input clk,
// 	input [1:0]shift_value_i,
// 	input [1:0]table_idx,
// 	output reg [(pData_LEN-1):0] shift_o
// );

// reg [(pData_LEN-1):0] shift_mux;
// always @(*) begin
// 	case (shift_value_i) // synopsys parallel_case
// 	2'b00: shift_mux = param1_i;
// 	2'b01: shift_mux = param2_i;
// 	2'b10: shift_mux = param3_i;
// 	2'b11: shift_mux = param4_i;
// 	endcase
// end

// reg [(pData_LEN-1):0] reg_i;
// always @(*) begin
// 	case ({load_i, encrypt_i}) // synopsys parallel_case
// 	2'b01: reg_i = shift_mux;
// 	2'b10: reg_i = shift_i;
// 	default: reg_i = shift_o;
// 	endcase
// end

// always @(posedge clk) begin
// 	if (table_idx == 2'b00 || encrypt_i == 1) begin
// 	  shift_o <= reg_i;
// 	end else begin
// 	  shift_o <= shift_o;
// 	end
	
// end

// endmodule

// // ----- Rotor B submodule -----//
// module RotorB_cell # (
// 	parameter pData_LEN = 6
// )(
// 	input wire [(pData_LEN-1):0] param1_i,
// 	input wire [(pData_LEN-1):0] param2_i,
// 	input wire [(pData_LEN-1):0] param3_i,
// 	input wire [(pData_LEN-1):0] param4_i,
// 	input wire [(pData_LEN-1):0] shift_i, // previous stage output
// 	input load_i,
// 	input encrypt_i,
// 	input clk,
// 	input [1:0]shift_value_i,
// 	input [1:0]table_idx,
// 	input [(pData_LEN-1):0] mux_i,
// 	output reg [(pData_LEN-1):0] shift_o,
// 	output reg [(pData_LEN-1):0] mux_o
// );

// always @(*) begin
// 	case (shift_value_i) // synopsys parallel_case
// 	2'b00: mux_o = param1_i;
// 	2'b01: mux_o = param2_i;
// 	2'b10: mux_o = param3_i;
// 	2'b11: mux_o = param4_i;
// 	endcase
// end

// reg [(pData_LEN-1):0] reg_i;
// always @(*) begin
// 	case ({load_i, encrypt_i}) // synopsys parallel_case
// 	2'b01: reg_i = mux_i;
// 	2'b10: reg_i = shift_i;
// 	default: reg_i = shift_o;
// 	endcase
// end

// always @(posedge clk) begin
// 	if (table_idx == 2'b10 || encrypt_i == 1) begin
// 	  shift_o <= reg_i;
// 	end else begin
// 	  shift_o <= shift_o;
// 	end
	
// end

// endmodule

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

