`timescale 1ns/1ps
`define CYCLE 10
`define END_CYCLE 10000

module test_enigma();

// ************************** enigma instantiation *************************
enigma u_enigma();
// *******************************************************************************



// ********************************** Waveform ***********************************
// Not neccessary 
// Dump waveform if you need it

// *******************************************************************************

// ******** Read rotor and pattern from pat/ and rotor/ with $readmemh() *********

// *******************************************************************************



// ****************************** clock generation *******************************

// *******************************************************************************



// ********************************* feed input **********************************
// reset -> load rotor -> encrpyt/decrypt

// *******************************************************************************

// ******************************** check output  ********************************
/* If code_out is incorrect, print it is wrong and finish the simulation */
/* If all code_out is correct, print
============= Congratulations =============
             All patterns pass !
============= Congratulations =============
and finish the simulation
*/

integer pat_error;

initial begin
    pat_error = 0;
    /*
    Your testbench
    */
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

    // *******************************************************************************
    `endif
    $finish;
end
// *******************************************************************************

endmodule