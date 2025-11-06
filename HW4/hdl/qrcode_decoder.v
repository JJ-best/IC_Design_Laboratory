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
localparam qrcode_find1_7bitzero = 7'b0000000;
localparam qrcode_find1_rotation = 7'b1011101;
localparam qrcode_find1_rot_double_check = 7'b1000001;

localparam qrcode_find2 = 42'b1111111_1111111_00110011001100_1111111_1111111;
localparam qrcode_find2_direction = 42'b1100000_0000011_0000000_0000000_1100000_0000011;
localparam qrcode_find2_14bitzero = 14'b0000000_0000000;
localparam qrcode_find2_rotation = 14'b1100111_1110011;
localparam qrcode_find2_rot_double_check = 14'b1100000_0000011;
// 42x42 qrcode need to match 1111111_1111111_00110011001100_1111111_1111111 in two line

// 2. Demask
// 3. Decode

// ===== declare ===== //
// input buffer
reg start_reg;
// ----- fsm ----- //
reg [2:0] state;
reg [2:0] state_n;
localparam IDLE = 3'd0;
localparam FIND = 3'd1;
localparam CHECK = 3'd2;
localparam MASK1 = 3'd3;
localparam MASK2 = 3'd4;
localparam DECODE = 3'd5;
localparam CHECK_42 = 3'd6;
// ----- addr gener ----- //
reg [9:0]addr;
reg [9:0]addr_n;
reg [9:0]addr_pointer; // remember the address to jump back after check
// ----- find position and rotation ----- //
// shift registers
localparam shift_reg_depth = 14;
reg [(shift_reg_depth-1):0]line0; 
reg [(shift_reg_depth-1):0]line1;
reg [(shift_reg_depth-1):0]line2;
reg [(shift_reg_depth-1):0]line3;
reg [(shift_reg_depth-1):0]line4;
reg [(shift_reg_depth-1):0]line5;
reg [(shift_reg_depth-1):0]line6;
reg [(shift_reg_depth-1):0]line7;
reg [(shift_reg_depth-1):0]line8;
reg [(shift_reg_depth-1):0]line9;
reg [(shift_reg_depth-1):0]line10;
reg [(shift_reg_depth-1):0]line11;
reg [(shift_reg_depth-1):0]line12;
reg [(shift_reg_depth-1):0]line13;
reg [(shift_reg_depth-1):0]line14;
reg [(shift_reg_depth-1):0]line15;
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
reg up_direction_42;
reg down_direction_42;
reg [3:0] rot_cnt;
reg [3:0] rot_cnt_n;
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

reg check_row_11_21_zero;
reg check_row_12_21_zero;
reg check_row_13_21_zero;
reg check_row_14_21_zero;

reg check_row_21_21_zero;
reg check_row_22_21_zero;
reg check_row_23_21_zero;
reg check_row_24_21_zero;

reg check_row_31_21_zero;
reg check_row_32_21_zero;
reg check_row_33_21_zero;
reg check_row_34_21_zero;

reg check_row_41_21_zero;
reg check_row_42_21_zero;
reg check_row_43_21_zero;
reg check_row_44_21_zero;

reg check; // if any row match qrcode_find1
reg check_42; // if any row match qrcode_find2

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

// ----- 42x42 qrcode ----- //
reg check_row11_42;
reg check_row12_42;
reg check_row13_42;
reg check_row14_42;

reg check_row21_42;
reg check_row22_42;
reg check_row23_42;
reg check_row24_42;

reg check_row31_42;
reg check_row32_42;
reg check_row33_42;
reg check_row34_42;

reg check_row41_42;
reg check_row42_42;
reg check_row43_42;
reg check_row44_42;

reg check_row11_42_direction;
reg check_row12_42_direction;
reg check_row13_42_direction;
reg check_row14_42_direction;

reg check_row21_42_direction;
reg check_row22_42_direction;
reg check_row23_42_direction;
reg check_row24_42_direction;

reg check_row31_42_direction;
reg check_row32_42_direction;
reg check_row33_42_direction;
reg check_row34_42_direction;

reg check_row41_42_direction;
reg check_row42_42_direction;
reg check_row43_42_direction;
reg check_row44_42_direction;

reg check_row_11_42_zero;
reg check_row_12_42_zero;
reg check_row_13_42_zero;
reg check_row_14_42_zero;

reg check_row_21_42_zero;
reg check_row_22_42_zero;
reg check_row_23_42_zero;
reg check_row_24_42_zero;

reg check_row_31_42_zero;
reg check_row_32_42_zero;
reg check_row_33_42_zero;
reg check_row_34_42_zero;

reg check_row_41_42_zero;
reg check_row_42_42_zero;
reg check_row_43_42_zero;
reg check_row_44_42_zero;

reg large_qrcode_flag;
// ----- 42x42 qrcode ----- //

reg check_rot; // check the rotation flag
reg check_rot42;
reg rot_left;
reg rot_right;
reg rot_left42;
reg rot_right42;

reg [3:0]pos_x_onehot;
reg [3:0]pos_y_onehot;

reg [1:0]pos_x_binary;
reg [1:0]pos_y_binary;
reg [9:0]addr_finder;
reg [6:0]loc_x_finder; // addr_finder[4:0] * 4
reg [6:0]loc_y_finder; // addr_finder[9:5] * 4
reg [6:0]loc_x_rot0;
reg [6:0]loc_y_rot0;
reg [6:0]loc_x_rot90;
reg [6:0]loc_y_rot90;
reg [6:0]loc_x_rot180;
reg [6:0]loc_y_rot180;
reg [6:0]loc_x_rot270;
reg [6:0]loc_y_rot270; // 32 = 100000
reg [6:0]loc_x_n;
reg [6:0]loc_y_n;
reg [6:0]loc_x_finder_42;
reg [6:0]loc_y_finder_42;
// mask
reg [4:0]loc_x_mask_block_addr_start;
reg [4:0]loc_y_mask_block_addr_start;

reg [4:0]loc_x_mask_block_addr_end;
reg [4:0]loc_y_mask_block_addr_end;

reg [1:0]loc_x_mask_inblock_addr_start;
reg [1:0]loc_x_mask_inblock_addr_end;
reg [1:0]loc_y_mask_inblock_addr_start;
reg [1:0]loc_y_mask_inblock_addr_end;

reg [6:0]loc_x_mask_start; // start addr
reg [6:0]loc_x_mask_end;   // end addr
reg [6:0]loc_y_mask_start; // start addr
reg [6:0]loc_y_mask_end;   // end addr
reg [9:0]mask_block1_addr;
reg [9:0]mask_block2_addr;
reg mask_2cyc; // true if mask cross two block
reg mask_done;

// ----- demask ----- //
// coordinate compare to loc_x, loc_y, consider rotation
reg [6:0] i0_sym;  reg [6:0] j0_sym;
reg [6:0] i1_sym;  reg [6:0] j1_sym;
reg [6:0] i2_sym;  reg [6:0] j2_sym;
reg [6:0] i3_sym;  reg [6:0] j3_sym;
reg [6:0] i4_sym;  reg [6:0] j4_sym;
reg [6:0] i5_sym;  reg [6:0] j5_sym;
reg [6:0] i6_sym;  reg [6:0] j6_sym;
reg [6:0] i7_sym;  reg [6:0] j7_sym;
reg [6:0] i8_sym;  reg [6:0] j8_sym;
reg [6:0] i9_sym;  reg [6:0] j9_sym;
reg [6:0] i10_sym; reg [6:0] j10_sym;
reg [6:0] i11_sym; reg [6:0] j11_sym;
reg [6:0] i12_sym; reg [6:0] j12_sym;
reg [6:0] i13_sym; reg [6:0] j13_sym;
reg [6:0] i14_sym; reg [6:0] j14_sym;
reg [6:0] i15_sym; reg [6:0] j15_sym;

wire [6:0] i0_mask;  wire [6:0] j0_mask;
wire [6:0] i1_mask;  wire [6:0] j1_mask;
wire [6:0] i2_mask;  wire [6:0] j2_mask;
wire [6:0] i3_mask;  wire [6:0] j3_mask;
wire [6:0] i4_mask;  wire [6:0] j4_mask;
wire [6:0] i5_mask;  wire [6:0] j5_mask;
wire [6:0] i6_mask;  wire [6:0] j6_mask;
wire [6:0] i7_mask;  wire [6:0] j7_mask;
wire [6:0] i8_mask;  wire [6:0] j8_mask;
wire [6:0] i9_mask;  wire [6:0] j9_mask;
wire [6:0] i10_mask; wire [6:0] j10_mask;
wire [6:0] i11_mask; wire [6:0] j11_mask;
wire [6:0] i12_mask; wire [6:0] j12_mask;
wire [6:0] i13_mask; wire [6:0] j13_mask;
wire [6:0] i14_mask; wire [6:0] j14_mask;
wire [6:0] i15_mask; wire [6:0] j15_mask;

assign i0_mask  = (large_qrcode_flag)? {1'b0, i0_sym[6:1]}   : i0_sym;
assign i1_mask  = (large_qrcode_flag)? {1'b0, i1_sym[6:1]}   : i1_sym;
assign i2_mask  = (large_qrcode_flag)? {1'b0, i2_sym[6:1]}   : i2_sym;
assign i3_mask  = (large_qrcode_flag)? {1'b0, i3_sym[6:1]}   : i3_sym;
assign i4_mask  = (large_qrcode_flag)? {1'b0, i4_sym[6:1]}   : i4_sym;
assign i5_mask  = (large_qrcode_flag)? {1'b0, i5_sym[6:1]}   : i5_sym;
assign i6_mask  = (large_qrcode_flag)? {1'b0, i6_sym[6:1]}   : i6_sym;
assign i7_mask  = (large_qrcode_flag)? {1'b0, i7_sym[6:1]}   : i7_sym;
assign i8_mask  = (large_qrcode_flag)? {1'b0, i8_sym[6:1]}   : i8_sym;
assign i9_mask  = (large_qrcode_flag)? {1'b0, i9_sym[6:1]}   : i9_sym;
assign i10_mask = (large_qrcode_flag)? {1'b0, i10_sym[6:1]}  : i10_sym;
assign i11_mask = (large_qrcode_flag)? {1'b0, i11_sym[6:1]}  : i11_sym;
assign i12_mask = (large_qrcode_flag)? {1'b0, i12_sym[6:1]}  : i12_sym;
assign i13_mask = (large_qrcode_flag)? {1'b0, i13_sym[6:1]}  : i13_sym;
assign i14_mask = (large_qrcode_flag)? {1'b0, i14_sym[6:1]}  : i14_sym;
assign i15_mask = (large_qrcode_flag)? {1'b0, i15_sym[6:1]}  : i15_sym;

assign j0_mask  = (large_qrcode_flag)? {1'b0, j0_sym[6:1]}   : j0_sym;
assign j1_mask  = (large_qrcode_flag)? {1'b0, j1_sym[6:1]}   : j1_sym;
assign j2_mask  = (large_qrcode_flag)? {1'b0, j2_sym[6:1]}   : j2_sym;
assign j3_mask  = (large_qrcode_flag)? {1'b0, j3_sym[6:1]}   : j3_sym;
assign j4_mask  = (large_qrcode_flag)? {1'b0, j4_sym[6:1]}   : j4_sym;
assign j5_mask  = (large_qrcode_flag)? {1'b0, j5_sym[6:1]}   : j5_sym;
assign j6_mask  = (large_qrcode_flag)? {1'b0, j6_sym[6:1]}   : j6_sym;
assign j7_mask  = (large_qrcode_flag)? {1'b0, j7_sym[6:1]}   : j7_sym;
assign j8_mask  = (large_qrcode_flag)? {1'b0, j8_sym[6:1]}   : j8_sym;
assign j9_mask  = (large_qrcode_flag)? {1'b0, j9_sym[6:1]}   : j9_sym;
assign j10_mask = (large_qrcode_flag)? {1'b0, j10_sym[6:1]}  : j10_sym;
assign j11_mask = (large_qrcode_flag)? {1'b0, j11_sym[6:1]}  : j11_sym;
assign j12_mask = (large_qrcode_flag)? {1'b0, j12_sym[6:1]}  : j12_sym;
assign j13_mask = (large_qrcode_flag)? {1'b0, j13_sym[6:1]}  : j13_sym;
assign j14_mask = (large_qrcode_flag)? {1'b0, j14_sym[6:1]}  : j14_sym;
assign j15_mask = (large_qrcode_flag)? {1'b0, j15_sym[6:1]}  : j15_sym;
wire [13:0] p0,  p1,  p2,  p3,  p4,  p5,  p6,  p7,  p8,  p9,  p10, p11, p12, p13, p14, p15;
wire [1:0]  p0m3,p1m3,p2m3,p3m3,p4m3,p5m3,p6m3,p7m3,p8m3,p9m3,p10m3,p11m3,p12m3,p13m3,p14m3,p15m3;
reg        mask_cond0;
reg        mask_cond1;
reg        mask_cond2;
reg        mask_cond3;
reg        mask_cond4;
reg        mask_cond5;
reg        mask_cond6;
reg        mask_cond7;
reg        mask_cond8;
reg        mask_cond9;
reg        mask_cond10;
reg        mask_cond11;
reg        mask_cond12;
reg        mask_cond13;
reg        mask_cond14;
reg        mask_cond15;
// ----- decode ----- //
reg [6:0]loc_x_decode_corner1_addr;
reg [6:0]loc_y_decode_corner1_addr;

reg [6:0]loc_x_decode_corner2_addr;
reg [6:0]loc_y_decode_corner2_addr;

reg [6:0]loc_x_decode_corner3_addr;
reg [6:0]loc_y_decode_corner3_addr;

reg [6:0]loc_x_decode_corner4_addr;
reg [6:0]loc_y_decode_corner4_addr;

reg [6:0]loc_x_decode_corner5_addr;
reg [6:0]loc_y_decode_corner5_addr;

reg [6:0]loc_x_decode_corner6_addr;
reg [6:0]loc_y_decode_corner6_addr;

reg [6:0]loc_x_decode_corner7_addr;
reg [6:0]loc_y_decode_corner7_addr;

reg [6:0]loc_x_decode_corner8_addr;
reg [6:0]loc_y_decode_corner8_addr;
reg [9:0]corner1_block_addr;
reg [9:0]corner2_block_addr;
reg [9:0]corner3_block_addr;
reg [9:0]corner4_block_addr;
reg [9:0]corner5_block_addr;
reg [9:0]corner6_block_addr;
reg [9:0]corner7_block_addr;
reg [9:0]corner8_block_addr;
reg [4:0]block_bound_2_4;// sram addr bound of corner 2 and 4
reg [4:0]block_bound_3_4;// sram addr bound of corner 3 and 4
reg [4:0]block_bound_6_8;
reg [4:0]block_bound_7_8;
reg [9:0]decode_addr;
reg [4:0]sram_raddr_h_swap;//y addr
reg [4:0]sram_raddr_l_swap;//x addr
wire [9:0]sram_raddr_swap;
reg [4:0]sram_raddr_h_jump1;
reg [4:0]sram_raddr_l_jump1;
wire [9:0]sram_raddr_jump1;
reg [4:0]sram_raddr_h_jump2;
reg [4:0]sram_raddr_l_jump2;
wire [9:0]sram_raddr_jump2;

reg [2:0]decode_state;
reg [2:0]decode_state_n;
reg decode_read2; // read two row flag
localparam DECODE_IDLE = 3'd0;
localparam DECODE_SWAP1_UP = 3'd1;// swap read the block
localparam DECODE_SWAP2_UP = 3'd2;// jump to next row block
localparam DECODE_JUMP2 = 3'd3;// jump to next block region
localparam DECODE_DECODE1 = 3'd4; // region 1 word 0-11
localparam DECODE_DECODE2 = 3'd5; // region 1 word 12-14
localparam DECODE_DECODE3 = 3'd6; // region 2 word 15-18
wire rot0_bound1_check;
wire rot90_bound1_check;
wire rot180_bound1_check;
wire rot270_bound1_check;
wire bound1_check; // check 2_4 bound 
wire jump1;
wire jump2;


// bit address of sram_rdata
reg [6:0] sram_dat0_x;
reg [6:0] sram_dat1_x;
reg [6:0] sram_dat2_x;
reg [6:0] sram_dat3_x;
reg [6:0] sram_dat4_x;
reg [6:0] sram_dat5_x;
reg [6:0] sram_dat6_x;
reg [6:0] sram_dat7_x;
reg [6:0] sram_dat8_x;
reg [6:0] sram_dat9_x;
reg [6:0] sram_dat10_x;
reg [6:0] sram_dat11_x;
reg [6:0] sram_dat12_x;
reg [6:0] sram_dat13_x;
reg [6:0] sram_dat14_x;
reg [6:0] sram_dat15_x;

reg [6:0] sram_dat0_y;
reg [6:0] sram_dat1_y;
reg [6:0] sram_dat2_y;
reg [6:0] sram_dat3_y;
reg [6:0] sram_dat4_y;
reg [6:0] sram_dat5_y;
reg [6:0] sram_dat6_y;
reg [6:0] sram_dat7_y;
reg [6:0] sram_dat8_y;
reg [6:0] sram_dat9_y;
reg [6:0] sram_dat10_y;
reg [6:0] sram_dat11_y;
reg [6:0] sram_dat12_y;
reg [6:0] sram_dat13_y;
reg [6:0] sram_dat14_y;
reg [6:0] sram_dat15_y;

reg [1:0] check_bound_cnt;
reg [1:0] check_bound_cnt_n;
reg [4:0] global_word_idx;
reg [3:0] local_word_idx;  // 6 word per decode
reg [4:0] data_len;

reg [7:0] decode_text_r;
reg       decode_valid_r;

reg [7:0] decode_text_n2;
reg       decode_valid_n2;
// ----- region2 decode data ----- //
reg line0_dat;
reg line1_dat;
reg line2_dat;
reg line3_dat;
reg line4_dat;
reg line5_dat;
reg line6_dat;
reg line7_dat;
reg line8_dat;
reg line9_dat;
reg line10_dat;
reg line11_dat;
reg line12_dat;
reg line13_dat;
reg line14_dat;
reg line15_dat;
reg shift0_en;
reg shift1_en;
reg shift2_en;
reg shift3_en;
reg shift4_en;
reg shift5_en;
reg shift6_en;
reg shift7_en;
reg shift8_en;
reg shift9_en;
reg shift10_en;
reg shift11_en;
reg shift12_en;
reg shift13_en;
reg shift14_en;
reg shift15_en;
// ===== declare ===== //

// ===== finite state machine ===== //
always @(posedge clk) begin
    if (!srst_n) begin
      state <= IDLE;
      start_reg <= 0;
    end else begin
      state <= state_n;
      start_reg <= start;
    end
end

always @(*) begin
    case (state)
    IDLE: begin
      if (start_reg) begin
        state_n = FIND;
      end else begin
        state_n = IDLE;
      end
    end
    FIND: begin // find position
      if (check) begin
        state_n = CHECK; 
      end else if (check_42) begin
        state_n = CHECK_42;
      end else begin
        state_n = FIND;
      end
    end
    CHECK: begin // check rotation
      if (rot_cnt == 8) begin // refresh line
        state_n = FIND;
      end else if (check_rot) begin
        state_n = MASK1;
      end else begin
        state_n = CHECK;
      end
    end
    MASK1: begin //3
      if (mask_2cyc) begin
        state_n = MASK2;
      end else begin
        state_n = DECODE;
      end
    end
    MASK2: begin // 4
      state_n = DECODE;
    end
    DECODE: begin // 5
      if (global_word_idx == 2 && decode_text_n2 == 0) begin
        state_n = FIND;
      end else if (global_word_idx == data_len + 2 && (global_word_idx != 2)) begin
        state_n = FIND;
      end else begin
        state_n = DECODE;
      end
    end
    CHECK_42: begin // 6
      if (rot_cnt == 14) begin //refresh line
        state_n = FIND;
      end else if (check_rot42) begin
        state_n = MASK1;
      end else begin
        state_n = CHECK_42;
      end
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
    addr_pointer <= ((state == FIND && check) | (state == FIND && check_42))? addr - 1: addr_pointer; 
    // remember the addr, after decode this qrcode, jump back.
  end
end
always @(*) begin
  if (rot_cnt == 14 && state == CHECK_42) begin
    addr_n = addr_pointer;
  end else if (rot_cnt == 8 && state == CHECK) begin // if didnt find rotation in 8 cycle
    addr_n = addr_pointer;
  end else if (check) begin // rotation state for 21x21 qrcode
    if (up_direction && addr > 102) begin
      addr_n = addr - 6 - 96;
    end else if (down_direction) begin
      addr_n = addr - 6 + 96;
    end else begin
      addr_n = addr;
    end
  end else if (check_42) begin // rotation check for 42x42 qrcode
    if (up_direction_42) begin
      addr_n = addr - 12 - 160;
    end else if (down_direction_42) begin
      addr_n = addr - 12 + 160;
    end else begin
      addr_n = addr;
    end
  end else if (state == MASK1) begin
    addr_n = mask_block1_addr;
  end else if (state == MASK2) begin
    addr_n = mask_block2_addr;
  end else if (state == DECODE) begin
    addr_n = decode_addr;
  end else begin
    addr_n = addr + 1;
  end
end

reg [4:0] finish_cnt ;
reg finish_flag;

assign sram_raddr = addr;
// assign finish = (finish_cnt == 30);
assign finish = finish_flag && (state == FIND);
// start cnt up to 30 if addr == 1023
always @(posedge clk) begin
  if (!srst_n) begin
    finish_flag <= 0;
  end else if (addr == 1023) begin
    finish_flag <= 1;
  end else begin
    finish_flag <= finish_flag;
  end
end 
// always @(posedge clk) begin
//   if (!srst_n) begin
//     finish_cnt <= 0;
//   end else if (finish_flag) begin
//     finish_cnt <= finish_cnt + 1;
//   end else begin
//     finish_cnt <= finish_cnt;
//   end
// end 

// ===== finite state machine ===== //

// ===== rotation finite state machine ===== //
reg [2:0]rot_state;
reg [2:0]rot_state_n;
localparam ROT_IDLE = 3'd0;
localparam ROT_UP   = 3'd1;
localparam ROT_DOWN = 3'd2;
localparam ROT_0    = 3'd3;
localparam ROT_90   = 3'd4;
localparam ROT_180  = 3'd5;
localparam ROT_270  = 3'd6;
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
      if ((check & up_direction) | (check_42 & up_direction_42)) begin
        rot_state_n = ROT_UP;
      end else if ((check & down_direction) | (check_42 & down_direction_42)) begin
        rot_state_n = ROT_DOWN;
      end else begin
        rot_state_n = rot_state;
      end
    end
    ROT_UP: begin //1
      if (global_word_idx == 2 && decode_text_n2 == 0) begin
        rot_state_n = ROT_IDLE;
      end else if (rot_cnt == 13) begin
        rot_state_n = ROT_IDLE;
      end else if ((rot_left & check_rot) | (rot_left42 & check_rot42)) begin
        rot_state_n = ROT_90;
      end else if ((rot_right & check_rot) | (rot_right42 & check_rot42)) begin
        rot_state_n = ROT_180;
      end else if (state == FIND) begin
        rot_state_n = ROT_IDLE;
      end else begin
        rot_state_n = rot_state;
      end
    end
    ROT_DOWN: begin //2
      if (global_word_idx == 2 && decode_text_n2 == 0) begin
        rot_state_n = ROT_IDLE;
      end else if (rot_cnt == 13) begin
        rot_state_n = ROT_IDLE;
      end else if ((rot_left & check_rot) | (rot_left42 & check_rot42)) begin
        rot_state_n = ROT_0;
      end else if (rot_right & check_rot | (rot_right42 & check_rot42)) begin
        rot_state_n = ROT_270;
      end else if (state == FIND) begin
        rot_state_n = ROT_IDLE;
      end else begin
        rot_state_n = rot_state;
      end
    end
    ROT_0: begin //3
      if (global_word_idx == 2 && decode_text_n2 == 0) begin
        rot_state_n = ROT_IDLE;
      end else if (global_word_idx == data_len + 2 && (global_word_idx != 2)) begin
        rot_state_n = ROT_IDLE;
      end else if (state == FIND) begin
        rot_state_n = ROT_IDLE;
      end else begin
        rot_state_n = ROT_0;
      end
    end
    ROT_90: begin //4
      if (global_word_idx == 2 && decode_text_n2 == 0) begin
        rot_state_n = ROT_IDLE;
      end else if (global_word_idx == data_len + 2 && (global_word_idx != 2)) begin
        rot_state_n = ROT_IDLE;
      end else if (state == FIND) begin
        rot_state_n = ROT_IDLE;
      end else begin
        rot_state_n = ROT_90;
      end
    end
    ROT_180: begin // 5
      if (global_word_idx == 2 && decode_text_n2 == 0) begin
        rot_state_n = ROT_IDLE;
      end else if (global_word_idx == data_len + 2 && (global_word_idx != 2)) begin
        rot_state_n = ROT_IDLE;
      end else if (state == FIND) begin
        rot_state_n = ROT_IDLE;
      end else begin
        rot_state_n = ROT_180;
      end
    end
    ROT_270: begin // 6
      if (global_word_idx == 2 && decode_text_n2 == 0) begin
        rot_state_n = ROT_IDLE;
      end else if (global_word_idx == data_len + 2 && (global_word_idx != 2)) begin
        rot_state_n = ROT_IDLE;
      end else if (state == FIND) begin
        rot_state_n = ROT_IDLE;
      end else begin
        rot_state_n = ROT_270;
      end
    end
    default : begin
      rot_state_n = ROT_IDLE;
    end
      
  endcase
end

// if jump to the up or down state, neet to find rotation in 8 cycle, 
// else, jump back to rot_idle, addr = addr_pointer, state = find

// 8 cycle counter

always @(posedge clk) begin
  if (!srst_n) begin
    rot_cnt <= 0;
  end else if (state == CHECK | state == CHECK_42) begin
    rot_cnt <= rot_cnt + 1;
  end else begin
    rot_cnt <= 0;
  end
end

// ===== rotation finite state machine ===== //

// ===== find position and rotation ===== //
reg [3:0] fifo_wptr0;
reg [3:0] fifo_wptr1;
reg [3:0] fifo_wptr2;
reg [3:0] fifo_wptr3;
reg [3:0] fifo_wptr4;
reg [3:0] fifo_wptr5;
reg [3:0] fifo_wptr6;
reg [3:0] fifo_wptr7;
reg [3:0] fifo_wptr8;
reg [3:0] fifo_wptr9;
reg [3:0] fifo_wptr10;
reg [3:0] fifo_wptr11;
reg [3:0] fifo_wptr12;
reg [3:0] fifo_wptr13;
reg [3:0] fifo_wptr14;
reg [3:0] fifo_wptr15;

always @(posedge clk) begin
  if (!srst_n) begin
    line0  <= 0; line1  <= 0; line2  <= 0; line3  <= 0;
    line4  <= 0; line5  <= 0; line6  <= 0; line7  <= 0;
    line8  <= 0; line9  <= 0; line10 <= 0; line11 <= 0;
    line12 <= 0; line13 <= 0; line14 <= 0; line15 <= 0;
  end else if (check | check_42 | (state == DECODE && decode_state == DECODE_IDLE)| (state == CHECK_42 && rot_cnt == 14) | (state == CHECK && rot_cnt == 8)) begin
    line0  <= 0; line1  <= 0; line2  <= 0; line3  <= 0;
    line4  <= 0; line5  <= 0; line6  <= 0; line7  <= 0;
    line8  <= 0; line9  <= 0; line10 <= 0; line11 <= 0;
    line12 <= 0; line13 <= 0; line14 <= 0; line15 <= 0;
  end 
  else if (state == DECODE) begin // fifo
  // we need to define rptr and wptr later
    line0 [fifo_wptr0 ] <= line0_dat;
    line1 [fifo_wptr1 ] <= line1_dat;
    line2 [fifo_wptr2 ] <= line2_dat;
    line3 [fifo_wptr3 ] <= line3_dat;
    line4 [fifo_wptr4 ] <= line4_dat;
    line5 [fifo_wptr5 ] <= line5_dat;
    line6 [fifo_wptr6 ] <= line6_dat;
    line7 [fifo_wptr7 ] <= line7_dat;
    line8 [fifo_wptr8 ] <= line8_dat;
    line9 [fifo_wptr9 ] <= line9_dat;
    line10[fifo_wptr10] <= line10_dat;
    line11[fifo_wptr11] <= line11_dat;
    line12[fifo_wptr12] <= line12_dat;
    line13[fifo_wptr13] <= line13_dat;
    line14[fifo_wptr14] <= line14_dat;
    line15[fifo_wptr15] <= line15_dat;
  end 
  else if (state != IDLE) begin
    line0[(shift_reg_depth-1):0]  <= {line0[(shift_reg_depth-2):0],  sram_rdata[0]};
    line1[(shift_reg_depth-1):0]  <= {line1[(shift_reg_depth-2):0],  sram_rdata[1]};
    line2[(shift_reg_depth-1):0]  <= {line2[(shift_reg_depth-2):0],  sram_rdata[2]};
    line3[(shift_reg_depth-1):0]  <= {line3[(shift_reg_depth-2):0],  sram_rdata[3]};

    line4[(shift_reg_depth-1):0]  <= {line4[(shift_reg_depth-2):0],  sram_rdata[4]};
    line5[(shift_reg_depth-1):0]  <= {line5[(shift_reg_depth-2):0],  sram_rdata[5]};
    line6[(shift_reg_depth-1):0]  <= {line6[(shift_reg_depth-2):0],  sram_rdata[6]};
    line7[(shift_reg_depth-1):0]  <= {line7[(shift_reg_depth-2):0],  sram_rdata[7]};

    line8[(shift_reg_depth-1):0]  <= {line8[(shift_reg_depth-2):0],  sram_rdata[8]};
    line9[(shift_reg_depth-1):0]  <= {line9[(shift_reg_depth-2):0],  sram_rdata[9]};
    line10[(shift_reg_depth-1):0] <= {line10[(shift_reg_depth-2):0], sram_rdata[10]};
    line11[(shift_reg_depth-1):0] <= {line11[(shift_reg_depth-2):0], sram_rdata[11]};

    line12[(shift_reg_depth-1):0] <= {line12[(shift_reg_depth-2):0], sram_rdata[12]};
    line13[(shift_reg_depth-1):0] <= {line13[(shift_reg_depth-2):0], sram_rdata[13]};
    line14[(shift_reg_depth-1):0] <= {line14[(shift_reg_depth-2):0], sram_rdata[14]};
    line15[(shift_reg_depth-1):0] <= {line15[(shift_reg_depth-2):0], sram_rdata[15]};
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

//row word 48 bit
// add here
always @(*) begin
  row1_42 = {line0[11], line1[11], line2[11], line3[11],
             line0[10], line1[10], line2[10], line3[10],
             line0[9],  line1[9],  line2[9],  line3[9],
             line0[8],  line1[8],  line2[8],  line3[8],
             line0[7],  line1[7],  line2[7],  line3[7],
             line0[6],  line1[6],  line2[6],  line3[6],
             line0[5],  line1[5],  line2[5],  line3[5],
             line0[4],  line1[4],  line2[4],  line3[4],
             line0[3],  line1[3],  line2[3],  line3[3],
             line0[2],  line1[2],  line2[2],  line3[2],
             line0[1],  line1[1],  line2[1],  line3[1],
             line0[0],  line1[0],  line2[0],  line3[0]};

  row2_42 = {line4[11], line5[11], line6[11], line7[11],
             line4[10], line5[10], line6[10], line7[10],
             line4[9],  line5[9],  line6[9],  line7[9],
             line4[8],  line5[8],  line6[8],  line7[8],
             line4[7],  line5[7],  line6[7],  line7[7],
             line4[6],  line5[6],  line6[6],  line7[6],
             line4[5],  line5[5],  line6[5],  line7[5],
             line4[4],  line5[4],  line6[4],  line7[4],
             line4[3],  line5[3],  line6[3],  line7[3],
             line4[2],  line5[2],  line6[2],  line7[2],
             line4[1],  line5[1],  line6[1],  line7[1],
             line4[0],  line5[0],  line6[0],  line7[0]};

  row3_42 = {line8[11],  line9[11],  line10[11], line11[11],
             line8[10],  line9[10],  line10[10], line11[10],
             line8[9],   line9[9],   line10[9],  line11[9],
             line8[8],   line9[8],   line10[8],  line11[8],
             line8[7],   line9[7],   line10[7],  line11[7],
             line8[6],   line9[6],   line10[6],  line11[6],
             line8[5],   line9[5],   line10[5],  line11[5],
             line8[4],   line9[4],   line10[4],  line11[4],
             line8[3],   line9[3],   line10[3],  line11[3],
             line8[2],   line9[2],   line10[2],  line11[2],
             line8[1],   line9[1],   line10[1],  line11[1],
             line8[0],   line9[0],   line10[0],  line11[0]};

  row4_42 = {line12[11], line13[11], line14[11], line15[11],
             line12[10], line13[10], line14[10], line15[10],
             line12[9],  line13[9],  line14[9],  line15[9],
             line12[8],  line13[8],  line14[8],  line15[8],
             line12[7],  line13[7],  line14[7],  line15[7],
             line12[6],  line13[6],  line14[6],  line15[6],
             line12[5],  line13[5],  line14[5],  line15[5],
             line12[4],  line13[4],  line14[4],  line15[4],
             line12[3],  line13[3],  line14[3],  line15[3],
             line12[2],  line13[2],  line14[2],  line15[2],
             line12[1],  line13[1],  line14[1],  line15[1],
             line12[0],  line13[0],  line14[0],  line15[0]};
end

// ----- region 2 decode data ----- //
// if lower than the loc_finder, use these data, else sram_rdata[i]


// 1. 需要增加該line的wptr
// 2. 需要判斷是否低於finder
  // 記得改上面fifo
  // only for decodestate SWAP2
wire demask_data0;
wire demask_data1;
wire demask_data2;
wire demask_data3;
wire demask_data4;
wire demask_data5;
wire demask_data6;
wire demask_data7;
wire demask_data8;
wire demask_data9;
wire demask_data10;
wire demask_data11;
wire demask_data12;
wire demask_data13;
wire demask_data14;
wire demask_data15;
assign demask_data0 = sram_rdata[0] ^ mask_cond0;
assign demask_data1 = sram_rdata[1] ^ mask_cond1;
assign demask_data2 = sram_rdata[2] ^ mask_cond2;
assign demask_data3 = sram_rdata[3] ^ mask_cond3;
assign demask_data4 = sram_rdata[4] ^ mask_cond4;
assign demask_data5 = sram_rdata[5] ^ mask_cond5;
assign demask_data6 = sram_rdata[6] ^ mask_cond6;
assign demask_data7 = sram_rdata[7] ^ mask_cond7;
assign demask_data8 = sram_rdata[8] ^ mask_cond8;
assign demask_data9 = sram_rdata[9] ^ mask_cond9;
assign demask_data10 = sram_rdata[10] ^ mask_cond10;
assign demask_data11 = sram_rdata[11] ^ mask_cond11;
assign demask_data12 = sram_rdata[12] ^ mask_cond12;
assign demask_data13 = sram_rdata[13] ^ mask_cond13;
assign demask_data14 = sram_rdata[14] ^ mask_cond14;
assign demask_data15 = sram_rdata[15] ^ mask_cond15;

always @(*) begin
  case (rot_state)
    ROT_0: begin // NOTE: here may be loc_y_finder_42 + 1, fix later
      shift0_en  = (!large_qrcode_flag)? (sram_dat0_y  > loc_y_finder): (sram_dat0_y  > loc_y_finder_42 + 1);
      shift1_en  = (!large_qrcode_flag)? (sram_dat1_y  > loc_y_finder): (sram_dat1_y  > loc_y_finder_42 + 1);
      shift2_en  = (!large_qrcode_flag)? (sram_dat2_y  > loc_y_finder): (sram_dat2_y  > loc_y_finder_42 + 1);
      shift3_en  = (!large_qrcode_flag)? (sram_dat3_y  > loc_y_finder): (sram_dat3_y  > loc_y_finder_42 + 1);
      shift4_en  = (!large_qrcode_flag)? (sram_dat4_y  > loc_y_finder): (sram_dat4_y  > loc_y_finder_42 + 1);
      shift5_en  = (!large_qrcode_flag)? (sram_dat5_y  > loc_y_finder): (sram_dat5_y  > loc_y_finder_42 + 1);
      shift6_en  = (!large_qrcode_flag)? (sram_dat6_y  > loc_y_finder): (sram_dat6_y  > loc_y_finder_42 + 1);
      shift7_en  = (!large_qrcode_flag)? (sram_dat7_y  > loc_y_finder): (sram_dat7_y  > loc_y_finder_42 + 1);
      shift8_en  = (!large_qrcode_flag)? (sram_dat8_y  > loc_y_finder): (sram_dat8_y  > loc_y_finder_42 + 1);
      shift9_en  = (!large_qrcode_flag)? (sram_dat9_y  > loc_y_finder): (sram_dat9_y  > loc_y_finder_42 + 1);
      shift10_en = (!large_qrcode_flag)? (sram_dat10_y > loc_y_finder): (sram_dat10_y  > loc_y_finder_42 + 1);
      shift11_en = (!large_qrcode_flag)? (sram_dat11_y > loc_y_finder): (sram_dat11_y  > loc_y_finder_42 + 1);
      shift12_en = (!large_qrcode_flag)? (sram_dat12_y > loc_y_finder): (sram_dat12_y  > loc_y_finder_42 + 1);
      shift13_en = (!large_qrcode_flag)? (sram_dat13_y > loc_y_finder): (sram_dat13_y  > loc_y_finder_42 + 1);
      shift14_en = (!large_qrcode_flag)? (sram_dat14_y > loc_y_finder): (sram_dat14_y  > loc_y_finder_42 + 1);
      shift15_en = (!large_qrcode_flag)? (sram_dat15_y > loc_y_finder): (sram_dat15_y  > loc_y_finder_42 + 1);
    end
    ROT_90: begin
      // may be loc_x_finder + 13?
      shift0_en  = (!large_qrcode_flag)? (sram_dat0_x  > loc_x_finder + 6) : (sram_dat0_x  > loc_x_finder_42 + 13);
      shift1_en  = (!large_qrcode_flag)? (sram_dat1_x  > loc_x_finder + 6) : (sram_dat1_x  > loc_x_finder_42 + 13);
      shift2_en  = (!large_qrcode_flag)? (sram_dat2_x  > loc_x_finder + 6) : (sram_dat2_x  > loc_x_finder_42 + 13);
      shift3_en  = (!large_qrcode_flag)? (sram_dat3_x  > loc_x_finder + 6) : (sram_dat3_x  > loc_x_finder_42 + 13);
      shift4_en  = (!large_qrcode_flag)? (sram_dat4_x  > loc_x_finder + 6) : (sram_dat4_x  > loc_x_finder_42 + 13);
      shift5_en  = (!large_qrcode_flag)? (sram_dat5_x  > loc_x_finder + 6) : (sram_dat5_x  > loc_x_finder_42 + 13);
      shift6_en  = (!large_qrcode_flag)? (sram_dat6_x  > loc_x_finder + 6) : (sram_dat6_x  > loc_x_finder_42 + 13);
      shift7_en  = (!large_qrcode_flag)? (sram_dat7_x  > loc_x_finder + 6) : (sram_dat7_x  > loc_x_finder_42 + 13);
      shift8_en  = (!large_qrcode_flag)? (sram_dat8_x  > loc_x_finder + 6) : (sram_dat8_x  > loc_x_finder_42 + 13);
      shift9_en  = (!large_qrcode_flag)? (sram_dat9_x  > loc_x_finder + 6) : (sram_dat9_x  > loc_x_finder_42 + 13);
      shift10_en = (!large_qrcode_flag)? (sram_dat10_x > loc_x_finder + 6) : (sram_dat10_x > loc_x_finder_42 + 13);
      shift11_en = (!large_qrcode_flag)? (sram_dat11_x > loc_x_finder + 6) : (sram_dat11_x > loc_x_finder_42 + 13);
      shift12_en = (!large_qrcode_flag)? (sram_dat12_x > loc_x_finder + 6) : (sram_dat12_x > loc_x_finder_42 + 13);
      shift13_en = (!large_qrcode_flag)? (sram_dat13_x > loc_x_finder + 6) : (sram_dat13_x > loc_x_finder_42 + 13);
      shift14_en = (!large_qrcode_flag)? (sram_dat14_x > loc_x_finder + 6) : (sram_dat14_x > loc_x_finder_42 + 13);
      shift15_en = (!large_qrcode_flag)? (sram_dat15_x > loc_x_finder + 6) : (sram_dat15_x > loc_x_finder_42 + 13);
    end
    ROT_180: begin
      shift0_en  = (!large_qrcode_flag)? (sram_dat0_y  < loc_y_finder): (sram_dat0_y  < loc_y_finder_42 - 1);
      shift1_en  = (!large_qrcode_flag)? (sram_dat1_y  < loc_y_finder): (sram_dat1_y  < loc_y_finder_42 - 1);
      shift2_en  = (!large_qrcode_flag)? (sram_dat2_y  < loc_y_finder): (sram_dat2_y  < loc_y_finder_42 - 1);
      shift3_en  = (!large_qrcode_flag)? (sram_dat3_y  < loc_y_finder): (sram_dat3_y  < loc_y_finder_42 - 1);
      shift4_en  = (!large_qrcode_flag)? (sram_dat4_y  < loc_y_finder): (sram_dat4_y  < loc_y_finder_42 - 1);
      shift5_en  = (!large_qrcode_flag)? (sram_dat5_y  < loc_y_finder): (sram_dat5_y  < loc_y_finder_42 - 1);
      shift6_en  = (!large_qrcode_flag)? (sram_dat6_y  < loc_y_finder): (sram_dat6_y  < loc_y_finder_42 - 1);
      shift7_en  = (!large_qrcode_flag)? (sram_dat7_y  < loc_y_finder): (sram_dat7_y  < loc_y_finder_42 - 1);
      shift8_en  = (!large_qrcode_flag)? (sram_dat8_y  < loc_y_finder): (sram_dat8_y  < loc_y_finder_42 - 1);
      shift9_en  = (!large_qrcode_flag)? (sram_dat9_y  < loc_y_finder): (sram_dat9_y  < loc_y_finder_42 - 1);
      shift10_en = (!large_qrcode_flag)? (sram_dat10_y < loc_y_finder): (sram_dat10_y  < loc_y_finder_42 - 1);
      shift11_en = (!large_qrcode_flag)? (sram_dat11_y < loc_y_finder): (sram_dat11_y  < loc_y_finder_42 - 1);
      shift12_en = (!large_qrcode_flag)? (sram_dat12_y < loc_y_finder): (sram_dat12_y  < loc_y_finder_42 - 1);
      shift13_en = (!large_qrcode_flag)? (sram_dat13_y < loc_y_finder): (sram_dat13_y  < loc_y_finder_42 - 1);
      shift14_en = (!large_qrcode_flag)? (sram_dat14_y < loc_y_finder): (sram_dat14_y  < loc_y_finder_42 - 1);
      shift15_en = (!large_qrcode_flag)? (sram_dat15_y < loc_y_finder): (sram_dat15_y  < loc_y_finder_42 - 1);
    end
    ROT_270: begin
      // need implement here
      shift0_en  = (!large_qrcode_flag)? (sram_dat0_x  < loc_x_finder + 14) : (sram_dat0_x  < loc_x_finder_42 + 28);
      shift1_en  = (!large_qrcode_flag)? (sram_dat1_x  < loc_x_finder + 14) : (sram_dat1_x  < loc_x_finder_42 + 28);
      shift2_en  = (!large_qrcode_flag)? (sram_dat2_x  < loc_x_finder + 14) : (sram_dat2_x  < loc_x_finder_42 + 28);
      shift3_en  = (!large_qrcode_flag)? (sram_dat3_x  < loc_x_finder + 14) : (sram_dat3_x  < loc_x_finder_42 + 28);
      shift4_en  = (!large_qrcode_flag)? (sram_dat4_x  < loc_x_finder + 14) : (sram_dat4_x  < loc_x_finder_42 + 28);
      shift5_en  = (!large_qrcode_flag)? (sram_dat5_x  < loc_x_finder + 14) : (sram_dat5_x  < loc_x_finder_42 + 28);
      shift6_en  = (!large_qrcode_flag)? (sram_dat6_x  < loc_x_finder + 14) : (sram_dat6_x  < loc_x_finder_42 + 28);
      shift7_en  = (!large_qrcode_flag)? (sram_dat7_x  < loc_x_finder + 14) : (sram_dat7_x  < loc_x_finder_42 + 28);
      shift8_en  = (!large_qrcode_flag)? (sram_dat8_x  < loc_x_finder + 14) : (sram_dat8_x  < loc_x_finder_42 + 28);
      shift9_en  = (!large_qrcode_flag)? (sram_dat9_x  < loc_x_finder + 14) : (sram_dat9_x  < loc_x_finder_42 + 28);
      shift10_en = (!large_qrcode_flag)? (sram_dat10_x < loc_x_finder + 14) : (sram_dat10_x < loc_x_finder_42 + 28);
      shift11_en = (!large_qrcode_flag)? (sram_dat11_x < loc_x_finder + 14) : (sram_dat11_x < loc_x_finder_42 + 28);
      shift12_en = (!large_qrcode_flag)? (sram_dat12_x < loc_x_finder + 14) : (sram_dat12_x < loc_x_finder_42 + 28);
      shift13_en = (!large_qrcode_flag)? (sram_dat13_x < loc_x_finder + 14) : (sram_dat13_x < loc_x_finder_42 + 28);
      shift14_en = (!large_qrcode_flag)? (sram_dat14_x < loc_x_finder + 14) : (sram_dat14_x < loc_x_finder_42 + 28);
      shift15_en = (!large_qrcode_flag)? (sram_dat15_x < loc_x_finder + 14) : (sram_dat15_x < loc_x_finder_42 + 28);
    end
    default: begin
      shift0_en  = 0;
      shift1_en  = 0;
      shift2_en  = 0;
      shift3_en  = 0;
      shift4_en  = 0;
      shift5_en  = 0;
      shift6_en  = 0;
      shift7_en  = 0;
      shift8_en  = 0;
      shift9_en  = 0;
      shift10_en = 0;
      shift11_en = 0;
      shift12_en = 0;
      shift13_en = 0;
      shift14_en = 0;
      shift15_en = 0;
    end

  endcase
end

always @(*) begin
  // here need to add for large qrcode, you can just define the numebr pair as the 
  // note in the data enable part
  case (rot_state)
    ROT_0: begin
      if ((decode_state == DECODE_SWAP2_UP) && shift8_en && large_qrcode_flag) begin
        // large qrcode region2
        line0_dat = demask_data8;
      end else if (shift4_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line0_dat = demask_data4;
      end else begin
        // region1
        line0_dat = demask_data0;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift9_en && large_qrcode_flag) begin
        // large qrcode region2
        line1_dat = demask_data9;
      end else if (shift5_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line1_dat = demask_data5;
      end else begin
        // region1
        line1_dat = demask_data1;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift10_en && large_qrcode_flag) begin
        // large qrcode region2
        line2_dat = demask_data10;
      end else if (shift6_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line2_dat = demask_data6;
      end else begin
        // region1
        line2_dat = demask_data2;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift11_en && large_qrcode_flag) begin
        // large qrcode region2
        line3_dat = demask_data11;
      end else if (shift7_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line3_dat = demask_data7;
      end else begin
        // region1
        line3_dat = demask_data3;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift12_en && large_qrcode_flag) begin
        // large qrcode region2
        line4_dat = demask_data12;
      end else if (shift8_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line4_dat = demask_data8;
      end else begin
        // region1
        line4_dat = demask_data4;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift13_en && large_qrcode_flag) begin
        // large qrcode region2
        line5_dat = demask_data13;
      end else if (shift9_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line5_dat = demask_data9;
      end else begin
        // region1
        line5_dat = demask_data5;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift14_en && large_qrcode_flag) begin
        // large qrcode region2
        line6_dat = demask_data14;
      end else if (shift10_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line6_dat = demask_data10;
      end else begin
        // region1
        line6_dat = demask_data6;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift15_en && large_qrcode_flag) begin
        // large qrcode region2
        line7_dat = demask_data15;
      end else if (shift11_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line7_dat = demask_data11;
      end else begin
        // region1
        line7_dat = demask_data7;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift0_en && large_qrcode_flag) begin
        // large qrcode region2
        line8_dat = demask_data0;
      end else if (shift12_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line8_dat = demask_data12;
      end else begin
        // region1
        line8_dat = demask_data8;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift1_en && large_qrcode_flag) begin
        // large qrcode region2
        line9_dat = demask_data1;
      end else if (shift13_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line9_dat = demask_data13;
      end else begin
        // region1
        line9_dat = demask_data9;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift2_en && large_qrcode_flag) begin
        // large qrcode region2
        line10_dat = demask_data2;
      end else if (shift14_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line10_dat = demask_data14;
      end else begin
        // region1
        line10_dat = demask_data10;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift3_en && large_qrcode_flag) begin
        // large qrcode region2
        line11_dat = demask_data3;
      end else if (shift15_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line11_dat = demask_data15;
      end else begin
        // region1
        line11_dat = demask_data11;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift4_en && large_qrcode_flag) begin
        // large qrcode region2
        line12_dat = demask_data4;
      end else if (shift0_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line12_dat = demask_data0;
      end else begin
        // region1
        line12_dat = demask_data12;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift5_en && large_qrcode_flag) begin
        // large qrcode region2
        line13_dat = demask_data5;
      end else if (shift1_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line13_dat = demask_data1;
      end else begin
        // region1
        line13_dat = demask_data13;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift6_en && large_qrcode_flag) begin
        // large qrcode region2
        line14_dat = demask_data6;
      end else if (shift2_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line14_dat = demask_data2;
      end else begin
        // region1
        line14_dat = demask_data14;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift7_en && large_qrcode_flag) begin
        // large qrcode region2
        line15_dat = demask_data7;
      end else if (shift3_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line15_dat = demask_data3;
      end else begin
        // region1
        line15_dat = demask_data15;
      end

      //line0_dat  = (shift4_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data4  : demask_data0;
      //line1_dat  = (shift5_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data5  : demask_data1;
      //line2_dat  = (shift6_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data6  : demask_data2; 
      //line3_dat  = (shift7_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data7  : demask_data3;
      //line4_dat  = (shift8_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data8  : demask_data4;
      //line5_dat  = (shift9_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data9  : demask_data5;
      //line6_dat  = (shift10_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data10 : demask_data6;
      //line7_dat  = (shift11_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data11 : demask_data7;
      //line8_dat  = (shift12_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data12 : demask_data8;
      //line9_dat  = (shift13_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data13 : demask_data9;
      //line10_dat = (shift14_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data14 : demask_data10;
      //line11_dat = (shift15_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data15 : demask_data11;
      //line12_dat = (shift0_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data0  : demask_data12;
      //line13_dat = (shift1_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data1  : demask_data13;
      //line14_dat = (shift2_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data2  : demask_data14;
      //line15_dat = (shift3_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data3  : demask_data15;
    end
    ROT_90: begin
      if ((decode_state == DECODE_SWAP2_UP) && shift2_en && large_qrcode_flag) begin
        // large qrcode region2
        line0_dat = demask_data2;
      end else if (shift1_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line0_dat = demask_data1;
      end else begin
        // region1
        line0_dat = demask_data0;
      end
//coo
      if ((decode_state == DECODE_SWAP2_UP) && shift3_en && large_qrcode_flag) begin
        // large qrcode region2
        line1_dat = demask_data3;
      end else if (shift2_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line1_dat = demask_data2;
      end else begin
        // region1
        line1_dat = demask_data1;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift0_en && large_qrcode_flag) begin
        // large qrcode region2
        line2_dat = demask_data0;
      end else if (shift3_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line2_dat = demask_data3;
      end else begin
        // region1
        line2_dat = demask_data2;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift1_en && large_qrcode_flag) begin
        // large qrcode region2
        line3_dat = demask_data1;
      end else if (shift0_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line3_dat = demask_data0;
      end else begin
        // region1
        line3_dat = demask_data3;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift6_en && large_qrcode_flag) begin
        // large qrcode region2
        line4_dat = demask_data6;
      end else if (shift5_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line4_dat = demask_data5;
      end else begin
        // region1
        line4_dat = demask_data4;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift7_en && large_qrcode_flag) begin
        // large qrcode region2
        line5_dat = demask_data7;
      end else if (shift6_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line5_dat = demask_data6;
      end else begin
        // region1
        line5_dat = demask_data5;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift4_en && large_qrcode_flag) begin
        // large qrcode region2
        line6_dat = demask_data4;
      end else if (shift7_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line6_dat = demask_data7;
      end else begin
        // region1
        line6_dat = demask_data6;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift5_en && large_qrcode_flag) begin
        // large qrcode region2
        line7_dat = demask_data5;
      end else if (shift4_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line7_dat = demask_data4;
      end else begin
        // region1
        line7_dat = demask_data7;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift10_en && large_qrcode_flag) begin
        // large qrcode region2
        line8_dat = demask_data10;
      end else if (shift9_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line8_dat = demask_data9;
      end else begin
        // region1
        line8_dat = demask_data8;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift11_en && large_qrcode_flag) begin
        // large qrcode region2
        line9_dat = demask_data11;
      end else if (shift10_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line9_dat = demask_data10;
      end else begin
        // region1
        line9_dat = demask_data9;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift8_en && large_qrcode_flag) begin
        // large qrcode region2
        line10_dat = demask_data8;
      end else if (shift11_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line10_dat = demask_data11;
      end else begin
        // region1
        line10_dat = demask_data10;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift9_en && large_qrcode_flag) begin
        // large qrcode region2
        line11_dat = demask_data9;
      end else if (shift8_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line11_dat = demask_data8;
      end else begin
        // region1
        line11_dat = demask_data11;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift14_en && large_qrcode_flag) begin
        // large qrcode region2
        line12_dat = demask_data14;
      end else if (shift13_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line12_dat = demask_data13;
      end else begin
        // region1
        line12_dat = demask_data12;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift15_en && large_qrcode_flag) begin
        // large qrcode region2
        line13_dat = demask_data15;
      end else if (shift14_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line13_dat = demask_data14;
      end else begin
        // region1
        line13_dat = demask_data13;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift12_en && large_qrcode_flag) begin
        // large qrcode region2
        line14_dat = demask_data12;
      end else if (shift15_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line14_dat = demask_data15;
      end else begin
        // region1
        line14_dat = demask_data14;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift13_en && large_qrcode_flag) begin
        // large qrcode region2
        line15_dat = demask_data13;
      end else if (shift12_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line15_dat = demask_data12;
      end else begin
        // region1
        line15_dat = demask_data15;
      end
      // line0_dat  = (shift1_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data1  : demask_data0;
      // line1_dat  = (shift2_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data2  : demask_data1;
      // line2_dat  = (shift3_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data3  : demask_data2;
      // line3_dat  = (shift0_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data0  : demask_data3;
      // line4_dat  = (shift5_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data5  : demask_data4;
      // line5_dat  = (shift6_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data6  : demask_data5;
      // line6_dat  = (shift7_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data7  : demask_data6;
      // line7_dat  = (shift4_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data4  : demask_data7;
      // line8_dat  = (shift9_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data9  : demask_data8;
      // line9_dat  = (shift10_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data10 : demask_data9;
      // line10_dat = (shift11_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data11 : demask_data10;
      // line11_dat = (shift8_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data8  : demask_data11;
      // line12_dat = (shift13_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data13 : demask_data12;
      // line13_dat = (shift14_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data14 : demask_data13;
      // line14_dat = (shift15_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data15 : demask_data14;
      // line15_dat = (shift12_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data12 : demask_data15;
    end
    ROT_180: begin
      if ((decode_state == DECODE_SWAP2_UP) && shift8_en && large_qrcode_flag) begin
        // large qrcode region2
        line0_dat = demask_data8;
      end else if (shift12_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line0_dat = demask_data12;
      end else begin
        // region1
        line0_dat = demask_data0;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift9_en && large_qrcode_flag) begin
        // large qrcode region2
        line1_dat = demask_data9;
      end else if (shift13_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line1_dat = demask_data13;
      end else begin
        // region1
        line1_dat = demask_data1;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift10_en && large_qrcode_flag) begin
        // large qrcode region2
        line2_dat = demask_data10;
      end else if (shift14_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line2_dat = demask_data14;
      end else begin
        // region1
        line2_dat = demask_data2;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift11_en && large_qrcode_flag) begin
        // large qrcode region2
        line3_dat = demask_data11;
      end else if (shift15_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line3_dat = demask_data15;
      end else begin
        // region1
        line3_dat = demask_data3;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift12_en && large_qrcode_flag) begin
        // large qrcode region2
        line4_dat = demask_data12;
      end else if (shift0_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line4_dat = demask_data0;
      end else begin
        // region1
        line4_dat = demask_data4;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift13_en && large_qrcode_flag) begin
        // large qrcode region2
        line5_dat = demask_data13;
      end else if (shift1_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line5_dat = demask_data1;
      end else begin
        // region1
        line5_dat = demask_data5;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift14_en && large_qrcode_flag) begin
        // large qrcode region2
        line6_dat = demask_data14;
      end else if (shift2_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line6_dat = demask_data2;
      end else begin
        // region1
        line6_dat = demask_data6;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift15_en && large_qrcode_flag) begin
        // large qrcode region2
        line7_dat = demask_data15;
      end else if (shift3_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line7_dat = demask_data3;
      end else begin
        // region1
        line7_dat = demask_data7;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift0_en && large_qrcode_flag) begin
        // large qrcode region2
        line8_dat = demask_data0;
      end else if (shift4_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line8_dat = demask_data4;
      end else begin
        // region1
        line8_dat = demask_data8;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift1_en && large_qrcode_flag) begin
        // large qrcode region2
        line9_dat = demask_data1;
      end else if (shift5_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line9_dat = demask_data5;
      end else begin
        // region1
        line9_dat = demask_data9;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift2_en && large_qrcode_flag) begin
        // large qrcode region2
        line10_dat = demask_data2;
      end else if (shift6_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line10_dat = demask_data6;
      end else begin
        // region1
        line10_dat = demask_data10;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift3_en && large_qrcode_flag) begin
        // large qrcode region2
        line11_dat = demask_data3;
      end else if (shift7_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line11_dat = demask_data7;
      end else begin
        // region1
        line11_dat = demask_data11;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift4_en && large_qrcode_flag) begin
        // large qrcode region2
        line12_dat = demask_data4;
      end else if (shift8_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line12_dat = demask_data8;
      end else begin
        // region1
        line12_dat = demask_data12;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift5_en && large_qrcode_flag) begin
        // large qrcode region2
        line13_dat = demask_data5;
      end else if (shift9_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line13_dat = demask_data9;
      end else begin
        // region1
        line13_dat = demask_data13;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift6_en && large_qrcode_flag) begin
        // large qrcode region2
        line14_dat = demask_data6;
      end else if (shift10_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line14_dat = demask_data10;
      end else begin
        // region1
        line14_dat = demask_data14;
      end

      if ((decode_state == DECODE_SWAP2_UP) && shift7_en && large_qrcode_flag) begin
        // large qrcode region2
        line15_dat = demask_data7;
      end else if (shift11_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line15_dat = demask_data11;
      end else begin
        // region1
        line15_dat = demask_data15;
      end
      // line0_dat  = (shift12_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data12 : demask_data0;
      // line1_dat  = (shift13_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data13 : demask_data1;
      // line2_dat  = (shift14_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data14 : demask_data2;
      // line3_dat  = (shift15_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data15 : demask_data3;
      // line4_dat  = (shift0_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data0  : demask_data4;
      // line5_dat  = (shift1_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data1  : demask_data5;
      // line6_dat  = (shift2_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data2  : demask_data6;
      // line7_dat  = (shift3_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data3  : demask_data7;
      // line8_dat  = (shift4_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data4  : demask_data8;
      // line9_dat  = (shift5_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data5  : demask_data9;
      // line10_dat = (shift6_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data6  : demask_data10;
      // line11_dat = (shift7_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data7  : demask_data11;
      // line12_dat = (shift8_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data8  : demask_data12;
      // line13_dat = (shift9_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data9  : demask_data13;
      // line14_dat = (shift10_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data10 : demask_data14;
      // line15_dat = (shift11_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data11 : demask_data15;
    end
    ROT_270: begin
      if ((decode_state == DECODE_SWAP2_UP) && shift2_en && large_qrcode_flag) begin
        // large qrcode region2
        line0_dat = demask_data2;
      end else if (shift3_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line0_dat = demask_data3;
      end else begin
        // region1
        line0_dat = demask_data0;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift3_en && large_qrcode_flag) begin
        // large qrcode region2
        line1_dat = demask_data3;
      end else if (shift0_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line1_dat = demask_data0;
      end else begin
        // region1
        line1_dat = demask_data1;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift0_en && large_qrcode_flag) begin
        // large qrcode region2
        line2_dat = demask_data0;
      end else if (shift1_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line2_dat = demask_data1;
      end else begin
        // region1
        line2_dat = demask_data2;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift1_en && large_qrcode_flag) begin
        // large qrcode region2
        line3_dat = demask_data1;
      end else if (shift2_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line3_dat = demask_data2;
      end else begin
        // region1
        line3_dat = demask_data3;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift6_en && large_qrcode_flag) begin
        // large qrcode region2
        line4_dat = demask_data6;
      end else if (shift7_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line4_dat = demask_data7;
      end else begin
        // region1
        line4_dat = demask_data4;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift7_en && large_qrcode_flag) begin
        // large qrcode region2
        line5_dat = demask_data7;
      end else if (shift4_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line5_dat = demask_data4;
      end else begin
        // region1
        line5_dat = demask_data5;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift4_en && large_qrcode_flag) begin
        // large qrcode region2
        line6_dat = demask_data4;
      end else if (shift5_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line6_dat = demask_data5;
      end else begin
        // region1
        line6_dat = demask_data6;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift5_en && large_qrcode_flag) begin
        // large qrcode region2
        line7_dat = demask_data5;
      end else if (shift6_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line7_dat = demask_data6;
      end else begin
        // region1
        line7_dat = demask_data7;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift10_en && large_qrcode_flag) begin
        // large qrcode region2
        line8_dat = demask_data10;
      end else if (shift11_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line8_dat = demask_data11;
      end else begin
        // region1
        line8_dat = demask_data8;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift11_en && large_qrcode_flag) begin
        // large qrcode region2
        line9_dat = demask_data11;
      end else if (shift8_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line9_dat = demask_data8;
      end else begin
        // region1
        line9_dat = demask_data9;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift8_en && large_qrcode_flag) begin
        // large qrcode region2
        line10_dat = demask_data8;
      end else if (shift9_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line10_dat = demask_data9;
      end else begin
        // region1
        line10_dat = demask_data10;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift9_en && large_qrcode_flag) begin
        // large qrcode region2
        line11_dat = demask_data9;
      end else if (shift10_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line11_dat = demask_data10;
      end else begin
        // region1
        line11_dat = demask_data11;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift14_en && large_qrcode_flag) begin
        // large qrcode region2
        line12_dat = demask_data14;
      end else if (shift15_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line12_dat = demask_data15;
      end else begin
        // region1
        line12_dat = demask_data12;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift15_en && large_qrcode_flag) begin
        // large qrcode region2
        line13_dat = demask_data15;
      end else if (shift12_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line13_dat = demask_data12;
      end else begin
        // region1
        line13_dat = demask_data13;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift12_en && large_qrcode_flag) begin
        // large qrcode region2
        line14_dat = demask_data12;
      end else if (shift13_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line14_dat = demask_data13;
      end else begin
        // region1
        line14_dat = demask_data14;
      end
      if ((decode_state == DECODE_SWAP2_UP) && shift13_en && large_qrcode_flag) begin
        // large qrcode region2
        line15_dat = demask_data13;
      end else if (shift14_en  && (decode_state == DECODE_SWAP2_UP)) begin
        // normal qrcode region2
        line15_dat = demask_data14;
      end else begin
        // region1
        line15_dat = demask_data15;
      end
      // line0_dat  = (shift3_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data3  : demask_data0;
      // line1_dat  = (shift0_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data0  : demask_data1;
      // line2_dat  = (shift1_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data1  : demask_data2;
      // line3_dat  = (shift2_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data2  : demask_data3;
      // line4_dat  = (shift7_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data7  : demask_data4;
      // line5_dat  = (shift4_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data4  : demask_data5;
      //line6_dat  = (shift5_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data5  : demask_data6;
      //line7_dat  = (shift6_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data6  : demask_data7;
      // line8_dat  = (shift11_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data11 : demask_data8;
      // line9_dat  = (shift8_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data8  : demask_data9;
      // line10_dat = (shift9_en  && (decode_state == DECODE_SWAP2_UP)) ? demask_data9  : demask_data10;
      // line11_dat = (shift10_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data10 : demask_data11;
      // line12_dat = (shift15_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data15 : demask_data12;
      // line13_dat = (shift12_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data12 : demask_data13;
      // line14_dat = (shift13_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data13 : demask_data14;
      // line15_dat = (shift14_en && (decode_state == DECODE_SWAP2_UP)) ? demask_data14 : demask_data15;
    end
    default: begin
      line0_dat  = demask_data0;
      line1_dat  = demask_data1;
      line2_dat  = demask_data2;
      line3_dat  = demask_data3;
      line4_dat  = demask_data4;
      line5_dat  = demask_data5;
      line6_dat  = demask_data6;
      line7_dat  = demask_data7;
      line8_dat  = demask_data8;
      line9_dat  = demask_data9;
      line10_dat = demask_data10;
      line11_dat = demask_data11;
      line12_dat = demask_data12;
      line13_dat = demask_data13;
      line14_dat = demask_data14;
      line15_dat = demask_data15;


    end    
  endcase
end
// ----- region 2 decode data ----- //

// ----- check pos and rot----- //
// finder pattern position check, and determine the qrcode direction
always @(*) begin
  check_row11_21 = ~|(row1_21[23:3] ^ qrcode_find1);
  check_row12_21 = ~|(row1_21[22:2] ^ qrcode_find1);
  check_row13_21 = ~|(row1_21[21:1] ^ qrcode_find1);
  check_row14_21 = ~|(row1_21[20:0] ^ qrcode_find1);
  check_row11_21_direction = ~|({row1_21[23:17] ^ qrcode_find1_direction[20:14], // 21'b1000001_xxxxxxx_1000001
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
  // 0000000_xxxxxxx_0000000
  check_row_21_21_zero = ~|({row2_21[23:17] ^ qrcode_find1_7bitzero, 
                                 row2_21[9:3]   ^ qrcode_find1_7bitzero});
  check_row_22_21_zero = ~|({row2_21[22:16] ^ qrcode_find1_7bitzero,
                                 row2_21[8:2]   ^ qrcode_find1_7bitzero});
  check_row_23_21_zero = ~|({row2_21[21:15] ^ qrcode_find1_7bitzero,
                                 row2_21[7:1]   ^ qrcode_find1_7bitzero});
  check_row_24_21_zero = ~|({row2_21[20:14] ^ qrcode_find1_7bitzero,
                                 row2_21[6:0]   ^ qrcode_find1_7bitzero});

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
  check_row_31_21_zero = ~|({row3_21[23:17] ^ qrcode_find1_7bitzero, 
                                 row3_21[9:3]   ^ qrcode_find1_7bitzero});
  check_row_32_21_zero = ~|({row3_21[22:16] ^ qrcode_find1_7bitzero,
                                 row3_21[8:2]   ^ qrcode_find1_7bitzero});
  check_row_33_21_zero = ~|({row3_21[21:15] ^ qrcode_find1_7bitzero,
                                 row3_21[7:1]   ^ qrcode_find1_7bitzero});
  check_row_34_21_zero = ~|({row3_21[20:14] ^ qrcode_find1_7bitzero,
                                 row3_21[6:0]   ^ qrcode_find1_7bitzero});

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


    // ----- 42x42 finder pattern check ----- //
  check_row11_42 = ~|(row1_42[47:6] ^ qrcode_find2);
  check_row12_42 = ~|(row1_42[46:5] ^ qrcode_find2);
  check_row13_42 = ~|(row1_42[45:4] ^ qrcode_find2);
  check_row14_42 = ~|(row1_42[44:3] ^ qrcode_find2);
  check_row11_42_direction = ~|({row1_42[47:34] ^ qrcode_find2_direction[41:28],
                                 row1_42[19:6]  ^ qrcode_find2_direction[13:0]});
  check_row12_42_direction = ~|({row1_42[46:33] ^ qrcode_find2_direction[41:28],
                                 row1_42[18:5]  ^ qrcode_find2_direction[13:0]});
  check_row13_42_direction = ~|({row1_42[45:32] ^ qrcode_find2_direction[41:28],
                                 row1_42[17:4]  ^ qrcode_find2_direction[13:0]});
  check_row14_42_direction = ~|({row1_42[44:31] ^ qrcode_find2_direction[41:28],
                                 row1_42[16:3]  ^ qrcode_find2_direction[13:0]});
  check_row_11_42_zero = ~|({row1_42[47:34] ^ qrcode_find2_14bitzero,
                             row1_42[19:6]  ^ qrcode_find2_14bitzero});
  check_row_12_42_zero = ~|({row1_42[46:33] ^ qrcode_find2_14bitzero,
                             row1_42[18:5]  ^ qrcode_find2_14bitzero});
  check_row_13_42_zero = ~|({row1_42[45:32] ^ qrcode_find2_14bitzero,
                             row1_42[17:4]  ^ qrcode_find2_14bitzero});
  check_row_14_42_zero = ~|({row1_42[44:31] ^ qrcode_find2_14bitzero,
                             row1_42[16:3]  ^ qrcode_find2_14bitzero});

  check_row21_42 = ~|(row2_42[47:6] ^ qrcode_find2);
  check_row22_42 = ~|(row2_42[46:5] ^ qrcode_find2);
  check_row23_42 = ~|(row2_42[45:4] ^ qrcode_find2);
  check_row24_42 = ~|(row2_42[44:3] ^ qrcode_find2);
  check_row21_42_direction = ~|({row2_42[47:34] ^ qrcode_find2_direction[41:28],
                                 row2_42[19:6]  ^ qrcode_find2_direction[13:0]});
  check_row22_42_direction = ~|({row2_42[46:33] ^ qrcode_find2_direction[41:28],
                                 row2_42[18:5]  ^ qrcode_find2_direction[13:0]});
  check_row23_42_direction = ~|({row2_42[45:32] ^ qrcode_find2_direction[41:28],
                                 row2_42[17:4]  ^ qrcode_find2_direction[13:0]});
  check_row24_42_direction = ~|({row2_42[44:31] ^ qrcode_find2_direction[41:28],
                                 row2_42[16:3]  ^ qrcode_find2_direction[13:0]});
  check_row_21_42_zero = ~|({row2_42[47:34] ^ qrcode_find2_14bitzero,
                             row2_42[19:6]  ^ qrcode_find2_14bitzero});
  check_row_22_42_zero = ~|({row2_42[46:33] ^ qrcode_find2_14bitzero,
                             row2_42[18:5]  ^ qrcode_find2_14bitzero});
  check_row_23_42_zero = ~|({row2_42[45:32] ^ qrcode_find2_14bitzero,
                             row2_42[17:4]  ^ qrcode_find2_14bitzero});
  check_row_24_42_zero = ~|({row2_42[44:31] ^ qrcode_find2_14bitzero,
                             row2_42[16:3]  ^ qrcode_find2_14bitzero});

  check_row31_42 = ~|(row3_42[47:6] ^ qrcode_find2);
  check_row32_42 = ~|(row3_42[46:5] ^ qrcode_find2);
  check_row33_42 = ~|(row3_42[45:4] ^ qrcode_find2);
  check_row34_42 = ~|(row3_42[44:3] ^ qrcode_find2);
  check_row31_42_direction = ~|({row3_42[47:34] ^ qrcode_find2_direction[41:28],
                                 row3_42[19:6]  ^ qrcode_find2_direction[13:0]});
  check_row32_42_direction = ~|({row3_42[46:33] ^ qrcode_find2_direction[41:28],
                                 row3_42[18:5]  ^ qrcode_find2_direction[13:0]});
  check_row33_42_direction = ~|({row3_42[45:32] ^ qrcode_find2_direction[41:28],
                                 row3_42[17:4]  ^ qrcode_find2_direction[13:0]});
  check_row34_42_direction = ~|({row3_42[44:31] ^ qrcode_find2_direction[41:28],
                                 row3_42[16:3]  ^ qrcode_find2_direction[13:0]});
  check_row_31_42_zero = ~|({row3_42[47:34] ^ qrcode_find2_14bitzero,
                             row3_42[19:6]  ^ qrcode_find2_14bitzero});
  check_row_32_42_zero = ~|({row3_42[46:33] ^ qrcode_find2_14bitzero,
                             row3_42[18:5]  ^ qrcode_find2_14bitzero});
  check_row_33_42_zero = ~|({row3_42[45:32] ^ qrcode_find2_14bitzero,
                             row3_42[17:4]  ^ qrcode_find2_14bitzero});
  check_row_34_42_zero = ~|({row3_42[44:31] ^ qrcode_find2_14bitzero,
                             row3_42[16:3]  ^ qrcode_find2_14bitzero});

  check_row41_42 = ~|(row4_42[47:6] ^ qrcode_find2);
  check_row42_42 = ~|(row4_42[46:5] ^ qrcode_find2);
  check_row43_42 = ~|(row4_42[45:4] ^ qrcode_find2);
  check_row44_42 = ~|(row4_42[44:3] ^ qrcode_find2);
  check_row41_42_direction = ~|({row4_42[47:34] ^ qrcode_find2_direction[41:28],
                                 row4_42[19:6]  ^ qrcode_find2_direction[13:0]});
  check_row42_42_direction = ~|({row4_42[46:33] ^ qrcode_find2_direction[41:28],
                                 row4_42[18:5]  ^ qrcode_find2_direction[13:0]});
  check_row43_42_direction = ~|({row4_42[45:32] ^ qrcode_find2_direction[41:28],
                                 row4_42[17:4]  ^ qrcode_find2_direction[13:0]});
  check_row44_42_direction = ~|({row4_42[44:31] ^ qrcode_find2_direction[41:28],
                                 row4_42[16:3]  ^ qrcode_find2_direction[13:0]});
  check_row_41_42_zero = ~|({row4_42[47:34] ^ qrcode_find2_14bitzero,
                             row4_42[19:6]  ^ qrcode_find2_14bitzero});
  check_row_42_42_zero = ~|({row4_42[46:33] ^ qrcode_find2_14bitzero,
                             row4_42[18:5]  ^ qrcode_find2_14bitzero});
  check_row_43_42_zero = ~|({row4_42[45:32] ^ qrcode_find2_14bitzero,
                             row4_42[17:4]  ^ qrcode_find2_14bitzero});
  check_row_44_42_zero = ~|({row4_42[44:31] ^ qrcode_find2_14bitzero,
                             row4_42[16:3]  ^ qrcode_find2_14bitzero});

// jump to check rotation
  check = check_row11_21 | check_row12_21 | check_row13_21 | check_row14_21 |
          check_row21_21 | check_row22_21 | check_row23_21 | check_row24_21 | 
          check_row31_21 | check_row32_21 | check_row33_21 | check_row34_21 | 
          check_row41_21 | check_row42_21 | check_row43_21 | check_row44_21;

  check_42 = (check_row11_42 & check_row21_42) | (check_row11_42_direction & check_row21_42 & check_row31_42) |
             (check_row21_42_direction & check_row31_42 & check_row41_42) | (check_row31_42_direction & check_row41_42) | 
             (check_row11_42 & check_row21_42_direction) | (check_row21_42 & check_row31_42_direction) |
             (check_row31_42 & check_row41_42_direction) | (check_row31_42 & check_row41_42 & check_row_21_42_zero) |

             (check_row12_42 & check_row22_42) | (check_row12_42_direction & check_row22_42 & check_row32_42) |
             (check_row22_42_direction & check_row32_42 & check_row42_42) | (check_row32_42_direction & check_row42_42) | 
             (check_row12_42 & check_row22_42_direction) | (check_row22_42 & check_row32_42_direction) |
             (check_row32_42 & check_row42_42_direction) | (check_row32_42 & check_row42_42 & check_row_22_42_zero) |

             (check_row13_42 & check_row23_42) | (check_row13_42_direction & check_row23_42 & check_row33_42) |
             (check_row23_42_direction & check_row33_42 & check_row43_42) | (check_row33_42_direction & check_row43_42) | 
             (check_row13_42 & check_row23_42_direction) | (check_row23_42 & check_row33_42_direction) |
             (check_row33_42 & check_row43_42_direction) | (check_row33_42 & check_row43_42 & check_row_23_42_zero) |

             (check_row14_42 & check_row24_42) | (check_row14_42_direction & check_row24_42 & check_row34_42) |
             (check_row24_42_direction & check_row34_42 & check_row44_42) | (check_row34_42_direction & check_row44_42) | 
             (check_row14_42 & check_row24_42_direction) | (check_row24_42 & check_row34_42_direction) |
             (check_row34_42 & check_row44_42_direction) | (check_row34_42 & check_row44_42 & check_row_24_42_zero);

  // check_42 = check_row11_42 | check_row12_42 | check_row13_42 | check_row14_42 |
  //            check_row21_42 | check_row22_42 | check_row23_42 | check_row24_42 |
  //            check_row31_42 | check_row32_42 | check_row33_42 | check_row34_42 |
  //            check_row41_42 | check_row42_42 | check_row43_42 | check_row44_42;

  down_direction = (check_row_21_21_zero & check_row11_21) | (check_row_22_21_zero & check_row12_21) |
                   (check_row_23_21_zero & check_row13_21) | (check_row_24_21_zero & check_row14_21) |
                   (check_row11_21_direction & check_row21_21) | (check_row12_21_direction & check_row22_21) | 
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
                 (check_row33_21 & check_row43_21_direction) | (check_row34_21 & check_row44_21_direction) |
                 (check_row41_21 & check_row_31_21_zero) | (check_row42_21 & check_row_32_21_zero) |
                 (check_row43_21 & check_row_33_21_zero) | (check_row44_21 & check_row_34_21_zero);

  down_direction_42 = (check_row11_42 & check_row21_42) | (check_row21_42 & check_row11_42_direction) |
                      (check_row31_42 & check_row21_42_direction) | (check_row41_42 & check_row31_42_direction)|
                      (check_row12_42 & check_row22_42) | (check_row22_42 & check_row12_42_direction) |
                      (check_row32_42 & check_row22_42_direction) | (check_row42_42 & check_row32_42_direction)|
                      (check_row13_42 & check_row23_42) | (check_row23_42 & check_row13_42_direction) |
                      (check_row33_42 & check_row23_42_direction) | (check_row43_42 & check_row33_42_direction)|
                      (check_row14_42 & check_row24_42) | (check_row24_42 & check_row14_42_direction) |
                      (check_row34_42 & check_row24_42_direction) | (check_row44_42 & check_row34_42_direction);

  up_direction_42 = (check_row11_42 & check_row21_42_direction) | (check_row21_42 & check_row31_42_direction) |
                    (check_row31_42 & check_row41_42_direction) | (check_row_21_42_zero & check_row31_42 & check_row41_42) |
                    (check_row12_42 & check_row22_42_direction) | (check_row22_42 & check_row32_42_direction) |
                    (check_row32_42 & check_row42_42_direction) | (check_row_22_42_zero & check_row32_42 & check_row42_42) |
                    (check_row13_42 & check_row23_42_direction) | (check_row23_42 & check_row33_42_direction) |
                    (check_row33_42 & check_row43_42_direction) | (check_row_23_42_zero & check_row33_42 & check_row43_42) |
                    (check_row14_42 & check_row24_42_direction) | (check_row24_42 & check_row34_42_direction) |
                    (check_row34_42 & check_row44_42_direction) | (check_row_24_42_zero & check_row34_42 & check_row44_42);
end

// find rotation: check 1011101 pattern position
// find rotation double check: check 1000001 pattern position
// chech the rotation for 21x21 
// check 1011101
reg check_rot13_21;
reg check_rot14_21;
reg check_rot23_21;
reg check_rot24_21;
reg check_rot33_21;
reg check_rot34_21;
reg check_rot43_21;
reg check_rot44_21;

// checl 1000001
reg check_rot11_21_d;
reg check_rot12_21_d;
reg check_rot13_21_d;
reg check_rot14_21_d;
reg check_rot21_21_d;
reg check_rot22_21_d;
reg check_rot23_21_d;
reg check_rot24_21_d;
reg check_rot31_21_d;
reg check_rot32_21_d;
reg check_rot33_21_d;
reg check_rot34_21_d;
reg check_rot41_21_d;
reg check_rot42_21_d;
reg check_rot43_21_d;
reg check_rot44_21_d;

// ----- 42x42 qrcode ----- //
reg check_rot11_42;
reg check_rot12_42;
reg check_rot13_42;
reg check_rot14_42;
reg check_rot21_42;
reg check_rot22_42;
reg check_rot23_42;
reg check_rot24_42;
reg check_rot31_42;
reg check_rot32_42;
reg check_rot33_42;
reg check_rot34_42;
reg check_rot41_42;
reg check_rot42_42;
reg check_rot43_42;
reg check_rot44_42;

reg check_rot11_42_d;
reg check_rot12_42_d;
reg check_rot13_42_d;
reg check_rot14_42_d;
reg check_rot21_42_d;
reg check_rot22_42_d;
reg check_rot23_42_d;
reg check_rot24_42_d;
reg check_rot31_42_d;
reg check_rot32_42_d;
reg check_rot33_42_d;
reg check_rot34_42_d;
reg check_rot41_42_d;
reg check_rot42_42_d;
reg check_rot43_42_d;
reg check_rot44_42_d;

reg check_rot1_42;
reg check_rot2_42;
reg check_rot3_42;
reg check_rot4_42;

reg check_zero1_42;
reg check_zero2_42;
reg check_zero3_42;
reg check_zero4_42;

reg check_rot_col1;
reg check_rot_col2;
reg check_rot_col3;
reg check_rot_col4;

reg check_rot_col1_42;
reg check_rot_col2_42;
reg check_rot_col3_42;
reg check_rot_col4_42;

// remember implement for 42x42 qrcode
always @(*) begin
  check_rot11_21 = ~|(row1_21[6:0] ^ qrcode_find1_rotation); // row1_21 == 1011101
  check_rot12_21 = ~|(row1_21[7:1] ^ qrcode_find1_rotation);
  check_rot13_21 = ~|(row1_21[8:2] ^ qrcode_find1_rotation);
  check_rot14_21 = ~|(row1_21[9:3] ^ qrcode_find1_rotation);
  check_rot11_21_d = ~|(row1_21[6:0] ^ qrcode_find1_rot_double_check); // row1_21 == 1000001
  check_rot12_21_d = ~|(row1_21[7:1] ^ qrcode_find1_rot_double_check);
  check_rot13_21_d = ~|(row1_21[8:2] ^ qrcode_find1_rot_double_check);
  check_rot14_21_d = ~|(row1_21[9:3] ^ qrcode_find1_rot_double_check);
  check_rot1 = check_rot11_21 | check_rot12_21 | check_rot13_21 | check_rot14_21;
  check_zero1_21 = ~|row1_21[23:12]; // check all zero

  check_rot21_21 = ~|(row2_21[6:0] ^ qrcode_find1_rotation);
  check_rot22_21 = ~|(row2_21[7:1] ^ qrcode_find1_rotation);
  check_rot23_21 = ~|(row2_21[8:2] ^ qrcode_find1_rotation);
  check_rot24_21 = ~|(row2_21[9:3] ^ qrcode_find1_rotation);
  check_rot21_21_d = ~|(row2_21[6:0] ^ qrcode_find1_rot_double_check); // row2_21 == 1000001
  check_rot22_21_d = ~|(row2_21[7:1] ^ qrcode_find1_rot_double_check);
  check_rot23_21_d = ~|(row2_21[8:2] ^ qrcode_find1_rot_double_check);
  check_rot24_21_d = ~|(row2_21[9:3] ^ qrcode_find1_rot_double_check);
  check_rot2 = check_rot21_21 | check_rot22_21 | check_rot23_21 |check_rot24_21;
  check_zero2_21 = ~|row2_21[23:12];

  check_rot31_21 = ~|(row3_21[6:0] ^ qrcode_find1_rotation);
  check_rot32_21 = ~|(row3_21[7:1] ^ qrcode_find1_rotation);
  check_rot33_21 = ~|(row3_21[8:2] ^ qrcode_find1_rotation);
  check_rot34_21 = ~|(row3_21[9:3] ^ qrcode_find1_rotation);
  check_rot31_21_d = ~|(row3_21[6:0] ^ qrcode_find1_rot_double_check); // row3_21 == 1000001
  check_rot32_21_d = ~|(row3_21[7:1] ^ qrcode_find1_rot_double_check);
  check_rot33_21_d = ~|(row3_21[8:2] ^ qrcode_find1_rot_double_check);
  check_rot34_21_d = ~|(row3_21[9:3] ^ qrcode_find1_rot_double_check);
  check_rot3 = check_rot31_21 | check_rot32_21 | check_rot33_21 | check_rot34_21;
  check_zero3_21 = ~|row3_21[23:12];

  check_rot41_21 = ~|(row4_21[6:0] ^ qrcode_find1_rotation);
  check_rot42_21 = ~|(row4_21[7:1] ^ qrcode_find1_rotation);
  check_rot43_21 = ~|(row4_21[8:2] ^ qrcode_find1_rotation);
  check_rot44_21 = ~|(row4_21[9:3] ^ qrcode_find1_rotation);
  check_rot41_21_d = ~|(row4_21[6:0] ^ qrcode_find1_rot_double_check); // row4_21 == 1000001
  check_rot42_21_d = ~|(row4_21[7:1] ^ qrcode_find1_rot_double_check);
  check_rot43_21_d = ~|(row4_21[8:2] ^ qrcode_find1_rot_double_check);
  check_rot44_21_d = ~|(row4_21[9:3] ^ qrcode_find1_rot_double_check);
  check_rot4 = check_rot41_21 | check_rot42_21 | check_rot43_21 | check_rot44_21;
  check_zero4_21 = ~|row4_21[23:12];

  check_rot_col1 = (check_rot11_21 & check_rot21_21_d) | (check_rot21_21 & check_rot31_21_d) |
                   (check_rot31_21 & check_rot41_21_d) | (check_rot11_21_d & check_rot21_21) |
                   (check_rot21_21_d & check_rot31_21) | (check_rot31_21_d & check_rot41_21);
  check_rot_col2 = (check_rot12_21 & check_rot22_21_d) | (check_rot22_21 & check_rot32_21_d) |
                   (check_rot32_21 & check_rot42_21_d) | (check_rot12_21_d & check_rot22_21) |
                   (check_rot22_21_d & check_rot32_21) | (check_rot32_21_d & check_rot42_21);
  check_rot_col3 = (check_rot13_21 & check_rot23_21_d) | (check_rot23_21 & check_rot33_21_d) |
                   (check_rot33_21 & check_rot43_21_d) | (check_rot13_21_d & check_rot23_21) |
                   (check_rot23_21_d & check_rot33_21) | (check_rot33_21_d & check_rot43_21);
  check_rot_col4 = (check_rot14_21 & check_rot24_21_d) | (check_rot24_21 & check_rot34_21_d) |
                   (check_rot34_21 & check_rot44_21_d) | (check_rot14_21_d & check_rot24_21) |
                   (check_rot24_21_d & check_rot34_21) | (check_rot34_21_d & check_rot44_21);

    // ----- 42x42 rotation check -----
  check_rot11_42 = ~|(row1_42[13:0] ^ qrcode_find2_rotation);// 1100111_1110011
  check_rot12_42 = ~|(row1_42[14:1] ^ qrcode_find2_rotation);
  check_rot13_42 = ~|(row1_42[15:2] ^ qrcode_find2_rotation);
  check_rot14_42 = ~|(row1_42[16:3] ^ qrcode_find2_rotation);
  check_rot11_42_d = ~|(row1_42[13:0] ^ qrcode_find2_rot_double_check);// 1100000_0000011
  check_rot12_42_d = ~|(row1_42[14:1] ^ qrcode_find2_rot_double_check);
  check_rot13_42_d = ~|(row1_42[15:2] ^ qrcode_find2_rot_double_check);
  check_rot14_42_d = ~|(row1_42[16:3] ^ qrcode_find2_rot_double_check);
  check_rot1_42 = check_rot11_42 | check_rot12_42 | check_rot13_42 | check_rot14_42;
  check_zero1_42 = ~|row1_42[47:20];

  check_rot21_42 = ~|(row2_42[13:0] ^ qrcode_find2_rotation);
  check_rot22_42 = ~|(row2_42[14:1] ^ qrcode_find2_rotation);
  check_rot23_42 = ~|(row2_42[15:2] ^ qrcode_find2_rotation);
  check_rot24_42 = ~|(row2_42[16:3] ^ qrcode_find2_rotation);
  check_rot21_42_d = ~|(row2_42[13:0] ^ qrcode_find2_rot_double_check);
  check_rot22_42_d = ~|(row2_42[14:1] ^ qrcode_find2_rot_double_check);
  check_rot23_42_d = ~|(row2_42[15:2] ^ qrcode_find2_rot_double_check);
  check_rot24_42_d = ~|(row2_42[16:3] ^ qrcode_find2_rot_double_check);
  check_rot2_42 = check_rot21_42 | check_rot22_42 | check_rot23_42 | check_rot24_42;
  check_zero2_42 = ~|row2_42[47:20];

  check_rot31_42 = ~|(row3_42[13:0] ^ qrcode_find2_rotation);
  check_rot32_42 = ~|(row3_42[14:1] ^ qrcode_find2_rotation);
  check_rot33_42 = ~|(row3_42[15:2] ^ qrcode_find2_rotation);
  check_rot34_42 = ~|(row3_42[16:3] ^ qrcode_find2_rotation);
  check_rot31_42_d = ~|(row3_42[13:0] ^ qrcode_find2_rot_double_check);
  check_rot32_42_d = ~|(row3_42[14:1] ^ qrcode_find2_rot_double_check);
  check_rot33_42_d = ~|(row3_42[15:2] ^ qrcode_find2_rot_double_check);
  check_rot34_42_d = ~|(row3_42[16:3] ^ qrcode_find2_rot_double_check);
  check_rot3_42 = check_rot31_42 | check_rot32_42 | check_rot33_42 | check_rot34_42;
  check_zero3_42 = ~|row3_42[47:20];

  check_rot41_42 = ~|(row4_42[13:0] ^ qrcode_find2_rotation);
  check_rot42_42 = ~|(row4_42[14:1] ^ qrcode_find2_rotation);
  check_rot43_42 = ~|(row4_42[15:2] ^ qrcode_find2_rotation);
  check_rot44_42 = ~|(row4_42[16:3] ^ qrcode_find2_rotation);
  check_rot41_42_d = ~|(row4_42[13:0] ^ qrcode_find2_rot_double_check);
  check_rot42_42_d = ~|(row4_42[14:1] ^ qrcode_find2_rot_double_check);
  check_rot43_42_d = ~|(row4_42[15:2] ^ qrcode_find2_rot_double_check);
  check_rot44_42_d = ~|(row4_42[16:3] ^ qrcode_find2_rot_double_check);
  check_rot4_42 = check_rot41_42 | check_rot42_42 | check_rot43_42 | check_rot44_42;
  check_zero4_42 = ~|row4_42[47:20];
// need to add rot_col for 42x42 qrcode

  check_rot_col1_42 = (check_rot11_42 & check_rot21_42 & check_rot31_42 & check_rot41_42) |
                      (check_rot11_42 & check_rot21_42 & check_rot31_42 & check_rot41_42_d) |
                      (check_rot11_42 & check_rot21_42 & check_rot31_42_d & check_rot41_42_d) |
                      (check_rot11_42 & check_rot21_42_d & check_rot31_42_d) | //upper
                      (check_rot11_42 & check_rot21_42 & check_rot31_42 & check_rot41_42) |
                      (check_rot11_42_d & check_rot21_42 & check_rot31_42 & check_rot41_42) |
                      (check_rot11_42_d & check_rot21_42_d & check_rot31_42 & check_rot41_42) | 
                      (check_rot21_42_d & check_rot31_42_d & check_rot41_42);
  
  check_rot_col2_42 = (check_rot12_42 & check_rot22_42 & check_rot32_42 & check_rot42_42) |
                      (check_rot12_42 & check_rot22_42 & check_rot32_42 & check_rot42_42_d) |
                      (check_rot12_42 & check_rot22_42 & check_rot32_42_d & check_rot42_42_d) |
                      (check_rot12_42 & check_rot22_42_d & check_rot32_42_d) | //upper
                      (check_rot12_42 & check_rot22_42 & check_rot32_42 & check_rot42_42) |
                      (check_rot12_42_d & check_rot22_42 & check_rot32_42 & check_rot42_42) |
                      (check_rot12_42_d & check_rot22_42_d & check_rot32_42 & check_rot42_42) |
                      (check_rot22_42_d & check_rot32_42_d & check_rot42_42);

  check_rot_col3_42 = (check_rot13_42 & check_rot23_42 & check_rot33_42 & check_rot43_42) |
                      (check_rot13_42 & check_rot23_42 & check_rot33_42 & check_rot43_42_d) |
                      (check_rot13_42 & check_rot23_42 & check_rot33_42_d & check_rot43_42_d) |
                      (check_rot13_42 & check_rot23_42_d & check_rot33_42_d) | //upper
                      (check_rot13_42 & check_rot23_42 & check_rot33_42 & check_rot43_42) |
                      (check_rot13_42_d & check_rot23_42 & check_rot33_42 & check_rot43_42) |
                      (check_rot13_42_d & check_rot23_42_d & check_rot33_42 & check_rot43_42) |
                      (check_rot23_42_d & check_rot33_42_d & check_rot43_42);
                      
  check_rot_col4_42 = (check_rot14_42 & check_rot24_42 & check_rot34_42 & check_rot44_42) |
                      (check_rot14_42 & check_rot24_42 & check_rot34_42 & check_rot44_42_d) |
                      (check_rot14_42 & check_rot24_42 & check_rot34_42_d & check_rot44_42_d) |
                      (check_rot14_42 & check_rot24_42_d & check_rot34_42_d) | //upper
                      (check_rot14_42 & check_rot24_42 & check_rot34_42 & check_rot44_42) |
                      (check_rot14_42_d & check_rot24_42 & check_rot34_42 & check_rot44_42) |
                      (check_rot14_42_d & check_rot24_42_d & check_rot34_42 & check_rot44_42) |
                      (check_rot24_42_d & check_rot34_42_d & check_rot44_42);
 

  check_rot = (check_rot_col1 | check_rot_col2 | check_rot_col3 | check_rot_col4) && (rot_left | rot_right);

  check_rot42 = (check_rot_col1_42 | check_rot_col2_42 | check_rot_col3_42 | check_rot_col4_42) && (rot_right42 | rot_left42);


  rot_left = (check_rot1 | check_rot2 | check_rot3 | check_rot4) &&
             (check_zero1_21 && check_zero2_21 && check_zero3_21 && check_zero4_21);
  rot_right = (check_rot1 | check_rot2 | check_rot3 | check_rot4) && 
              ((!check_zero1_21) | (!check_zero2_21) | (!check_zero3_21) | (!check_zero4_21));

  rot_left42 = (check_rot1_42 | check_rot2_42 | check_rot3_42 | check_rot4_42) && 
               (check_zero1_42 && check_zero2_42 && check_zero3_42 && check_zero4_42);
  rot_right42 = (check_rot1_42 | check_rot2_42 | check_rot3_42 | check_rot4_42) && 
              ((!check_zero1_42) | (!check_zero2_42) | (!check_zero3_42) | (!check_zero4_42));

end

// ----- 42x42 qrcode flag ----- //

always @(posedge clk) begin
  if (!srst_n) begin
    large_qrcode_flag <= 0;
  end else if (check_rot42 && state == CHECK_42) begin 
    large_qrcode_flag <= 1;
  end else if (state == FIND) begin
    large_qrcode_flag <= 0;
  end else begin
    large_qrcode_flag <= large_qrcode_flag;
  end
end

// find the finder pattern position to find locx locy
reg [3:0] pos_x_onehot_42;
reg [3:0] pos_y_onehot_42; 
reg [1:0] pos_x_binary_42;
reg [1:0] pos_y_binary_42;
always @(*) begin
  pos_x_onehot[0] = check_row11_21 | check_row21_21 | check_row31_21 | check_row41_21;
  pos_x_onehot[1] = check_row12_21 | check_row22_21 | check_row32_21 | check_row42_21;
  pos_x_onehot[2] = check_row13_21 | check_row23_21 | check_row33_21 | check_row43_21;
  pos_x_onehot[3] = check_row14_21 | check_row24_21 | check_row34_21 | check_row44_21;

  pos_y_onehot[0] = check_row11_21 | check_row12_21 | check_row13_21 | check_row14_21;
  pos_y_onehot[1] = check_row21_21 | check_row22_21 | check_row23_21 | check_row24_21;
  pos_y_onehot[2] = check_row31_21 | check_row32_21 | check_row33_21 | check_row34_21;
  pos_y_onehot[3] = check_row41_21 | check_row42_21 | check_row43_21 | check_row44_21;

  pos_x_onehot_42[0] = (check_row11_42 & check_row21_42 & check_row_31_42_zero)|
                       (check_row11_42 & check_row21_42_direction)|
                       (check_row11_42_direction & check_row21_42 & check_row31_42) |
                       (check_row11_42 & check_row21_42 & check_row31_42_direction) |
                       (check_row21_42_direction & check_row31_42 & check_row41_42) |
                       (check_row21_42 & check_row31_42 & check_row41_42_direction) |
                       (check_row31_42_direction & check_row41_42) |
                       (check_row_21_42_zero & check_row31_42 & check_row41_42);
  
  pos_x_onehot_42[1] = (check_row12_42 & check_row22_42 & check_row_32_42_zero)|
                       (check_row12_42 & check_row22_42_direction)|
                       (check_row12_42_direction & check_row22_42 & check_row32_42) |
                       (check_row12_42 & check_row22_42 & check_row32_42_direction) |
                       (check_row22_42_direction & check_row32_42 & check_row42_42) |
                       (check_row22_42 & check_row32_42 & check_row42_42_direction) |
                       (check_row32_42_direction & check_row42_42) |
                       (check_row_22_42_zero & check_row32_42 & check_row42_42);

  pos_x_onehot_42[2] = (check_row13_42 & check_row23_42 & check_row_33_42_zero)|
                       (check_row13_42 & check_row23_42_direction)|
                       (check_row13_42_direction & check_row23_42 & check_row33_42) |
                       (check_row13_42 & check_row23_42 & check_row33_42_direction) |
                       (check_row23_42_direction & check_row33_42 & check_row43_42) |
                       (check_row23_42 & check_row33_42 & check_row43_42_direction) |
                       (check_row33_42_direction & check_row43_42) |
                       (check_row_23_42_zero & check_row33_42 & check_row43_42);

  pos_x_onehot_42[3] = (check_row14_42 & check_row24_42 & check_row_34_42_zero)|
                       (check_row14_42 & check_row24_42_direction) |
                       (check_row14_42_direction & check_row24_42 & check_row34_42) |
                       (check_row14_42 & check_row24_42 & check_row34_42_direction) |
                       (check_row24_42_direction & check_row34_42 & check_row44_42) |
                       (check_row24_42 & check_row34_42 & check_row44_42_direction) |
                       (check_row34_42_direction & check_row44_42) |
                       (check_row_24_42_zero & check_row34_42 & check_row44_42);

  pos_y_onehot_42[0] = (check_row11_42 & check_row21_42 & check_row_31_42_zero)|
                       (check_row11_42 & check_row21_42_direction)|
                       (check_row12_42 & check_row22_42 & check_row_32_42_zero)|
                       (check_row12_42 & check_row22_42_direction)|
                       (check_row13_42 & check_row23_42 & check_row_33_42_zero)|
                       (check_row13_42 & check_row23_42_direction)|
                       (check_row14_42 & check_row24_42 & check_row_34_42_zero)|
                       (check_row14_42 & check_row24_42_direction);

  pos_y_onehot_42[1] = (check_row11_42_direction & check_row21_42 & check_row31_42) |
                        (check_row11_42 & check_row21_42 & check_row31_42_direction) |
                        (check_row12_42_direction & check_row22_42 & check_row32_42) |
                        (check_row12_42 & check_row22_42 & check_row32_42_direction) |
                        (check_row13_42_direction & check_row23_42 & check_row33_42) |
                        (check_row13_42 & check_row23_42 & check_row33_42_direction) |
                        (check_row14_42_direction & check_row24_42 & check_row34_42) |
                        (check_row14_42 & check_row24_42 & check_row34_42_direction);

  pos_y_onehot_42[2] = (check_row21_42_direction & check_row31_42 & check_row41_42) |
                       (check_row21_42 & check_row31_42 & check_row41_42_direction) |
                       (check_row22_42_direction & check_row32_42 & check_row42_42) |
                       (check_row22_42 & check_row32_42 & check_row42_42_direction) |
                       (check_row23_42_direction & check_row33_42 & check_row43_42) |
                       (check_row23_42 & check_row33_42 & check_row43_42_direction) |
                       (check_row24_42_direction & check_row34_42 & check_row44_42) |
                       (check_row24_42 & check_row34_42 & check_row44_42_direction);

  pos_y_onehot_42[3] = (check_row31_42_direction & check_row41_42) |
                       (check_row_21_42_zero & check_row31_42 & check_row41_42) | 
                       (check_row32_42_direction & check_row42_42) |
                       (check_row_22_42_zero & check_row32_42 & check_row42_42) | 
                       (check_row33_42_direction & check_row43_42) |
                       (check_row_23_42_zero & check_row33_42 & check_row43_42) | 
                       (check_row34_42_direction & check_row44_42) |
                       (check_row_24_42_zero & check_row34_42 & check_row44_42);

  // onehot to binary
  pos_x_binary[1] = pos_x_onehot[2] | pos_x_onehot[3];
  pos_x_binary[0] = pos_x_onehot[1] | pos_x_onehot[3];
  pos_y_binary[1] = pos_y_onehot[2] | pos_y_onehot[3];
  pos_y_binary[0] = pos_y_onehot[1] | pos_y_onehot[3];

  pos_x_binary_42[1] = pos_x_onehot_42[2] | pos_x_onehot_42[3];
  pos_x_binary_42[0] = pos_x_onehot_42[1] | pos_x_onehot_42[3];
  pos_y_binary_42[1] = pos_y_onehot_42[2] | pos_y_onehot_42[3];
  pos_y_binary_42[0] = pos_y_onehot_42[1] | pos_y_onehot_42[3];
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
  end else if (check_42) begin
    pos_x_binary_reg <= pos_x_binary_42;
    pos_y_binary_reg <= pos_y_binary_42;
  end
end

reg [9:0]addr_finder_42;


reg [6:0]loc_x_rot0_42;
reg [6:0]loc_x_rot90_42;
reg [6:0]loc_x_rot180_42;
reg [6:0]loc_x_rot270_42;

reg [6:0]loc_y_rot0_42;
reg [6:0]loc_y_rot90_42;
reg [6:0]loc_y_rot180_42;
reg [6:0]loc_y_rot270_42;

always @(*) begin
  // need to fix for 42x42 qrcode
  addr_finder = addr_pointer - 5;
  addr_finder_42 = addr_pointer - 11; // some condition may need to - 10, fix latter

  loc_x_finder = {3'b0, addr_finder[4:0], 2'b0} + pos_x_binary_reg;
  loc_y_finder = {3'b0, addr_finder[9:5], 2'b0} + pos_y_binary_reg;
  loc_x_finder_42 = {3'b0, addr_finder_42[4:0], 2'b0} + pos_x_binary_reg;
  loc_y_finder_42 = {3'b0, addr_finder_42[9:5], 2'b0} + pos_y_binary_reg;

  loc_x_rot0 = loc_x_finder;
  loc_y_rot0 = loc_y_finder - 6;

  loc_x_rot0_42 = loc_x_finder_42;
  loc_y_rot0_42 = loc_y_finder_42 - 12;

  loc_x_rot90 = loc_x_finder;
  loc_y_rot90 = loc_y_finder + 6;

  loc_x_rot90_42 = loc_x_finder_42;
  loc_y_rot90_42 = loc_y_finder_42 + 12;

  loc_x_rot180 = loc_x_finder + 20;
  loc_y_rot180 = loc_y_finder + 6;

  loc_x_rot180_42 = loc_x_finder_42 + 41;
  loc_y_rot180_42 = loc_y_finder_42 + 12;

  loc_x_rot270 = loc_x_finder + 20;
  loc_y_rot270 = loc_y_finder - 6;

  loc_x_rot270_42 = loc_x_finder_42 + 41;
  loc_y_rot270_42 = loc_y_finder_42 - 12;

  case (rot_state_n)
  ROT_0: begin
    loc_x_n = (state == CHECK)? loc_x_rot0 : loc_x_rot0_42;
    loc_y_n = (state == CHECK)? loc_y_rot0 : loc_y_rot0_42;
  end 
  ROT_90: begin
    loc_x_n = (state == CHECK)? loc_x_rot90 : loc_x_rot90_42;
    loc_y_n = (state == CHECK)? loc_y_rot90 : loc_y_rot90_42;
  end
  ROT_180: begin
    loc_x_n = (state == CHECK)? loc_x_rot180 : loc_x_rot180_42;
    loc_y_n = (state == CHECK)? loc_y_rot180 : loc_y_rot180_42;
  end // 調整finish機制
  ROT_270: begin
    loc_x_n = (state == CHECK)? loc_x_rot270 : loc_x_rot270_42;
    loc_y_n = (state == CHECK)? loc_y_rot270 : loc_y_rot270_42;
  end
  default: begin
    loc_x_n = 0;
    loc_y_n = 0;
  end
  endcase
end

always @(posedge clk) begin
  if ((check_rot && state == CHECK) | (check_rot42 && state == CHECK_42)) begin
    loc_x <= loc_x_n;
    loc_y <= loc_y_n;
  end
end

// ===== find position and rotation ===== //

// ===== mask ===== //
// load the mask id 
reg [3:0]mask_inblock_addr1;
reg [3:0]mask_inblock_addr2;
reg [3:0]mask_inblock_addr3;
// step1: load mask block
always @(*) begin
  case (rot_state) // bit address
  ROT_0: begin
    loc_x_mask_start = (!large_qrcode_flag)? loc_x + 2: loc_x + 5;
    loc_y_mask_start = (!large_qrcode_flag)? loc_y + 8: loc_y + 16;
    loc_x_mask_end   = (!large_qrcode_flag)? loc_x + 4: loc_x + 8;
    loc_y_mask_end   = (!large_qrcode_flag)? loc_y + 8: loc_y + 16;
  end 
  ROT_90: begin
    loc_x_mask_start = (!large_qrcode_flag)? loc_x + 8: loc_x + 16;
    loc_y_mask_start = (!large_qrcode_flag)? loc_y - 2: loc_y - 5;
    loc_x_mask_end   = (!large_qrcode_flag)? loc_x + 8: loc_x + 16;
    loc_y_mask_end   = (!large_qrcode_flag)? loc_y - 4: loc_y - 8;
  end
  ROT_180: begin
    loc_x_mask_start = (!large_qrcode_flag)? loc_x - 2: loc_x - 5;
    loc_y_mask_start = (!large_qrcode_flag)? loc_y - 8: loc_y - 16;
    loc_x_mask_end   = (!large_qrcode_flag)? loc_x - 4: loc_x - 8;
    loc_y_mask_end   = (!large_qrcode_flag)? loc_y - 8: loc_y - 16;
  end
  ROT_270: begin
    loc_x_mask_start = (!large_qrcode_flag)? loc_x - 8: loc_x - 16;
    loc_y_mask_start = (!large_qrcode_flag)? loc_y + 2: loc_y + 5;
    loc_x_mask_end   = (!large_qrcode_flag)? loc_x - 8: loc_x - 16;
    loc_y_mask_end   = (!large_qrcode_flag)? loc_y + 4: loc_y + 8;
  end
  default: begin
    loc_x_mask_start = 0;
    loc_x_mask_end   = 0;
    loc_y_mask_start = 0;
    loc_y_mask_end   = 0;
  end
  endcase

  // translate bit address to sram block address
  loc_x_mask_block_addr_start = loc_x_mask_start[6:2];
  loc_x_mask_block_addr_end   = loc_x_mask_end[6:2];
  loc_y_mask_block_addr_start = loc_y_mask_start[6:2];
  loc_y_mask_block_addr_end   = loc_y_mask_end[6:2];
  // inblock addr
  loc_x_mask_inblock_addr_start = loc_x_mask_start[1:0];
  loc_x_mask_inblock_addr_end   = loc_x_mask_end[1:0];
  loc_y_mask_inblock_addr_start = loc_y_mask_start[1:0];
  loc_y_mask_inblock_addr_end   = loc_y_mask_end[1:0];

  mask_block1_addr = {loc_y_mask_block_addr_start, loc_x_mask_block_addr_start};
  mask_block2_addr = {loc_y_mask_block_addr_end, loc_x_mask_block_addr_end};
  
  mask_2cyc = | (mask_block1_addr ^ mask_block2_addr); 
  // if euqal than false, only need one cycle
end

reg [2:0]mask_id;
reg [2:0]mask_id_n1;
reg [2:0]mask_id_n2;
reg [3:0]row_sel;
reg [3:0]col_sel;
// for rot0 or rot 180
always @(*) begin
  case (loc_y_mask_inblock_addr_start)
    0: row_sel = {sram_rdata[0] , sram_rdata[1] , sram_rdata[2] , sram_rdata[3]};
    1: row_sel = {sram_rdata[4] , sram_rdata[5] , sram_rdata[6] , sram_rdata[7]};
    2: row_sel = {sram_rdata[8] , sram_rdata[9] , sram_rdata[10], sram_rdata[11]};
    3: row_sel = {sram_rdata[12], sram_rdata[13], sram_rdata[14], sram_rdata[15]};
  endcase
end
// for rot90 or rot 270
always @(*) begin
  case (loc_x_mask_inblock_addr_start)
    0: col_sel = {sram_rdata[12], sram_rdata[8] , sram_rdata[4], sram_rdata[0]};
    1: col_sel = {sram_rdata[13], sram_rdata[9] , sram_rdata[5], sram_rdata[1]};
    2: col_sel = {sram_rdata[14], sram_rdata[10], sram_rdata[6], sram_rdata[2]};
    3: col_sel = {sram_rdata[15], sram_rdata[11], sram_rdata[7], sram_rdata[3]};
  endcase
end

always @(*) begin
  case (rot_state)
    ROT_0: begin
      case (loc_x_mask_inblock_addr_start)
      0: begin // all mask in same block
        mask_id_n1 = (!large_qrcode_flag)? row_sel[3:1]: {row_sel[3], row_sel[2], row_sel[0]};
        mask_id_n2 = (!large_qrcode_flag)? mask_id: mask_id;
      end
      1: begin // all mask in same block
        mask_id_n1 = (!large_qrcode_flag)? row_sel[2:0]: {row_sel[2], row_sel[1], 1'b0}; 
        mask_id_n2 = (!large_qrcode_flag)? mask_id: {mask_id[2], mask_id[1], row_sel[3]};
      end
      2: begin // mask in diff block
        mask_id_n1 = (!large_qrcode_flag)? {row_sel[1:0], 1'b0}: {row_sel[1], row_sel[0], 1'b0};
        mask_id_n2 = (!large_qrcode_flag)? {mask_id[2:1], row_sel[3]}: {mask_id[2], mask_id[1], row_sel[2]};
      end
      3: begin // mask in diff block
        mask_id_n1 = (!large_qrcode_flag)? {row_sel[0], 2'b0}: {row_sel[0], 2'b0};
        mask_id_n2 = (!large_qrcode_flag)? {mask_id[2], row_sel[3:2]}: {mask_id[2], row_sel[2], row_sel[1]};
      end 
      endcase
    end
    ROT_90: begin
      case (loc_y_mask_inblock_addr_start)
      0: begin
        mask_id_n1 = (!large_qrcode_flag)? {col_sel[0], 2'b0}: {col_sel[0], 2'b0};
        mask_id_n2 = (!large_qrcode_flag)? {mask_id[2], col_sel[3:2]}: {mask_id[2], col_sel[2], col_sel[1]};
      end
      1: begin
        mask_id_n1 = (!large_qrcode_flag)? {col_sel[1:0], 1'b0}: {col_sel[1], col_sel[0], 1'b0};
        mask_id_n2 = (!large_qrcode_flag)? {mask_id[2:1], col_sel[3]}: {mask_id[2], mask_id[1], col_sel[2]};
      end
      2: begin
        mask_id_n1 = (!large_qrcode_flag)? col_sel[2:0]: {col_sel[2], col_sel[1], 1'b0};
        mask_id_n2 = (!large_qrcode_flag)? mask_id: {mask_id[2], mask_id[1], col_sel[3]};
      end
      3: begin
        mask_id_n1 = (!large_qrcode_flag)? col_sel[3:1]: {col_sel[3], col_sel[2], col_sel[0]};
        mask_id_n2 = (!large_qrcode_flag)? mask_id: mask_id;
      end
      endcase
    end
    ROT_180: begin
      case (loc_x_mask_inblock_addr_start) 
      0: begin
        mask_id_n1 = (!large_qrcode_flag)? {row_sel[3], 2'b0}: {row_sel[3], 2'b0};
        mask_id_n2 = (!large_qrcode_flag)? {mask_id[2], row_sel[0], row_sel[1]}: {mask_id[2], row_sel[1], row_sel[2]};
      end
      1: begin
        mask_id_n1 = (!large_qrcode_flag)? {row_sel[2], row_sel[3], 1'b0}: {row_sel[2], row_sel[3], 1'b0};
        mask_id_n2 = (!large_qrcode_flag)? {mask_id[2], mask_id[1], row_sel[0]}: {mask_id[2], mask_id[1], row_sel[1]};
      end
      2: begin
        mask_id_n1 = (!large_qrcode_flag)? {row_sel[1], row_sel[2], row_sel[3]}: {row_sel[1], row_sel[2], 1'b0};
        mask_id_n2 = (!large_qrcode_flag)? mask_id: {mask_id[2], mask_id[1], row_sel[0]};
      end
      3: begin
        mask_id_n1 = (!large_qrcode_flag)? {row_sel[0], row_sel[1], row_sel[2]}: {row_sel[0], row_sel[1], row_sel[3]};
        mask_id_n2 = (!large_qrcode_flag)? mask_id: mask_id;
      end
      endcase
    end
    ROT_270: begin
      case (loc_y_mask_inblock_addr_start)
      0: begin
        mask_id_n1 = (!large_qrcode_flag)? {col_sel[0], col_sel[1], col_sel[2]}: {col_sel[0], col_sel[1], col_sel[3]};
        mask_id_n2 = (!large_qrcode_flag)? mask_id: mask_id;
      end
      1: begin
        mask_id_n1 = (!large_qrcode_flag)? {col_sel[1], col_sel[2], col_sel[3]}: {col_sel[1], col_sel[2], 1'b0};
        mask_id_n2 = (!large_qrcode_flag)? mask_id: {mask_id[2], mask_id[1], col_sel[0]};
      end
      2: begin
        mask_id_n1 = (!large_qrcode_flag)? {col_sel[2], col_sel[3], 1'b0}: {col_sel[2], col_sel[3], 1'b0};
        mask_id_n2 = (!large_qrcode_flag)? {mask_id[2:1], col_sel[0]}: {mask_id[2], mask_id[1], col_sel[1]};
      end
      3: begin
        mask_id_n1 = (!large_qrcode_flag)? {col_sel[3], 2'b0}: {col_sel[3], 2'b0};
        mask_id_n2 = (!large_qrcode_flag)? {mask_id[2], col_sel[0], col_sel[1]}: {mask_id[2], col_sel[1], col_sel[2]};
      end
      endcase
    end
    default: begin
      mask_id_n1 = 0;
      mask_id_n2 = 0;
    end  
  endcase

  mask_done = (~|(sram_raddr ^ mask_block2_addr))? 1:0;
end


always @(posedge clk) begin
  if (~|(sram_raddr ^ mask_block1_addr) && (state == DECODE | state == MASK2)) begin
    mask_id <= mask_id_n1;
  end else if (~|(sram_raddr ^ mask_block2_addr) && (state == DECODE)) begin
    mask_id <= mask_id_n2;
  end
end

wire [2:0] real_mask_id;
assign real_mask_id = mask_id ^ 3'b101;
// ===== mask ===== //

// ===== demask ===== //

// rotation: 2'b00 = 0°, 2'b01 = 90° (CW), 2'b10 = 180°, 2'b11 = 270° (CW)
localparam N = 21;
// rotation: 2'b00 = 0°, 2'b01 = 90° CW, 2'b10 = 180°, 2'b11 = 270° CW
always @* begin
  case (rot_state)
    // 0° : i = y - loc_y ; j = x - loc_x
    ROT_0: begin
      i0_sym  = sram_dat0_y  - loc_y;  j0_sym  = sram_dat0_x  - loc_x;
      i1_sym  = sram_dat1_y  - loc_y;  j1_sym  = sram_dat1_x  - loc_x;
      i2_sym  = sram_dat2_y  - loc_y;  j2_sym  = sram_dat2_x  - loc_x;
      i3_sym  = sram_dat3_y  - loc_y;  j3_sym  = sram_dat3_x  - loc_x;
      i4_sym  = sram_dat4_y  - loc_y;  j4_sym  = sram_dat4_x  - loc_x;
      i5_sym  = sram_dat5_y  - loc_y;  j5_sym  = sram_dat5_x  - loc_x;
      i6_sym  = sram_dat6_y  - loc_y;  j6_sym  = sram_dat6_x  - loc_x;
      i7_sym  = sram_dat7_y  - loc_y;  j7_sym  = sram_dat7_x  - loc_x;
      i8_sym  = sram_dat8_y  - loc_y;  j8_sym  = sram_dat8_x  - loc_x;
      i9_sym  = sram_dat9_y  - loc_y;  j9_sym  = sram_dat9_x  - loc_x;
      i10_sym = sram_dat10_y - loc_y;  j10_sym = sram_dat10_x - loc_x;
      i11_sym = sram_dat11_y - loc_y;  j11_sym = sram_dat11_x - loc_x;
      i12_sym = sram_dat12_y - loc_y;  j12_sym = sram_dat12_x - loc_x;
      i13_sym = sram_dat13_y - loc_y;  j13_sym = sram_dat13_x - loc_x;
      i14_sym = sram_dat14_y - loc_y;  j14_sym = sram_dat14_x - loc_x;
      i15_sym = sram_dat15_y - loc_y;  j15_sym = sram_dat15_x - loc_x;
    end

    // 90° CW : i = x - loc_x ; j = loc_y - y
    ROT_90: begin
      i0_sym  = sram_dat0_x  - loc_x;  j0_sym  = loc_y - sram_dat0_y;
      i1_sym  = sram_dat1_x  - loc_x;  j1_sym  = loc_y - sram_dat1_y;
      i2_sym  = sram_dat2_x  - loc_x;  j2_sym  = loc_y - sram_dat2_y;
      i3_sym  = sram_dat3_x  - loc_x;  j3_sym  = loc_y - sram_dat3_y;
      i4_sym  = sram_dat4_x  - loc_x;  j4_sym  = loc_y - sram_dat4_y;
      i5_sym  = sram_dat5_x  - loc_x;  j5_sym  = loc_y - sram_dat5_y;
      i6_sym  = sram_dat6_x  - loc_x;  j6_sym  = loc_y - sram_dat6_y;
      i7_sym  = sram_dat7_x  - loc_x;  j7_sym  = loc_y - sram_dat7_y;
      i8_sym  = sram_dat8_x  - loc_x;  j8_sym  = loc_y - sram_dat8_y;
      i9_sym  = sram_dat9_x  - loc_x;  j9_sym  = loc_y - sram_dat9_y;
      i10_sym = sram_dat10_x - loc_x;  j10_sym = loc_y - sram_dat10_y;
      i11_sym = sram_dat11_x - loc_x;  j11_sym = loc_y - sram_dat11_y;
      i12_sym = sram_dat12_x - loc_x;  j12_sym = loc_y - sram_dat12_y;
      i13_sym = sram_dat13_x - loc_x;  j13_sym = loc_y - sram_dat13_y;
      i14_sym = sram_dat14_x - loc_x;  j14_sym = loc_y - sram_dat14_y;
      i15_sym = sram_dat15_x - loc_x;  j15_sym = loc_y - sram_dat15_y;
    end

    // 180° : i = loc_y - y ; j = loc_x - x
    ROT_180: begin
      i0_sym  = loc_y - sram_dat0_y;   j0_sym  = loc_x - sram_dat0_x;
      i1_sym  = loc_y - sram_dat1_y;   j1_sym  = loc_x - sram_dat1_x;
      i2_sym  = loc_y - sram_dat2_y;   j2_sym  = loc_x - sram_dat2_x;
      i3_sym  = loc_y - sram_dat3_y;   j3_sym  = loc_x - sram_dat3_x;
      i4_sym  = loc_y - sram_dat4_y;   j4_sym  = loc_x - sram_dat4_x;
      i5_sym  = loc_y - sram_dat5_y;   j5_sym  = loc_x - sram_dat5_x;
      i6_sym  = loc_y - sram_dat6_y;   j6_sym  = loc_x - sram_dat6_x;
      i7_sym  = loc_y - sram_dat7_y;   j7_sym  = loc_x - sram_dat7_x;
      i8_sym  = loc_y - sram_dat8_y;   j8_sym  = loc_x - sram_dat8_x;
      i9_sym  = loc_y - sram_dat9_y;   j9_sym  = loc_x - sram_dat9_x;
      i10_sym = loc_y - sram_dat10_y;  j10_sym = loc_x - sram_dat10_x;
      i11_sym = loc_y - sram_dat11_y;  j11_sym = loc_x - sram_dat11_x;
      i12_sym = loc_y - sram_dat12_y;  j12_sym = loc_x - sram_dat12_x;
      i13_sym = loc_y - sram_dat13_y;  j13_sym = loc_x - sram_dat13_x;
      i14_sym = loc_y - sram_dat14_y;  j14_sym = loc_x - sram_dat14_x;
      i15_sym = loc_y - sram_dat15_y;  j15_sym = loc_x - sram_dat15_x;
    end

    // 270° CW : i = loc_x - x ; j = y - loc_y
    ROT_270: begin
      i0_sym  = loc_x - sram_dat0_x;   j0_sym  = sram_dat0_y  - loc_y;
      i1_sym  = loc_x - sram_dat1_x;   j1_sym  = sram_dat1_y  - loc_y;
      i2_sym  = loc_x - sram_dat2_x;   j2_sym  = sram_dat2_y  - loc_y;
      i3_sym  = loc_x - sram_dat3_x;   j3_sym  = sram_dat3_y  - loc_y;
      i4_sym  = loc_x - sram_dat4_x;   j4_sym  = sram_dat4_y  - loc_y;
      i5_sym  = loc_x - sram_dat5_x;   j5_sym  = sram_dat5_y  - loc_y;
      i6_sym  = loc_x - sram_dat6_x;   j6_sym  = sram_dat6_y  - loc_y;
      i7_sym  = loc_x - sram_dat7_x;   j7_sym  = sram_dat7_y  - loc_y;
      i8_sym  = loc_x - sram_dat8_x;   j8_sym  = sram_dat8_y  - loc_y;
      i9_sym  = loc_x - sram_dat9_x;   j9_sym  = sram_dat9_y  - loc_y;
      i10_sym = loc_x - sram_dat10_x;  j10_sym = sram_dat10_y - loc_y;
      i11_sym = loc_x - sram_dat11_x;  j11_sym = sram_dat11_y - loc_y;
      i12_sym = loc_x - sram_dat12_x;  j12_sym = sram_dat12_y - loc_y;
      i13_sym = loc_x - sram_dat13_x;  j13_sym = sram_dat13_y - loc_y;
      i14_sym = loc_x - sram_dat14_x;  j14_sym = sram_dat14_y - loc_y;
      i15_sym = loc_x - sram_dat15_x;  j15_sym = sram_dat15_y - loc_y;
    end

    default: begin
      i0_sym  = 7'd0; j0_sym  = 7'd0;
      i1_sym  = 7'd0; j1_sym  = 7'd0;
      i2_sym  = 7'd0; j2_sym  = 7'd0;
      i3_sym  = 7'd0; j3_sym  = 7'd0;
      i4_sym  = 7'd0; j4_sym  = 7'd0;
      i5_sym  = 7'd0; j5_sym  = 7'd0;
      i6_sym  = 7'd0; j6_sym  = 7'd0;
      i7_sym  = 7'd0; j7_sym  = 7'd0;
      i8_sym  = 7'd0; j8_sym  = 7'd0;
      i9_sym  = 7'd0; j9_sym  = 7'd0;
      i10_sym = 7'd0; j10_sym = 7'd0;
      i11_sym = 7'd0; j11_sym = 7'd0;
      i12_sym = 7'd0; j12_sym = 7'd0;
      i13_sym = 7'd0; j13_sym = 7'd0;
      i14_sym = 7'd0; j14_sym = 7'd0;
      i15_sym = 7'd0; j15_sym = 7'd0;
    end
  endcase
end

assign p0  = i0_mask  * j0_mask;
assign p1  = i1_mask  * j1_mask;
assign p2  = i2_mask  * j2_mask;
assign p3  = i3_mask  * j3_mask;
assign p4  = i4_mask  * j4_mask;
assign p5  = i5_mask  * j5_mask;
assign p6  = i6_mask  * j6_mask;
assign p7  = i7_mask  * j7_mask;
assign p8  = i8_mask  * j8_mask;
assign p9  = i9_mask  * j9_mask;
assign p10 = i10_mask * j10_mask;
assign p11 = i11_mask * j11_mask;
assign p12 = i12_mask * j12_mask;
assign p13 = i13_mask * j13_mask;
assign p14 = i14_mask * j14_mask;
assign p15 = i15_mask * j15_mask;

assign p0m3  = p0  % 3;
assign p1m3  = p1  % 3;
assign p2m3  = p2  % 3;
assign p3m3  = p3  % 3;
assign p4m3  = p4  % 3;
assign p5m3  = p5  % 3;
assign p6m3  = p6  % 3;
assign p7m3  = p7  % 3;
assign p8m3  = p8  % 3;
assign p9m3  = p9  % 3;
assign p10m3 = p10 % 3;
assign p11m3 = p11 % 3;
assign p12m3 = p12 % 3;
assign p13m3 = p13 % 3;
assign p14m3 = p14 % 3;
assign p15m3 = p15 % 3;



// didnt consider rotation yet
always @* begin
  case (real_mask_id)
    // 0: (i + j) % 2 == 0
    3'd0: begin
      mask_cond0  = (((i0_mask  ^ j0_mask ) & 1'b1) == 1'b0);
      mask_cond1  = (((i1_mask  ^ j1_mask ) & 1'b1) == 1'b0);
      mask_cond2  = (((i2_mask  ^ j2_mask ) & 1'b1) == 1'b0);
      mask_cond3  = (((i3_mask  ^ j3_mask ) & 1'b1) == 1'b0);
      mask_cond4  = (((i4_mask  ^ j4_mask ) & 1'b1) == 1'b0);
      mask_cond5  = (((i5_mask  ^ j5_mask ) & 1'b1) == 1'b0);
      mask_cond6  = (((i6_mask  ^ j6_mask ) & 1'b1) == 1'b0);
      mask_cond7  = (((i7_mask  ^ j7_mask ) & 1'b1) == 1'b0);
      mask_cond8  = (((i8_mask  ^ j8_mask ) & 1'b1) == 1'b0);
      mask_cond9  = (((i9_mask  ^ j9_mask ) & 1'b1) == 1'b0);
      mask_cond10 = (((i10_mask ^ j10_mask) & 1'b1) == 1'b0);
      mask_cond11 = (((i11_mask ^ j11_mask) & 1'b1) == 1'b0);
      mask_cond12 = (((i12_mask ^ j12_mask) & 1'b1) == 1'b0);
      mask_cond13 = (((i13_mask ^ j13_mask) & 1'b1) == 1'b0);
      mask_cond14 = (((i14_mask ^ j14_mask) & 1'b1) == 1'b0);
      mask_cond15 = (((i15_mask ^ j15_mask) & 1'b1) == 1'b0);
    end
    // 1: i % 2 == 0
    3'd1: begin
      mask_cond0  = (i0_mask[0]  == 1'b0);
      mask_cond1  = (i1_mask[0]  == 1'b0);
      mask_cond2  = (i2_mask[0]  == 1'b0);
      mask_cond3  = (i3_mask[0]  == 1'b0);
      mask_cond4  = (i4_mask[0]  == 1'b0);
      mask_cond5  = (i5_mask[0]  == 1'b0);
      mask_cond6  = (i6_mask[0]  == 1'b0);
      mask_cond7  = (i7_mask[0]  == 1'b0);
      mask_cond8  = (i8_mask[0]  == 1'b0);
      mask_cond9  = (i9_mask[0]  == 1'b0);
      mask_cond10 = (i10_mask[0] == 1'b0);
      mask_cond11 = (i11_mask[0] == 1'b0);
      mask_cond12 = (i12_mask[0] == 1'b0);
      mask_cond13 = (i13_mask[0] == 1'b0);
      mask_cond14 = (i14_mask[0] == 1'b0);
      mask_cond15 = (i15_mask[0] == 1'b0);
    end
    // 2: j % 3 == 0
    3'd2: begin
      mask_cond0  = ((j0_mask  % 3) == 0);
      mask_cond1  = ((j1_mask  % 3) == 0);
      mask_cond2  = ((j2_mask  % 3) == 0);
      mask_cond3  = ((j3_mask  % 3) == 0);
      mask_cond4  = ((j4_mask  % 3) == 0);
      mask_cond5  = ((j5_mask  % 3) == 0);
      mask_cond6  = ((j6_mask  % 3) == 0);
      mask_cond7  = ((j7_mask  % 3) == 0);
      mask_cond8  = ((j8_mask  % 3) == 0);
      mask_cond9  = ((j9_mask  % 3) == 0);
      mask_cond10 = ((j10_mask % 3) == 0);
      mask_cond11 = ((j11_mask % 3) == 0);
      mask_cond12 = ((j12_mask % 3) == 0);
      mask_cond13 = ((j13_mask % 3) == 0);
      mask_cond14 = ((j14_mask % 3) == 0);
      mask_cond15 = ((j15_mask % 3) == 0);
    end
    // 3: (i + j) % 3 == 0
    3'd3: begin
      mask_cond0  = (((i0_mask  + j0_mask ) % 3) == 0);
      mask_cond1  = (((i1_mask  + j1_mask ) % 3) == 0);
      mask_cond2  = (((i2_mask  + j2_mask ) % 3) == 0);
      mask_cond3  = (((i3_mask  + j3_mask ) % 3) == 0);
      mask_cond4  = (((i4_mask  + j4_mask ) % 3) == 0);
      mask_cond5  = (((i5_mask  + j5_mask ) % 3) == 0);
      mask_cond6  = (((i6_mask  + j6_mask ) % 3) == 0);
      mask_cond7  = (((i7_mask  + j7_mask ) % 3) == 0);
      mask_cond8  = (((i8_mask  + j8_mask ) % 3) == 0);
      mask_cond9  = (((i9_mask  + j9_mask ) % 3) == 0);
      mask_cond10 = (((i10_mask + j10_mask) % 3) == 0);
      mask_cond11 = (((i11_mask + j11_mask) % 3) == 0);
      mask_cond12 = (((i12_mask + j12_mask) % 3) == 0);
      mask_cond13 = (((i13_mask + j13_mask) % 3) == 0);
      mask_cond14 = (((i14_mask + j14_mask) % 3) == 0);
      mask_cond15 = (((i15_mask + j15_mask) % 3) == 0);
    end
    // 4: ((i/2) + (j/3)) % 2 == 0
    3'd4: begin
      mask_cond0  = ((((i0_mask  >> 1) + (j0_mask  / 3)) & 1'b1) == 1'b0);
      mask_cond1  = ((((i1_mask  >> 1) + (j1_mask  / 3)) & 1'b1) == 1'b0);
      mask_cond2  = ((((i2_mask  >> 1) + (j2_mask  / 3)) & 1'b1) == 1'b0);
      mask_cond3  = ((((i3_mask  >> 1) + (j3_mask  / 3)) & 1'b1) == 1'b0);
      mask_cond4  = ((((i4_mask  >> 1) + (j4_mask  / 3)) & 1'b1) == 1'b0);
      mask_cond5  = ((((i5_mask  >> 1) + (j5_mask  / 3)) & 1'b1) == 1'b0);
      mask_cond6  = ((((i6_mask  >> 1) + (j6_mask  / 3)) & 1'b1) == 1'b0);
      mask_cond7  = ((((i7_mask  >> 1) + (j7_mask  / 3)) & 1'b1) == 1'b0);
      mask_cond8  = ((((i8_mask  >> 1) + (j8_mask  / 3)) & 1'b1) == 1'b0);
      mask_cond9  = ((((i9_mask  >> 1) + (j9_mask  / 3)) & 1'b1) == 1'b0);
      mask_cond10 = ((((i10_mask >> 1) + (j10_mask / 3)) & 1'b1) == 1'b0);
      mask_cond11 = ((((i11_mask >> 1) + (j11_mask / 3)) & 1'b1) == 1'b0);
      mask_cond12 = ((((i12_mask >> 1) + (j12_mask / 3)) & 1'b1) == 1'b0);
      mask_cond13 = ((((i13_mask >> 1) + (j13_mask / 3)) & 1'b1) == 1'b0);
      mask_cond14 = ((((i14_mask >> 1) + (j14_mask / 3)) & 1'b1) == 1'b0);
      mask_cond15 = ((((i15_mask >> 1) + (j15_mask / 3)) & 1'b1) == 1'b0);
    end
    // 5: (i*j)%2 + (i*j)%3 == 0  <=> even(p) && (p%3==0)
    3'd5: begin
      mask_cond0  = ((p0[0]  == 1'b0) && (p0m3  == 2'd0));
      mask_cond1  = ((p1[0]  == 1'b0) && (p1m3  == 2'd0));
      mask_cond2  = ((p2[0]  == 1'b0) && (p2m3  == 2'd0));
      mask_cond3  = ((p3[0]  == 1'b0) && (p3m3  == 2'd0));
      mask_cond4  = ((p4[0]  == 1'b0) && (p4m3  == 2'd0));
      mask_cond5  = ((p5[0]  == 1'b0) && (p5m3  == 2'd0));
      mask_cond6  = ((p6[0]  == 1'b0) && (p6m3  == 2'd0));
      mask_cond7  = ((p7[0]  == 1'b0) && (p7m3  == 2'd0));
      mask_cond8  = ((p8[0]  == 1'b0) && (p8m3  == 2'd0));
      mask_cond9  = ((p9[0]  == 1'b0) && (p9m3  == 2'd0));
      mask_cond10 = ((p10[0] == 1'b0) && (p10m3 == 2'd0));
      mask_cond11 = ((p11[0] == 1'b0) && (p11m3 == 2'd0));
      mask_cond12 = ((p12[0] == 1'b0) && (p12m3 == 2'd0));
      mask_cond13 = ((p13[0] == 1'b0) && (p13m3 == 2'd0));
      mask_cond14 = ((p14[0] == 1'b0) && (p14m3 == 2'd0));
      mask_cond15 = ((p15[0] == 1'b0) && (p15m3 == 2'd0));
    end
    // 6: (((i*j)%2) XOR ((i*j)%3 LSB)) == 0
    3'd6: begin
      mask_cond0  = ((p0[0]  ^ p0m3[0])  == 1'b0);
      mask_cond1  = ((p1[0]  ^ p1m3[0])  == 1'b0);
      mask_cond2  = ((p2[0]  ^ p2m3[0])  == 1'b0);
      mask_cond3  = ((p3[0]  ^ p3m3[0])  == 1'b0);
      mask_cond4  = ((p4[0]  ^ p4m3[0])  == 1'b0);
      mask_cond5  = ((p5[0]  ^ p5m3[0])  == 1'b0);
      mask_cond6  = ((p6[0]  ^ p6m3[0])  == 1'b0);
      mask_cond7  = ((p7[0]  ^ p7m3[0])  == 1'b0);
      mask_cond8  = ((p8[0]  ^ p8m3[0])  == 1'b0);
      mask_cond9  = ((p9[0]  ^ p9m3[0])  == 1'b0);
      mask_cond10 = ((p10[0] ^ p10m3[0]) == 1'b0);
      mask_cond11 = ((p11[0] ^ p11m3[0]) == 1'b0);
      mask_cond12 = ((p12[0] ^ p12m3[0]) == 1'b0);
      mask_cond13 = ((p13[0] ^ p13m3[0]) == 1'b0);
      mask_cond14 = ((p14[0] ^ p14m3[0]) == 1'b0);
      mask_cond15 = ((p15[0] ^ p15m3[0]) == 1'b0);
    end
    // 7: (parity(i+j) XOR parity((i*j)%3)) == 0
    3'd7: begin
      mask_cond0  = ((((i0_mask  ^ j0_mask ) & 1'b1) ^ p0m3[0])  == 1'b0);
      mask_cond1  = ((((i1_mask  ^ j1_mask ) & 1'b1) ^ p1m3[0])  == 1'b0);
      mask_cond2  = ((((i2_mask  ^ j2_mask ) & 1'b1) ^ p2m3[0])  == 1'b0);
      mask_cond3  = ((((i3_mask  ^ j3_mask ) & 1'b1) ^ p3m3[0])  == 1'b0);
      mask_cond4  = ((((i4_mask  ^ j4_mask ) & 1'b1) ^ p4m3[0])  == 1'b0);
      mask_cond5  = ((((i5_mask  ^ j5_mask ) & 1'b1) ^ p5m3[0])  == 1'b0);
      mask_cond6  = ((((i6_mask  ^ j6_mask ) & 1'b1) ^ p6m3[0])  == 1'b0);
      mask_cond7  = ((((i7_mask  ^ j7_mask ) & 1'b1) ^ p7m3[0])  == 1'b0);
      mask_cond8  = ((((i8_mask  ^ j8_mask ) & 1'b1) ^ p8m3[0])  == 1'b0);
      mask_cond9  = ((((i9_mask  ^ j9_mask ) & 1'b1) ^ p9m3[0])  == 1'b0);
      mask_cond10 = ((((i10_mask ^ j10_mask) & 1'b1) ^ p10m3[0]) == 1'b0);
      mask_cond11 = ((((i11_mask ^ j11_mask) & 1'b1) ^ p11m3[0]) == 1'b0);
      mask_cond12 = ((((i12_mask ^ j12_mask) & 1'b1) ^ p12m3[0]) == 1'b0);
      mask_cond13 = ((((i13_mask ^ j13_mask) & 1'b1) ^ p13m3[0]) == 1'b0);
      mask_cond14 = ((((i14_mask ^ j14_mask) & 1'b1) ^ p14m3[0]) == 1'b0);
      mask_cond15 = ((((i15_mask ^ j15_mask) & 1'b1) ^ p15m3[0]) == 1'b0);
    end
  endcase
end
// ===== demask ===== //


// ===== decode ===== //
// bit addr generator, define 8 point corner

// corner bit address 
always @(*) begin
  case (rot_state)
  ROT_0: begin
    // ----- region 1 ----- //
    loc_x_decode_corner1_addr = (!large_qrcode_flag)? loc_x + 20: loc_x + 41;
    loc_y_decode_corner1_addr = (!large_qrcode_flag)? loc_y + 20: loc_y + 41;

    loc_x_decode_corner2_addr = (!large_qrcode_flag)? loc_x + 20: loc_x + 41;
    loc_y_decode_corner2_addr = (!large_qrcode_flag)? loc_y + 9: loc_y + 18;

    loc_x_decode_corner3_addr = (!large_qrcode_flag)? loc_x + 11: loc_x + 22;
    loc_y_decode_corner3_addr = (!large_qrcode_flag)? loc_y + 20: loc_y + 41;

    loc_x_decode_corner4_addr = (!large_qrcode_flag)? loc_x + 11: loc_x + 22;
    loc_y_decode_corner4_addr = (!large_qrcode_flag)? loc_y + 9: loc_y + 18;

    // ----- region 2 ----- //
    loc_x_decode_corner5_addr = (!large_qrcode_flag)? loc_x + 12: loc_x + 25;
    loc_y_decode_corner5_addr = (!large_qrcode_flag)? loc_y + 8: loc_y + 17;

    loc_x_decode_corner6_addr = (!large_qrcode_flag)? loc_x + 12: loc_x + 25;
    loc_y_decode_corner6_addr = (!large_qrcode_flag)? loc_y: loc_y + 0;

    loc_x_decode_corner7_addr = (!large_qrcode_flag)? loc_x + 9: loc_x + 18;
    loc_y_decode_corner7_addr = (!large_qrcode_flag)? loc_y + 8: loc_y + 17;

    loc_x_decode_corner8_addr = (!large_qrcode_flag)? loc_x + 9: loc_x + 18;
    loc_y_decode_corner8_addr = (!large_qrcode_flag)? loc_y: loc_y + 0;
  end
  ROT_90: begin
    // ----- region 1 ----- //
    loc_x_decode_corner1_addr = (!large_qrcode_flag)? loc_x + 20: loc_x + 41;
    loc_y_decode_corner1_addr = (!large_qrcode_flag)? loc_y - 20: loc_y - 41;

    loc_x_decode_corner2_addr = (!large_qrcode_flag)? loc_x + 9: loc_x + 18;
    loc_y_decode_corner2_addr = (!large_qrcode_flag)? loc_y - 20: loc_y -41;

    loc_x_decode_corner3_addr = (!large_qrcode_flag)? loc_x + 20: loc_x + 41;
    loc_y_decode_corner3_addr = (!large_qrcode_flag)? loc_y - 11: loc_y - 22;

    loc_x_decode_corner4_addr = (!large_qrcode_flag)? loc_x + 9: loc_x + 18;
    loc_y_decode_corner4_addr = (!large_qrcode_flag)? loc_y - 11: loc_y - 22;

    // ----- region 2 ----- //
    loc_x_decode_corner5_addr = (!large_qrcode_flag)? loc_x + 8: loc_x + 17;
    loc_y_decode_corner5_addr = (!large_qrcode_flag)? loc_y - 12: loc_y -25;

    loc_x_decode_corner6_addr = (!large_qrcode_flag)? loc_x: loc_x;
    loc_y_decode_corner6_addr = (!large_qrcode_flag)? loc_y - 12: loc_y - 25;

    loc_x_decode_corner7_addr = (!large_qrcode_flag)? loc_x + 8: loc_x + 17;
    loc_y_decode_corner7_addr = (!large_qrcode_flag)? loc_y - 9: loc_y - 18;

    loc_x_decode_corner8_addr = (!large_qrcode_flag)? loc_x: loc_x;
    loc_y_decode_corner8_addr = (!large_qrcode_flag)? loc_y - 9: loc_y - 18;
  end
  ROT_180: begin
    // ----- region 1 ----- //
    loc_x_decode_corner1_addr = (!large_qrcode_flag)? loc_x - 20: loc_x - 41;
    loc_y_decode_corner1_addr = (!large_qrcode_flag)? loc_y - 20: loc_y - 41;

    loc_x_decode_corner2_addr = (!large_qrcode_flag)? loc_x - 20: loc_x - 41;
    loc_y_decode_corner2_addr = (!large_qrcode_flag)? loc_y - 9: loc_y - 18;

    loc_x_decode_corner3_addr = (!large_qrcode_flag)? loc_x - 11: loc_x - 22;
    loc_y_decode_corner3_addr = (!large_qrcode_flag)? loc_y - 20: loc_y - 41;

    loc_x_decode_corner4_addr = (!large_qrcode_flag)? loc_x - 11: loc_x - 22;
    loc_y_decode_corner4_addr = (!large_qrcode_flag)? loc_y - 9: loc_y - 18;

    // ----- region 2 ----- //
    loc_x_decode_corner5_addr = (!large_qrcode_flag)? loc_x - 12: loc_x - 25;
    loc_y_decode_corner5_addr = (!large_qrcode_flag)? loc_y - 8: loc_y - 17;

    loc_x_decode_corner6_addr = (!large_qrcode_flag)? loc_x - 12: loc_x - 25;
    loc_y_decode_corner6_addr = (!large_qrcode_flag)? loc_y: loc_y;

    loc_x_decode_corner7_addr = (!large_qrcode_flag)? loc_x - 9: loc_x - 18;
    loc_y_decode_corner7_addr = (!large_qrcode_flag)? loc_y - 8: loc_y - 17;

    loc_x_decode_corner8_addr = (!large_qrcode_flag)? loc_x - 9: loc_x - 18;
    loc_y_decode_corner8_addr = (!large_qrcode_flag)? loc_y: loc_y;
  end
  ROT_270: begin
    // ----- region 1 ----- //
    loc_x_decode_corner1_addr = (!large_qrcode_flag)? loc_x - 20: loc_x - 41;
    loc_y_decode_corner1_addr = (!large_qrcode_flag)? loc_y + 20: loc_y + 41;

    loc_x_decode_corner2_addr = (!large_qrcode_flag)? loc_x - 9: loc_x - 18;
    loc_y_decode_corner2_addr = (!large_qrcode_flag)? loc_y + 20: loc_y + 41;

    loc_x_decode_corner3_addr = (!large_qrcode_flag)? loc_x - 20: loc_x - 41;
    loc_y_decode_corner3_addr = (!large_qrcode_flag)? loc_y + 11: loc_y + 22;

    loc_x_decode_corner4_addr = (!large_qrcode_flag)? loc_x - 9: loc_x - 18;
    loc_y_decode_corner4_addr = (!large_qrcode_flag)? loc_y + 11: loc_y + 22;

    // ----- region 2 ----- //
    loc_x_decode_corner5_addr = (!large_qrcode_flag)? loc_x - 8: loc_x - 17;
    loc_y_decode_corner5_addr = (!large_qrcode_flag)? loc_y + 12: loc_y + 25;

    loc_x_decode_corner6_addr = (!large_qrcode_flag)? loc_x: loc_x;
    loc_y_decode_corner6_addr = (!large_qrcode_flag)? loc_y + 12: loc_y + 25;

    loc_x_decode_corner7_addr = (!large_qrcode_flag)? loc_x - 8: loc_x - 17;
    loc_y_decode_corner7_addr = (!large_qrcode_flag)? loc_y + 9: loc_y + 18;

    loc_x_decode_corner8_addr = (!large_qrcode_flag)? loc_x: loc_x;
    loc_y_decode_corner8_addr = (!large_qrcode_flag)? loc_y + 9: loc_y + 18;
  end
  default: begin
    loc_x_decode_corner1_addr = loc_x;
    loc_y_decode_corner1_addr = loc_y;

    loc_x_decode_corner2_addr = loc_x;
    loc_y_decode_corner2_addr = loc_y;

    loc_x_decode_corner3_addr = loc_x;
    loc_y_decode_corner3_addr = loc_y;

    loc_x_decode_corner4_addr = loc_x;
    loc_y_decode_corner4_addr = loc_y;

    // ----- region 2 ----- //
    loc_x_decode_corner5_addr = loc_x;
    loc_y_decode_corner5_addr = loc_y;

    loc_x_decode_corner6_addr = loc_x;
    loc_y_decode_corner6_addr = loc_y;

    loc_x_decode_corner7_addr = loc_x;
    loc_y_decode_corner7_addr = loc_y;

    loc_x_decode_corner8_addr = loc_x;
    loc_y_decode_corner8_addr = loc_y;
  end
  endcase
end

// tranfer corner bit address to block address


always @(*) begin
  corner1_block_addr = {loc_y_decode_corner1_addr[6:2], loc_x_decode_corner1_addr[6:2]};
  corner2_block_addr = {loc_y_decode_corner2_addr[6:2], loc_x_decode_corner2_addr[6:2]};
  corner3_block_addr = {loc_y_decode_corner3_addr[6:2], loc_x_decode_corner3_addr[6:2]};
  corner4_block_addr = {loc_y_decode_corner4_addr[6:2], loc_x_decode_corner4_addr[6:2]};
  corner5_block_addr = {loc_y_decode_corner5_addr[6:2], loc_x_decode_corner5_addr[6:2]};
  corner6_block_addr = {loc_y_decode_corner6_addr[6:2], loc_x_decode_corner6_addr[6:2]};
  corner7_block_addr = {loc_y_decode_corner7_addr[6:2], loc_x_decode_corner7_addr[6:2]};
  corner8_block_addr = {loc_y_decode_corner8_addr[6:2], loc_x_decode_corner8_addr[6:2]};
end

assign rot0_bound1_check   = (rot_state == ROT_0) && (sram_raddr[9:5] == corner2_block_addr[9:5]);   // y addr
assign rot90_bound1_check  = (rot_state == ROT_90) && (sram_raddr[4:0] == corner2_block_addr[4:0]);  // x addr
assign rot180_bound1_check = (rot_state == ROT_180) && (sram_raddr[9:5] == corner2_block_addr[9:5]); // y addr
assign rot270_bound1_check = (rot_state == ROT_270) && (sram_raddr[4:0] == corner2_block_addr[4:0]); // x addr
assign bound1_check = rot0_bound1_check | rot90_bound1_check | rot180_bound1_check | rot270_bound1_check;
assign jump1 = (sram_raddr == corner4_block_addr); // jump to next block region


wire rot0_bound2_check;
wire rot90_bound2_check;
wire rot180_bound2_check;
wire rot270_bound2_check;
wire bound2_check;

assign rot0_bound2_check = (rot_state == ROT_0) && (sram_raddr[9:5] == corner6_block_addr[9:5]);
assign rot90_bound2_check = (rot_state == ROT_90) && (sram_raddr[4:0] == corner6_block_addr[4:0]);
assign rot180_bound2_check = (rot_state == ROT_180) && (sram_raddr[9:5] == corner6_block_addr[9:5]);
assign rot270_bound2_check = (rot_state == ROT_270) && (sram_raddr[4:0] == corner6_block_addr[4:0]);
assign bound2_check = rot0_bound2_check | rot90_bound2_check | rot180_bound2_check | rot270_bound2_check;
assign jump2 = (sram_raddr == corner8_block_addr); // finish decode

always @(posedge clk) begin
  if (!srst_n) begin
    decode_state <= DECODE_IDLE;
  end else begin
    decode_state <= decode_state_n;
  end
end
always @(*) begin
  case (decode_state)
    DECODE_IDLE: begin
      if (state == DECODE) begin
        decode_state_n = DECODE_SWAP1_UP;
        decode_addr = corner1_block_addr;
      end else begin
        decode_state_n = DECODE_IDLE;
        decode_addr = 0; // initialize
      end
    end
    DECODE_SWAP1_UP: begin
      if (global_word_idx == data_len + 2 && (global_word_idx != 2)) begin
        decode_addr = addr_pointer;
        decode_state_n = DECODE_IDLE;
      end else if (jump1) begin
        decode_addr = corner5_block_addr;
        decode_state_n = DECODE_DECODE2;
      end else if (check_bound_cnt_n == 2 && !large_qrcode_flag) begin
        decode_addr = sram_raddr; // do not enable write fifo
        decode_state_n = DECODE_DECODE1;
      end else if (check_bound_cnt_n == 3 && large_qrcode_flag) begin
        decode_addr = sram_raddr;
        decode_state_n = DECODE_DECODE1;
      end else if (bound1_check) begin
        decode_addr = sram_raddr_jump1;
        decode_state_n = DECODE_SWAP1_UP; // some confuse, write = decode_state may cause error
      end else begin
        decode_addr = sram_raddr_swap;
        decode_state_n = DECODE_SWAP1_UP;
      end
    end
    DECODE_SWAP2_UP: begin
      if (global_word_idx == data_len + 2 && (global_word_idx != 2)) begin
        decode_addr = addr_pointer;
        decode_state_n = DECODE_IDLE;
      end else if (jump2) begin
        decode_addr = sram_raddr; // tmp
        decode_state_n = DECODE_DECODE3;
      end else if (bound2_check) begin
        decode_addr = (!large_qrcode_flag)? corner7_block_addr: sram_raddr_jump2; //swap;
        decode_state_n = DECODE_SWAP2_UP;
      end else begin
        decode_addr = sram_raddr_swap;
        decode_state_n = DECODE_SWAP2_UP;
      end
    end
    DECODE_DECODE1: begin // decode 6+6 word of region1
      if (global_word_idx == 2 && decode_text_n2 == 0) begin // data_len = 0 qrcode, skip
        decode_addr = addr_pointer;
        decode_state_n = DECODE_IDLE;
      end else if (global_word_idx == data_len + 2 && (global_word_idx != 2)) begin
        decode_addr = addr_pointer;
        decode_state_n = DECODE_IDLE;
      end else if (local_word_idx == 3'd5) begin
        decode_state_n = DECODE_SWAP1_UP;
        decode_addr = sram_raddr_jump1;
      end else begin
        decode_addr = sram_raddr;
        decode_state_n = DECODE_DECODE1;
      end
    end
    DECODE_DECODE2: begin // decode the remain 8 word of region1
    // add some code here like DECODE_DECODE_1
      if (global_word_idx == data_len + 2 && (global_word_idx != 2)) begin
        decode_addr = addr_pointer;
        decode_state_n = DECODE_IDLE;
      end else if (local_word_idx == 8) begin // need to clear the wptr, rptr, line?
        decode_state_n = DECODE_SWAP2_UP;
        decode_addr = corner5_block_addr;
      end else begin
        decode_addr = sram_raddr;
        decode_state_n = DECODE_DECODE2;
      end
    end
    DECODE_DECODE3: begin // decode the 4 word of region2
      if (local_word_idx == 3'd4) begin
        decode_state_n = DECODE_IDLE;
        decode_addr = addr_pointer;
      end else if (global_word_idx == data_len + 2 && (global_word_idx != 2)) begin
        decode_addr = addr_pointer;
        decode_state_n = DECODE_IDLE;
      end else begin
        decode_addr = sram_raddr;
        decode_state_n = DECODE_DECODE3;
      end
    end
    default: begin
      decode_state_n = 0;
      decode_addr = 0;
    end
      
  endcase
end

reg [4:0]sram_raddr_h_swap2;
reg [4:0]sram_raddr_l_swap2;
always @(*) begin
  case (rot_state)
      ROT_0: begin
        sram_raddr_h_swap = sram_raddr[9:5] - 1; // y
        sram_raddr_l_swap = sram_raddr[4:0]; // x 

        sram_raddr_h_jump1 = corner1_block_addr[9:5]; // y
        sram_raddr_l_jump1 = sram_raddr[4:0] - 1; // x

        sram_raddr_h_jump2 = corner5_block_addr[9:5]; // y
        sram_raddr_l_jump2 = sram_raddr[4:0] - 1; // x
        
      end
      ROT_90: begin
        sram_raddr_h_swap = sram_raddr[9:5];
        sram_raddr_l_swap = sram_raddr[4:0] - 1;

        sram_raddr_h_jump1 = sram_raddr[9:5] + 1; // y
        sram_raddr_l_jump1 = corner1_block_addr[4:0]; // x

        sram_raddr_h_jump2 = sram_raddr[9:5] + 1; // y
        sram_raddr_l_jump2 = corner5_block_addr[4:0]; // x
      end
      ROT_180: begin
        sram_raddr_h_swap = sram_raddr[9:5] + 1;
        sram_raddr_l_swap = sram_raddr[4:0];

        sram_raddr_h_jump1 = corner1_block_addr[9:5]; // y
        sram_raddr_l_jump1 = sram_raddr[4:0] + 1;

        sram_raddr_h_jump2 = corner5_block_addr[9:5]; // y
        sram_raddr_l_jump2 = sram_raddr[4:0] + 1;
      end
      ROT_270: begin
        sram_raddr_h_swap = sram_raddr[9:5];
        sram_raddr_l_swap = sram_raddr[4:0] + 1;

        sram_raddr_h_jump1 = sram_raddr[9:5] - 1; // y
        sram_raddr_l_jump1 = corner1_block_addr[4:0]; // x

        sram_raddr_h_jump2 = sram_raddr[9:5] - 1; // y
        sram_raddr_l_jump2 = corner5_block_addr[4:0]; // x
      end
      default: begin
        sram_raddr_h_swap = 0;
        sram_raddr_l_swap = 0;

        sram_raddr_h_jump1 = 0;
        sram_raddr_l_jump1 = 0;

        sram_raddr_h_jump2 = 0; // y
        sram_raddr_l_jump2 = 0; // x
      end
  endcase
end
assign sram_raddr_swap = {sram_raddr_h_swap, sram_raddr_l_swap};
assign sram_raddr_jump1 = {sram_raddr_h_jump1, sram_raddr_l_jump1};
assign sram_raddr_jump2 = {sram_raddr_h_jump2, sram_raddr_l_jump2};
// ----- check bound counter ----- //

always @(posedge clk) begin
  if (!srst_n) begin
    check_bound_cnt <= 0;
  end else if (state == DECODE) begin
    check_bound_cnt <= check_bound_cnt_n;
  end else begin
    check_bound_cnt <= 0;
  end
end

always @(*) begin
  if ((bound1_check && decode_state == DECODE_SWAP1_UP) | (bound2_check && decode_state == DECODE_SWAP2_UP)) begin
    check_bound_cnt_n = check_bound_cnt + 1;
  end else if (decode_state != DECODE_SWAP1_UP && decode_state != DECODE_SWAP2_UP) begin
    check_bound_cnt_n = 0;
  end else begin
    check_bound_cnt_n = check_bound_cnt;
  end
end

// bit enable


// ----- bit address of current sram data ----- //
always @(*) begin
  sram_dat0_x  = {sram_raddr[4:0], 2'b00};
  sram_dat1_x  = {sram_raddr[4:0], 2'b01};
  sram_dat2_x  = {sram_raddr[4:0], 2'b10};
  sram_dat3_x  = {sram_raddr[4:0], 2'b11};
  sram_dat4_x  = {sram_raddr[4:0], 2'b00};
  sram_dat5_x  = {sram_raddr[4:0], 2'b01};
  sram_dat6_x  = {sram_raddr[4:0], 2'b10};
  sram_dat7_x  = {sram_raddr[4:0], 2'b11};
  sram_dat8_x  = {sram_raddr[4:0], 2'b00};
  sram_dat9_x  = {sram_raddr[4:0], 2'b01};
  sram_dat10_x = {sram_raddr[4:0], 2'b10};
  sram_dat11_x = {sram_raddr[4:0], 2'b11};
  sram_dat12_x = {sram_raddr[4:0], 2'b00};
  sram_dat13_x = {sram_raddr[4:0], 2'b01};
  sram_dat14_x = {sram_raddr[4:0], 2'b10};
  sram_dat15_x = {sram_raddr[4:0], 2'b11};

  sram_dat0_y  = {sram_raddr[9:5], 2'b00};
  sram_dat1_y  = {sram_raddr[9:5], 2'b00};
  sram_dat2_y  = {sram_raddr[9:5], 2'b00};
  sram_dat3_y  = {sram_raddr[9:5], 2'b00};
  sram_dat4_y  = {sram_raddr[9:5], 2'b01};
  sram_dat5_y  = {sram_raddr[9:5], 2'b01};
  sram_dat6_y  = {sram_raddr[9:5], 2'b01};
  sram_dat7_y  = {sram_raddr[9:5], 2'b01};
  sram_dat8_y  = {sram_raddr[9:5], 2'b10};
  sram_dat9_y  = {sram_raddr[9:5], 2'b10};
  sram_dat10_y = {sram_raddr[9:5], 2'b10};
  sram_dat11_y = {sram_raddr[9:5], 2'b10};
  sram_dat12_y = {sram_raddr[9:5], 2'b11};
  sram_dat13_y = {sram_raddr[9:5], 2'b11};
  sram_dat14_y = {sram_raddr[9:5], 2'b11};
  sram_dat15_y = {sram_raddr[9:5], 2'b11};
end



// define block corner region boundary
reg [6:0] region1_right_x;
reg [6:0] region1_left_x;
reg [6:0] region1_up_y;
reg [6:0] region1_down_y;
reg [6:0] region2_right_x;
reg [6:0] region2_left_x;
reg [6:0] region2_up_y;
reg [6:0] region2_down_y;
always @(*) begin
  case (rot_state)
    ROT_0: begin
      region1_right_x = loc_x_decode_corner1_addr;
      region1_left_x  = loc_x_decode_corner4_addr;
      region1_up_y    = loc_y_decode_corner1_addr;
      region1_down_y  = loc_y_decode_corner4_addr;

      region2_right_x = loc_x_decode_corner5_addr;
      region2_left_x  = loc_x_decode_corner8_addr;
      region2_up_y    = loc_y_decode_corner5_addr;
      region2_down_y  = loc_y_decode_corner8_addr;
    end
    ROT_90: begin
      region1_right_x = loc_x_decode_corner1_addr;
      region1_left_x  = loc_x_decode_corner4_addr;
      region1_up_y    = loc_y_decode_corner4_addr;
      region1_down_y  = loc_y_decode_corner1_addr;

      region2_right_x = loc_x_decode_corner5_addr;
      region2_left_x  = loc_x_decode_corner8_addr;
      region2_up_y    = loc_y_decode_corner8_addr;
      region2_down_y  = loc_y_decode_corner5_addr;
    end
    ROT_180: begin
      region1_right_x = loc_x_decode_corner4_addr; // right bound
      region1_left_x  = loc_x_decode_corner1_addr; // left  bound
      region1_up_y    = loc_y_decode_corner4_addr; // upper bound
      region1_down_y  = loc_y_decode_corner1_addr; // lower bound

      region2_right_x = loc_x_decode_corner8_addr;
      region2_left_x  = loc_x_decode_corner5_addr;
      region2_up_y    = loc_y_decode_corner8_addr;
      region2_down_y  = loc_y_decode_corner5_addr;
    end
    ROT_270: begin
      region1_right_x = loc_x_decode_corner4_addr;
      region1_left_x  = loc_x_decode_corner1_addr;
      region1_up_y    = loc_y_decode_corner1_addr;
      region1_down_y  = loc_y_decode_corner4_addr;

      region2_right_x = loc_x_decode_corner8_addr;
      region2_left_x  = loc_x_decode_corner5_addr;
      region2_up_y    = loc_y_decode_corner5_addr;
      region2_down_y  = loc_y_decode_corner8_addr;
    end
    default: begin
      region1_right_x = 0;
      region1_left_x  = 0;
      region1_up_y    = 0;
      region1_down_y  = 0;

      region2_right_x = 0;
      region2_left_x  = 0;
      region2_up_y    = 0;
      region2_down_y  = 0;
    end
  endcase
end

// write the decode data into fifo
// if the data is out of corner than we dont increment the fifo write pointer
reg dat0_en;
reg dat1_en;
reg dat2_en;
reg dat3_en;
reg dat4_en;
reg dat5_en;
reg dat6_en;
reg dat7_en;
reg dat8_en;
reg dat9_en;
reg dat10_en;
reg dat11_en;
reg dat12_en;
reg dat13_en;
reg dat14_en;
reg dat15_en;
// ----- debug signal ----- //
wire tmp;
wire tmp2;
wire tmp3;
wire tmp4;
wire tmp5 = (decode_state == DECODE_SWAP1_UP);
assign tmp = (sram_dat0_x <= region1_right_x);
assign tmp2 = (sram_dat0_x >= region1_left_x);
assign tmp3 = (sram_dat0_y <= region1_up_y);
assign tmp4 = (sram_dat0_y >= region1_down_y);
// ----- debug signal ----- //

// ----- 42x42 qrcode mask data ----- //
// since 42x42 qrcode is 21x21 qrcode scale by two, there is only 1/4 data we need,
// we can mask other data, so they will not write into fifo(dont push wptr).
localparam [41:0] SCALE2_ROW_MASK = (128'd1 << 1)  | (128'd1 << 3)  | (128'd1 << 4)  | (128'd1 << 6)  |
                                      (128'd1 << 9)  | (128'd1 << 11) | (128'd1 << 14) | (128'd1 << 16) |
                                      (128'd1 << 19) | (128'd1 << 21) | (128'd1 << 22) | (128'd1 << 24) |
                                      (128'd1 << 27) | (128'd1 << 29) | (128'd1 << 30) | (128'd1 << 32) |
                                      (128'd1 << 35) | (128'd1 << 37) | (128'd1 << 38) | (128'd1 << 40);

localparam [41:0] SCALE2_COL_MASK = (128'd1 << 18) | (128'd1 << 21) | (128'd1 << 23) | (128'd1 << 24) |
                                      (128'd1 << 26) | (128'd1 << 29) | (128'd1 << 31) | (128'd1 << 32) |
                                      (128'd1 << 34) | (128'd1 << 37) | (128'd1 << 39) | (128'd1 << 40);
wire dat0_scale2;
wire dat1_scale2;
wire dat2_scale2;
wire dat3_scale2;
wire dat4_scale2;
wire dat5_scale2;
wire dat6_scale2;
wire dat7_scale2;
wire dat8_scale2;
wire dat9_scale2;
wire dat10_scale2;
wire dat11_scale2;
wire dat12_scale2;
wire dat13_scale2;
wire dat14_scale2;
wire dat15_scale2;
// each data comes from the sram need to match the mask condition in i-j coordinate
// i-j coordinate is the index correspond to (loc_y, loc_x) under each rotation
assign dat0_scale2  = SCALE2_ROW_MASK[i0_sym]  & SCALE2_COL_MASK[j0_sym];
assign dat1_scale2  = SCALE2_ROW_MASK[i1_sym]  & SCALE2_COL_MASK[j1_sym];
assign dat2_scale2  = SCALE2_ROW_MASK[i2_sym]  & SCALE2_COL_MASK[j2_sym];
assign dat3_scale2  = SCALE2_ROW_MASK[i3_sym]  & SCALE2_COL_MASK[j3_sym];
assign dat4_scale2  = SCALE2_ROW_MASK[i4_sym]  & SCALE2_COL_MASK[j4_sym];
assign dat5_scale2  = SCALE2_ROW_MASK[i5_sym]  & SCALE2_COL_MASK[j5_sym];
assign dat6_scale2  = SCALE2_ROW_MASK[i6_sym]  & SCALE2_COL_MASK[j6_sym];
assign dat7_scale2  = SCALE2_ROW_MASK[i7_sym]  & SCALE2_COL_MASK[j7_sym];
assign dat8_scale2  = SCALE2_ROW_MASK[i8_sym]  & SCALE2_COL_MASK[j8_sym];
assign dat9_scale2  = SCALE2_ROW_MASK[i9_sym]  & SCALE2_COL_MASK[j9_sym];
assign dat10_scale2 = SCALE2_ROW_MASK[i10_sym] & SCALE2_COL_MASK[j10_sym];
assign dat11_scale2 = SCALE2_ROW_MASK[i11_sym] & SCALE2_COL_MASK[j11_sym];
assign dat12_scale2 = SCALE2_ROW_MASK[i12_sym] & SCALE2_COL_MASK[j12_sym];
assign dat13_scale2 = SCALE2_ROW_MASK[i13_sym] & SCALE2_COL_MASK[j13_sym];
assign dat14_scale2 = SCALE2_ROW_MASK[i14_sym] & SCALE2_COL_MASK[j14_sym];
assign dat15_scale2 = SCALE2_ROW_MASK[i15_sym] & SCALE2_COL_MASK[j15_sym];

always @(*) begin
    if (decode_state == DECODE_SWAP1_UP && large_qrcode_flag) begin
    // if decode the 42x42 qrcode, check the mask condition
    dat0_en = (sram_dat0_x <= region1_right_x) && (sram_dat0_x >= region1_left_x)
           && (sram_dat0_y <= region1_up_y)    && (sram_dat0_y >= region1_down_y)
           && dat0_scale2;
    dat1_en = (sram_dat1_x <= region1_right_x) && (sram_dat1_x >= region1_left_x)
           && (sram_dat1_y <= region1_up_y)    && (sram_dat1_y >= region1_down_y)
           && dat1_scale2;
    dat2_en = (sram_dat2_x <= region1_right_x) && (sram_dat2_x >= region1_left_x)
           && (sram_dat2_y <= region1_up_y)    && (sram_dat2_y >= region1_down_y)
           && dat2_scale2;
    dat3_en = (sram_dat3_x <= region1_right_x) && (sram_dat3_x >= region1_left_x)
           && (sram_dat3_y <= region1_up_y)    && (sram_dat3_y >= region1_down_y)
           && dat3_scale2;
    dat4_en = (sram_dat4_x <= region1_right_x) && (sram_dat4_x >= region1_left_x)
           && (sram_dat4_y <= region1_up_y)    && (sram_dat4_y >= region1_down_y)
           && dat4_scale2;
    dat5_en = (sram_dat5_x <= region1_right_x) && (sram_dat5_x >= region1_left_x)
           && (sram_dat5_y <= region1_up_y)    && (sram_dat5_y >= region1_down_y)
           && dat5_scale2;
    dat6_en = (sram_dat6_x <= region1_right_x) && (sram_dat6_x >= region1_left_x)
           && (sram_dat6_y <= region1_up_y)    && (sram_dat6_y >= region1_down_y)
           && dat6_scale2;
    dat7_en = (sram_dat7_x <= region1_right_x) && (sram_dat7_x >= region1_left_x)
           && (sram_dat7_y <= region1_up_y)    && (sram_dat7_y >= region1_down_y)
           && dat7_scale2;
    dat8_en = (sram_dat8_x <= region1_right_x) && (sram_dat8_x >= region1_left_x)
           && (sram_dat8_y <= region1_up_y)    && (sram_dat8_y >= region1_down_y)
           && dat8_scale2;
    dat9_en = (sram_dat9_x <= region1_right_x) && (sram_dat9_x >= region1_left_x)
           && (sram_dat9_y <= region1_up_y)    && (sram_dat9_y >= region1_down_y)
           && dat9_scale2;
    dat10_en = (sram_dat10_x <= region1_right_x) && (sram_dat10_x >= region1_left_x)
            && (sram_dat10_y <= region1_up_y)    && (sram_dat10_y >= region1_down_y)
            && dat10_scale2;
    dat11_en = (sram_dat11_x <= region1_right_x) && (sram_dat11_x >= region1_left_x)
            && (sram_dat11_y <= region1_up_y)    && (sram_dat11_y >= region1_down_y)
            && dat11_scale2;
    dat12_en = (sram_dat12_x <= region1_right_x) && (sram_dat12_x >= region1_left_x)
            && (sram_dat12_y <= region1_up_y)    && (sram_dat12_y >= region1_down_y)
            && dat12_scale2;
    dat13_en = (sram_dat13_x <= region1_right_x) && (sram_dat13_x >= region1_left_x)
            && (sram_dat13_y <= region1_up_y)    && (sram_dat13_y >= region1_down_y)
            && dat13_scale2;
    dat14_en = (sram_dat14_x <= region1_right_x) && (sram_dat14_x >= region1_left_x)
            && (sram_dat14_y <= region1_up_y)    && (sram_dat14_y >= region1_down_y)
            && dat14_scale2;
    dat15_en = (sram_dat15_x <= region1_right_x) && (sram_dat15_x >= region1_left_x)
            && (sram_dat15_y <= region1_up_y)    && (sram_dat15_y >= region1_down_y)
            && dat15_scale2;
    end else if (decode_state == DECODE_SWAP2_UP && large_qrcode_flag) begin
      case (rot_state)
      // need to implement here
        ROT_0: begin
          // data enable mapping for shift condition
          // |0 |1 |2 |3 |     |8 |9 |10|11|
          // |4 |5 |6 |7 |     |12|13|14|15|
          // |8 |9 |10|11| --> |0 |1 |2 |3 |
          // |12|13|14|15|     |4 |5 |6 |7 |
          if (shift0_en) begin  // 0 -> 8
            dat8_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
                    && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y)
                    && dat0_scale2;
          end else begin
            dat8_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
                    && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y) 
                    && dat8_scale2
                    && (sram_dat8_y != loc_y + 12) && (sram_dat8_y != loc_y + 13) 
                    && (sram_dat8_y != loc_y + 14) && (sram_dat8_y != loc_y + 15);
          end
          if (shift1_en) begin
            dat9_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
                   && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y)
                   && dat1_scale2;
          end else begin
            dat9_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
                   && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y)
                   && dat9_scale2
                   && (sram_dat9_y != loc_y + 7'd12) && (sram_dat9_y != loc_y + 7'd13)
                   && (sram_dat9_y != loc_y + 7'd14) && (sram_dat9_y != loc_y + 7'd15);
          end
          if (shift2_en) begin
            dat10_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
                    && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y)
                    && dat2_scale2;
          end else begin
            dat10_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
                    && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y)
                    && dat10_scale2
                    && (sram_dat10_y != loc_y + 7'd12) && (sram_dat10_y != loc_y + 7'd13)
                    && (sram_dat10_y != loc_y + 7'd14) && (sram_dat10_y != loc_y + 7'd15);
          end
          if (shift3_en) begin
            dat11_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
                    && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y)
                    && dat3_scale2;
          end else begin
            dat11_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
                    && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y)
                    && dat11_scale2
                    && (sram_dat11_y != loc_y + 7'd12) && (sram_dat11_y != loc_y + 7'd13)
                    && (sram_dat11_y != loc_y + 7'd14) && (sram_dat11_y != loc_y + 7'd15);
          end
          if (shift4_en) begin
            dat12_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
                    && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y)
                    && dat4_scale2;
          end else begin
            dat12_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
                    && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y)
                    && dat12_scale2
                    && (sram_dat12_y != loc_y + 7'd12) && (sram_dat12_y != loc_y + 7'd13)
                    && (sram_dat12_y != loc_y + 7'd14) && (sram_dat12_y != loc_y + 7'd15);
          end
          if (shift5_en) begin
            dat13_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
                    && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y)
                    && dat5_scale2;
          end else begin
            dat13_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
                    && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y)
                    && dat13_scale2
                    && (sram_dat13_y != loc_y + 7'd12) && (sram_dat13_y != loc_y + 7'd13)
                    && (sram_dat13_y != loc_y + 7'd14) && (sram_dat13_y != loc_y + 7'd15);
          end
          if (shift6_en) begin
            dat14_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
                    && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y)
                    && dat6_scale2;
          end else begin
            dat14_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
                    && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y)
                    && dat14_scale2
                    && (sram_dat14_y != loc_y + 7'd12) && (sram_dat14_y != loc_y + 7'd13)
                    && (sram_dat14_y != loc_y + 7'd14) && (sram_dat14_y != loc_y + 7'd15);
          end
          if (shift7_en) begin
            dat15_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
                    && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y)
                    && dat7_scale2;
          end else begin
            dat15_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
                    && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y)
                    && dat15_scale2
                    && (sram_dat15_y != loc_y + 7'd12) && (sram_dat15_y != loc_y + 7'd13)
                    && (sram_dat15_y != loc_y + 7'd14) && (sram_dat15_y != loc_y + 7'd15);
          end
          if (shift8_en) begin
            dat0_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
                   && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y)
                   && dat8_scale2;
          end else begin
            dat0_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
                   && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y)
                   && dat0_scale2
                   && (sram_dat0_y != loc_y + 7'd12) && (sram_dat0_y != loc_y + 7'd13)
                   && (sram_dat0_y != loc_y + 7'd14) && (sram_dat0_y != loc_y + 7'd15);
          end
          if (shift9_en) begin
            dat1_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
                   && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y)
                   && dat9_scale2;
          end else begin
            dat1_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
                   && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y)
                   && dat1_scale2
                   && (sram_dat1_y != loc_y + 7'd12) && (sram_dat1_y != loc_y + 7'd13)
                   && (sram_dat1_y != loc_y + 7'd14) && (sram_dat1_y != loc_y + 7'd15);
          end
          if (shift10_en) begin
            dat2_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
                    && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y)
                    && dat10_scale2;
          end else begin
            dat2_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
                    && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y)
                    && dat2_scale2
                    && (sram_dat2_y != loc_y + 7'd12) && (sram_dat2_y != loc_y + 7'd13)
                    && (sram_dat2_y != loc_y + 7'd14) && (sram_dat2_y != loc_y + 7'd15);
          end
          if (shift11_en) begin
            dat3_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
                    && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y)
                    && dat11_scale2;
          end else begin
            dat3_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
                    && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y)
                    && dat3_scale2
                    && (sram_dat3_y != loc_y + 7'd12) && (sram_dat3_y != loc_y + 7'd13)
                    && (sram_dat3_y != loc_y + 7'd14) && (sram_dat3_y != loc_y + 7'd15);
          end
          if (shift12_en) begin
            dat4_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
                    && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y)
                    && dat12_scale2;
          end else begin
            dat4_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
                    && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y)
                    && dat4_scale2
                    && (sram_dat4_y != loc_y + 7'd12) && (sram_dat4_y != loc_y + 7'd13)
                    && (sram_dat4_y != loc_y + 7'd14) && (sram_dat4_y != loc_y + 7'd15);
          end
          if (shift13_en) begin
            dat5_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
                    && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y)
                    && dat13_scale2;
          end else begin
            dat5_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
                    && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y)
                    && dat5_scale2
                    && (sram_dat5_y != loc_y + 7'd12) && (sram_dat5_y != loc_y + 7'd13)
                    && (sram_dat5_y != loc_y + 7'd14) && (sram_dat5_y != loc_y + 7'd15);
          end
          if (shift14_en) begin
            dat6_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
                    && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y)
                    && dat14_scale2;
          end else begin
            dat6_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
                    && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y)
                    && dat6_scale2
                    && (sram_dat6_y != loc_y + 7'd12) && (sram_dat6_y != loc_y + 7'd13)
                    && (sram_dat6_y != loc_y + 7'd14) && (sram_dat6_y != loc_y + 7'd15);
          end
          if (shift15_en) begin
            dat7_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
                    && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y)
                    && dat15_scale2;
          end else begin
            dat7_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
                    && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y)
                    && dat7_scale2
                    && (sram_dat7_y != loc_y + 7'd12) && (sram_dat7_y != loc_y + 7'd13)
                    && (sram_dat7_y != loc_y + 7'd14) && (sram_dat7_y != loc_y + 7'd15);
          end
        end
        ROT_90: begin
          // data enable mapping for shift condition
          // |0 |1 |2 |3 |     |2 |3 |0 |1 |
          // |4 |5 |6 |7 |     |6 |7 |4 |5 |
          // |8 |9 |10|11| --> |10|11|8 |9 |
          // |12|13|14|15|     |14|15|12|13|
          if (shift0_en) begin
            dat2_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
                   && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y)
                   && dat0_scale2;
          end else begin
            dat2_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
                   && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y)
                   && dat2_scale2
                   && (sram_dat2_x != loc_x + 7'd12) && (sram_dat2_x != loc_x + 7'd13)
                   && (sram_dat2_x != loc_x + 7'd14) && (sram_dat2_x != loc_x + 7'd15);
          end

          if (shift1_en) begin
            dat3_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
                   && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y)
                   && dat1_scale2;
          end else begin
            dat3_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
                   && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y)
                   && dat3_scale2
                   && (sram_dat3_x != loc_x + 7'd12) && (sram_dat3_x != loc_x + 7'd13)
                   && (sram_dat3_x != loc_x + 7'd14) && (sram_dat3_x != loc_x + 7'd15);
          end

          if (shift2_en) begin
            dat0_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
                   && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y)
                   && dat2_scale2;
          end else begin
            dat0_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
                   && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y)
                   && dat0_scale2
                   && (sram_dat0_x != loc_x + 7'd12) && (sram_dat0_x != loc_x + 7'd13)
                   && (sram_dat0_x != loc_x + 7'd14) && (sram_dat0_x != loc_x + 7'd15);
          end

          if (shift3_en) begin
            dat1_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
                   && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y)
                   && dat3_scale2;
          end else begin
            dat1_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
                   && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y)
                   && dat1_scale2
                   && (sram_dat1_x != loc_x + 7'd12) && (sram_dat1_x != loc_x + 7'd13)
                   && (sram_dat1_x != loc_x + 7'd14) && (sram_dat1_x != loc_x + 7'd15);
          end

          if (shift4_en) begin
            dat6_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
                   && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y)
                   && dat4_scale2;
          end else begin
            dat6_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
                   && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y)
                   && dat6_scale2
                   && (sram_dat6_x != loc_x + 7'd12) && (sram_dat6_x != loc_x + 7'd13)
                   && (sram_dat6_x != loc_x + 7'd14) && (sram_dat6_x != loc_x + 7'd15);
          end

          if (shift5_en) begin
            dat7_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
                   && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y)
                   && dat5_scale2;
          end else begin
            dat7_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
                   && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y)
                   && dat7_scale2
                   && (sram_dat7_x != loc_x + 7'd12) && (sram_dat7_x != loc_x + 7'd13)
                   && (sram_dat7_x != loc_x + 7'd14) && (sram_dat7_x != loc_x + 7'd15);
          end

          if (shift6_en) begin
            dat4_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
                   && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y)
                   && dat6_scale2;
          end else begin
            dat4_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
                   && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y)
                   && dat4_scale2
                   && (sram_dat4_x != loc_x + 7'd12) && (sram_dat4_x != loc_x + 7'd13)
                   && (sram_dat4_x != loc_x + 7'd14) && (sram_dat4_x != loc_x + 7'd15);
          end

          if (shift7_en) begin
            dat5_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
                   && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y)
                   && dat7_scale2;
          end else begin
            dat5_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
                   && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y)
                   && dat5_scale2
                   && (sram_dat5_x != loc_x + 7'd12) && (sram_dat5_x != loc_x + 7'd13)
                   && (sram_dat5_x != loc_x + 7'd14) && (sram_dat5_x != loc_x + 7'd15);
          end

          if (shift8_en) begin
            dat10_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
                    && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y)
                    && dat8_scale2;
          end else begin
            dat10_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
                    && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y)
                    && dat10_scale2
                    && (sram_dat10_x != loc_x + 7'd12) && (sram_dat10_x != loc_x + 7'd13)
                    && (sram_dat10_x != loc_x + 7'd14) && (sram_dat10_x != loc_x + 7'd15);
          end

          if (shift9_en) begin
            dat11_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
                    && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y)
                    && dat9_scale2;
          end else begin
            dat11_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
                    && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y)
                    && dat11_scale2
                    && (sram_dat11_x != loc_x + 7'd12) && (sram_dat11_x != loc_x + 7'd13)
                    && (sram_dat11_x != loc_x + 7'd14) && (sram_dat11_x != loc_x + 7'd15);
          end

          if (shift10_en) begin
            dat8_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
                   && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y)
                   && dat10_scale2;
          end else begin
            dat8_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
                   && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y)
                   && dat8_scale2
                   && (sram_dat8_x != loc_x + 7'd12) && (sram_dat8_x != loc_x + 7'd13)
                   && (sram_dat8_x != loc_x + 7'd14) && (sram_dat8_x != loc_x + 7'd15);
          end

          if (shift11_en) begin
            dat9_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
                   && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y)
                   && dat11_scale2;
          end else begin
            dat9_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
                   && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y)
                   && dat9_scale2
                   && (sram_dat9_x != loc_x + 7'd12) && (sram_dat9_x != loc_x + 7'd13)
                   && (sram_dat9_x != loc_x + 7'd14) && (sram_dat9_x != loc_x + 7'd15);
          end

          if (shift12_en) begin
            dat14_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
                    && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y)
                    && dat12_scale2;
          end else begin
            dat14_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
                    && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y)
                    && dat14_scale2
                    && (sram_dat14_x != loc_x + 7'd12) && (sram_dat14_x != loc_x + 7'd13)
                    && (sram_dat14_x != loc_x + 7'd14) && (sram_dat14_x != loc_x + 7'd15);
          end

          if (shift13_en) begin
            dat15_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
                    && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y)
                    && dat13_scale2;
          end else begin
            dat15_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
                    && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y)
                    && dat15_scale2
                    && (sram_dat15_x != loc_x + 7'd12) && (sram_dat15_x != loc_x + 7'd13)
                    && (sram_dat15_x != loc_x + 7'd14) && (sram_dat15_x != loc_x + 7'd15);
          end

          if (shift14_en) begin
            dat12_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
                    && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y)
                    && dat14_scale2;
          end else begin
            dat12_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
                    && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y)
                    && dat12_scale2
                    && (sram_dat12_x != loc_x + 7'd12) && (sram_dat12_x != loc_x + 7'd13)
                    && (sram_dat12_x != loc_x + 7'd14) && (sram_dat12_x != loc_x + 7'd15);
          end

          if (shift15_en) begin
            dat13_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
                    && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y)
                    && dat15_scale2;
          end else begin
            dat13_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
                    && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y)
                    && dat13_scale2
                    && (sram_dat13_x != loc_x + 7'd12) && (sram_dat13_x != loc_x + 7'd13)
                    && (sram_dat13_x != loc_x + 7'd14) && (sram_dat13_x != loc_x + 7'd15);
          end
        end
        ROT_180: begin
          // data enable mapping for shift condition
          // |0 |1 |2 |3 |     |8 |9 |10|11|
          // |4 |5 |6 |7 |     |12|13|14|15|
          // |8 |9 |10|11| --> |0 |1 |2 |3 |
          // |12|13|14|15|     |4 |5 |6 |7 |
          if (shift0_en) begin
            dat8_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
                   && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y)
                   && dat0_scale2;
          end else begin
            dat8_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
                   && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y)
                   && dat8_scale2
                   && (sram_dat8_y != loc_y - 7'd12) && (sram_dat8_y != loc_y - 7'd13)
                   && (sram_dat8_y != loc_y - 7'd14) && (sram_dat8_y != loc_y - 7'd15);
          end

          if (shift1_en) begin
            dat9_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
                   && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y)
                   && dat1_scale2;
          end else begin
            dat9_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
                   && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y)
                   && dat9_scale2
                   && (sram_dat9_y != loc_y - 7'd12) && (sram_dat9_y != loc_y - 7'd13)
                   && (sram_dat9_y != loc_y - 7'd14) && (sram_dat9_y != loc_y - 7'd15);
          end

          if (shift2_en) begin
            dat10_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
                    && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y)
                    && dat2_scale2;
          end else begin
            dat10_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
                    && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y)
                    && dat10_scale2
                    && (sram_dat10_y != loc_y - 7'd12) && (sram_dat10_y != loc_y - 7'd13)
                    && (sram_dat10_y != loc_y - 7'd14) && (sram_dat10_y != loc_y - 7'd15);
          end

          if (shift3_en) begin
            dat11_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
                    && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y)
                    && dat3_scale2;
          end else begin
            dat11_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
                    && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y)
                    && dat11_scale2
                    && (sram_dat11_y != loc_y - 7'd12) && (sram_dat11_y != loc_y - 7'd13)
                    && (sram_dat11_y != loc_y - 7'd14) && (sram_dat11_y != loc_y - 7'd15);
          end

          if (shift4_en) begin
            dat12_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
                    && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y)
                    && dat4_scale2;
          end else begin
            dat12_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
                    && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y)
                    && dat12_scale2
                    && (sram_dat12_y != loc_y - 7'd12) && (sram_dat12_y != loc_y - 7'd13)
                    && (sram_dat12_y != loc_y - 7'd14) && (sram_dat12_y != loc_y - 7'd15);
          end

          if (shift5_en) begin
            dat13_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
                    && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y)
                    && dat5_scale2;
          end else begin
            dat13_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
                    && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y)
                    && dat13_scale2
                    && (sram_dat13_y != loc_y - 7'd12) && (sram_dat13_y != loc_y - 7'd13)
                    && (sram_dat13_y != loc_y - 7'd14) && (sram_dat13_y != loc_y - 7'd15);
          end

          if (shift6_en) begin
            dat14_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
                    && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y)
                    && dat6_scale2;
          end else begin
            dat14_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
                    && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y)
                    && dat14_scale2
                    && (sram_dat14_y != loc_y - 7'd12) && (sram_dat14_y != loc_y - 7'd13)
                    && (sram_dat14_y != loc_y - 7'd14) && (sram_dat14_y != loc_y - 7'd15);
          end

          if (shift7_en) begin
            dat15_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
                    && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y)
                    && dat7_scale2;
          end else begin
            dat15_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
                    && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y)
                    && dat15_scale2
                    && (sram_dat15_y != loc_y - 7'd12) && (sram_dat15_y != loc_y - 7'd13)
                    && (sram_dat15_y != loc_y - 7'd14) && (sram_dat15_y != loc_y - 7'd15);
          end

          if (shift8_en) begin
            dat0_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
                   && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y)
                   && dat8_scale2;
          end else begin
            dat0_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
                   && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y)
                   && dat0_scale2
                   && (sram_dat0_y != loc_y - 7'd12) && (sram_dat0_y != loc_y - 7'd13)
                   && (sram_dat0_y != loc_y - 7'd14) && (sram_dat0_y != loc_y - 7'd15);
          end

          if (shift9_en) begin
            dat1_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
                   && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y)
                   && dat9_scale2;
          end else begin
            dat1_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
                   && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y)
                   && dat1_scale2
                   && (sram_dat1_y != loc_y - 7'd12) && (sram_dat1_y != loc_y - 7'd13)
                   && (sram_dat1_y != loc_y - 7'd14) && (sram_dat1_y != loc_y - 7'd15);
          end

          if (shift10_en) begin
            dat2_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
                    && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y)
                    && dat10_scale2;
          end else begin
            dat2_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
                    && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y)
                    && dat2_scale2
                    && (sram_dat2_y != loc_y - 7'd12) && (sram_dat2_y != loc_y - 7'd13)
                    && (sram_dat2_y != loc_y - 7'd14) && (sram_dat2_y != loc_y - 7'd15);
          end

          if (shift11_en) begin
            dat3_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
                    && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y)
                    && dat11_scale2;
          end else begin
            dat3_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
                    && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y)
                    && dat3_scale2
                    && (sram_dat3_y != loc_y - 7'd12) && (sram_dat3_y != loc_y - 7'd13)
                    && (sram_dat3_y != loc_y - 7'd14) && (sram_dat3_y != loc_y - 7'd15);
          end

          if (shift12_en) begin
            dat4_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
                    && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y)
                    && dat12_scale2;
          end else begin
            dat4_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
                    && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y)
                    && dat4_scale2
                    && (sram_dat4_y != loc_y - 7'd12) && (sram_dat4_y != loc_y - 7'd13)
                    && (sram_dat4_y != loc_y - 7'd14) && (sram_dat4_y != loc_y - 7'd15);
          end

          if (shift13_en) begin
            dat5_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
                    && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y)
                    && dat13_scale2;
          end else begin
            dat5_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
                    && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y)
                    && dat5_scale2
                    && (sram_dat5_y != loc_y - 7'd12) && (sram_dat5_y != loc_y - 7'd13)
                    && (sram_dat5_y != loc_y - 7'd14) && (sram_dat5_y != loc_y - 7'd15);
          end

          if (shift14_en) begin
            dat6_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
                    && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y)
                    && dat14_scale2;
          end else begin
            dat6_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
                    && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y)
                    && dat6_scale2
                    && (sram_dat6_y != loc_y - 7'd12) && (sram_dat6_y != loc_y - 7'd13)
                    && (sram_dat6_y != loc_y - 7'd14) && (sram_dat6_y != loc_y - 7'd15);
          end

          if (shift15_en) begin
            dat7_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
                    && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y)
                    && dat15_scale2;
          end else begin
            dat7_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
                    && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y)
                    && dat7_scale2
                    && (sram_dat7_y != loc_y - 7'd12) && (sram_dat7_y != loc_y - 7'd13)
                    && (sram_dat7_y != loc_y - 7'd14) && (sram_dat7_y != loc_y - 7'd15);
          end
        end
        ROT_270: begin
          // data enable mapping for shift condition
          // |0 |1 |2 |3 |     |2 |3 |0 |1 |
          // |4 |5 |6 |7 |     |6 |7 |4 |5 |
          // |8 |9 |10|11| --> |10|11|8 |9 |
          // |12|13|14|15|     |14|15|12|13|
          if (shift0_en) begin
            dat2_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
                   && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y)
                   && dat0_scale2;
          end else begin
            dat2_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
                   && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y)
                   && dat2_scale2
                   && (sram_dat2_x != loc_x - 7'd12) && (sram_dat2_x != loc_x - 7'd13)
                   && (sram_dat2_x != loc_x - 7'd14) && (sram_dat2_x != loc_x - 7'd15);
          end

          if (shift1_en) begin
            dat3_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
                   && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y)
                   && dat1_scale2;
          end else begin
            dat3_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
                   && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y)
                   && dat3_scale2
                   && (sram_dat3_x != loc_x - 7'd12) && (sram_dat3_x != loc_x - 7'd13)
                   && (sram_dat3_x != loc_x - 7'd14) && (sram_dat3_x != loc_x - 7'd15);
          end

          if (shift2_en) begin
            dat0_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
                   && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y)
                   && dat2_scale2;
          end else begin
            dat0_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
                   && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y)
                   && dat0_scale2
                   && (sram_dat0_x != loc_x - 7'd12) && (sram_dat0_x != loc_x - 7'd13)
                   && (sram_dat0_x != loc_x - 7'd14) && (sram_dat0_x != loc_x - 7'd15);
          end

          if (shift3_en) begin
            dat1_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
                   && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y)
                   && dat3_scale2;
          end else begin
            dat1_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
                   && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y)
                   && dat1_scale2
                   && (sram_dat1_x != loc_x - 7'd12) && (sram_dat1_x != loc_x - 7'd13)
                   && (sram_dat1_x != loc_x - 7'd14) && (sram_dat1_x != loc_x - 7'd15);
          end

          if (shift4_en) begin
            dat6_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
                   && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y)
                   && dat4_scale2;
          end else begin
            dat6_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
                   && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y)
                   && dat6_scale2
                   && (sram_dat6_x != loc_x - 7'd12) && (sram_dat6_x != loc_x - 7'd13)
                   && (sram_dat6_x != loc_x - 7'd14) && (sram_dat6_x != loc_x - 7'd15);
          end

          if (shift5_en) begin
            dat7_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
                   && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y)
                   && dat5_scale2;
          end else begin
            dat7_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
                   && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y)
                   && dat7_scale2
                   && (sram_dat7_x != loc_x - 7'd12) && (sram_dat7_x != loc_x - 7'd13)
                   && (sram_dat7_x != loc_x - 7'd14) && (sram_dat7_x != loc_x - 7'd15);
          end

          if (shift6_en) begin
            dat4_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
                   && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y)
                   && dat6_scale2;
          end else begin
            dat4_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
                   && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y)
                   && dat4_scale2
                   && (sram_dat4_x != loc_x - 7'd12) && (sram_dat4_x != loc_x - 7'd13)
                   && (sram_dat4_x != loc_x - 7'd14) && (sram_dat4_x != loc_x - 7'd15);
          end

          if (shift7_en) begin
            dat5_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
                   && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y)
                   && dat7_scale2;
          end else begin
            dat5_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
                   && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y)
                   && dat5_scale2
                   && (sram_dat5_x != loc_x - 7'd12) && (sram_dat5_x != loc_x - 7'd13)
                   && (sram_dat5_x != loc_x - 7'd14) && (sram_dat5_x != loc_x - 7'd15);
          end

          if (shift8_en) begin
            dat10_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
                    && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y)
                    && dat8_scale2;
          end else begin
            dat10_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
                    && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y)
                    && dat10_scale2
                    && (sram_dat10_x != loc_x - 7'd12) && (sram_dat10_x != loc_x - 7'd13)
                    && (sram_dat10_x != loc_x - 7'd14) && (sram_dat10_x != loc_x - 7'd15);
          end

          if (shift9_en) begin
            dat11_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
                    && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y)
                    && dat9_scale2;
          end else begin
            dat11_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
                    && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y)
                    && dat11_scale2
                    && (sram_dat11_x != loc_x - 7'd12) && (sram_dat11_x != loc_x - 7'd13)
                    && (sram_dat11_x != loc_x - 7'd14) && (sram_dat11_x != loc_x - 7'd15);
          end

          if (shift10_en) begin
            dat8_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
                   && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y)
                   && dat10_scale2;
          end else begin
            dat8_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
                   && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y)
                   && dat8_scale2
                   && (sram_dat8_x != loc_x - 7'd12) && (sram_dat8_x != loc_x - 7'd13)
                   && (sram_dat8_x != loc_x - 7'd14) && (sram_dat8_x != loc_x - 7'd15);
          end

          if (shift11_en) begin
            dat9_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
                   && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y)
                   && dat11_scale2;
          end else begin
            dat9_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
                   && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y)
                   && dat9_scale2
                   && (sram_dat9_x != loc_x - 7'd12) && (sram_dat9_x != loc_x - 7'd13)
                   && (sram_dat9_x != loc_x - 7'd14) && (sram_dat9_x != loc_x - 7'd15);
          end

          if (shift12_en) begin
            dat14_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
                    && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y)
                    && dat12_scale2;
          end else begin
            dat14_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
                    && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y)
                    && dat14_scale2
                    && (sram_dat14_x != loc_x - 7'd12) && (sram_dat14_x != loc_x - 7'd13)
                    && (sram_dat14_x != loc_x - 7'd14) && (sram_dat14_x != loc_x - 7'd15);
          end

          if (shift13_en) begin
            dat15_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
                    && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y)
                    && dat13_scale2;
          end else begin
            dat15_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
                    && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y)
                    && dat15_scale2
                    && (sram_dat15_x != loc_x - 7'd12) && (sram_dat15_x != loc_x - 7'd13)
                    && (sram_dat15_x != loc_x - 7'd14) && (sram_dat15_x != loc_x - 7'd15);
          end

          if (shift14_en) begin
            dat12_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
                    && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y)
                    && dat14_scale2;
          end else begin
            dat12_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
                    && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y)
                    && dat12_scale2
                    && (sram_dat12_x != loc_x - 7'd12) && (sram_dat12_x != loc_x - 7'd13)
                    && (sram_dat12_x != loc_x - 7'd14) && (sram_dat12_x != loc_x - 7'd15);
          end

          if (shift15_en) begin
            dat13_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
                    && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y)
                    && dat15_scale2;
          end else begin
            dat13_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
                    && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y)
                    && dat13_scale2
                    && (sram_dat13_x != loc_x - 7'd12) && (sram_dat13_x != loc_x - 7'd13)
                    && (sram_dat13_x != loc_x - 7'd14) && (sram_dat13_x != loc_x - 7'd15);
          end
        end
        default: begin
          dat0_en = 0;
          dat1_en = 0;
          dat2_en = 0;
          dat3_en = 0;
          dat4_en = 0;
          dat5_en = 0;
          dat6_en = 0;
          dat7_en = 0;
          dat8_en = 0;
          dat9_en = 0;
          dat10_en = 0;
          dat11_en = 0;
          dat12_en = 0;
          dat13_en = 0;
          dat14_en = 0;
          dat15_en = 0;
        end
      endcase
    end else if (decode_state == DECODE_SWAP1_UP) begin
    dat0_en = (sram_dat0_x <= region1_right_x) && (sram_dat0_x >= region1_left_x)
           && (sram_dat0_y <= region1_up_y)    && (sram_dat0_y >= region1_down_y);
    dat1_en = (sram_dat1_x <= region1_right_x) && (sram_dat1_x >= region1_left_x)
           && (sram_dat1_y <= region1_up_y)    && (sram_dat1_y >= region1_down_y);
    dat2_en = (sram_dat2_x <= region1_right_x) && (sram_dat2_x >= region1_left_x)
           && (sram_dat2_y <= region1_up_y)    && (sram_dat2_y >= region1_down_y);
    dat3_en = (sram_dat3_x <= region1_right_x) && (sram_dat3_x >= region1_left_x)
           && (sram_dat3_y <= region1_up_y)    && (sram_dat3_y >= region1_down_y);
    dat4_en = (sram_dat4_x <= region1_right_x) && (sram_dat4_x >= region1_left_x)
           && (sram_dat4_y <= region1_up_y)    && (sram_dat4_y >= region1_down_y);
    dat5_en = (sram_dat5_x <= region1_right_x) && (sram_dat5_x >= region1_left_x)
           && (sram_dat5_y <= region1_up_y)    && (sram_dat5_y >= region1_down_y);
    dat6_en = (sram_dat6_x <= region1_right_x) && (sram_dat6_x >= region1_left_x)
           && (sram_dat6_y <= region1_up_y)    && (sram_dat6_y >= region1_down_y);
    dat7_en = (sram_dat7_x <= region1_right_x) && (sram_dat7_x >= region1_left_x)
           && (sram_dat7_y <= region1_up_y)    && (sram_dat7_y >= region1_down_y);
    dat8_en = (sram_dat8_x <= region1_right_x) && (sram_dat8_x >= region1_left_x)
           && (sram_dat8_y <= region1_up_y)    && (sram_dat8_y >= region1_down_y);
    dat9_en = (sram_dat9_x <= region1_right_x) && (sram_dat9_x >= region1_left_x)
           && (sram_dat9_y <= region1_up_y)    && (sram_dat9_y >= region1_down_y);
    dat10_en = (sram_dat10_x <= region1_right_x) && (sram_dat10_x >= region1_left_x)
           && (sram_dat10_y <= region1_up_y)    && (sram_dat10_y >= region1_down_y);
    dat11_en = (sram_dat11_x <= region1_right_x) && (sram_dat11_x >= region1_left_x)
           && (sram_dat11_y <= region1_up_y)    && (sram_dat11_y >= region1_down_y);
    dat12_en = (sram_dat12_x <= region1_right_x) && (sram_dat12_x >= region1_left_x)
           && (sram_dat12_y <= region1_up_y)    && (sram_dat12_y >= region1_down_y);
    dat13_en = (sram_dat13_x <= region1_right_x) && (sram_dat13_x >= region1_left_x)
           && (sram_dat13_y <= region1_up_y)    && (sram_dat13_y >= region1_down_y);
    dat14_en = (sram_dat14_x <= region1_right_x) && (sram_dat14_x >= region1_left_x)
           && (sram_dat14_y <= region1_up_y)    && (sram_dat14_y >= region1_down_y);
    dat15_en = (sram_dat15_x <= region1_right_x) && (sram_dat15_x >= region1_left_x)
           && (sram_dat15_y <= region1_up_y)    && (sram_dat15_y >= region1_down_y);
  end else if (decode_state == DECODE_SWAP2_UP) begin // DECODE_DECODE2
  // wptr controlle, dat_en control the increment of write pointer
  case (rot_state)
    ROT_0: begin
      // data enable mapping for shift condition
      // |0 |1 |2 |3 |     |12|13|14|15|
      // |4 |5 |6 |7 |     |0 |1 |2 |3 |
      // |8 |9 |10|11| --> |4 |5 |6 |7 |
      // |12|13|14|15|     |8 |9 |10|11|
      if (shift0_en) begin
        dat12_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
                && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y);
      end else begin
        dat12_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
                && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y) 
                && (sram_dat12_y != loc_y_finder + 1) && (sram_dat12_y != loc_y_finder + 2) && (sram_dat12_y != loc_y_finder);
      end
      // since the finder row is written by the next row data. so the original place of next row data should not be write

      if (shift1_en) begin // shift_en = out of finder
        dat13_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
                && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y);
      end else begin
        dat13_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
                && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y) 
                && (sram_dat13_y != loc_y_finder + 1) && (sram_dat13_y != loc_y_finder + 2) && (sram_dat13_y != loc_y_finder);
      end

      if (shift2_en) begin
        dat14_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
                && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y);
      end else begin
        dat14_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
                && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y) 
                && (sram_dat14_y != loc_y_finder + 1)&& (sram_dat14_y != loc_y_finder + 2) && (sram_dat14_y != loc_y_finder);
      end

      if (shift3_en) begin
        dat15_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
                && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y);
      end else begin
        dat15_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
                && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y) 
                && (sram_dat15_y != loc_y_finder + 1)&& (sram_dat15_y != loc_y_finder + 2) && (sram_dat15_y != loc_y_finder);
      end

      if (shift4_en) begin
        dat0_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
               && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y);
      end else begin
        dat0_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
               && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y) 
               && (sram_dat0_y != loc_y_finder + 1)&& (sram_dat0_y != loc_y_finder + 2) && (sram_dat0_y != loc_y_finder);
      end

      if (shift5_en) begin
        dat1_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
               && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y);
      end else begin
        dat1_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
               && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y) 
               && (sram_dat1_y != loc_y_finder + 1)&& (sram_dat1_y != loc_y_finder + 2) && (sram_dat1_y != loc_y_finder);
      end

      if (shift6_en) begin
        dat2_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
               && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y);
      end else begin
        dat2_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
               && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y) 
               && (sram_dat2_y != loc_y_finder + 1)&& (sram_dat2_y != loc_y_finder + 2) && (sram_dat2_y != loc_y_finder);
      end

      if (shift7_en) begin
        dat3_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
               && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y);
      end else begin
        dat3_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
               && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y) 
               && (sram_dat3_y != loc_y_finder + 1)&& (sram_dat3_y != loc_y_finder + 2) && (sram_dat3_y != loc_y_finder);
      end

      if (shift8_en) begin
        dat4_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
               && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y);
      end else begin
        dat4_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
               && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y) 
               && (sram_dat4_y != loc_y_finder + 1)&& (sram_dat4_y != loc_y_finder + 2) && (sram_dat4_y != loc_y_finder);
      end

      if (shift9_en) begin
        dat5_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
               && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y);
      end else begin
        dat5_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
               && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y) 
               && (sram_dat5_y != loc_y_finder + 1)&& (sram_dat5_y != loc_y_finder + 2) && (sram_dat5_y != loc_y_finder);
      end

      if (shift10_en) begin
        dat6_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
               && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y);
      end else begin
        dat6_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
               && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y) 
               && (sram_dat6_y != loc_y_finder + 1)&& (sram_dat6_y != loc_y_finder + 2) && (sram_dat6_y != loc_y_finder);
      end

      if (shift11_en) begin
        dat7_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
               && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y);
      end else begin
        dat7_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
               && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y) 
               && (sram_dat7_y != loc_y_finder + 1)&& (sram_dat7_y != loc_y_finder + 2) && (sram_dat7_y != loc_y_finder);
      end

      if (shift12_en) begin
        dat8_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
               && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y);
      end else begin
        dat8_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
               && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y) 
               && (sram_dat8_y != loc_y_finder + 1)&& (sram_dat8_y != loc_y_finder + 2) && (sram_dat8_y != loc_y_finder);
      end

      if (shift13_en) begin
        dat9_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
               && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y);
      end else begin
        dat9_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
               && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y) 
               && (sram_dat9_y != loc_y_finder + 1)&& (sram_dat9_y != loc_y_finder + 2) && (sram_dat9_y != loc_y_finder);
      end

      if (shift14_en) begin
        dat10_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
                && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y);
      end else begin
        dat10_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
                && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y) 
                && (sram_dat10_y != loc_y_finder + 1)&& (sram_dat10_y != loc_y_finder + 2) && (sram_dat10_y != loc_y_finder);
      end

      if (shift15_en) begin
        dat11_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
                && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y);
      end else begin
        dat11_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
                && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y) 
                && (sram_dat11_y != loc_y_finder + 1)&& (sram_dat11_y != loc_y_finder + 2) && (sram_dat11_y != loc_y_finder);
      end
    end
    ROT_90: begin
      // data enable mapping for shift condition
      // |0 |1 |2 |3 |     |3 |0 |1 |2 |
      // |4 |5 |6 |7 |     |7 |4 |5 |6 |
      // |8 |9 |10|11| --> |11|8 |9 |10|
      // |12|13|14|15|     |15|12|13|14|
      if (shift0_en) begin
        dat3_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
               && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y);
      end else begin
        dat3_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
               && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y) 
               && (sram_dat3_x != loc_x + 7)       && (sram_dat3_x != loc_x + 8) && (sram_dat3_x != loc_x + 6);
      end

      if (shift1_en) begin
        dat0_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
               && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y);
      end else begin
        dat0_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
               && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y) 
               && (sram_dat0_x != loc_x + 7)       && (sram_dat0_x != loc_x + 8) && (sram_dat0_x != loc_x + 6);
      end

      if (shift2_en) begin
        dat1_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
               && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y);
      end else begin
        dat1_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
               && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y) 
               && (sram_dat1_x != loc_x + 7)       && (sram_dat1_x != loc_x + 8) && (sram_dat1_x != loc_x + 6);
      end

      if (shift3_en) begin
        dat2_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
               && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y);
      end else begin
        dat2_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
               && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y) 
               && (sram_dat2_x != loc_x + 7)       && (sram_dat2_x != loc_x + 8) && (sram_dat2_x != loc_x + 6);
      end

      if (shift4_en) begin
        dat7_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
               && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y);
      end else begin
        dat7_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
               && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y) 
               && (sram_dat7_x != loc_x + 7)       && (sram_dat7_x != loc_x + 8) && (sram_dat7_x != loc_x + 6);
      end

      if (shift5_en) begin
        dat4_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
               && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y);
      end else begin
        dat4_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
               && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y) 
               && (sram_dat4_x != loc_x + 7)       && (sram_dat4_x != loc_x + 8) && (sram_dat4_x != loc_x + 6);
      end

      if (shift6_en) begin
        dat5_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
               && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y);
      end else begin
        dat5_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
               && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y) 
               && (sram_dat5_x != loc_x + 7)       && (sram_dat5_x != loc_x + 8) && (sram_dat5_x != loc_x + 6);
      end

      if (shift7_en) begin
        dat6_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
               && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y);
      end else begin
        dat6_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
               && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y) 
               && (sram_dat6_x != loc_x + 7)       && (sram_dat6_x != loc_x + 8) && (sram_dat6_x != loc_x + 6);
      end

      if (shift8_en) begin
        dat11_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
               && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y);
      end else begin
        dat11_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
               && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y) 
               && (sram_dat11_x != loc_x + 7)       && (sram_dat11_x != loc_x + 8) && (sram_dat11_x != loc_x + 6);
      end

      if (shift9_en) begin
        dat8_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
               && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y);
      end else begin
        dat8_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
               && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y) 
               && (sram_dat8_x != loc_x + 7)       && (sram_dat8_x != loc_x + 8) && (sram_dat8_x != loc_x + 6);
      end

      if (shift10_en) begin
        dat9_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
               && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y);
      end else begin
        dat9_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
               && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y) 
               && (sram_dat9_x != loc_x + 7)       && (sram_dat9_x != loc_x + 8) && (sram_dat9_x != loc_x + 6);
      end

      if (shift11_en) begin
        dat10_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
               && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y);
      end else begin
        dat10_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
               && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y) 
               && (sram_dat10_x != loc_x + 7)       && (sram_dat10_x != loc_x + 8) && (sram_dat10_x != loc_x + 6);
      end

      if (shift12_en) begin
        dat15_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
               && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y);
      end else begin
        dat15_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
               && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y) 
               && (sram_dat15_x != loc_x + 7)       && (sram_dat15_x != loc_x + 8) && (sram_dat15_x != loc_x + 6);
      end

      if (shift13_en) begin
        dat12_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
               && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y);
      end else begin
        dat12_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
               && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y) 
               && (sram_dat12_x != loc_x + 7)       && (sram_dat12_x != loc_x + 8) && (sram_dat12_x != loc_x + 6);
      end

      if (shift14_en) begin
        dat13_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
               && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y);
      end else begin
        dat13_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
               && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y) 
               && (sram_dat13_x != loc_x + 7)       && (sram_dat13_x != loc_x + 8) && (sram_dat13_x != loc_x + 6);
      end

      if (shift15_en) begin
        dat14_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
               && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y);
      end else begin
        dat14_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
               && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y) 
               && (sram_dat14_x != loc_x + 7)       && (sram_dat14_x != loc_x + 8) && (sram_dat14_x != loc_x + 6);
      end
    end
    ROT_180: begin
      // data enable mapping for shift condition
      // |0 |1 |2 |3 |     |4 |5 |6 |7 |
      // |4 |5 |6 |7 |     |8 |9 |10|11|
      // |8 |9 |10|11| --> |12|13|14|15|
      // |12|13|14|15|     |0 |1 |2 |3 |
      if (shift0_en) begin
        dat4_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
               && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y);
      end else begin
        dat4_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
               && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y) 
               && (sram_dat4_y != loc_y - 7)       && (sram_dat4_y != loc_y - 8) && (sram_dat4_y != loc_y - 6);
      end

      if (shift1_en) begin
        dat5_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
               && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y);
      end else begin
        dat5_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
               && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y) 
               && (sram_dat5_y != loc_y - 7)       && (sram_dat5_y != loc_y - 8) && (sram_dat5_y != loc_y - 6);
      end

      if (shift2_en) begin
        dat6_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
               && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y);
      end else begin
        dat6_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
               && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y) 
               && (sram_dat6_y != loc_y - 7)       && (sram_dat6_y != loc_y - 8) && (sram_dat6_y != loc_y - 6);
      end

      if (shift3_en) begin
        dat7_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
               && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y);
      end else begin
        dat7_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
               && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y) 
               && (sram_dat7_y != loc_y - 7)       && (sram_dat7_y != loc_y - 8) && (sram_dat7_y != loc_y - 6);
      end

      if (shift4_en) begin
        dat8_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
               && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y);
      end else begin
        dat8_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
               && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y) 
               && (sram_dat8_y != loc_y - 7)       && (sram_dat8_y != loc_y - 8) && (sram_dat8_y != loc_y - 6);
      end

      if (shift5_en) begin
        dat9_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
               && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y);
      end else begin
        dat9_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
               && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y) 
               && (sram_dat9_y != loc_y - 7)       && (sram_dat9_y != loc_y - 8) && (sram_dat9_y != loc_y - 6);
      end

      if (shift6_en) begin
        dat10_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
               && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y);
      end else begin
        dat10_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
               && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y) 
               && (sram_dat10_y != loc_y - 7)       && (sram_dat10_y != loc_y - 8) && (sram_dat10_y != loc_y - 6);
      end

      if (shift7_en) begin
        dat11_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
               && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y);
      end else begin
        dat11_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
               && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y) 
               && (sram_dat11_y != loc_y - 7)       && (sram_dat11_y != loc_y - 8) && (sram_dat11_y != loc_y - 6);
      end

      if (shift8_en) begin
        dat12_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
               && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y);
      end else begin
        dat12_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
               && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y) 
               && (sram_dat12_y != loc_y - 7)       && (sram_dat12_y != loc_y - 8) && (sram_dat12_y != loc_y - 6);
      end

      if (shift9_en) begin
        dat13_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
               && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y);
      end else begin
        dat13_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
               && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y) 
               && (sram_dat13_y != loc_y - 7)       && (sram_dat13_y != loc_y - 8) && (sram_dat13_y != loc_y - 6);
      end

      if (shift10_en) begin
        dat14_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
               && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y);
      end else begin
        dat14_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
               && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y) 
               && (sram_dat14_y != loc_y - 7)       && (sram_dat14_y != loc_y - 8) && (sram_dat14_y != loc_y - 6);
      end

      if (shift11_en) begin
        dat15_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
               && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y);
      end else begin
        dat15_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
               && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y) 
               && (sram_dat15_y != loc_y - 7)       && (sram_dat15_y != loc_y - 8) && (sram_dat15_y != loc_y - 6);
      end

      if (shift12_en) begin
        dat0_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
               && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y);
      end else begin
        dat0_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
               && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y) 
               && (sram_dat0_y != loc_y - 7)       && (sram_dat0_y != loc_y - 8) && (sram_dat0_y != loc_y - 6);
      end

      if (shift13_en) begin
        dat1_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
               && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y);
      end else begin
        dat1_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
               && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y) 
               && (sram_dat1_y != loc_y - 7)       && (sram_dat1_y != loc_y - 8) && (sram_dat1_y != loc_y - 6);
      end

      if (shift14_en) begin
        dat2_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
               && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y);
      end else begin
        dat2_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
               && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y) 
               && (sram_dat2_y != loc_y - 7)       && (sram_dat2_y != loc_y - 8) && (sram_dat2_y != loc_y - 6);
      end

      if (shift15_en) begin
        dat3_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
               && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y);
      end else begin
        dat3_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
               && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y) 
               && (sram_dat3_y != loc_y - 7)       && (sram_dat3_y != loc_y - 8) && (sram_dat3_y != loc_y - 6);
      end
    end
    ROT_270: begin
      // data enable mapping for shift condition
      // |0 |1 |2 |3 |     |1 |2 |3 |0 |
      // |4 |5 |6 |7 |     |5 |6 |7 |4 |
      // |8 |9 |10|11| --> |9 |10|11|8 |
      // |12|13|14|15|     |13|14|15|12|
      if (shift0_en) begin
        dat1_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
               && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y);
      end else begin
        dat1_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
               && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y) 
               && (sram_dat1_x != loc_x - 7)       && (sram_dat1_x != loc_x - 8) && (sram_dat1_x != loc_x - 6);
      end

      if (shift1_en) begin
        dat2_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
               && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y);
      end else begin
        dat2_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
               && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y) 
               && (sram_dat2_x != loc_x - 7)       && (sram_dat2_x != loc_x - 8) && (sram_dat2_x != loc_x - 6);
      end

      if (shift2_en) begin
        dat3_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
               && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y);
      end else begin
        dat3_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
               && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y) 
               && (sram_dat3_x != loc_x - 7)       && (sram_dat3_x != loc_x - 8) && (sram_dat3_x != loc_x - 6);
      end

      if (shift3_en) begin
        dat0_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
               && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y);
      end else begin
        dat0_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
               && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y) 
               && (sram_dat0_x != loc_x - 7)       && (sram_dat0_x != loc_x - 8) && (sram_dat0_x != loc_x - 6);
      end

      if (shift4_en) begin
        dat5_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
               && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y);
      end else begin
        dat5_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
               && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y) 
               && (sram_dat5_x != loc_x - 7)       && (sram_dat5_x != loc_x - 8) && (sram_dat5_x != loc_x - 6);
      end

      if (shift5_en) begin
        dat6_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
               && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y);
      end else begin
        dat6_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
               && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y) 
               && (sram_dat6_x != loc_x - 7)       && (sram_dat6_x != loc_x - 8) && (sram_dat6_x != loc_x - 6);
      end

      if (shift6_en) begin
        dat7_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
               && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y);
      end else begin
        dat7_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
               && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y) 
               && (sram_dat7_x != loc_x - 7)       && (sram_dat7_x != loc_x - 8) && (sram_dat7_x != loc_x - 6);
      end

      if (shift7_en) begin
        dat4_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
               && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y);
      end else begin
        dat4_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
               && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y) 
               && (sram_dat4_x != loc_x - 7)       && (sram_dat4_x != loc_x - 8) && (sram_dat4_x != loc_x - 6);
      end

      if (shift8_en) begin
        dat9_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
               && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y);
      end else begin
        dat9_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
               && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y) 
               && (sram_dat9_x != loc_x - 7)       && (sram_dat9_x != loc_x - 8) && (sram_dat9_x != loc_x - 6);
      end

      if (shift9_en) begin
        dat10_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
               && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y);
      end else begin
        dat10_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
               && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y) 
               && (sram_dat10_x != loc_x - 7)       && (sram_dat10_x != loc_x - 8) && (sram_dat10_x != loc_x - 6);
      end

      if (shift10_en) begin
        dat11_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
               && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y);
      end else begin
        dat11_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
               && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y) 
               && (sram_dat11_x != loc_x - 7)       && (sram_dat11_x != loc_x - 8) && (sram_dat11_x != loc_x - 6);
      end

      if (shift11_en) begin
        dat8_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
               && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y);
      end else begin
        dat8_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
               && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y) 
               && (sram_dat8_x != loc_x - 7)       && (sram_dat8_x != loc_x - 8) && (sram_dat8_x != loc_x - 6);
      end

      if (shift12_en) begin
        dat13_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
               && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y);
      end else begin
        dat13_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
               && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y) 
               && (sram_dat13_x != loc_x - 7)       && (sram_dat13_x != loc_x - 8) && (sram_dat13_x != loc_x - 6);
      end

      if (shift13_en) begin
        dat14_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
               && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y);
      end else begin
        dat14_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
               && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y) 
               && (sram_dat14_x != loc_x - 7)       && (sram_dat14_x != loc_x - 8) && (sram_dat14_x != loc_x - 6);
      end

      if (shift14_en) begin
        dat15_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
               && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y);
      end else begin
        dat15_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
               && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y) 
               && (sram_dat15_x != loc_x - 7)       && (sram_dat15_x != loc_x - 8) && (sram_dat15_x != loc_x - 6);
      end

      if (shift15_en) begin
        dat12_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
               && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y);
      end else begin
        dat12_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
               && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y) 
               && (sram_dat12_x != loc_x - 7)       && (sram_dat12_x != loc_x - 8) && (sram_dat12_x != loc_x - 6);
      end
    end
    default: begin
      dat0_en = (sram_dat0_x <= region2_right_x) && (sram_dat0_x >= region2_left_x)
           && (sram_dat0_y <= region2_up_y)    && (sram_dat0_y >= region2_down_y);
    dat1_en = (sram_dat1_x <= region2_right_x) && (sram_dat1_x >= region2_left_x)
           && (sram_dat1_y <= region2_up_y)    && (sram_dat1_y >= region2_down_y);
    dat2_en = (sram_dat2_x <= region2_right_x) && (sram_dat2_x >= region2_left_x)
           && (sram_dat2_y <= region2_up_y)    && (sram_dat2_y >= region2_down_y);
    dat3_en = (sram_dat3_x <= region2_right_x) && (sram_dat3_x >= region2_left_x)
           && (sram_dat3_y <= region2_up_y)    && (sram_dat3_y >= region2_down_y);
    dat4_en = (sram_dat4_x <= region2_right_x) && (sram_dat4_x >= region2_left_x)
           && (sram_dat4_y <= region2_up_y)    && (sram_dat4_y >= region2_down_y);
    dat5_en = (sram_dat5_x <= region2_right_x) && (sram_dat5_x >= region2_left_x)
           && (sram_dat5_y <= region2_up_y)    && (sram_dat5_y >= region2_down_y);
    dat6_en = (sram_dat6_x <= region2_right_x) && (sram_dat6_x >= region2_left_x)
           && (sram_dat6_y <= region2_up_y)    && (sram_dat6_y >= region2_down_y);
    dat7_en = (sram_dat7_x <= region2_right_x) && (sram_dat7_x >= region2_left_x)
           && (sram_dat7_y <= region2_up_y)    && (sram_dat7_y >= region2_down_y);
    dat8_en = (sram_dat8_x <= region2_right_x) && (sram_dat8_x >= region2_left_x)
           && (sram_dat8_y <= region2_up_y)    && (sram_dat8_y >= region2_down_y);
    dat9_en = (sram_dat9_x <= region2_right_x) && (sram_dat9_x >= region2_left_x)
           && (sram_dat9_y <= region2_up_y)    && (sram_dat9_y >= region2_down_y);
    dat10_en = (sram_dat10_x <= region2_right_x) && (sram_dat10_x >= region2_left_x)
           && (sram_dat10_y <= region2_up_y)    && (sram_dat10_y >= region2_down_y);
    dat11_en = (sram_dat11_x <= region2_right_x) && (sram_dat11_x >= region2_left_x)
           && (sram_dat11_y <= region2_up_y)    && (sram_dat11_y >= region2_down_y);
    dat12_en = (sram_dat12_x <= region2_right_x) && (sram_dat12_x >= region2_left_x)
           && (sram_dat12_y <= region2_up_y)    && (sram_dat12_y >= region2_down_y);
    dat13_en = (sram_dat13_x <= region2_right_x) && (sram_dat13_x >= region2_left_x)
           && (sram_dat13_y <= region2_up_y)    && (sram_dat13_y >= region2_down_y);
    dat14_en = (sram_dat14_x <= region2_right_x) && (sram_dat14_x >= region2_left_x)
           && (sram_dat14_y <= region2_up_y)    && (sram_dat14_y >= region2_down_y);
    dat15_en = (sram_dat15_x <= region2_right_x) && (sram_dat15_x >= region2_left_x)
           && (sram_dat15_y <= region2_up_y)    && (sram_dat15_y >= region2_down_y);
    end
  endcase
  end else begin
    dat0_en = 0;
    dat1_en = 0;
    dat2_en = 0;
    dat3_en = 0;
    dat4_en = 0;
    dat5_en = 0;
    dat6_en = 0;
    dat7_en = 0;
    dat8_en = 0;
    dat9_en = 0;
    dat10_en = 0;
    dat11_en = 0;
    dat12_en = 0;
    dat13_en = 0;
    dat14_en = 0;
    dat15_en = 0;
  end
end

always @(posedge clk) begin
  if (!srst_n) begin
    fifo_wptr0  <= 0;  fifo_wptr1  <= 0;  fifo_wptr2  <= 0;  fifo_wptr3  <= 0;
    fifo_wptr4  <= 0;  fifo_wptr5  <= 0;  fifo_wptr6  <= 0;  fifo_wptr7  <= 0;
    fifo_wptr8  <= 0;  fifo_wptr9  <= 0;  fifo_wptr10 <= 0;  fifo_wptr11 <= 0;
    fifo_wptr12 <= 0;  fifo_wptr13 <= 0;  fifo_wptr14 <= 0;  fifo_wptr15 <= 0;
  end else if ((state==DECODE && decode_state==DECODE_IDLE)) begin
    fifo_wptr0  <= 0;  fifo_wptr1  <= 0;  fifo_wptr2  <= 0;  fifo_wptr3  <= 0;
    fifo_wptr4  <= 0;  fifo_wptr5  <= 0;  fifo_wptr6  <= 0;  fifo_wptr7  <= 0;
    fifo_wptr8  <= 0;  fifo_wptr9  <= 0;  fifo_wptr10 <= 0;  fifo_wptr11 <= 0;
    fifo_wptr12 <= 0;  fifo_wptr13 <= 0;  fifo_wptr14 <= 0;  fifo_wptr15 <= 0;
  end else if (state==DECODE) begin
    if (dat0_en)   fifo_wptr0  <= (fifo_wptr0  == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr0  + 4'd1);
    if (dat1_en)   fifo_wptr1  <= (fifo_wptr1  == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr1  + 4'd1);
    if (dat2_en)   fifo_wptr2  <= (fifo_wptr2  == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr2  + 4'd1);
    if (dat3_en)   fifo_wptr3  <= (fifo_wptr3  == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr3  + 4'd1);
    if (dat4_en)   fifo_wptr4  <= (fifo_wptr4  == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr4  + 4'd1);
    if (dat5_en)   fifo_wptr5  <= (fifo_wptr5  == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr5  + 4'd1);
    if (dat6_en)   fifo_wptr6  <= (fifo_wptr6  == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr6  + 4'd1);
    if (dat7_en)   fifo_wptr7  <= (fifo_wptr7  == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr7  + 4'd1);
    if (dat8_en)   fifo_wptr8  <= (fifo_wptr8  == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr8  + 4'd1);
    if (dat9_en)   fifo_wptr9  <= (fifo_wptr9  == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr9  + 4'd1);
    if (dat10_en)  fifo_wptr10 <= (fifo_wptr10 == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr10 + 4'd1);
    if (dat11_en)  fifo_wptr11 <= (fifo_wptr11 == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr11 + 4'd1);
    if (dat12_en)  fifo_wptr12 <= (fifo_wptr12 == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr12 + 4'd1);
    if (dat13_en)  fifo_wptr13 <= (fifo_wptr13 == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr13 + 4'd1);
    if (dat14_en)  fifo_wptr14 <= (fifo_wptr14 == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr14 + 4'd1);
    if (dat15_en)  fifo_wptr15 <= (fifo_wptr15 == shift_reg_depth - 1) ? 4'd0 : (fifo_wptr15 + 4'd1);
  end
end


// ===== read pointer control ===== //
wire [3:0] decode_type;
// didnt implement rotation
assign decode_type = {loc_y[1:0], loc_x[1:0]};

// ----- new define for 42x42 qrcode begin ----- //
// if large_qrcode_flag, use these decode format
// still need to implement rot90, rot180, rot270 later
// ----- region 1 ----- //
// rotation 0, type (0, 0) = (y, x)
// |7 |1' |0' |6 |
// |3 |5' |4' |2 |
// |5 |3' |2' |4 |
// |1 |7' |6' |0 |
// 8-bit word A: {line0, line3, line8, line11, line4, line7, line12, line15}
// 8-bit word B: {line13, line14, line5, line6, line9, line10, line1, line2}
localparam [3:0] type00_large_A0 = 4'd15;
localparam [3:0] type00_large_A1 = 4'd12;
localparam [3:0] type00_large_A2 = 4'd7;
localparam [3:0] type00_large_A3 = 4'd4;
localparam [3:0] type00_large_A4 = 4'd11;
localparam [3:0] type00_large_A5 = 4'd8;
localparam [3:0] type00_large_A6 = 4'd3;
localparam [3:0] type00_large_A7 = 4'd0;

localparam [3:0] type00_large_B0 = 4'd2;
localparam [3:0] type00_large_B1 = 4'd1;
localparam [3:0] type00_large_B2 = 4'd10;
localparam [3:0] type00_large_B3 = 4'd9;
localparam [3:0] type00_large_B4 = 4'd6;
localparam [3:0] type00_large_B5 = 4'd5;
localparam [3:0] type00_large_B6 = 4'd14;
localparam [3:0] type00_large_B7 = 4'd13;

// rotation 90, type (0, 0) = (y, x)
// |7  |3  |5  |1  |
// |6  |2  |4  |0  |
// |0' |4' |2' |6' |
// |1' |5' |3' |7' |
// 8-bit word A: {line0, line4, line2, line6, line1, line5, line3, line7}
// 8-bit word B: {line15, line11, line13, line9, line14, line10, line12, line8}
localparam [3:0] type90_large_A0 = 4'd7;
localparam [3:0] type90_large_A1 = 4'd3;
localparam [3:0] type90_large_A2 = 4'd5;
localparam [3:0] type90_large_A3 = 4'd1;
localparam [3:0] type90_large_A4 = 4'd6;
localparam [3:0] type90_large_A5 = 4'd2;
localparam [3:0] type90_large_A6 = 4'd4;
localparam [3:0] type90_large_A7 = 4'd0;

localparam [3:0] type90_large_B0 = 4'd8;
localparam [3:0] type90_large_B1 = 4'd12;
localparam [3:0] type90_large_B2 = 4'd10;
localparam [3:0] type90_large_B3 = 4'd14;
localparam [3:0] type90_large_B4 = 4'd9;
localparam [3:0] type90_large_B5 = 4'd13;
localparam [3:0] type90_large_B6 = 4'd11;
localparam [3:0] type90_large_B7 = 4'd15;

// rotation 180, type (0, 0) = (y, x)
// |7  |6  |0' |1' |
// |1  |0  |6' |7' |
// |5  |4  |2' |3' |
// |3  |2  |4' |5' |
// 8-bit word A: {line0, line1, line8, line9, line12, line13, line4, line5}
// 8-bit word B: {line7, line6, line15, line14, line11, line10, line3, line2}
localparam [3:0] type180_large_A0 = 4'd5;
localparam [3:0] type180_large_A1 = 4'd4;
localparam [3:0] type180_large_A2 = 4'd13;
localparam [3:0] type180_large_A3 = 4'd12;
localparam [3:0] type180_large_A4 = 4'd9;
localparam [3:0] type180_large_A5 = 4'd8;
localparam [3:0] type180_large_A6 = 4'd1;
localparam [3:0] type180_large_A7 = 4'd0;

localparam [3:0] type180_large_B0 = 4'd2;
localparam [3:0] type180_large_B1 = 4'd3;
localparam [3:0] type180_large_B2 = 4'd10;
localparam [3:0] type180_large_B3 = 4'd11;
localparam [3:0] type180_large_B4 = 4'd14;
localparam [3:0] type180_large_B5 = 4'd15;
localparam [3:0] type180_large_B6 = 4'd6;
localparam [3:0] type180_large_B7 = 4'd7;

// rotation 270, type (0, 0) = (y, x)
// |7  |1  |5  |3  |
// |1' |7' |3' |5' |
// |0' |6' |2' |4' |
// |6  |0  |4  |2  |
// 8-bit word A: {line0, line12, line2, line14, line3, line15, line1, line13}
// 8-bit word B: {line5, line9, line7, line11, line6, line10, line4, line8}
// rotation 270
localparam [3:0] type270_large_A0 = 4'd13;
localparam [3:0] type270_large_A1 = 4'd1;
localparam [3:0] type270_large_A2 = 4'd15;
localparam [3:0] type270_large_A3 = 4'd3;
localparam [3:0] type270_large_A4 = 4'd14;
localparam [3:0] type270_large_A5 = 4'd2;
localparam [3:0] type270_large_A6 = 4'd12;
localparam [3:0] type270_large_A7 = 4'd0;

localparam [3:0] type270_large_B0 = 4'd8;
localparam [3:0] type270_large_B1 = 4'd4;
localparam [3:0] type270_large_B2 = 4'd10;
localparam [3:0] type270_large_B3 = 4'd6;
localparam [3:0] type270_large_B4 = 4'd11;
localparam [3:0] type270_large_B5 = 4'd7;
localparam [3:0] type270_large_B6 = 4'd9;
localparam [3:0] type270_large_B7 = 4'd5;

// ----- region 2 ----- //
// rotation 0, type (0, 0) = (y, x)
// |5 |3' |2' |4 |
// |1 |7' |6' |0 |
// |7 |1' |0' |6 |
// |3 |5' |4' |2 |
// 8-bit word A: {line8, line11, line0, line3, line12, line15, line4, line7}
// 8-bit word B: {line5, line6, line13, line14, line1, line2, line9, line10}
// ----- new define for 42x42 qrcode end ----- //
// rotation 0
localparam [3:0] type00_large_R2A0 = 4'd7;
localparam [3:0] type00_large_R2A1 = 4'd4;
localparam [3:0] type00_large_R2A2 = 4'd15;
localparam [3:0] type00_large_R2A3 = 4'd12;
localparam [3:0] type00_large_R2A4 = 4'd3;
localparam [3:0] type00_large_R2A5 = 4'd0;
localparam [3:0] type00_large_R2A6 = 4'd11;
localparam [3:0] type00_large_R2A7 = 4'd8;

localparam [3:0] type00_large_R2B0 = 4'd10;
localparam [3:0] type00_large_R2B1 = 4'd9;
localparam [3:0] type00_large_R2B2 = 4'd2;
localparam [3:0] type00_large_R2B3 = 4'd1;
localparam [3:0] type00_large_R2B4 = 4'd14;
localparam [3:0] type00_large_R2B5 = 4'd13;
localparam [3:0] type00_large_R2B6 = 4'd6;
localparam [3:0] type00_large_R2B7 = 4'd5;

// rotation 90, type (0, 0) = (y, x)
// |5  |1  |7  |3  |
// |4  |0  |6  |2  |
// |2' |6' |0' |4' |
// |3' |7' |1' |5' |
// 8-bit word A: {line2, line6, line0, line4, line3, line7, line1, line5}
// 8-bit word B: {line13, line9, line15, line11, line12, line8, line14, line10}

// rotation 90
localparam [3:0] type90_large_R2A0 = 4'd5;
localparam [3:0] type90_large_R2A1 = 4'd1;
localparam [3:0] type90_large_R2A2 = 4'd7;
localparam [3:0] type90_large_R2A3 = 4'd3;
localparam [3:0] type90_large_R2A4 = 4'd4;
localparam [3:0] type90_large_R2A5 = 4'd0;
localparam [3:0] type90_large_R2A6 = 4'd6;
localparam [3:0] type90_large_R2A7 = 4'd2;

localparam [3:0] type90_large_R2B0 = 4'd10;
localparam [3:0] type90_large_R2B1 = 4'd14;
localparam [3:0] type90_large_R2B2 = 4'd8;
localparam [3:0] type90_large_R2B3 = 4'd12;
localparam [3:0] type90_large_R2B4 = 4'd11;
localparam [3:0] type90_large_R2B5 = 4'd15;
localparam [3:0] type90_large_R2B6 = 4'd9;
localparam [3:0] type90_large_R2B7 = 4'd13;

// rotation 180, type (0, 0) = (y, x)
// |5  |4  |2' |3' |
// |3  |2  |4' |5' |
// |7  |6  |0' |1' |
// |1  |0  |6' |7' |
// 8-bit word A: {line8, line9, line0, line1, line4, line5, line12, line13}
// 8-bit word B: {line15, line14, line7, line6, line3, line2, line11, line10}

localparam [3:0] type180_large_R2A0 = 4'd13;
localparam [3:0] type180_large_R2A1 = 4'd12;
localparam [3:0] type180_large_R2A2 = 4'd5;
localparam [3:0] type180_large_R2A3 = 4'd4;
localparam [3:0] type180_large_R2A4 = 4'd1;
localparam [3:0] type180_large_R2A5 = 4'd0;
localparam [3:0] type180_large_R2A6 = 4'd9;
localparam [3:0] type180_large_R2A7 = 4'd8;

localparam [3:0] type180_large_R2B0 = 4'd10;
localparam [3:0] type180_large_R2B1 = 4'd11;
localparam [3:0] type180_large_R2B2 = 4'd2;
localparam [3:0] type180_large_R2B3 = 4'd3;
localparam [3:0] type180_large_R2B4 = 4'd6;
localparam [3:0] type180_large_R2B5 = 4'd7;
localparam [3:0] type180_large_R2B6 = 4'd14;
localparam [3:0] type180_large_R2B7 = 4'd15;

// rotation 270, type (0, 0) = (y, x)
// |5  |3  |7  |1  |
// |3' |5' |1' |7' |
// |2' |4' |0' |6' |
// |4  |2  |6  |0  |
// 8-bit word A: {line2, line14, line0, line12, line1, line13, line3, line15}
// 8-bit word B: {line7, line11, line5, line9, line4, line8, line6, line10}

localparam [3:0] type270_large_R2A0 = 4'd15;
localparam [3:0] type270_large_R2A1 = 4'd3;
localparam [3:0] type270_large_R2A2 = 4'd13;
localparam [3:0] type270_large_R2A3 = 4'd1;
localparam [3:0] type270_large_R2A4 = 4'd12;
localparam [3:0] type270_large_R2A5 = 4'd0;
localparam [3:0] type270_large_R2A6 = 4'd14;
localparam [3:0] type270_large_R2A7 = 4'd2;

localparam [3:0] type270_large_R2B0 = 4'd10;
localparam [3:0] type270_large_R2B1 = 4'd6;
localparam [3:0] type270_large_R2B2 = 4'd8;
localparam [3:0] type270_large_R2B3 = 4'd4;
localparam [3:0] type270_large_R2B4 = 4'd9;
localparam [3:0] type270_large_R2B5 = 4'd5;
localparam [3:0] type270_large_R2B6 = 4'd11;
localparam [3:0] type270_large_R2B7 = 4'd7;

// ----- 21x21 qrcode ----- //
// ----- region 1 ----- //
// 1 word is 8 bit
// 2 type , each decode we read 6 word, read by rptr to fifo
// word 0, 1, 2, 6, 7, 8, 12, 13, 14on line7, 4, 11, 8, 15, 12, 3, 0
// word 3, 4, 5, 9, 10, 11 on line1, 2, 13, 14, 9, 10, 5, 6
// |line0 |line1 |line2 |line3 |
// |line4 |line5 |line6 |line7 |
// |line8 |line9 |line10|line11|
// |line12|line13|line14|line15|

// rotation 0
// type (0, 0) = (y, x)
// |7 |0' |1' |6 |
// |1 |6' |7' |0 |
// |3 |4' |5' |2 |
// |5 |2' |3' |4 |
// 8-bit word A: {line0, line3, line12, line15, line8, line11, line4, line7}
// 8-bit word B: {line6, line5, line10, line9, line14, line13, line2, line1}
localparam type00_A0 = 4'd7;
localparam type00_A1 = 4'd4;
localparam type00_A2 = 4'd11;
localparam type00_A3 = 4'd8;
localparam type00_A4 = 4'd15;
localparam type00_A5 = 4'd12;
localparam type00_A6 = 4'd3;
localparam type00_A7 = 4'd0;

localparam type00_B0 = 4'd1;
localparam type00_B1 = 4'd2;
localparam type00_B2 = 4'd13;
localparam type00_B3 = 4'd14;
localparam type00_B4 = 4'd9;
localparam type00_B5 = 4'd10;
localparam type00_B6 = 4'd5;
localparam type00_B7 = 4'd6;
// ===== rotation region 1===== //
// rotation 90
// type (0, 0) = (y, x)
// |7  |1  |3  |5  |
// |6  |0  |2  |4  |
// |1' |7' |5' |3' |
// |0' |6' |4' |2' |
// 8-bit word A: {line0, line4, line3, line7, line2, line6, line1, line5}
// 8-bit word B: {line9, line13, line10, line14, line11, line15, line8, line12}
localparam type90_A0 = 4'd5;
localparam type90_A1 = 4'd1;
localparam type90_A2 = 4'd6;
localparam type90_A3 = 4'd2;
localparam type90_A4 = 4'd7;
localparam type90_A5 = 4'd3;
localparam type90_A6 = 4'd4;
localparam type90_A7 = 4'd0;

localparam type90_B0 = 4'd12;
localparam type90_B1 = 4'd8;
localparam type90_B2 = 4'd15;
localparam type90_B3 = 4'd11;
localparam type90_B4 = 4'd14;
localparam type90_B5 = 4'd10;
localparam type90_B6 = 4'd13;
localparam type90_B7 = 4'd9;
// rotation 180
// type (0, 0) = (y, x)
// |7  |6  |1' |0' |
// |5  |4  |3' |2' |
// |3  |2  |5' |4' |
// |1  |0  |7' |6' |
// 8-bit word A: {line0, line1, line4, line5, line8, line9, line12, line13}
// 8-bit word B: {line14, line15, line10, line11, line6, line7, line2, line3}
localparam type180_A0 = 4'd13;
localparam type180_A1 = 4'd12;
localparam type180_A2 = 4'd9;
localparam type180_A3 = 4'd8;
localparam type180_A4 = 4'd5;
localparam type180_A5 = 4'd4;
localparam type180_A6 = 4'd1;
localparam type180_A7 = 4'd0;

localparam type180_B0 = 4'd3;
localparam type180_B1 = 4'd2;
localparam type180_B2 = 4'd7;
localparam type180_B3 = 4'd6;
localparam type180_B4 = 4'd11;
localparam type180_B5 = 4'd10;
localparam type180_B6 = 4'd15;
localparam type180_B7 = 4'd14;

// rotation 270
// type (0, 0) = (y, x)
// |7  |5  |3  |1  |
// |0' |2' |4' |6' |
// |1' |3' |5' |7' |
// |6  |4  |2  |0  |
// 8-bit word A: {line0, line12, line1, line13, line2, line14, line3, line15}
// 8-bit word B: {line11, line7, line10, line6, line9, line5, line8, line4}
localparam type270_A0 = 4'd15;
localparam type270_A1 = 4'd3;
localparam type270_A2 = 4'd14;
localparam type270_A3 = 4'd2;
localparam type270_A4 = 4'd13;
localparam type270_A5 = 4'd1;
localparam type270_A6 = 4'd12;
localparam type270_A7 = 4'd0;

localparam type270_B0 = 4'd4;
localparam type270_B1 = 4'd8;
localparam type270_B2 = 4'd5;
localparam type270_B3 = 4'd9;
localparam type270_B4 = 4'd6;
localparam type270_B5 = 4'd10;
localparam type270_B6 = 4'd7;
localparam type270_B7 = 4'd11;

wire [1:0] ty = decode_type[3:2];
wire [1:0] tx = decode_type[1:0];

reg [3:0] base_A0, base_A1, base_A2, base_A3, base_A4, base_A5, base_A6, base_A7;
reg [3:0] base_B0, base_B1, base_B2, base_B3, base_B4, base_B5, base_B6, base_B7;
reg [3:0] base_R2A0, base_R2A1, base_R2A2, base_R2A3, base_R2A4, base_R2A5, base_R2A6, base_R2A7;
reg [3:0] base_R2B0, base_R2B1, base_R2B2, base_R2B3, base_R2B4, base_R2B5, base_R2B6, base_R2B7;



// ----- region 2 ----- //
// (0, 0)
// 1 word is 8 bit
// 2 type , each decode we read 6 word, read by rptr to fifo
// WordA: word 15, 16 = {line12, line15, line8, line11, line4, line7, line0, line3};
// WordB: word 17, 18 = {line2, line1, line6, line5, line10, line9, line14, line13};
// |line0 |line1 |line2 |line3 |
// |line4 |line5 |line6 |line7 |
// |line8 |line9 |line10|line11|
// |line12|line13|line14|line15|

// rotation 0
// type (0, 0) = (y, x)
// |1 |6' |7' |0 |
// |3 |4' |5' |2 |
// |5 |2' |3' |4 |
// |7 |0' |1' |6 |
// word 15, 16 = {line12, line15, line8, line11, line4, line7, line0, line3};
// word 17, 18 = {line2, line1, line6, line5, line10, line9, line14, line13};
localparam [3:0] type00_R2A0 = 4'd3;
localparam [3:0] type00_R2A1 = 4'd0;
localparam [3:0] type00_R2A2 = 4'd7;
localparam [3:0] type00_R2A3 = 4'd4;
localparam [3:0] type00_R2A4 = 4'd11;
localparam [3:0] type00_R2A5 = 4'd8;
localparam [3:0] type00_R2A6 = 4'd15;
localparam [3:0] type00_R2A7 = 4'd12;

localparam [3:0] type00_R2B0 = 4'd13;
localparam [3:0] type00_R2B1 = 4'd14;
localparam [3:0] type00_R2B2 = 4'd9;
localparam [3:0] type00_R2B3 = 4'd10;
localparam [3:0] type00_R2B4 = 4'd5;
localparam [3:0] type00_R2B5 = 4'd6;
localparam [3:0] type00_R2B6 = 4'd1;
localparam [3:0] type00_R2B7 = 4'd2;
// rotation 90
// type (0, 0) = (y, x)
// |1  |3  |5  |7  |
// |0  |2  |4  |6  |
// |7' |5' |3' |1' |
// |6' |4' |2' |0' |
// word 15, 16 = {line3, line7, line2, line6, line1, line5, line0, line4};
// word 17, 18 = {line8, line12, line9, line13, line10, line14, line11, line15};
localparam [3:0] type90_R2A0 = 4'd4;
localparam [3:0] type90_R2A1 = 4'd0;
localparam [3:0] type90_R2A2 = 4'd5;
localparam [3:0] type90_R2A3 = 4'd1;
localparam [3:0] type90_R2A4 = 4'd6;
localparam [3:0] type90_R2A5 = 4'd2;
localparam [3:0] type90_R2A6 = 4'd7;
localparam [3:0] type90_R2A7 = 4'd3;

localparam [3:0] type90_R2B0 = 4'd15;
localparam [3:0] type90_R2B1 = 4'd11;
localparam [3:0] type90_R2B2 = 4'd14;
localparam [3:0] type90_R2B3 = 4'd10;
localparam [3:0] type90_R2B4 = 4'd13;
localparam [3:0] type90_R2B5 = 4'd9;
localparam [3:0] type90_R2B6 = 4'd12;
localparam [3:0] type90_R2B7 = 4'd8;
// rotation 180
// type (0, 0) = (y, x)
// |1  |0  |7' |6' |
// |7  |6  |1' |0' |
// |5  |4  |3' |2' |
// |3  |2  |5' |4' |
// word 15, 16 = {line4, line5, line8, line9, line12, line13, line0, line1};
// word 17, 18 = {line2, line3, line14, line15, line10, line11, line6, line7};
localparam [3:0] type180_R2A0 = 4'd1;
localparam [3:0] type180_R2A1 = 4'd0;
localparam [3:0] type180_R2A2 = 4'd13;
localparam [3:0] type180_R2A3 = 4'd12;
localparam [3:0] type180_R2A4 = 4'd9;
localparam [3:0] type180_R2A5 = 4'd8;
localparam [3:0] type180_R2A6 = 4'd5;
localparam [3:0] type180_R2A7 = 4'd4;

localparam [3:0] type180_R2B0 = 4'd7;
localparam [3:0] type180_R2B1 = 4'd6;
localparam [3:0] type180_R2B2 = 4'd11;
localparam [3:0] type180_R2B3 = 4'd10;
localparam [3:0] type180_R2B4 = 4'd15;
localparam [3:0] type180_R2B5 = 4'd14;
localparam [3:0] type180_R2B6 = 4'd3;
localparam [3:0] type180_R2B7 = 4'd2;
// rotation 270
// type (0, 0) = (y, x)
// |1  |7  |5  |3  |
// |6' |0' |2' |4' |
// |7' |1' |3' |5' |
// |0  |6  |4  |2  |
// word 15, 16 = {line1, line13, line2, line14, line3, line15, line0, line12};
// word 17, 18 = {line8, line4, line11, line7, line10, line6, line9, line5};
localparam [3:0] type270_R2A0 = 4'd12;
localparam [3:0] type270_R2A1 = 4'd0;
localparam [3:0] type270_R2A2 = 4'd15;
localparam [3:0] type270_R2A3 = 4'd3;
localparam [3:0] type270_R2A4 = 4'd14;
localparam [3:0] type270_R2A5 = 4'd2;
localparam [3:0] type270_R2A6 = 4'd13;
localparam [3:0] type270_R2A7 = 4'd1;

localparam [3:0] type270_R2B0 = 4'd5;
localparam [3:0] type270_R2B1 = 4'd9;
localparam [3:0] type270_R2B2 = 4'd6;
localparam [3:0] type270_R2B3 = 4'd10;
localparam [3:0] type270_R2B4 = 4'd7;
localparam [3:0] type270_R2B5 = 4'd11;
localparam [3:0] type270_R2B6 = 4'd4;
localparam [3:0] type270_R2B7 = 4'd8;

// ----- region 1 ----- //
wire [3:0] A_sel0 = { (base_A0[3:2] + ty), (base_A0[1:0] + tx) };
wire [3:0] A_sel1 = { (base_A1[3:2] + ty), (base_A1[1:0] + tx) };
wire [3:0] A_sel2 = { (base_A2[3:2] + ty), (base_A2[1:0] + tx) };
wire [3:0] A_sel3 = { (base_A3[3:2] + ty), (base_A3[1:0] + tx) };
wire [3:0] A_sel4 = { (base_A4[3:2] + ty), (base_A4[1:0] + tx) };
wire [3:0] A_sel5 = { (base_A5[3:2] + ty), (base_A5[1:0] + tx) };
wire [3:0] A_sel6 = { (base_A6[3:2] + ty), (base_A6[1:0] + tx) };
wire [3:0] A_sel7 = { (base_A7[3:2] + ty), (base_A7[1:0] + tx) };

wire [3:0] B_sel0 = { (base_B0[3:2] + ty), (base_B0[1:0] + tx) };
wire [3:0] B_sel1 = { (base_B1[3:2] + ty), (base_B1[1:0] + tx) };
wire [3:0] B_sel2 = { (base_B2[3:2] + ty), (base_B2[1:0] + tx) };
wire [3:0] B_sel3 = { (base_B3[3:2] + ty), (base_B3[1:0] + tx) };
wire [3:0] B_sel4 = { (base_B4[3:2] + ty), (base_B4[1:0] + tx) };
wire [3:0] B_sel5 = { (base_B5[3:2] + ty), (base_B5[1:0] + tx) };
wire [3:0] B_sel6 = { (base_B6[3:2] + ty), (base_B6[1:0] + tx) };
wire [3:0] B_sel7 = { (base_B7[3:2] + ty), (base_B7[1:0] + tx) };


// Type A word: 0, 1, 2, 6, 7, 8, 12, 13, 14
// Type B word: 3, 4, 5, 9, 10, 11
wire use_A_now =
  (global_word_idx==6'd0 ) | (global_word_idx==6'd1 ) | (global_word_idx==6'd2 ) |
  (global_word_idx==6'd6 ) | (global_word_idx==6'd7 ) | (global_word_idx==6'd8 ) |
  (global_word_idx==6'd12) | (global_word_idx==6'd13) | (global_word_idx==6'd14);

wire [3:0] sel_line0 = use_A_now ? A_sel0 : B_sel0;
wire [3:0] sel_line1 = use_A_now ? A_sel1 : B_sel1;
wire [3:0] sel_line2 = use_A_now ? A_sel2 : B_sel2;
wire [3:0] sel_line3 = use_A_now ? A_sel3 : B_sel3;
wire [3:0] sel_line4 = use_A_now ? A_sel4 : B_sel4;
wire [3:0] sel_line5 = use_A_now ? A_sel5 : B_sel5;
wire [3:0] sel_line6 = use_A_now ? A_sel6 : B_sel6;
wire [3:0] sel_line7 = use_A_now ? A_sel7 : B_sel7;
// ----- region 1 ----- //

// ----- region 2 ----- //
wire [3:0] R2A_sel0 = { (base_R2A0[3:2] + ty), (base_R2A0[1:0] + tx) };
wire [3:0] R2A_sel1 = { (base_R2A1[3:2] + ty), (base_R2A1[1:0] + tx) };
wire [3:0] R2A_sel2 = { (base_R2A2[3:2] + ty), (base_R2A2[1:0] + tx) };
wire [3:0] R2A_sel3 = { (base_R2A3[3:2] + ty), (base_R2A3[1:0] + tx) };
wire [3:0] R2A_sel4 = { (base_R2A4[3:2] + ty), (base_R2A4[1:0] + tx) };
wire [3:0] R2A_sel5 = { (base_R2A5[3:2] + ty), (base_R2A5[1:0] + tx) };
wire [3:0] R2A_sel6 = { (base_R2A6[3:2] + ty), (base_R2A6[1:0] + tx) };
wire [3:0] R2A_sel7 = { (base_R2A7[3:2] + ty), (base_R2A7[1:0] + tx) };

wire [3:0] R2B_sel0 = { (base_R2B0[3:2] + ty), (base_R2B0[1:0] + tx) };
wire [3:0] R2B_sel1 = { (base_R2B1[3:2] + ty), (base_R2B1[1:0] + tx) };
wire [3:0] R2B_sel2 = { (base_R2B2[3:2] + ty), (base_R2B2[1:0] + tx) };
wire [3:0] R2B_sel3 = { (base_R2B3[3:2] + ty), (base_R2B3[1:0] + tx) };
wire [3:0] R2B_sel4 = { (base_R2B4[3:2] + ty), (base_R2B4[1:0] + tx) };
wire [3:0] R2B_sel5 = { (base_R2B5[3:2] + ty), (base_R2B5[1:0] + tx) };
wire [3:0] R2B_sel6 = { (base_R2B6[3:2] + ty), (base_R2B6[1:0] + tx) };
wire [3:0] R2B_sel7 = { (base_R2B7[3:2] + ty), (base_R2B7[1:0] + tx) };

wire use_A_now_r2 = (global_word_idx==5'd15) | (global_word_idx==5'd16);

wire [3:0] R2_sel_line0 = use_A_now_r2 ? R2A_sel0 : R2B_sel0;
wire [3:0] R2_sel_line1 = use_A_now_r2 ? R2A_sel1 : R2B_sel1;
wire [3:0] R2_sel_line2 = use_A_now_r2 ? R2A_sel2 : R2B_sel2;
wire [3:0] R2_sel_line3 = use_A_now_r2 ? R2A_sel3 : R2B_sel3;
wire [3:0] R2_sel_line4 = use_A_now_r2 ? R2A_sel4 : R2B_sel4;
wire [3:0] R2_sel_line5 = use_A_now_r2 ? R2A_sel5 : R2B_sel5;
wire [3:0] R2_sel_line6 = use_A_now_r2 ? R2A_sel6 : R2B_sel6;
wire [3:0] R2_sel_line7 = use_A_now_r2 ? R2A_sel7 : R2B_sel7;
// ----- region 2 ----- //

always @(*) begin
  if (large_qrcode_flag) begin
    case (rot_state)
      ROT_0: begin
        base_A0 = type00_large_A0; base_A1 = type00_large_A1; base_A2 = type00_large_A2; base_A3 = type00_large_A3;
        base_A4 = type00_large_A4; base_A5 = type00_large_A5; base_A6 = type00_large_A6; base_A7 = type00_large_A7;

        base_B0 = type00_large_B0; base_B1 = type00_large_B1; base_B2 = type00_large_B2; base_B3 = type00_large_B3;
        base_B4 = type00_large_B4; base_B5 = type00_large_B5; base_B6 = type00_large_B6; base_B7 = type00_large_B7;

        base_R2A0 = type00_large_R2A0; base_R2A1 = type00_large_R2A1; base_R2A2 = type00_large_R2A2; base_R2A3 = type00_large_R2A3;
        base_R2A4 = type00_large_R2A4; base_R2A5 = type00_large_R2A5; base_R2A6 = type00_large_R2A6; base_R2A7 = type00_large_R2A7;

        base_R2B0 = type00_large_R2B0; base_R2B1 = type00_large_R2B1; base_R2B2 = type00_large_R2B2; base_R2B3 = type00_large_R2B3;
        base_R2B4 = type00_large_R2B4; base_R2B5 = type00_large_R2B5; base_R2B6 = type00_large_R2B6; base_R2B7 = type00_large_R2B7;
      end
      ROT_90: begin
        base_A0 = type90_large_A0; base_A1 = type90_large_A1; base_A2 = type90_large_A2; base_A3 = type90_large_A3;
        base_A4 = type90_large_A4; base_A5 = type90_large_A5; base_A6 = type90_large_A6; base_A7 = type90_large_A7;

        base_B0 = type90_large_B0; base_B1 = type90_large_B1; base_B2 = type90_large_B2; base_B3 = type90_large_B3;
        base_B4 = type90_large_B4; base_B5 = type90_large_B5; base_B6 = type90_large_B6; base_B7 = type90_large_B7;

        base_R2A0 = type90_large_R2A0; base_R2A1 = type90_large_R2A1; base_R2A2 = type90_large_R2A2; base_R2A3 = type90_large_R2A3;
        base_R2A4 = type90_large_R2A4; base_R2A5 = type90_large_R2A5; base_R2A6 = type90_large_R2A6; base_R2A7 = type90_large_R2A7;

        base_R2B0 = type90_large_R2B0; base_R2B1 = type90_large_R2B1; base_R2B2 = type90_large_R2B2; base_R2B3 = type90_large_R2B3;
        base_R2B4 = type90_large_R2B4; base_R2B5 = type90_large_R2B5; base_R2B6 = type90_large_R2B6; base_R2B7 = type90_large_R2B7;
      end
      ROT_180: begin
        base_A0 = type180_large_A0; base_A1 = type180_large_A1; base_A2 = type180_large_A2; base_A3 = type180_large_A3;
        base_A4 = type180_large_A4; base_A5 = type180_large_A5; base_A6 = type180_large_A6; base_A7 = type180_large_A7;

        base_B0 = type180_large_B0; base_B1 = type180_large_B1; base_B2 = type180_large_B2; base_B3 = type180_large_B3;
        base_B4 = type180_large_B4; base_B5 = type180_large_B5; base_B6 = type180_large_B6; base_B7 = type180_large_B7;

        base_R2A0 = type180_large_R2A0; base_R2A1 = type180_large_R2A1; base_R2A2 = type180_large_R2A2; base_R2A3 = type180_large_R2A3;
        base_R2A4 = type180_large_R2A4; base_R2A5 = type180_large_R2A5; base_R2A6 = type180_large_R2A6; base_R2A7 = type180_large_R2A7;

        base_R2B0 = type180_large_R2B0; base_R2B1 = type180_large_R2B1; base_R2B2 = type180_large_R2B2; base_R2B3 = type180_large_R2B3;
        base_R2B4 = type180_large_R2B4; base_R2B5 = type180_large_R2B5; base_R2B6 = type180_large_R2B6; base_R2B7 = type180_large_R2B7;
      end
      ROT_270: begin
        base_A0 = type270_large_A0; base_A1 = type270_large_A1; base_A2 = type270_large_A2; base_A3 = type270_large_A3;
        base_A4 = type270_large_A4; base_A5 = type270_large_A5; base_A6 = type270_large_A6; base_A7 = type270_large_A7;

        base_B0 = type270_large_B0; base_B1 = type270_large_B1; base_B2 = type270_large_B2; base_B3 = type270_large_B3;
        base_B4 = type270_large_B4; base_B5 = type270_large_B5; base_B6 = type270_large_B6; base_B7 = type270_large_B7;

        base_R2A0 = type270_large_R2A0; base_R2A1 = type270_large_R2A1; base_R2A2 = type270_large_R2A2; base_R2A3 = type270_large_R2A3;
        base_R2A4 = type270_large_R2A4; base_R2A5 = type270_large_R2A5; base_R2A6 = type270_large_R2A6; base_R2A7 = type270_large_R2A7;

        base_R2B0 = type270_large_R2B0; base_R2B1 = type270_large_R2B1; base_R2B2 = type270_large_R2B2; base_R2B3 = type270_large_R2B3;
        base_R2B4 = type270_large_R2B4; base_R2B5 = type270_large_R2B5; base_R2B6 = type270_large_R2B6; base_R2B7 = type270_large_R2B7;
      end
      default: begin
        base_A0 = type00_large_A0; base_A1 = type00_large_A1; base_A2 = type00_large_A2; base_A3 = type00_large_A3;
        base_A4 = type00_large_A4; base_A5 = type00_large_A5; base_A6 = type00_large_A6; base_A7 = type00_large_A7;

        base_B0 = type00_large_B0; base_B1 = type00_large_B1; base_B2 = type00_large_B2; base_B3 = type00_large_B3;
        base_B4 = type00_large_B4; base_B5 = type00_large_B5; base_B6 = type00_large_B6; base_B7 = type00_large_B7;

        base_R2A0 = type00_large_R2A0; base_R2A1 = type00_large_R2A1; base_R2A2 = type00_large_R2A2; base_R2A3 = type00_large_R2A3;
        base_R2A4 = type00_large_R2A4; base_R2A5 = type00_large_R2A5; base_R2A6 = type00_large_R2A6; base_R2A7 = type00_large_R2A7;
        
        base_R2B0 = type00_large_R2B0; base_R2B1 = type00_large_R2B1; base_R2B2 = type00_large_R2B2; base_R2B3 = type00_large_R2B3;
        base_R2B4 = type00_large_R2B4; base_R2B5 = type00_large_R2B5; base_R2B6 = type00_large_R2B6; base_R2B7 = type00_large_R2B7;
      end
    endcase
  end else begin
    case (rot_state)
      ROT_0: begin
        base_A0 = type00_A0; base_A1 = type00_A1; base_A2 = type00_A2; base_A3 = type00_A3;
        base_A4 = type00_A4; base_A5 = type00_A5; base_A6 = type00_A6; base_A7 = type00_A7;

        base_B0 = type00_B0; base_B1 = type00_B1; base_B2 = type00_B2; base_B3 = type00_B3;
        base_B4 = type00_B4; base_B5 = type00_B5; base_B6 = type00_B6; base_B7 = type00_B7;

        base_R2A0 = type00_R2A0; base_R2A1 = type00_R2A1; base_R2A2 = type00_R2A2; base_R2A3 = type00_R2A3;
        base_R2A4 = type00_R2A4; base_R2A5 = type00_R2A5; base_R2A6 = type00_R2A6; base_R2A7 = type00_R2A7;

        base_R2B0 = type00_R2B0; base_R2B1 = type00_R2B1; base_R2B2 = type00_R2B2; base_R2B3 = type00_R2B3;
        base_R2B4 = type00_R2B4; base_R2B5 = type00_R2B5; base_R2B6 = type00_R2B6; base_R2B7 = type00_R2B7;
      end
      ROT_90: begin
        base_A0 = type90_A0; base_A1 = type90_A1; base_A2 = type90_A2; base_A3 = type90_A3;
        base_A4 = type90_A4; base_A5 = type90_A5; base_A6 = type90_A6; base_A7 = type90_A7;

        base_B0 = type90_B0; base_B1 = type90_B1; base_B2 = type90_B2; base_B3 = type90_B3;
        base_B4 = type90_B4; base_B5 = type90_B5; base_B6 = type90_B6; base_B7 = type90_B7;

        base_R2A0 = type90_R2A0; base_R2A1 = type90_R2A1; base_R2A2 = type90_R2A2; base_R2A3 = type90_R2A3;
        base_R2A4 = type90_R2A4; base_R2A5 = type90_R2A5; base_R2A6 = type90_R2A6; base_R2A7 = type90_R2A7;

        base_R2B0 = type90_R2B0; base_R2B1 = type90_R2B1; base_R2B2 = type90_R2B2; base_R2B3 = type90_R2B3;
        base_R2B4 = type90_R2B4; base_R2B5 = type90_R2B5; base_R2B6 = type90_R2B6; base_R2B7 = type90_R2B7;
      end
      ROT_180: begin
        base_A0 = type180_A0; base_A1 = type180_A1; base_A2 = type180_A2; base_A3 = type180_A3;
        base_A4 = type180_A4; base_A5 = type180_A5; base_A6 = type180_A6; base_A7 = type180_A7;

        base_B0 = type180_B0; base_B1 = type180_B1; base_B2 = type180_B2; base_B3 = type180_B3;
        base_B4 = type180_B4; base_B5 = type180_B5; base_B6 = type180_B6; base_B7 = type180_B7;

        base_R2A0 = type180_R2A0; base_R2A1 = type180_R2A1; base_R2A2 = type180_R2A2; base_R2A3 = type180_R2A3;
        base_R2A4 = type180_R2A4; base_R2A5 = type180_R2A5; base_R2A6 = type180_R2A6; base_R2A7 = type180_R2A7;

        base_R2B0 = type180_R2B0; base_R2B1 = type180_R2B1; base_R2B2 = type180_R2B2; base_R2B3 = type180_R2B3;
        base_R2B4 = type180_R2B4; base_R2B5 = type180_R2B5; base_R2B6 = type180_R2B6; base_R2B7 = type180_R2B7;
      end
      ROT_270: begin
        base_A0 = type270_A0; base_A1 = type270_A1; base_A2 = type270_A2; base_A3 = type270_A3;
        base_A4 = type270_A4; base_A5 = type270_A5; base_A6 = type270_A6; base_A7 = type270_A7;

        base_B0 = type270_B0; base_B1 = type270_B1; base_B2 = type270_B2; base_B3 = type270_B3;
        base_B4 = type270_B4; base_B5 = type270_B5; base_B6 = type270_B6; base_B7 = type270_B7;

        base_R2A0 = type270_R2A0; base_R2A1 = type270_R2A1; base_R2A2 = type270_R2A2; base_R2A3 = type270_R2A3;
        base_R2A4 = type270_R2A4; base_R2A5 = type270_R2A5; base_R2A6 = type270_R2A6; base_R2A7 = type270_R2A7;

        base_R2B0 = type270_R2B0; base_R2B1 = type270_R2B1; base_R2B2 = type270_R2B2; base_R2B3 = type270_R2B3;
        base_R2B4 = type270_R2B4; base_R2B5 = type270_R2B5; base_R2B6 = type270_R2B6; base_R2B7 = type270_R2B7;
      end
      default: begin
        base_A0 = type00_A0; base_A1 = type00_A1; base_A2 = type00_A2; base_A3 = type00_A3;
        base_A4 = type00_A4; base_A5 = type00_A5; base_A6 = type00_A6; base_A7 = type00_A7;

        base_B0 = type00_B0; base_B1 = type00_B1; base_B2 = type00_B2; base_B3 = type00_B3;
        base_B4 = type00_B4; base_B5 = type00_B5; base_B6 = type00_B6; base_B7 = type00_B7;

        base_R2A0 = type00_R2A0; base_R2A1 = type00_R2A1; base_R2A2 = type00_R2A2; base_R2A3 = type00_R2A3;
        base_R2A4 = type00_R2A4; base_R2A5 = type00_R2A5; base_R2A6 = type00_R2A6; base_R2A7 = type00_R2A7;
        
        base_R2B0 = type00_R2B0; base_R2B1 = type00_R2B1; base_R2B2 = type00_R2B2; base_R2B3 = type00_R2B3;
        base_R2B4 = type00_R2B4; base_R2B5 = type00_R2B5; base_R2B6 = type00_R2B6; base_R2B7 = type00_R2B7;
      end
    endcase
  end
end



// select how to read the fifo to decode data
wire [3:0] sel_line0_final = (decode_state==DECODE_DECODE3) ? R2_sel_line0 : sel_line0;
wire [3:0] sel_line1_final = (decode_state==DECODE_DECODE3) ? R2_sel_line1 : sel_line1;
wire [3:0] sel_line2_final = (decode_state==DECODE_DECODE3) ? R2_sel_line2 : sel_line2;
wire [3:0] sel_line3_final = (decode_state==DECODE_DECODE3) ? R2_sel_line3 : sel_line3;
wire [3:0] sel_line4_final = (decode_state==DECODE_DECODE3) ? R2_sel_line4 : sel_line4;
wire [3:0] sel_line5_final = (decode_state==DECODE_DECODE3) ? R2_sel_line5 : sel_line5;
wire [3:0] sel_line6_final = (decode_state==DECODE_DECODE3) ? R2_sel_line6 : sel_line6;
wire [3:0] sel_line7_final = (decode_state==DECODE_DECODE3) ? R2_sel_line7 : sel_line7;
// ---- read pointers ----
reg [3:0] fifo_rptr0,  fifo_rptr1,  fifo_rptr2,  fifo_rptr3;
reg [3:0] fifo_rptr4,  fifo_rptr5,  fifo_rptr6,  fifo_rptr7;
reg [3:0] fifo_rptr8,  fifo_rptr9,  fifo_rptr10, fifo_rptr11;
reg [3:0] fifo_rptr12, fifo_rptr13, fifo_rptr14, fifo_rptr15;

reg [3:0] fifo_rptr0_n,  fifo_rptr1_n,  fifo_rptr2_n,  fifo_rptr3_n;
reg [3:0] fifo_rptr4_n,  fifo_rptr5_n,  fifo_rptr6_n,  fifo_rptr7_n;
reg [3:0] fifo_rptr8_n,  fifo_rptr9_n,  fifo_rptr10_n, fifo_rptr11_n;
reg [3:0] fifo_rptr12_n, fifo_rptr13_n, fifo_rptr14_n, fifo_rptr15_n;

wire in_decode_pop  = (state==DECODE) && (decode_state==DECODE_DECODE1);
wire in_decode_pop2 = (state==DECODE) && (decode_state==DECODE_DECODE2);
wire in_decode_pop3 = (state==DECODE) && (decode_state==DECODE_DECODE3);
wire in_decode_pop_control = in_decode_pop | in_decode_pop2 | in_decode_pop3;

wire hit_line0  = (sel_line0_final==4'd0 )|(sel_line1_final==4'd0 )|(sel_line2_final==4'd0 )|(sel_line3_final==4'd0 )|
                  (sel_line4_final==4'd0 )|(sel_line5_final==4'd0 )|(sel_line6_final==4'd0 )|(sel_line7_final==4'd0 );
wire hit_line1  = (sel_line0_final==4'd1 )|(sel_line1_final==4'd1 )|(sel_line2_final==4'd1 )|(sel_line3_final==4'd1 )|
                  (sel_line4_final==4'd1 )|(sel_line5_final==4'd1 )|(sel_line6_final==4'd1 )|(sel_line7_final==4'd1 );
wire hit_line2  = (sel_line0_final==4'd2 )|(sel_line1_final==4'd2 )|(sel_line2_final==4'd2 )|(sel_line3_final==4'd2 )|
                  (sel_line4_final==4'd2 )|(sel_line5_final==4'd2 )|(sel_line6_final==4'd2 )|(sel_line7_final==4'd2 );
wire hit_line3  = (sel_line0_final==4'd3 )|(sel_line1_final==4'd3 )|(sel_line2_final==4'd3 )|(sel_line3_final==4'd3 )|
                  (sel_line4_final==4'd3 )|(sel_line5_final==4'd3 )|(sel_line6_final==4'd3 )|(sel_line7_final==4'd3 );
wire hit_line4  = (sel_line0_final==4'd4 )|(sel_line1_final==4'd4 )|(sel_line2_final==4'd4 )|(sel_line3_final==4'd4 )|
                  (sel_line4_final==4'd4 )|(sel_line5_final==4'd4 )|(sel_line6_final==4'd4 )|(sel_line7_final==4'd4 );
wire hit_line5  = (sel_line0_final==4'd5 )|(sel_line1_final==4'd5 )|(sel_line2_final==4'd5 )|(sel_line3_final==4'd5 )|
                  (sel_line4_final==4'd5 )|(sel_line5_final==4'd5 )|(sel_line6_final==4'd5 )|(sel_line7_final==4'd5 );
wire hit_line6  = (sel_line0_final==4'd6 )|(sel_line1_final==4'd6 )|(sel_line2_final==4'd6 )|(sel_line3_final==4'd6 )|
                  (sel_line4_final==4'd6 )|(sel_line5_final==4'd6 )|(sel_line6_final==4'd6 )|(sel_line7_final==4'd6 );
wire hit_line7  = (sel_line0_final==4'd7 )|(sel_line1_final==4'd7 )|(sel_line2_final==4'd7 )|(sel_line3_final==4'd7 )|
                  (sel_line4_final==4'd7 )|(sel_line5_final==4'd7 )|(sel_line6_final==4'd7 )|(sel_line7_final==4'd7 );
wire hit_line8  = (sel_line0_final==4'd8 )|(sel_line1_final==4'd8 )|(sel_line2_final==4'd8 )|(sel_line3_final==4'd8 )|
                  (sel_line4_final==4'd8 )|(sel_line5_final==4'd8 )|(sel_line6_final==4'd8 )|(sel_line7_final==4'd8 );
wire hit_line9  = (sel_line0_final==4'd9 )|(sel_line1_final==4'd9 )|(sel_line2_final==4'd9 )|(sel_line3_final==4'd9 )|
                  (sel_line4_final==4'd9 )|(sel_line5_final==4'd9 )|(sel_line6_final==4'd9 )|(sel_line7_final==4'd9 );
wire hit_line10 = (sel_line0_final==4'd10)|(sel_line1_final==4'd10)|(sel_line2_final==4'd10)|(sel_line3_final==4'd10)|
                  (sel_line4_final==4'd10)|(sel_line5_final==4'd10)|(sel_line6_final==4'd10)|(sel_line7_final==4'd10);
wire hit_line11 = (sel_line0_final==4'd11)|(sel_line1_final==4'd11)|(sel_line2_final==4'd11)|(sel_line3_final==4'd11)|
                  (sel_line4_final==4'd11)|(sel_line5_final==4'd11)|(sel_line6_final==4'd11)|(sel_line7_final==4'd11);
wire hit_line12 = (sel_line0_final==4'd12)|(sel_line1_final==4'd12)|(sel_line2_final==4'd12)|(sel_line3_final==4'd12)|
                  (sel_line4_final==4'd12)|(sel_line5_final==4'd12)|(sel_line6_final==4'd12)|(sel_line7_final==4'd12);
wire hit_line13 = (sel_line0_final==4'd13)|(sel_line1_final==4'd13)|(sel_line2_final==4'd13)|(sel_line3_final==4'd13)|
                  (sel_line4_final==4'd13)|(sel_line5_final==4'd13)|(sel_line6_final==4'd13)|(sel_line7_final==4'd13);
wire hit_line14 = (sel_line0_final==4'd14)|(sel_line1_final==4'd14)|(sel_line2_final==4'd14)|(sel_line3_final==4'd14)|
                  (sel_line4_final==4'd14)|(sel_line5_final==4'd14)|(sel_line6_final==4'd14)|(sel_line7_final==4'd14);
wire hit_line15 = (sel_line0_final==4'd15)|(sel_line1_final==4'd15)|(sel_line2_final==4'd15)|(sel_line3_final==4'd15)|
                  (sel_line4_final==4'd15)|(sel_line5_final==4'd15)|(sel_line6_final==4'd15)|(sel_line7_final==4'd15);

// read ptr enable
wire rd0_en  = in_decode_pop_control && hit_line0;
wire rd1_en  = in_decode_pop_control && hit_line1;
wire rd2_en  = in_decode_pop_control && hit_line2;
wire rd3_en  = in_decode_pop_control && hit_line3;
wire rd4_en  = in_decode_pop_control && hit_line4;
wire rd5_en  = in_decode_pop_control && hit_line5;
wire rd6_en  = in_decode_pop_control && hit_line6;
wire rd7_en  = in_decode_pop_control && hit_line7;
wire rd8_en  = in_decode_pop_control && hit_line8;
wire rd9_en  = in_decode_pop_control && hit_line9;
wire rd10_en = in_decode_pop_control && hit_line10;
wire rd11_en = in_decode_pop_control && hit_line11;
wire rd12_en = in_decode_pop_control && hit_line12;
wire rd13_en = in_decode_pop_control && hit_line13;
wire rd14_en = in_decode_pop_control && hit_line14;
wire rd15_en = in_decode_pop_control && hit_line15;

always @(*) begin
  fifo_rptr0_n  = rd0_en  ? ((fifo_rptr0  == shift_reg_depth-1) ? 4'd0 : (fifo_rptr0  + 4'd1)) : fifo_rptr0;
  fifo_rptr1_n  = rd1_en  ? ((fifo_rptr1  == shift_reg_depth-1) ? 4'd0 : (fifo_rptr1  + 4'd1)) : fifo_rptr1;
  fifo_rptr2_n  = rd2_en  ? ((fifo_rptr2  == shift_reg_depth-1) ? 4'd0 : (fifo_rptr2  + 4'd1)) : fifo_rptr2;
  fifo_rptr3_n  = rd3_en  ? ((fifo_rptr3  == shift_reg_depth-1) ? 4'd0 : (fifo_rptr3  + 4'd1)) : fifo_rptr3;
  fifo_rptr4_n  = rd4_en  ? ((fifo_rptr4  == shift_reg_depth-1) ? 4'd0 : (fifo_rptr4  + 4'd1)) : fifo_rptr4;
  fifo_rptr5_n  = rd5_en  ? ((fifo_rptr5  == shift_reg_depth-1) ? 4'd0 : (fifo_rptr5  + 4'd1)) : fifo_rptr5;
  fifo_rptr6_n  = rd6_en  ? ((fifo_rptr6  == shift_reg_depth-1) ? 4'd0 : (fifo_rptr6  + 4'd1)) : fifo_rptr6;
  fifo_rptr7_n  = rd7_en  ? ((fifo_rptr7  == shift_reg_depth-1) ? 4'd0 : (fifo_rptr7  + 4'd1)) : fifo_rptr7;
  fifo_rptr8_n  = rd8_en  ? ((fifo_rptr8  == shift_reg_depth-1) ? 4'd0 : (fifo_rptr8  + 4'd1)) : fifo_rptr8;
  fifo_rptr9_n  = rd9_en  ? ((fifo_rptr9  == shift_reg_depth-1) ? 4'd0 : (fifo_rptr9  + 4'd1)) : fifo_rptr9;
  fifo_rptr10_n = rd10_en ? ((fifo_rptr10 == shift_reg_depth-1) ? 4'd0 : (fifo_rptr10 + 4'd1)) : fifo_rptr10;
  fifo_rptr11_n = rd11_en ? ((fifo_rptr11 == shift_reg_depth-1) ? 4'd0 : (fifo_rptr11 + 4'd1)) : fifo_rptr11;
  fifo_rptr12_n = rd12_en ? ((fifo_rptr12 == shift_reg_depth-1) ? 4'd0 : (fifo_rptr12 + 4'd1)) : fifo_rptr12;
  fifo_rptr13_n = rd13_en ? ((fifo_rptr13 == shift_reg_depth-1) ? 4'd0 : (fifo_rptr13 + 4'd1)) : fifo_rptr13;
  fifo_rptr14_n = rd14_en ? ((fifo_rptr14 == shift_reg_depth-1) ? 4'd0 : (fifo_rptr14 + 4'd1)) : fifo_rptr14;
  fifo_rptr15_n = rd15_en ? ((fifo_rptr15 == shift_reg_depth-1) ? 4'd0 : (fifo_rptr15 + 4'd1)) : fifo_rptr15;
end

// reset & update rptrs
always @(posedge clk) begin
  if (!srst_n) begin
    fifo_rptr0  <= 0;  fifo_rptr1  <= 0;  fifo_rptr2  <= 0;  fifo_rptr3  <= 0;
    fifo_rptr4  <= 0;  fifo_rptr5  <= 0;  fifo_rptr6  <= 0;  fifo_rptr7  <= 0;
    fifo_rptr8  <= 0;  fifo_rptr9  <= 0;  fifo_rptr10 <= 0;  fifo_rptr11 <= 0;
    fifo_rptr12 <= 0;  fifo_rptr13 <= 0;  fifo_rptr14 <= 0;  fifo_rptr15 <= 0;
  end else if ((state==DECODE && decode_state==DECODE_IDLE)) begin
    fifo_rptr0  <= 0;  fifo_rptr1  <= 0;  fifo_rptr2  <= 0;  fifo_rptr3  <= 0;
    fifo_rptr4  <= 0;  fifo_rptr5  <= 0;  fifo_rptr6  <= 0;  fifo_rptr7  <= 0;
    fifo_rptr8  <= 0;  fifo_rptr9  <= 0;  fifo_rptr10 <= 0;  fifo_rptr11 <= 0;
    fifo_rptr12 <= 0;  fifo_rptr13 <= 0;  fifo_rptr14 <= 0;  fifo_rptr15 <= 0;
  end else begin
    fifo_rptr0  <= fifo_rptr0_n;   fifo_rptr1  <= fifo_rptr1_n;
    fifo_rptr2  <= fifo_rptr2_n;   fifo_rptr3  <= fifo_rptr3_n;
    fifo_rptr4  <= fifo_rptr4_n;   fifo_rptr5  <= fifo_rptr5_n;
    fifo_rptr6  <= fifo_rptr6_n;   fifo_rptr7  <= fifo_rptr7_n;
    fifo_rptr8  <= fifo_rptr8_n;   fifo_rptr9  <= fifo_rptr9_n;
    fifo_rptr10 <= fifo_rptr10_n;  fifo_rptr11 <= fifo_rptr11_n;
    fifo_rptr12 <= fifo_rptr12_n;  fifo_rptr13 <= fifo_rptr13_n;
    fifo_rptr14 <= fifo_rptr14_n;  fifo_rptr15 <= fifo_rptr15_n;
  end
end

// Region 1
// The Type b rptr need to be 2, 1, 0, 5, 4, 3, 8, 7, 6, ....
reg  [1:0] b_mod3;           // 0 -> +2, 1 -> +0, 2 -> -2
wire       use_B_now = ~use_A_now;
always @(posedge clk or negedge srst_n) begin
  if (!srst_n) begin
    b_mod3 <= 2'd0;
  end else if (in_decode_pop_control && use_B_now) begin
    b_mod3 <= (b_mod3==2'd2) ? 2'd0 : (b_mod3 + 2'd1);
  end else begin
    b_mod3 <= 0;
  end
end

wire [3:0] inc2_0  = fifo_rptr0  + 4'd2;
wire [3:0] inc2_1  = fifo_rptr1  + 4'd2;
wire [3:0] inc2_2  = fifo_rptr2  + 4'd2;
wire [3:0] inc2_3  = fifo_rptr3  + 4'd2;
wire [3:0] inc2_4  = fifo_rptr4  + 4'd2;
wire [3:0] inc2_5  = fifo_rptr5  + 4'd2;
wire [3:0] inc2_6  = fifo_rptr6  + 4'd2;
wire [3:0] inc2_7  = fifo_rptr7  + 4'd2;
wire [3:0] inc2_8  = fifo_rptr8  + 4'd2;
wire [3:0] inc2_9  = fifo_rptr9  + 4'd2;
wire [3:0] inc2_10 = fifo_rptr10 + 4'd2;
wire [3:0] inc2_11 = fifo_rptr11 + 4'd2;
wire [3:0] inc2_12 = fifo_rptr12 + 4'd2;
wire [3:0] inc2_13 = fifo_rptr13 + 4'd2;
wire [3:0] inc2_14 = fifo_rptr14 + 4'd2;
wire [3:0] inc2_15 = fifo_rptr15 + 4'd2;

wire [3:0] dec2_0  = fifo_rptr0  - 4'd2;
wire [3:0] dec2_1  = fifo_rptr1  - 4'd2;
wire [3:0] dec2_2  = fifo_rptr2  - 4'd2;
wire [3:0] dec2_3  = fifo_rptr3  - 4'd2;
wire [3:0] dec2_4  = fifo_rptr4  - 4'd2;
wire [3:0] dec2_5  = fifo_rptr5  - 4'd2;
wire [3:0] dec2_6  = fifo_rptr6  - 4'd2;
wire [3:0] dec2_7  = fifo_rptr7  - 4'd2;
wire [3:0] dec2_8  = fifo_rptr8  - 4'd2;
wire [3:0] dec2_9  = fifo_rptr9  - 4'd2;
wire [3:0] dec2_10 = fifo_rptr10 - 4'd2;
wire [3:0] dec2_11 = fifo_rptr11 - 4'd2;
wire [3:0] dec2_12 = fifo_rptr12 - 4'd2;
wire [3:0] dec2_13 = fifo_rptr13 - 4'd2;
wire [3:0] dec2_14 = fifo_rptr14 - 4'd2;
wire [3:0] dec2_15 = fifo_rptr15 - 4'd2;

// b_mod3：0->+2, 1->0, 2->-2
wire [3:0] map0  = (b_mod3==2'd0) ? inc2_0  : ((b_mod3==2'd1) ? fifo_rptr0  : dec2_0 );
wire [3:0] map1  = (b_mod3==2'd0) ? inc2_1  : ((b_mod3==2'd1) ? fifo_rptr1  : dec2_1 );
wire [3:0] map2  = (b_mod3==2'd0) ? inc2_2  : ((b_mod3==2'd1) ? fifo_rptr2  : dec2_2 );
wire [3:0] map3  = (b_mod3==2'd0) ? inc2_3  : ((b_mod3==2'd1) ? fifo_rptr3  : dec2_3 );
wire [3:0] map4  = (b_mod3==2'd0) ? inc2_4  : ((b_mod3==2'd1) ? fifo_rptr4  : dec2_4 );
wire [3:0] map5  = (b_mod3==2'd0) ? inc2_5  : ((b_mod3==2'd1) ? fifo_rptr5  : dec2_5 );
wire [3:0] map6  = (b_mod3==2'd0) ? inc2_6  : ((b_mod3==2'd1) ? fifo_rptr6  : dec2_6 );
wire [3:0] map7  = (b_mod3==2'd0) ? inc2_7  : ((b_mod3==2'd1) ? fifo_rptr7  : dec2_7 );
wire [3:0] map8  = (b_mod3==2'd0) ? inc2_8  : ((b_mod3==2'd1) ? fifo_rptr8  : dec2_8 );
wire [3:0] map9  = (b_mod3==2'd0) ? inc2_9  : ((b_mod3==2'd1) ? fifo_rptr9  : dec2_9 );
wire [3:0] map10 = (b_mod3==2'd0) ? inc2_10 : ((b_mod3==2'd1) ? fifo_rptr10 : dec2_10);
wire [3:0] map11 = (b_mod3==2'd0) ? inc2_11 : ((b_mod3==2'd1) ? fifo_rptr11 : dec2_11);
wire [3:0] map12 = (b_mod3==2'd0) ? inc2_12 : ((b_mod3==2'd1) ? fifo_rptr12 : dec2_12);
wire [3:0] map13 = (b_mod3==2'd0) ? inc2_13 : ((b_mod3==2'd1) ? fifo_rptr13 : dec2_13);
wire [3:0] map14 = (b_mod3==2'd0) ? inc2_14 : ((b_mod3==2'd1) ? fifo_rptr14 : dec2_14);
wire [3:0] map15 = (b_mod3==2'd0) ? inc2_15 : ((b_mod3==2'd1) ? fifo_rptr15 : dec2_15);

// Region 2
// Typr B should be 1, 0, 3, 2, 5, 4..
reg  c_mod2;           // 0 -> +1, 1 -> -1
wire       use_B_now_r2 = ~use_A_now_r2;
always @(posedge clk or negedge srst_n) begin
  if (!srst_n) begin
    c_mod2 <= 0;
  end else if (in_decode_pop3 && use_B_now_r2) begin
    c_mod2 <= ~c_mod2;
  end else begin
    c_mod2 <= 0;
  end
end
wire [3:0] inc1_0  = fifo_rptr0  + 4'd1;
wire [3:0] inc1_1  = fifo_rptr1  + 4'd1;
wire [3:0] inc1_2  = fifo_rptr2  + 4'd1;
wire [3:0] inc1_3  = fifo_rptr3  + 4'd1;
wire [3:0] inc1_4  = fifo_rptr4  + 4'd1;
wire [3:0] inc1_5  = fifo_rptr5  + 4'd1;
wire [3:0] inc1_6  = fifo_rptr6  + 4'd1;
wire [3:0] inc1_7  = fifo_rptr7  + 4'd1;
wire [3:0] inc1_8  = fifo_rptr8  + 4'd1;
wire [3:0] inc1_9  = fifo_rptr9  + 4'd1;
wire [3:0] inc1_10 = fifo_rptr10 + 4'd1;
wire [3:0] inc1_11 = fifo_rptr11 + 4'd1;
wire [3:0] inc1_12 = fifo_rptr12 + 4'd1;
wire [3:0] inc1_13 = fifo_rptr13 + 4'd1;
wire [3:0] inc1_14 = fifo_rptr14 + 4'd1;
wire [3:0] inc1_15 = fifo_rptr15 + 4'd1;

wire [3:0] dec1_0  = fifo_rptr0  - 4'd1;
wire [3:0] dec1_1  = fifo_rptr1  - 4'd1;
wire [3:0] dec1_2  = fifo_rptr2  - 4'd1;
wire [3:0] dec1_3  = fifo_rptr3  - 4'd1;
wire [3:0] dec1_4  = fifo_rptr4  - 4'd1;
wire [3:0] dec1_5  = fifo_rptr5  - 4'd1;
wire [3:0] dec1_6  = fifo_rptr6  - 4'd1;
wire [3:0] dec1_7  = fifo_rptr7  - 4'd1;
wire [3:0] dec1_8  = fifo_rptr8  - 4'd1;
wire [3:0] dec1_9  = fifo_rptr9  - 4'd1;
wire [3:0] dec1_10 = fifo_rptr10 - 4'd1;
wire [3:0] dec1_11 = fifo_rptr11 - 4'd1;
wire [3:0] dec1_12 = fifo_rptr12 - 4'd1;
wire [3:0] dec1_13 = fifo_rptr13 - 4'd1;
wire [3:0] dec1_14 = fifo_rptr14 - 4'd1;
wire [3:0] dec1_15 = fifo_rptr15 - 4'd1;

wire [3:0] map0r2  = (c_mod2==0)? inc1_0 : dec1_0;
wire [3:0] map1r2  = (c_mod2==0)? inc1_1 : dec1_1;
wire [3:0] map2r2  = (c_mod2==0)? inc1_2 : dec1_2;
wire [3:0] map3r2  = (c_mod2==0)? inc1_3 : dec1_3;
wire [3:0] map4r2  = (c_mod2==0)? inc1_4 : dec1_4;
wire [3:0] map5r2  = (c_mod2==0)? inc1_5 : dec1_5;
wire [3:0] map6r2  = (c_mod2==0)? inc1_6 : dec1_6;
wire [3:0] map7r2  = (c_mod2==0)? inc1_7 : dec1_7;
wire [3:0] map8r2  = (c_mod2==0)? inc1_8 : dec1_8;
wire [3:0] map9r2  = (c_mod2==0)? inc1_9 : dec1_9;
wire [3:0] map10r2 = (c_mod2==0)? inc1_10 : dec1_10;
wire [3:0] map11r2 = (c_mod2==0)? inc1_11 : dec1_11;
wire [3:0] map12r2 = (c_mod2==0)? inc1_12 : dec1_12;
wire [3:0] map13r2 = (c_mod2==0)? inc1_13 : dec1_13;
wire [3:0] map14r2 = (c_mod2==0)? inc1_14 : dec1_14;
wire [3:0] map15r2 = (c_mod2==0)? inc1_15 : dec1_15;


// read ptr
reg [3:0] raddr0;
reg [3:0] raddr1;
reg [3:0] raddr2;
reg [3:0] raddr3;
reg [3:0] raddr4;
reg [3:0] raddr5;
reg [3:0] raddr6;
reg [3:0] raddr7;
reg [3:0] raddr8;
reg [3:0] raddr9;
reg [3:0] raddr10;
reg [3:0] raddr11;
reg [3:0] raddr12;
reg [3:0] raddr13;
reg [3:0] raddr14;
reg [3:0] raddr15;



always @(*) begin
  if (decode_state == DECODE_DECODE1 || decode_state == DECODE_DECODE2) begin
    raddr0  = use_A_now ? fifo_rptr0  : map0 ;
    raddr1  = use_A_now ? fifo_rptr1  : map1 ;
    raddr2  = use_A_now ? fifo_rptr2  : map2 ;
    raddr3  = use_A_now ? fifo_rptr3  : map3 ;
    raddr4  = use_A_now ? fifo_rptr4  : map4 ;
    raddr5  = use_A_now ? fifo_rptr5  : map5 ;
    raddr6  = use_A_now ? fifo_rptr6  : map6 ;
    raddr7  = use_A_now ? fifo_rptr7  : map7 ;
    raddr8  = use_A_now ? fifo_rptr8  : map8 ;
    raddr9  = use_A_now ? fifo_rptr9  : map9 ;
    raddr10 = use_A_now ? fifo_rptr10 : map10;
    raddr11 = use_A_now ? fifo_rptr11 : map11;
    raddr12 = use_A_now ? fifo_rptr12 : map12;
    raddr13 = use_A_now ? fifo_rptr13 : map13;
    raddr14 = use_A_now ? fifo_rptr14 : map14;
    raddr15 = use_A_now ? fifo_rptr15 : map15;
  end else if (decode_state == DECODE_DECODE3) begin
    raddr0  = use_A_now_r2 ? fifo_rptr0  : map0r2 ;
    raddr1  = use_A_now_r2 ? fifo_rptr1  : map1r2 ;
    raddr2  = use_A_now_r2 ? fifo_rptr2  : map2r2 ;
    raddr3  = use_A_now_r2 ? fifo_rptr3  : map3r2 ;
    raddr4  = use_A_now_r2 ? fifo_rptr4  : map4r2 ;
    raddr5  = use_A_now_r2 ? fifo_rptr5  : map5r2 ;
    raddr6  = use_A_now_r2 ? fifo_rptr6  : map6r2 ;
    raddr7  = use_A_now_r2 ? fifo_rptr7  : map7r2 ;
    raddr8  = use_A_now_r2 ? fifo_rptr8  : map8r2 ;
    raddr9  = use_A_now_r2 ? fifo_rptr9  : map9r2 ;
    raddr10 = use_A_now_r2 ? fifo_rptr10 : map10r2;
    raddr11 = use_A_now_r2 ? fifo_rptr11 : map11r2;
    raddr12 = use_A_now_r2 ? fifo_rptr12 : map12r2;
    raddr13 = use_A_now_r2 ? fifo_rptr13 : map13r2;
    raddr14 = use_A_now_r2 ? fifo_rptr14 : map14r2;
    raddr15 = use_A_now_r2 ? fifo_rptr15 : map15r2;
  end
end

// output text
reg bit0_sel, bit1_sel, bit2_sel, bit3_sel, bit4_sel, bit5_sel, bit6_sel, bit7_sel;

// sel_line0 -> bit0_sel
always @(*) begin
  case (sel_line0_final)
    4'd0:  bit0_sel = line0 [raddr0 ];
    4'd1:  bit0_sel = line1 [raddr1 ];
    4'd2:  bit0_sel = line2 [raddr2 ];
    4'd3:  bit0_sel = line3 [raddr3 ];
    4'd4:  bit0_sel = line4 [raddr4 ];
    4'd5:  bit0_sel = line5 [raddr5 ];
    4'd6:  bit0_sel = line6 [raddr6 ];
    4'd7:  bit0_sel = line7 [raddr7 ];
    4'd8:  bit0_sel = line8 [raddr8 ];
    4'd9:  bit0_sel = line9 [raddr9 ];
    4'd10: bit0_sel = line10[raddr10];
    4'd11: bit0_sel = line11[raddr11];
    4'd12: bit0_sel = line12[raddr12];
    4'd13: bit0_sel = line13[raddr13];
    4'd14: bit0_sel = line14[raddr14];
    4'd15: bit0_sel = line15[raddr15];
    default: bit0_sel = 1'b0;
  endcase
end

// sel_line1 -> bit1_sel
always @(*) begin
  case (sel_line1_final)
    4'd0:  bit1_sel = line0 [raddr0 ];
    4'd1:  bit1_sel = line1 [raddr1 ];
    4'd2:  bit1_sel = line2 [raddr2 ];
    4'd3:  bit1_sel = line3 [raddr3 ];
    4'd4:  bit1_sel = line4 [raddr4 ];
    4'd5:  bit1_sel = line5 [raddr5 ];
    4'd6:  bit1_sel = line6 [raddr6 ];
    4'd7:  bit1_sel = line7 [raddr7 ];
    4'd8:  bit1_sel = line8 [raddr8 ];
    4'd9:  bit1_sel = line9 [raddr9 ];
    4'd10: bit1_sel = line10[raddr10];
    4'd11: bit1_sel = line11[raddr11];
    4'd12: bit1_sel = line12[raddr12];
    4'd13: bit1_sel = line13[raddr13];
    4'd14: bit1_sel = line14[raddr14];
    4'd15: bit1_sel = line15[raddr15];
    default: bit1_sel = 1'b0;
  endcase
end

always @(*) begin
  case (sel_line2_final)
    4'd0:  bit2_sel = line0 [raddr0 ];
    4'd1:  bit2_sel = line1 [raddr1 ];
    4'd2:  bit2_sel = line2 [raddr2 ];
    4'd3:  bit2_sel = line3 [raddr3 ];
    4'd4:  bit2_sel = line4 [raddr4 ];
    4'd5:  bit2_sel = line5 [raddr5 ];
    4'd6:  bit2_sel = line6 [raddr6 ];
    4'd7:  bit2_sel = line7 [raddr7 ];
    4'd8:  bit2_sel = line8 [raddr8 ];
    4'd9:  bit2_sel = line9 [raddr9 ];
    4'd10: bit2_sel = line10[raddr10];
    4'd11: bit2_sel = line11[raddr11];
    4'd12: bit2_sel = line12[raddr12];
    4'd13: bit2_sel = line13[raddr13];
    4'd14: bit2_sel = line14[raddr14];
    4'd15: bit2_sel = line15[raddr15];
    default: bit2_sel = 1'b0;
  endcase
end

always @(*) begin
  case (sel_line3_final)
    4'd0:  bit3_sel = line0 [raddr0 ];
    4'd1:  bit3_sel = line1 [raddr1 ];
    4'd2:  bit3_sel = line2 [raddr2 ];
    4'd3:  bit3_sel = line3 [raddr3 ];
    4'd4:  bit3_sel = line4 [raddr4 ];
    4'd5:  bit3_sel = line5 [raddr5 ];
    4'd6:  bit3_sel = line6 [raddr6 ];
    4'd7:  bit3_sel = line7 [raddr7 ];
    4'd8:  bit3_sel = line8 [raddr8 ];
    4'd9:  bit3_sel = line9 [raddr9 ];
    4'd10: bit3_sel = line10[raddr10];
    4'd11: bit3_sel = line11[raddr11];
    4'd12: bit3_sel = line12[raddr12];
    4'd13: bit3_sel = line13[raddr13];
    4'd14: bit3_sel = line14[raddr14];
    4'd15: bit3_sel = line15[raddr15];
    default: bit3_sel = 1'b0;
  endcase
end

always @(*) begin
  case (sel_line4_final)
    4'd0:  bit4_sel = line0 [raddr0 ];
    4'd1:  bit4_sel = line1 [raddr1 ];
    4'd2:  bit4_sel = line2 [raddr2 ];
    4'd3:  bit4_sel = line3 [raddr3 ];
    4'd4:  bit4_sel = line4 [raddr4 ];
    4'd5:  bit4_sel = line5 [raddr5 ];
    4'd6:  bit4_sel = line6 [raddr6 ];
    4'd7:  bit4_sel = line7 [raddr7 ];
    4'd8:  bit4_sel = line8 [raddr8 ];
    4'd9:  bit4_sel = line9 [raddr9 ];
    4'd10: bit4_sel = line10[raddr10];
    4'd11: bit4_sel = line11[raddr11];
    4'd12: bit4_sel = line12[raddr12];
    4'd13: bit4_sel = line13[raddr13];
    4'd14: bit4_sel = line14[raddr14];
    4'd15: bit4_sel = line15[raddr15];
    default: bit4_sel = 1'b0;
  endcase
end

always @(*) begin
  case (sel_line5_final)
    4'd0:  bit5_sel = line0 [raddr0 ];
    4'd1:  bit5_sel = line1 [raddr1 ];
    4'd2:  bit5_sel = line2 [raddr2 ];
    4'd3:  bit5_sel = line3 [raddr3 ];
    4'd4:  bit5_sel = line4 [raddr4 ];
    4'd5:  bit5_sel = line5 [raddr5 ];
    4'd6:  bit5_sel = line6 [raddr6 ];
    4'd7:  bit5_sel = line7 [raddr7 ];
    4'd8:  bit5_sel = line8 [raddr8 ];
    4'd9:  bit5_sel = line9 [raddr9 ];
    4'd10: bit5_sel = line10[raddr10];
    4'd11: bit5_sel = line11[raddr11];
    4'd12: bit5_sel = line12[raddr12];
    4'd13: bit5_sel = line13[raddr13];
    4'd14: bit5_sel = line14[raddr14];
    4'd15: bit5_sel = line15[raddr15];
    default: bit5_sel = 1'b0;
  endcase
end

always @(*) begin
  case (sel_line6_final)
    4'd0:  bit6_sel = line0 [raddr0 ];
    4'd1:  bit6_sel = line1 [raddr1 ];
    4'd2:  bit6_sel = line2 [raddr2 ];
    4'd3:  bit6_sel = line3 [raddr3 ];
    4'd4:  bit6_sel = line4 [raddr4 ];
    4'd5:  bit6_sel = line5 [raddr5 ];
    4'd6:  bit6_sel = line6 [raddr6 ];
    4'd7:  bit6_sel = line7 [raddr7 ];
    4'd8:  bit6_sel = line8 [raddr8 ];
    4'd9:  bit6_sel = line9 [raddr9 ];
    4'd10: bit6_sel = line10[raddr10];
    4'd11: bit6_sel = line11[raddr11];
    4'd12: bit6_sel = line12[raddr12];
    4'd13: bit6_sel = line13[raddr13];
    4'd14: bit6_sel = line14[raddr14];
    4'd15: bit6_sel = line15[raddr15];
    default: bit6_sel = 1'b0;
  endcase
end

always @(*) begin
  case (sel_line7_final)
    4'd0:  bit7_sel = line0 [raddr0 ];
    4'd1:  bit7_sel = line1 [raddr1 ];
    4'd2:  bit7_sel = line2 [raddr2 ];
    4'd3:  bit7_sel = line3 [raddr3 ];
    4'd4:  bit7_sel = line4 [raddr4 ];
    4'd5:  bit7_sel = line5 [raddr5 ];
    4'd6:  bit7_sel = line6 [raddr6 ];
    4'd7:  bit7_sel = line7 [raddr7 ];
    4'd8:  bit7_sel = line8 [raddr8 ];
    4'd9:  bit7_sel = line9 [raddr9 ];
    4'd10: bit7_sel = line10[raddr10];
    4'd11: bit7_sel = line11[raddr11];
    4'd12: bit7_sel = line12[raddr12];
    4'd13: bit7_sel = line13[raddr13];
    4'd14: bit7_sel = line14[raddr14];
    4'd15: bit7_sel = line15[raddr15];
    default: bit7_sel = 1'b0;
  endcase
end

// ----- decode ----- //



assign decode_text = decode_text_n2;
assign valid       = decode_valid_r;

//wire in_decode_pop = (state==DECODE) && (decode_state==DECODE_DECODE1);
always @(posedge clk) begin
  if (!srst_n) begin
    decode_text_r   <= 8'd0;
    decode_valid_r  <= 1'b0;
    local_word_idx  <= 3'd0;
    global_word_idx <= 6'd0;

    decode_text_n2  <= 8'd0;
    decode_valid_n2 <= 1'b0;
    data_len        <= 0;
  end else if (in_decode_pop) begin
    decode_text_r  <= {bit7_sel, bit6_sel, bit5_sel, bit4_sel, bit3_sel, bit2_sel, bit1_sel, bit0_sel};
    decode_valid_r <= (global_word_idx == 6'd0 || global_word_idx == 6'd1 || (global_word_idx == data_len + 2 && global_word_idx != 2) | (global_word_idx == 2 && decode_text_n2 == 0))? 0 : 1; // first word the length
    local_word_idx <= (local_word_idx == 3'd5)? 0 : local_word_idx + 3'd1;
    global_word_idx   <= global_word_idx + 6'd1;

    decode_text_n2 <= {decode_text_r[3:0], bit7_sel, bit6_sel, bit5_sel, bit4_sel};
    //decode_valid_n2 <= decode_valid_r;
    data_len <= (global_word_idx == 2)? decode_text_n2 : data_len;
  end else if (in_decode_pop2) begin
    decode_text_r  <= {bit7_sel, bit6_sel, bit5_sel, bit4_sel, bit3_sel, bit2_sel, bit1_sel, bit0_sel};
    decode_valid_r <= (global_word_idx == 6'd0 || global_word_idx == 6'd1 || (global_word_idx == data_len + 2 && global_word_idx != 2) | (global_word_idx == 2 && decode_text_n2 == 0))? 0 : 1; // first word the length
    local_word_idx <= (local_word_idx == 8)? 0 : local_word_idx + 3'd1;
    global_word_idx   <= global_word_idx + 6'd1;

    decode_text_n2 <= {decode_text_r[3:0], bit7_sel, bit6_sel, bit5_sel, bit4_sel};
    //decode_valid_n2 <= decode_valid_r;
    data_len <= (global_word_idx == 2)? decode_text_n2 : data_len;
  end else if (in_decode_pop3) begin
    decode_text_r  <= {bit7_sel, bit6_sel, bit5_sel, bit4_sel, bit3_sel, bit2_sel, bit1_sel, bit0_sel};
    decode_valid_r <= (global_word_idx == 6'd0 || global_word_idx == 6'd1 || (global_word_idx == data_len + 2 && global_word_idx != 2) | (global_word_idx == 2 && decode_text_n2 == 0))? 0 : 1; // first word the length
    local_word_idx <= (local_word_idx == 4)? 0 : local_word_idx + 3'd1;
    global_word_idx   <= global_word_idx + 6'd1;

    decode_text_n2 <= {decode_text_r[3:0], bit7_sel, bit6_sel, bit5_sel, bit4_sel};
    //decode_valid_n2 <= decode_valid_r;
    data_len <= (global_word_idx == 2)? decode_text_n2 : data_len;
  end else if (state == DECODE && decode_state != DECODE_DECODE1) begin
    decode_valid_r <= 0;
    data_len <= data_len;
    global_word_idx <= global_word_idx;
    local_word_idx <= local_word_idx;
    decode_text_r <= decode_text_r;
    decode_text_n2 <= decode_text_n2;
  end else begin
    global_word_idx <= 0;
    local_word_idx <= 0;
    data_len <= 0;
    decode_text_r <= 0;
    decode_text_n2 <= 0;
    decode_valid_r <= 0;
  end
end


// ===== decode ===== //

endmodule
