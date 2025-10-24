//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2025 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================


// ************************** do not modify *************************

`timescale 1ns/1ps
`define CYCLE 10
`define END_CYCLE 100000

module test_enigma();

// ************************** enigma instantiation *************************
reg  clk;
reg  srst_n;
reg  load;
reg  encrypt;
reg  crypt_mode;        // 0: ENCRYPT, 1: DECRYPT
reg  [2-1:0] table_idx; // 2'b00: rotorA, 2'b01: plugboard, 2'b10 rotorB
reg  [6-1:0] code_in;   // 
wire [6-1:0] code_out;
wire code_valid;

reg [6-1:0] rotorA     [0:64-1];
reg [6-1:0] rotorB     [0:64-1];
reg [6-1:0] plugboard [0:32-1];
reg [6-1:0] plaintext  [0:`PAT_LEN-1];
reg [6-1:0] ciphertext [0:`PAT_LEN-1];
reg [6-1:0] code_out_recorded [0:`PAT_LEN-1];

integer i, j;
// *******************************************************************************

enigma u_enigma(
    .clk(clk),
    .srst_n(srst_n),
    .load(load),
    .encrypt(encrypt),
    .crypt_mode(crypt_mode),
    .table_idx(table_idx),
    .code_in(code_in),
    .code_out(code_out),
    .code_valid(code_valid));

// ********************************** Waveform ***********************************
// Not neccessary 
// Dump waveform if you need it
// initial
// begin
//     $fsdbDumpfile("HW3.fsdb");
//     $fsdbDumpvars("+mda");
// end
// *******************************************************************************

// ******** Read rotor and pattern from pat/ and rotor/ with $readmemh() *********
initial begin
    $readmemh("./rotor/rotorA.dat", rotorA);
    $readmemh("./rotor/rotorB.dat", rotorB);
    $readmemh("./rotor/plugboard.dat", plugboard);
    `ifdef PAT1
        $readmemh("./pat/plaintexts1.dat", plaintext);
        $readmemh("./pat/ciphertexts1.dat", ciphertext);
    `elsif PAT2
        $readmemh("./pat/plaintexts2.dat", plaintext);
        $readmemh("./pat/ciphertexts2.dat", ciphertext);
    `else
        $readmemh("./pat/plaintexts3.dat", plaintext);
        $readmemh("./pat/ciphertexts3.dat", ciphertext);
    `endif
end
// *******************************************************************************



// ****************************** clock generation *******************************
initial begin
    clk = 0;
    while(1)
    #(`CYCLE/2) clk = ~clk;
end
// *******************************************************************************



// ********************************* feed input **********************************
// reset -> load rotor -> feed code
initial
begin
    srst_n = 1;
    `ifdef ENCRYPT
        crypt_mode = 0;
    `elsif DECRYPT
        crypt_mode = 1;
    `endif
    load = 0;
    table_idx = 2'b11;

    code_in = 0;
    encrypt = 0;    // load rotor, plugboard

    #(`CYCLE) 
    @(negedge clk) srst_n = 0;

    #(`CYCLE)
    @(negedge clk) srst_n = 1;

    #(`CYCLE)
    @(negedge clk)
    load = 1;

    // Load rotorA
    table_idx = 2'b00;
    for (i = 0; i < 64; i = i + 1)
    begin
        code_in = rotorA[i][5:0];
        @(negedge clk);
    end

    // Load plugboard
    table_idx = 2'b01;
    for (i = 0; i < 32; i = i + 1)
    begin
        code_in = plugboard[i][5:0];
        @(negedge clk);
    end

    // Load rotorB
    table_idx = 2'b10;
    for (i = 0; i < 64; i = i + 1)
    begin
        code_in = rotorB[i][5:0];
        @(negedge clk);
    end

    load = 0;
    table_idx = 2'b11;
    for (i = 0; i < `PAT_LEN; i = i + 1)
    begin
        @(negedge clk);
        `ifdef ENCRYPT
            code_in = plaintext[i][5:0];
        `else
            code_in = ciphertext[i][5:0];
        `endif
        encrypt = 1;
    end

    @(negedge clk)
    encrypt = 0;
end
// *******************************************************************************

// ******************************** check output  ********************************

integer plaintext_ascii;
reg [8-1:0] ascii_out;

integer pat_error;
reg [5:0] ans;

initial begin
    pat_error = 0;
    wait(encrypt === 1);
    wait(code_valid === 1);
    for (j = 0; j < `PAT_LEN; j = j + 1) begin
        
        @(negedge clk)

        `ifdef ENCRYPT
            ans = ciphertext[j][5:0];
        `else
            ans = plaintext[j][5:0];
        `endif
        
        code_out_recorded[j] = code_out;
        if (code_out !== ans) begin
            pat_error = pat_error + 1;
            $display("code_out = %h, ans = %h", code_out, ans);
        end
        // 
    end

    if (pat_error === 0) begin
        $display("\n============= Congratulations =============");
        $display("             All patterns pass !");
        $display("============= Congratulations =============\n");
    end

    `ifdef ASCII
    // ******************************  Write ASCII code  ******************************
    // * Steps:
    // * 1. Convert decrypted code (6-bit) to ASCII format (8-bit)
    // *    Example 6'h00 ('a' in this assignment) -> 8'h61  ('a' in ASCII format)
    // * 2. Use $fopen() and $fwrite() to write the result to ./result
        `ifdef DECRYPT
            `ifdef PAT1
                plaintext_ascii = $fopen("./result/plaintexts1_ascii.dat");
            `elsif PAT2
                plaintext_ascii = $fopen("./result/plaintexts2_ascii.dat");
            `elsif PAT3
                plaintext_ascii = $fopen("./result/plaintexts3_ascii.dat");
            `endif

            for (i = 0; i < `PAT_LEN; i = i + 1)
            begin
                EnigmaCodetoASCII(code_out_recorded[i], ascii_out);
                $fwrite(plaintext_ascii, "%c", ascii_out);
            end
        `endif
    // *******************************************************************************
    `endif

    #(`CYCLE) 
    @(negedge clk);
    $finish;
end
// *******************************************************************************


// ******************************** Time out **** ********************************
initial
begin
    #(`CYCLE * `END_CYCLE);
    $display("\n===================================================");
    $display("      Error!!! Simulation time is too long...      ");
    $display("   There might be something wrong in your code.    ");
    $display("===================================================\n");
    $finish;
end
// *******************************************************************************


task EnigmaCodetoASCII;
  input [6-1:0] eingmacode;
  output [8-1:0] ascii_out;
  reg [8-1:0] ascii_out;

  begin
    case(eingmacode)
      6'h00:
        ascii_out = 8'h61; //'a'
      6'h01:
        ascii_out = 8'h62; //'b'
      6'h02:
        ascii_out = 8'h63; //'c'
      6'h03:
        ascii_out = 8'h64; //'d'
      6'h04:
        ascii_out = 8'h65; //'e'
      6'h05:
        ascii_out = 8'h66; //'f'
      6'h06:
        ascii_out = 8'h67; //'g'
      6'h07:
        ascii_out = 8'h68; //'h'
      6'h08:
        ascii_out = 8'h69; //'i'
      6'h09:
        ascii_out = 8'h6a; //'j'
      6'h0a:
        ascii_out = 8'h6b; //'k'
      6'h0b:
        ascii_out = 8'h6c; //'l'
      6'h0c:
        ascii_out = 8'h6d; //'m'
      6'h0d:
        ascii_out = 8'h6e; //'n'
      6'h0e:
        ascii_out = 8'h6f; //'o'
      6'h0f:
        ascii_out = 8'h70; //'p'
      6'h10:
        ascii_out = 8'h71; //'q'
      6'h11:
        ascii_out = 8'h72; //'r'
      6'h12:
        ascii_out = 8'h73; //'s'
      6'h13:
        ascii_out = 8'h74; //'t'
      6'h14:
        ascii_out = 8'h75; //'u'
      6'h15:
        ascii_out = 8'h76; //'v'
      6'h16:
        ascii_out = 8'h77; //'w'
      6'h17:
        ascii_out = 8'h78; //'x'
      6'h18:
        ascii_out = 8'h79; //'y'
      6'h19:
        ascii_out = 8'h7a; //'z'
      6'h1a:
        ascii_out = 8'h20; //' '
      6'h1b:
        ascii_out = 8'h3f; //'?'
      6'h1c:
        ascii_out = 8'h2c; //','
      6'h1d:
        ascii_out = 8'h2d; //'-'
      6'h1e:
        ascii_out = 8'h2e; //'.'
      6'h1f:
        ascii_out = 8'h0a; //'\n' (change line)
      6'h20:
        ascii_out = 8'h41; //'A'
      6'h21:
        ascii_out = 8'h42; //'B'
      6'h22:
        ascii_out = 8'h43; //'C'
      6'h23:
        ascii_out = 8'h44; //'D'
      6'h24:
        ascii_out = 8'h45; //'E'
      6'h25:
        ascii_out = 8'h46; //'F'
      6'h26:
        ascii_out = 8'h47; //'G'
      6'h27:
        ascii_out = 8'h48; //'H'
      6'h28:
        ascii_out = 8'h49; //'I'
      6'h29:
        ascii_out = 8'h4a; //'J'
      6'h2a:
        ascii_out = 8'h4b; //'K'
      6'h2b:
        ascii_out = 8'h4c; //'L'
      6'h2c:
        ascii_out = 8'h4d; //'M'
      6'h2d:
        ascii_out = 8'h4e; //'N'
      6'h2e:
        ascii_out = 8'h4f; //'O'
      6'h2f:
        ascii_out = 8'h50; //'P'
      6'h30:
        ascii_out = 8'h51; //'Q'
      6'h31:
        ascii_out = 8'h52; //'R'
      6'h32:
        ascii_out = 8'h53; //'S'
      6'h33:
        ascii_out = 8'h54; //'T'
      6'h34:
        ascii_out = 8'h55; //'U'
      6'h35:
        ascii_out = 8'h56; //'V'
      6'h36:
        ascii_out = 8'h57; //'W'
      6'h37:
        ascii_out = 8'h58; //'X'
      6'h38:
        ascii_out = 8'h59; //'Y'
      6'h39:
        ascii_out = 8'h5a; //'Z'
      6'h3a:
        ascii_out = 8'h3a; //':'
      6'h3b:
        ascii_out = 8'h23; //'#'
      6'h3c:
        ascii_out = 8'h3b; //';'
      6'h3d:
        ascii_out = 8'h5f; //'_'
      6'h3e:
        ascii_out = 8'h2b; //'+'
      6'h3f:
        ascii_out = 8'h26; //'&'
    endcase
  end
endtask


endmodule