//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2025 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

// Behavior model of Enigma in part1 (rotorA + XOR-whitening)
// Not synthesizable !!!
module behavior_model(clk, srst_n, load, encrypt, crypt_mode, table_idx, code_in, code_out, code_valid);
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


integer i, j;

reg [6-1:0] rotorA    [0:64-1];
reg [6-1:0] rotorA_forward_out;
reg [2-1:0] rotorA_shift_amount;
reg [6-1:0] XOR_whitening_out;
reg [6-1:0] rotorA_load_cnt;
reg [6-1:0] first_symbol;

reg [5:0]state_reg;
reg feedback_bit;

/// Enigma ///
initial begin
  rotorA_load_cnt = 0;
  code_valid = 0;
  state_reg[0] = 1;
  for (i = 1; i < 6; i = i + 1)
    state_reg[i] = 0;

  wait(srst_n == 1'b0);
  wait(srst_n == 1'b1);

  while (1) begin
    @(posedge clk);
    code_valid = 1'b0;
    if (load && table_idx == 2'b00) begin
      // set rotor A table
      rotorA[rotorA_load_cnt] = code_in;
      rotorA_load_cnt = rotorA_load_cnt + 1;
    end

    if (encrypt) begin
      // code_in = address
      rotorA_forward_out = rotorA[code_in];
      if (crypt_mode == 1'b0)
      // forward path define shift amout
        rotorA_shift_amount = rotorA_forward_out[1:0];

      XOR_whitening_out = rotorA_forward_out ^ {state_reg[5], state_reg[4], state_reg[3], state_reg[2], state_reg[1], state_reg[0]};

      if (crypt_mode == 1'b1) 
      // inverse path define shift amout
        rotorA_shift_amount = XOR_whitening_out[1:0];

      for (i = 0; i < 64; i = i + 1) begin
        // inverse path rotor A, used XOR_out as input synbol
        // , correspond address as output.
        if (rotorA[i] == XOR_whitening_out)
          code_out = i;
      end
      code_valid = 1'b1;

      // rotate rotorA
      for (i = 0; i < rotorA_shift_amount; i = i + 1) begin
        first_symbol = rotorA[0];
        for (j = 0; j < 63; j = j + 1)
          rotorA[j] = rotorA[j+1];
        rotorA[63] = first_symbol;   

      end
      // shift LFSR
      feedback_bit = state_reg[5] ^ state_reg[4];
      {state_reg[5], state_reg[4], state_reg[3], state_reg[2], state_reg[1], state_reg[0]} = {state_reg[4], state_reg[3], state_reg[2], state_reg[1], state_reg[0], feedback_bit};
    end
end
end
endmodule
