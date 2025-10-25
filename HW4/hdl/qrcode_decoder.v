module qrcode_decoder(
    input clk,                           // clock input
    input srst_n,                        // synchronous reset (active low)
    input start,                         // start decoding (1-cycle pulse)
    input [15:0] sram_rdata,             // read data from SRAM
    output [9:0] sram_raddr,             // read address to SRAM
    output [6:0] loc_y,                  // y location of the QR code to which the output text belongs
    output [6:0] loc_x,                  // x location of the QR code to which the output text belongs
    output valid,                        // indicate decoded_text is valid
    output [7:0] decode_text,            // decoded text
    output finish                        // 1: decoding finished
);


endmodule
