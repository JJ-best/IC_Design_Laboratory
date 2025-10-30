// ===== RANK D ===== //

module qrcode_decoder(
    input clk,                           // clock input
    input srst_n,                        // synchronous reset (active low)
    input start,                         // start decoding (1-cycle pulse)
    input [15:0] sram_rdata,             // read data from SRAM
    output [9:0] sram_raddr,             // read address to SRAM
    output reg[6:0] loc_y,                  // y location of the QR code to which the output text belongs
    output reg[6:0] loc_x,                  // x location of the QR code to which the output text belongs
    output valid,                        // indicate decoded_text is valid
    output [7:0] decode_text,            // decoded text
    output finish                        // 1: decoding finished
);
// workflow
// 1. find position and rotation
// To find the finder pattern
// 21x21 qrcode need to match 1111111_0101010_1111111 in one line
localparam qrcode_find1 = 21'b1111111_0101010_1111111;
localparam qrcode_find1_direction = 21'b1000001_0000000_1000001; // middle 7-bit is dont care
localparam qrcode_find1_rotation = 7'b1011101;
localparam qrcode_find2 = 42'b1111111_1111111_00110011001100_1111111_1111111;
// 42x42 qrcode need to match 1111111_1111111_00110011001100_1111111_1111111 in two line

// 2. Demask
// 3. Decode

// ===== declare ===== //
// ----- fsm ----- //
reg [2:0] state;
reg [2:0] state_n;
localparam IDLE = 3'b000;
localparam FIND = 3'b001;
localparam CHECK = 3'b010;
localparam DECODE = 3'b100;
localparam DONE = 3'b101;
// ----- addr gener ----- //
reg [9:0]addr;
reg [9:0]addr_n;
reg [9:0]addr_pointer; // remember the address to jump back after check
// ----- find position and rotation ----- //
// shift registers
reg [11:0]line0; 
reg [11:0]line1;
reg [11:0]line2;
reg [11:0]line3;
reg [11:0]line4;
reg [11:0]line5;
reg [11:0]line6;
reg [11:0]line7;
reg [11:0]line8;
reg [11:0]line9;
reg [11:0]line10;
reg [11:0]line11;
reg [11:0]line12;
reg [11:0]line13;
reg [11:0]line14;
reg [11:0]line15;
localparam block_size = 4;

reg [(6*block_size-1):0] row1_21;
reg [(6*block_size-1):0] row2_21;
reg [(6*block_size-1):0] row3_21;
reg [(6*block_size-1):0] row4_21;
reg [(12*block_size-1):0] row1_42;
reg [(12*block_size-1):0] row2_42;
reg [(12*block_size-1):0] row3_42;
reg [(12*block_size-1):0] row4_42;

reg up_direction;   // find the other one finder pattern from up direction
reg down_direction; // find the other one finder pattern from down direction

reg check_row11_21;
reg check_row12_21;
reg check_row13_21;
reg check_row14_21;

reg check_row11_21_direction;
reg check_row12_21_direction;
reg check_row13_21_direction;
reg check_row14_21_direction;

reg check_row21_21;
reg check_row22_21;
reg check_row23_21;
reg check_row24_21;

reg check_row21_21_direction;
reg check_row22_21_direction;
reg check_row23_21_direction;
reg check_row24_21_direction;

reg check_row31_21;
reg check_row32_21;
reg check_row33_21;
reg check_row34_21;

reg check_row31_21_direction;
reg check_row32_21_direction;
reg check_row33_21_direction;
reg check_row34_21_direction;

reg check_row41_21;
reg check_row42_21;
reg check_row43_21;
reg check_row44_21;

reg check_row41_21_direction;
reg check_row42_21_direction;
reg check_row43_21_direction;
reg check_row44_21_direction;

reg check; // if any row match qrcode_find1

// find rotation
// row1
reg check_rot11_21;
reg check_rot12_21;
reg check_rot1;
reg check_zero1_21;
// row2
reg check_rot21_21;
reg check_rot22_21;
reg check_rot2;
reg check_zero2_21;
// row3
reg check_rot31_21;
reg check_rot32_21;
reg check_rot3;
reg check_zero3_21;
// row4
reg check_rot41_21;
reg check_rot42_21;
reg check_rot4;
reg check_zero4_21;

reg check_rot; // check the rotation flag

reg rot_left;
reg rot_right;

reg [3:0]pos_x_onehot;
reg [3:0]pos_y_onehot;
reg [1:0]pos_x_binary;
reg [1:0]pos_y_binary;
// ===== declare ===== //

// ===== finite state machine ===== //
always @(posedge clk) begin
    if (!srst_n) begin
      state <= IDLE;
    end else begin
      state <= state_n;
    end
end

always @(*) begin
    case (state)
    IDLE: begin
      if (start) begin
        state_n = FIND;
      end else begin
        state_n = IDLE;
      end
    end
    FIND: begin
      if (check) begin
        state_n = CHECK; // check the rotation
      end else begin
        state_n = FIND;
      end
    end
    CHECK: begin
      state_n = CHECK;
    end
    default : begin
      state_n = FIND;
    end
    endcase
end

// address generator

always @(posedge clk) begin
  if (!srst_n) begin
    addr <= 0;
    addr_pointer <= 0;
  end else if (state != IDLE) begin
    addr <= addr_n;
    addr_pointer <= (check)? addr : addr_pointer; 
    // remember the addr, after decode this qrcode, jump back.
  end
end
always @(*) begin
  if (check) begin
    if (up_direction) begin
      addr_n = addr - 5 - 95;
    end else if (down_direction) begin
      addr_n = addr - 5 + 95;
    end else begin
      addr_n = 0; // debug
    end
  end else begin
    addr_n = addr + 1;
  end
end


assign sram_raddr = addr;
assign finish = (addr == 1200)? 1 :0 ;
// ===== finite state machine ===== //

// ===== rotation finite state machine ===== //
reg [2:0]rot_state;
reg [2:0]rot_state_n;
localparam ROT_IDLE = 3'b000;
localparam ROT_UP   = 3'b001;
localparam ROT_DOWN = 3'b010;
localparam ROT_0    = 3'b011;
localparam ROT_90   = 3'b100;
localparam ROT_180  = 3'b101;
localparam ROT_270  = 3'b110;
always @(posedge clk) begin
  if (!srst_n) begin
    rot_state <= ROT_IDLE;
  end else begin
    rot_state <= rot_state_n;
  end
end 
always @(*) begin
  case (rot_state)
    ROT_IDLE: begin //0
      if (check & up_direction) begin
        rot_state_n = ROT_UP;
      end else if (check & down_direction) begin
        rot_state_n = ROT_DOWN;
      end else begin
        rot_state_n = rot_state;
      end
    end
    ROT_UP: begin //1
      if (rot_left) begin
        rot_state_n = ROT_90;
      end else if (rot_right) begin
        rot_state_n = ROT_180;
      end else begin
        rot_state_n = rot_state;
      end
    end
    ROT_DOWN: begin //2
      if (rot_left) begin
        rot_state_n = ROT_0;
      end else if (rot_right) begin
        rot_state_n = ROT_270;
      end else begin
        rot_state_n = rot_state;
      end
    end
    ROT_0: begin //3
      rot_state_n = ROT_IDLE;
    end
    ROT_90: begin
      rot_state_n = ROT_IDLE;
    end
    ROT_180: begin
      rot_state_n = ROT_IDLE;
    end
    ROT_270: begin
      rot_state_n = ROT_IDLE;
    end
    default : begin
      rot_state_n = IDLE;
    end
      
  endcase
end
// ===== rotation finite state machine ===== //

// ===== find position and rotation ===== //
always @(posedge clk) begin
  if (!srst_n) begin
    line0  <= 0; line1  <= 0; line2  <= 0; line3  <= 0;
    line4  <= 0; line5  <= 0; line6  <= 0; line7  <= 0;
    line8  <= 0; line9  <= 0; line10 <= 0; line11 <= 0;
    line12 <= 0; line13 <= 0; line14 <= 0; line15 <= 0;
  end else if (check) begin
    line0  <= 0; line1  <= 0; line2  <= 0; line3  <= 0;
    line4  <= 0; line5  <= 0; line6  <= 0; line7  <= 0;
    line8  <= 0; line9  <= 0; line10 <= 0; line11 <= 0;
    line12 <= 0; line13 <= 0; line14 <= 0; line15 <= 0;
  end else if (state != IDLE) begin
    line0[11:0]  <= {line0[10:0],  sram_rdata[0]};
    line1[11:0]  <= {line1[10:0],  sram_rdata[1]};
    line2[11:0]  <= {line2[10:0],  sram_rdata[2]};
    line3[11:0]  <= {line3[10:0],  sram_rdata[3]};

    line4[11:0]  <= {line4[10:0],  sram_rdata[4]};
    line5[11:0]  <= {line5[10:0],  sram_rdata[5]};
    line6[11:0]  <= {line6[10:0],  sram_rdata[6]};
    line7[11:0]  <= {line7[10:0],  sram_rdata[7]};

    line8[11:0]  <= {line8[10:0],  sram_rdata[8]};
    line9[11:0]  <= {line9[10:0],  sram_rdata[9]};
    line10[11:0] <= {line10[10:0], sram_rdata[10]};
    line11[11:0] <= {line11[10:0], sram_rdata[11]};

    line12[11:0] <= {line12[10:0], sram_rdata[12]};
    line13[11:0] <= {line13[10:0], sram_rdata[13]};
    line14[11:0] <= {line14[10:0], sram_rdata[14]};
    line15[11:0] <= {line15[10:0], sram_rdata[15]};
  end
end

// row word 24 bit
always @(*) begin
  row1_21 = {line0[5], line1[5], line2[5], line3[5],
             line0[4], line1[4], line2[4], line3[4],
             line0[3], line1[3], line2[3], line3[3],
             line0[2], line1[2], line2[2], line3[2],
             line0[1], line1[1], line2[1], line3[1],
             line0[0], line1[0], line2[0], line3[0]};

  row2_21 = {line4[5], line5[5], line6[5], line7[5],
             line4[4], line5[4], line6[4], line7[4],
             line4[3], line5[3], line6[3], line7[3],
             line4[2], line5[2], line6[2], line7[2],
             line4[1], line5[1], line6[1], line7[1],
             line4[0], line5[0], line6[0], line7[0]};

  row3_21 = {line8[5], line9[5], line10[5], line11[5],
             line8[4], line9[4], line10[4], line11[4],
             line8[3], line9[3], line10[3], line11[3],
             line8[2], line9[2], line10[2], line11[2],
             line8[1], line9[1], line10[1], line11[1],
             line8[0], line9[0], line10[0], line11[0]};

  row4_21 = {line12[5], line13[5], line14[5], line15[5],
             line12[4], line13[4], line14[4], line15[4],
             line12[3], line13[3], line14[3], line15[3],
             line12[2], line13[2], line14[2], line15[2],
             line12[1], line13[1], line14[1], line15[1],
             line12[0], line13[0], line14[0], line15[0]};
end


// finder pattern position check, and determine the qrcode direction
always @(*) begin
  check_row11_21 = ~|(row1_21[23:3] ^ qrcode_find1);
  check_row12_21 = ~|(row1_21[22:2] ^ qrcode_find1);
  check_row13_21 = ~|(row1_21[21:1] ^ qrcode_find1);
  check_row14_21 = ~|(row1_21[20:0] ^ qrcode_find1);
  check_row11_21_direction = ~|({row1_21[23:17] ^ qrcode_find1_direction[20:14], // 1011101_xxxxxxx_1011101
                                 row1_21[9:3]   ^ qrcode_find1_direction[6:0]});
  check_row12_21_direction = ~|({row1_21[22:16] ^ qrcode_find1_direction[20:14],
                                 row1_21[8:2]   ^ qrcode_find1_direction[6:0]});
  check_row13_21_direction = ~|({row1_21[21:15] ^ qrcode_find1_direction[20:14],
                                 row1_21[7:1]   ^ qrcode_find1_direction[6:0]});
  check_row14_21_direction = ~|({row1_21[20:14] ^ qrcode_find1_direction[20:14],
                                 row1_21[6:0]   ^ qrcode_find1_direction[6:0]});

  check_row21_21 = ~|(row2_21[23:3] ^ qrcode_find1);
  check_row22_21 = ~|(row2_21[22:2] ^ qrcode_find1);
  check_row23_21 = ~|(row2_21[21:1] ^ qrcode_find1);
  check_row24_21 = ~|(row2_21[20:0] ^ qrcode_find1);
  check_row21_21_direction = ~|({row2_21[23:17] ^ qrcode_find1_direction[20:14],
                                 row2_21[9:3]   ^ qrcode_find1_direction[6:0]});
  check_row22_21_direction = ~|({row2_21[22:16] ^ qrcode_find1_direction[20:14],
                                 row2_21[8:2]   ^ qrcode_find1_direction[6:0]});
  check_row23_21_direction = ~|({row2_21[21:15] ^ qrcode_find1_direction[20:14],
                                 row2_21[7:1]   ^ qrcode_find1_direction[6:0]});
  check_row24_21_direction = ~|({row2_21[20:14] ^ qrcode_find1_direction[20:14],
                                 row2_21[6:0]   ^ qrcode_find1_direction[6:0]});

  check_row31_21 = ~|(row3_21[23:3] ^ qrcode_find1);
  check_row32_21 = ~|(row3_21[22:2] ^ qrcode_find1);
  check_row33_21 = ~|(row3_21[21:1] ^ qrcode_find1);
  check_row34_21 = ~|(row3_21[20:0] ^ qrcode_find1);
  check_row31_21_direction = ~|({row3_21[23:17] ^ qrcode_find1_direction[20:14],
                                 row3_21[9:3]   ^ qrcode_find1_direction[6:0]});
  check_row32_21_direction = ~|({row3_21[22:16] ^ qrcode_find1_direction[20:14],
                                 row3_21[8:2]   ^ qrcode_find1_direction[6:0]});
  check_row33_21_direction = ~|({row3_21[21:15] ^ qrcode_find1_direction[20:14],
                                 row3_21[7:1]   ^ qrcode_find1_direction[6:0]});
  check_row34_21_direction = ~|({row3_21[20:14] ^ qrcode_find1_direction[20:14],
                                 row3_21[6:0]   ^ qrcode_find1_direction[6:0]});

  check_row41_21 = ~|(row4_21[23:3] ^ qrcode_find1);
  check_row42_21 = ~|(row4_21[22:2] ^ qrcode_find1);
  check_row43_21 = ~|(row4_21[21:1] ^ qrcode_find1);
  check_row44_21 = ~|(row4_21[20:0] ^ qrcode_find1);
  check_row41_21_direction = ~|({row4_21[23:17] ^ qrcode_find1_direction[20:14],
                                 row4_21[9:3]   ^ qrcode_find1_direction[6:0]});
  check_row42_21_direction = ~|({row4_21[22:16] ^ qrcode_find1_direction[20:14],
                                 row4_21[8:2]   ^ qrcode_find1_direction[6:0]});
  check_row43_21_direction = ~|({row4_21[21:15] ^ qrcode_find1_direction[20:14],
                                 row4_21[7:1]   ^ qrcode_find1_direction[6:0]});
  check_row44_21_direction = ~|({row4_21[20:14] ^ qrcode_find1_direction[20:14],
                                 row4_21[6:0]   ^ qrcode_find1_direction[6:0]});

  check = check_row11_21 | check_row12_21 | check_row13_21 | check_row14_21 |
          check_row21_21 | check_row22_21 | check_row23_21 | check_row24_21 | 
          check_row31_21 | check_row32_21 | check_row33_21 | check_row34_21 | 
          check_row41_21 | check_row42_21 | check_row43_21 | check_row44_21;

  down_direction = (check_row11_21_direction & check_row21_21) | (check_row12_21_direction & check_row22_21) | 
                   (check_row13_21_direction & check_row23_21) | (check_row14_21_direction & check_row24_21) |
                   (check_row21_21_direction & check_row31_21) | (check_row22_21_direction & check_row32_21) | 
                   (check_row23_21_direction & check_row33_21) | (check_row24_21_direction & check_row34_21) |
                   (check_row31_21_direction & check_row41_21) | (check_row32_21_direction & check_row42_21) | 
                   (check_row33_21_direction & check_row43_21) | (check_row34_21_direction & check_row44_21);

  up_direction = (check_row11_21 & check_row21_21_direction) | (check_row12_21 & check_row22_21_direction) | 
                 (check_row13_21 & check_row23_21_direction) | (check_row14_21 & check_row24_21_direction) |
                 (check_row21_21 & check_row31_21_direction) | (check_row22_21 & check_row32_21_direction) | 
                 (check_row23_21 & check_row33_21_direction) | (check_row24_21 & check_row34_21_direction) |
                 (check_row31_21 & check_row41_21_direction) | (check_row32_21 & check_row42_21_direction) | 
                 (check_row33_21 & check_row43_21_direction) | (check_row34_21 & check_row44_21_direction);
end

// find rotation: check 1011101 pattern position
// chech the rotation for 21x21 qrcode
always @(*) begin
  check_rot11_21 = ~|(row1_21[7:1] ^ qrcode_find1_rotation); // row1_21 == 1011101
  check_rot12_21 = ~|(row1_21[6:0] ^ qrcode_find1_rotation);
  check_rot1 = check_rot11_21 | check_rot12_21;
  check_zero1_21 = ~|row1_21[23:17]; // check all zero

  check_rot21_21 = ~|(row2_21[7:1] ^ qrcode_find1_rotation);
  check_rot22_21 = ~|(row2_21[6:0] ^ qrcode_find1_rotation);
  check_rot2 = check_rot21_21 | check_rot21_21;
  check_zero2_21 = ~|row2_21[23:17];

  check_rot31_21 = ~|(row3_21[7:1] ^ qrcode_find1_rotation);
  check_rot32_21 = ~|(row3_21[6:0] ^ qrcode_find1_rotation);
  check_rot3 = check_rot31_21 | check_rot32_21;
  check_zero3_21 = ~|row3_21[23:17];

  check_rot41_21 = ~|(row4_21[7:1] ^ qrcode_find1_rotation);
  check_rot42_21 = ~|(row4_21[6:0] ^ qrcode_find1_rotation);
  check_rot4 = check_rot41_21 | check_rot42_21;
  check_zero4_21 = ~|row4_21[23:17];

  check_rot = check_rot1 | check_rot2 | check_rot3 | check_rot4;

  rot_left = (check_rot1 & check_zero1_21) | (check_rot2 & check_zero2_21) | 
             (check_rot3 & check_zero3_21) | (check_rot4 & check_zero4_21);
  rot_right = (check_rot1 & !check_zero1_21) | (check_rot2 & !check_zero2_21) | 
             (check_rot3 & !check_zero3_21) | (check_rot4 & !check_zero4_21);
end

always @(*) begin
  pos_x_onehot[0] = check_row11_21 | check_row21_21 | check_row31_21 | check_row41_21;
  pos_x_onehot[1] = check_row12_21 | check_row22_21 | check_row32_21 | check_row42_21;
  pos_x_onehot[2] = check_row13_21 | check_row23_21 | check_row33_21 | check_row43_21;
  pos_x_onehot[3] = check_row14_21 | check_row24_21 | check_row34_21 | check_row44_21;

  pos_y_onehot[0] = check_row11_21 | check_row12_21 | check_row13_21 | check_row14_21;
  pos_y_onehot[1] = check_row21_21 | check_row22_21 | check_row23_21 | check_row24_21;
  pos_y_onehot[2] = check_row31_21 | check_row32_21 | check_row33_21 | check_row34_21;
  pos_y_onehot[3] = check_row41_21 | check_row42_21 | check_row43_21 | check_row44_21;

  // onehot to binary
  pos_x_binary[1] = pos_x_onehot[2] | pos_x_onehot[3];
  pos_x_binary[0] = pos_x_onehot[1] | pos_x_onehot[3];
  pos_y_binary[1] = pos_y_onehot[2] | pos_y_onehot[3];
  pos_y_binary[0] = pos_y_onehot[1] | pos_y_onehot[3];
end

reg [1:0]pos_x_binary_reg;
reg [1:0]pos_y_binary_reg;
always @(posedge clk) begin
  if (!srst_n) begin
    pos_x_binary_reg <= 0;
    pos_y_binary_reg <= 0;
  end else if (check) begin
    pos_x_binary_reg <= pos_x_binary;
    pos_y_binary_reg <= pos_y_binary;
  end
end

reg [9:0]addr_finder;
reg [7:0]loc_x_finder; // addr_finder[4:0] * 4
reg [7:0]loc_y_finder; // addr_finder[9:5] * 4
reg [7:0]loc_x_rot0;
reg [7:0]loc_y_rot0;
reg [7:0]loc_x_rot90;
reg [7:0]loc_y_rot90;
reg [7:0]loc_x_rot180;
reg [7:0]loc_y_rot180;
reg [7:0]loc_x_rot270;
reg [7:0]loc_y_rot270; // 32 = 100000
reg [7:0]loc_x_n;
reg [7:0]loc_y_n;
always @(*) begin
  addr_finder = addr_pointer - 6;
  loc_x_finder = {3'b0, addr_finder[4:0], 2'b0} + pos_x_binary_reg;
  loc_y_finder = {3'b0, addr_finder[9:5], 2'b0} + pos_y_binary_reg;

  loc_x_rot0 = loc_x_finder;
  loc_y_rot0 = loc_y_finder - 6;

  loc_x_rot90 = loc_x_finder;
  loc_y_rot90 = loc_y_finder + 6;

  loc_x_rot180 = loc_x_finder + 20;
  loc_y_rot180 = loc_y_finder + 6;

  loc_x_rot270 = loc_x_finder + 20;
  loc_y_rot270 = loc_y_finder - 6;

  case (rot_state)
  ROT_0: begin
    loc_x_n = loc_x_rot0;
    loc_y_n = loc_y_rot0;
  end 
  ROT_90: begin
    loc_x_n = loc_x_rot90;
    loc_y_n = loc_y_rot90;
  end
  ROT_180: begin
    loc_x_n = loc_x_rot180;
    loc_y_n = loc_y_rot180;
  end
  ROT_270: begin
    loc_x_n = loc_x_rot270;
    loc_y_n = loc_y_rot270;
  end
  default: begin
    loc_x_n = 0;
    loc_y_n = 0;
  end
  endcase
end

always @(posedge clk) begin
  if (rot_state == ROT_UP | rot_state == ROT_DOWN) begin
    loc_x <= loc_x_n;
    loc_y <= loc_y_n;
  end
end

// ===== find position and rotation ===== //


// ===== decode ===== //

// ===== decode ===== //


endmodule
