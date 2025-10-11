`timescale 1ns/1ps
`define CYCLE 10
`define END_CYCLE 10000
`define PAT_LEN 29

module test_enigma_part2();
localparam DAT_LEN = 6;
localparam ROT_LEN = 64;

`ifdef ENCRYPT
  localparam C_MODE = 1'b0;
`elsif DECRYPT
  localparam C_MODE = 1'b1;
`else
  localparam C_MODE = 1'bx; 
  initial begin
    $display("ERROR: Must define +define+ENCRYPT or +define+DECRYPT");
    $finish; 
  end
`endif
// ************************** enigma_part2 instantiation *************************
reg clk;
reg srst_n;
reg load;
reg encrypt;
reg crypt_mode;
reg [1:0]table_idx;
reg [(DAT_LEN-1):0]code_in;
wire [(DAT_LEN-1):0]code_out;
wire code_valid;

enigma_part2 u_enigma_part2(
        // input 
    .clk(clk),
    .srst_n(srst_n),
    .load(load), // load parameter of rotor if load == 1
    .encrypt(encrypt),
    .crypt_mode(crypt_mode),
    .table_idx(table_idx), // configuration destination
    .code_in(code_in),   // input data
    // output 
    .code_out(code_out),  // output data
    .code_valid(code_valid) // output valid
);
// *******************************************************************************/



// ********************************** Waveform ***********************************
// Not neccessary 
// Dump waveform if you need it
initial begin
	$dumpfile("hw2_part2.vcd");
	$dumpvars();
end
// *******************************************************************************/



// ******** Read rotor and pattern from pat/ and rotor/ with $readmemh() *********
reg [(DAT_LEN-1) : 0] plain_text [0 : (`PAT_LEN - 1)];
reg [(DAT_LEN-1) : 0] cipher_text [0 : (`PAT_LEN - 1)];
reg [(DAT_LEN-1) : 0] golden_pat [0 : (`PAT_LEN - 1)];
reg [(DAT_LEN-1) : 0] rotor_text [0 : (ROT_LEN-1)];
`ifdef PAT1
initial begin
    $readmemh("pat/plaintexts1_part2.dat", plain_text);
    $readmemh("pat/ciphertexts1_part2.dat", cipher_text);
    $readmemh("rotor/rotorA.dat", rotor_text);
end
`elsif PAT2
initial begin
    $readmemh("pat/plaintexts2_part2.dat", plain_text);
    $readmemh("pat/ciphertexts2_part2.dat", cipher_text);
    $readmemh("rotor/rotorA.dat", rotor_text);
end
`else
  initial begin
    $display("ERROR: Must define +define+PAT1 or +define+PAT2 for part1");
    $finish;
  end
`endif

integer k;
initial begin
    for (k = 0; k < `PAT_LEN; k = k + 1) begin
        if (C_MODE == 0) begin
          golden_pat[k] = cipher_text[k];
        end else if (C_MODE) begin
          golden_pat[k] = plain_text[k];
        end else begin
          golden_pat[k] = 6'b11_1111;
        end
    end
end
// *******************************************************************************/



// ****************************** clock generation *******************************
always #(`CYCLE/2) clk = ~clk;
// *******************************************************************************/



// ********************************* feed input **********************************
// reset -> load rotor -> encrpyt/decrypt
integer i;
initial begin
    // ----- reset ----- //
    clk <= 0;
    srst_n <= 1;
    load <= 0;
    encrypt <= 0;
    crypt_mode <= C_MODE;
    table_idx <= 3;
    code_in <= 0;
    @(posedge clk);
    srst_n <= 0;
    // ----- load rotor -----//
    @(posedge clk);
    srst_n <= 1;

    @(posedge clk);
    load <= 1;
    encrypt <= 0;
    table_idx <= 0;
    for (i = 0; i < ROT_LEN; i = i + 1) begin
      code_in <= rotor_text[i];
      @(posedge clk);
    end
    // ----- encrypt / decrypt ----- //
    load <= 0;
    encrypt <= 0;
    table_idx <= 3;
    @(posedge clk);
    load <= 0;
    encrypt <= 1;
    for (i = 0; i < `PAT_LEN; i = i + 1) begin
      if (crypt_mode == 0) begin
        code_in <= plain_text[i];
      end else if (crypt_mode == 1) begin
        code_in <= cipher_text[i];
      end else begin
        code_in <= 0;
      end
      @(posedge clk);
    end
end
// *******************************************************************************/

// ******************************** check output ********************************
/* If code_out is incorrect, print it is wrong and finish the simulation */
/* If code_out is correct for each pattern, print
============= Congratulations =============
             All patterns pass !
============= Congratulations =============
and finish the simulation
*/
integer pat_error;
integer j;
initial begin
    pat_error = 0;

    wait(srst_n == 0);
    wait(srst_n == 1);
    wait(load == 0 && encrypt == 1);
    @(posedge clk); // a little confuse about this cycle
    while (!code_valid) @(posedge clk);
        
    for (j = 0; j < `PAT_LEN; j = j + 1) begin
      if (golden_pat[j] === code_out) begin
        $display("[PASS]: PAT %d, golden_pat = %h, code_out = %h", j, golden_pat[j], code_out);
      end else begin
        $display("[FAIL]: PAT %d, golden_pat = %h, code_out = %h", j, golden_pat[j], code_out);
        pat_error = pat_error + 1;
      end
      @(posedge clk);
    end

    if (pat_error === 0) begin
        $display("\n============= Congratulations =============");
        $display("             All patterns pass !");
        $display("============= Congratulations =============\n");
    end
    $finish;
end
// ******************************************************************************

endmodule