`timescale 1ns/1ps
`define CYCLE 10
`define END_CYCLE 10000
`define PAT_LEN 29

module test_enigma();
localparam DAT_LEN = 6;
localparam ROT_LEN = 64;
localparam PLUG_LEN = 32;

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
// ************************** enigma instantiation *************************
reg clk;
reg srst_n;
reg load;
reg encrypt;
reg crypt_mode;
reg [1:0]table_idx;
reg [(DAT_LEN-1):0]code_in;
wire [(DAT_LEN-1):0]code_out;
wire code_valid;

enigma u_enigma(
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
	$dumpfile("hw2_part4.vcd");
	$dumpvars();
end
// *******************************************************************************/



// ******** Read rotor and pattern from pat/ and rotor/ with $readmemh() *********
reg [(DAT_LEN-1) : 0] plain_text [0 : (`PAT_LEN - 1)];
reg [(DAT_LEN-1) : 0] cipher_text [0 : (`PAT_LEN - 1)];
reg [(DAT_LEN-1) : 0] golden_pat [0 : (`PAT_LEN - 1)];
reg [(DAT_LEN-1) : 0] rotorA_text [0 : (ROT_LEN-1)];
reg [(DAT_LEN-1) : 0] rotorB_text [0 : (ROT_LEN-1)];
reg [(DAT_LEN-1) : 0] plug_text [0 : (PLUG_LEN-1)];

`ifdef PAT1
initial begin
    $readmemh("pat/plaintexts1.dat", plain_text);
    $readmemh("pat/ciphertexts1.dat", cipher_text);
    $readmemh("rotor/rotorA.dat", rotorA_text);
    $readmemh("rotor/rotorB.dat", rotorB_text);
end
`elsif PAT2
initial begin
    $readmemh("pat/plaintexts2.dat", plain_text);
    $readmemh("pat/ciphertexts2.dat", cipher_text);
    $readmemh("rotor/rotorA.dat", rotorA_text);
    $readmemh("rotor/rotorB.dat", rotorB_text);
end
`elsif PAT3
initial begin
    $readmemh("pat/plaintexts3.dat", plain_text);
    $readmemh("pat/ciphertexts3.dat", cipher_text);
    $readmemh("rotor/rotorA.dat", rotorA_text);
    $readmemh("rotor/rotorB.dat", rotorB_text);
end
`else
  initial begin
    $display("ERROR: Must define +define+PAT1 or +define+PAT2 or +define+PAT3 for part4");
    $finish;
  end
`endif

// load plugboard data
integer p;
initial begin
  $readmemh("rotor/plugboard.dat", plug_text);
  // for (p=0; p<PLUG_LEN; p=p+2)
  //   $display("[plug] pair %0d : %02h <-> %02h", p/2, plug_text[p], plug_text[p+1]);
end

// load golden data
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


// ********************************** ASCII***************************************/
reg [8*128-1:0] ascii_path;
reg [7:0] ascii_lut [0:63]; 
reg [7:0] ch;
`ifdef ASCII
  integer fd_ascii;
  
  initial begin

  `ifdef PAT1
      ascii_path = "./result/plaintexts1_ascii.dat";
  `elsif PAT2
      ascii_path = "./result/plaintexts2_ascii.dat";
  `elsif PAT3
      ascii_path = "./result/plaintexts3_ascii.dat";
  `else
      $display("ERROR: Must define PAT1/2/3 when ASCII is enabled");
      $finish;
  `endif
  ascii_lut[6'h00] = "a";
  ascii_lut[6'h01] = "b";
  ascii_lut[6'h02] = "c";
  ascii_lut[6'h03] = "d";
  ascii_lut[6'h04] = "e";
  ascii_lut[6'h05] = "f";
  ascii_lut[6'h06] = "g";
  ascii_lut[6'h07] = "h";
  ascii_lut[6'h08] = "i";
  ascii_lut[6'h09] = "j";
  ascii_lut[6'h0A] = "k";
  ascii_lut[6'h0B] = "l";
  ascii_lut[6'h0C] = "m";
  ascii_lut[6'h0D] = "n";
  ascii_lut[6'h0E] = "o";
  ascii_lut[6'h0F] = "p";
  ascii_lut[6'h10] = "q";
  ascii_lut[6'h11] = "r";
  ascii_lut[6'h12] = "s";
  ascii_lut[6'h13] = "t";
  ascii_lut[6'h14] = "u";
  ascii_lut[6'h15] = "v";
  ascii_lut[6'h16] = "w";
  ascii_lut[6'h17] = "x";
  ascii_lut[6'h18] = "y";
  ascii_lut[6'h19] = "z";
  ascii_lut[6'h1A] = 8'h20;   // space
  ascii_lut[6'h1B] = "!";
  ascii_lut[6'h1C] = ",";
  ascii_lut[6'h1D] = "-";
  ascii_lut[6'h1E] = ".";
  ascii_lut[6'h1F] = "\n";
  ascii_lut[6'h20] = "A";
  ascii_lut[6'h21] = "B";
  ascii_lut[6'h22] = "C";
  ascii_lut[6'h23] = "D";
  ascii_lut[6'h24] = "E";
  ascii_lut[6'h25] = "F";
  ascii_lut[6'h26] = "G";
  ascii_lut[6'h27] = "H";
  ascii_lut[6'h28] = "I";
  ascii_lut[6'h29] = "J";
  ascii_lut[6'h2A] = "K";
  ascii_lut[6'h2B] = "L";
  ascii_lut[6'h2C] = "M";
  ascii_lut[6'h2D] = "N";
  ascii_lut[6'h2E] = "O";
  ascii_lut[6'h2F] = "P";
  ascii_lut[6'h30] = "Q";
  ascii_lut[6'h31] = "R";
  ascii_lut[6'h32] = "S";
  ascii_lut[6'h33] = "T";
  ascii_lut[6'h34] = "U";
  ascii_lut[6'h35] = "V";
  ascii_lut[6'h36] = "W";
  ascii_lut[6'h37] = "X";
  ascii_lut[6'h38] = "Y";
  ascii_lut[6'h39] = "Z";
  ascii_lut[6'h3A] = ":";
  ascii_lut[6'h3B] = "#";
  ascii_lut[6'h3C] = ";";
  ascii_lut[6'h3D] = "_";
  ascii_lut[6'h3E] = "+";
  ascii_lut[6'h3F] = "&";


  fd_ascii = $fopen(ascii_path, "w");
    if (fd_ascii == 0) begin
      $display("ERROR: cannot open ASCII output file: %0s", ascii_path);
      $finish;
    end
  end

  always @(posedge clk) begin
    if (encrypt && (crypt_mode==1'b1) && code_valid) begin
      ch = ascii_lut[code_out];  
      $fwrite(fd_ascii, "%s", ch);
    end
  end
`endif




initial begin
	$dumpfile("hw2_part4.vcd");
	$dumpvars();
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
      code_in <= rotorA_text[i];
      @(posedge clk);
    end
    // ----- load plugboard ----- //
    load <= 1;
    encrypt <= 0;
    table_idx <= 1;
    for (i = 0; i < PLUG_LEN; i = i + 1) begin
      code_in <= plug_text[i]; 
    @(posedge clk);
    end
    // ----- load Rotor B ----- //
    load <= 1;
    encrypt <= 0;
    table_idx <= 2'b10;
    for (i = 0; i < ROT_LEN; i = i + 1) begin
      code_in <= rotorB_text[i]; 
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
    `ifdef ASCII
      if (fd_ascii) $fclose(fd_ascii);
    `endif
    $finish;
end
// ******************************************************************************

endmodule