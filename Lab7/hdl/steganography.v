//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module steganography
#
(
  parameter DRAM_DATA_WIDTH = 32,
  parameter SRAM_DATA_WIDTH = 4,
  parameter SRAM_ADDR_WIDTH = 7,
  parameter DATA_WIDTH = 8
)
(
  input clk,
  input rst_n,
  input enable,
  input [DATA_WIDTH-1:0] width,    // image width
  input [DATA_WIDTH-1:0] height,   // image height
  output reg DRAM_enable,
  input DRAM_data_valid,
  input [DRAM_DATA_WIDTH-1:0] DRAM_data,
  output wire valid,                // valid ASCII out
  output wire [DATA_WIDTH-1:0] out, // decoded ASCII code
  output wire done                  // finish to decode image
);
// ----- mode fsm -----//
localparam IDLE   = 2'b00; // write image into dram
localparam WRITE  = 2'b01; // write data into sram
localparam DECODE = 2'b10; // read sram and decode

reg [1:0]mode;
reg [1:0]mode_next;
reg [(DATA_WIDTH-1):0]dram_read_addr; // 7-bit(0-127)
reg [(DATA_WIDTH-1):0]sram_write_num;
// ----- sram ----- //
// signals connect to SRAM
// input 
wire SRAM_enable;
wire SRAM_r_w;
wire [SRAM_DATA_WIDTH-1:0] SRAM_in;
wire [SRAM_ADDR_WIDTH-1:0] SRAM_addr;
// output 
wire [SRAM_DATA_WIDTH-1:0] SRAM_out;

// ----- decoder ----- //
// signals connect to decoder
// input 
wire decoder_enable;
wire [SRAM_DATA_WIDTH-1:0] decoder_SRAM_data;
// output 
wire decoder_SRAM_enable;
wire [SRAM_ADDR_WIDTH-1:0] decoder_SRAM_addr;
wire decoder_valid;
wire [DATA_WIDTH-1:0] decoder_out;
wire decoder_done;

// ----- write fsm -----//
localparam WRITE_IDLE = 3'b000;
localparam WRITE1 = 3'b001;
localparam WRITE2 = 3'b010;
localparam WRITE3 = 3'b011;
localparam COM = 3'b111;
reg [2:0]write_stage;
reg [2:0]write_stage_next;
reg [(SRAM_ADDR_WIDTH-1):0] sram_addr_write;
reg [(SRAM_ADDR_WIDTH-1):0] sram_addr_write_next;

// ----- module output ----- //
assign valid = decoder_valid;
assign out = decoder_out;
assign done = decoder_done;
//-----
assign SRAM_enable = (mode == WRITE)? DRAM_data_valid : decoder_SRAM_enable;;
assign SRAM_r_w = (mode == WRITE)? 0 : 1 ;
assign SRAM_in = {1'b0, DRAM_data[16], DRAM_data[8], DRAM_data[0]};
assign SRAM_addr = (mode == WRITE)? sram_addr_write : decoder_SRAM_addr;

assign decoder_enable = (mode == DECODE)? 1 : 0;
assign decoder_SRAM_data = SRAM_out;

//assign DRAM_enable = (mode == WRITE)? 1 : 0;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    DRAM_enable <= 0;
  end else begin
    DRAM_enable <= ((mode == WRITE) && (sram_write_num < (width-2)))? 1 : 0;
  end
end

SRAM u_SRAM (
  // input 
  .clk(clk),
  .enable(SRAM_enable),
  .r_w(SRAM_r_w),
  .in(SRAM_in),
  .addr(SRAM_addr),
  // output
  .out(SRAM_out)
);


decoder u_decoder (
  // input 
  .clk(clk),
  .rst_n(rst_n),
  .width(width), // image width
  .enable(decoder_enable), // decode enable
  .SRAM_data(decoder_SRAM_data), // read data from sram
  // output 
  .SRAM_enable(decoder_SRAM_enable), // connect to sram
  .SRAM_addr(decoder_SRAM_addr), // connect to sram
  .valid(decoder_valid), // output valid
  .out(decoder_out), // output data
  .done(decoder_done) // decode done
);

// ----- FSM ----- //


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    mode <= IDLE;
  end else begin
    mode <= mode_next;
  end
end

always @(*) begin
  case (mode)
  IDLE: begin
    if (enable) begin
      mode_next = WRITE;
    end else begin
      mode_next = IDLE;
    end
  end
  WRITE: begin
    if (sram_write_num == width-1) begin
      mode_next = DECODE;
    end else begin
      mode_next = mode;
    end
  end
  DECODE: begin
    if (decoder_done) begin
      mode_next = IDLE;
    end else begin
      mode_next = DECODE;
    end
  end
  endcase
end

// ----- mode: IDLE ----- // 

// ----- mode: WRITE ----- //

// read dram to sram, dram_read_addr read how many data.
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dram_read_addr <= 0;
  end else if (DRAM_enable == 1) begin
    dram_read_addr <= dram_read_addr + 1;
  end else if (mode != WRITE) begin
    dram_read_addr <= 0;
  end else begin
    dram_read_addr <= dram_read_addr;
  end
end

// count write how many data

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sram_write_num <= 0;
  end else if (mode != WRITE) begin
    sram_write_num <= 0;
  end else if (DRAM_data_valid) begin
    sram_write_num <= sram_write_num + 1;
  end else begin
    sram_write_num <= 0;
  end
end

// address generator
// write stage fsm

always @(posedge clk or negedge rst_n) begin  
  if (!rst_n) begin
    write_stage <= WRITE_IDLE;
    sram_addr_write <= 0;
  end else begin
    write_stage <= write_stage_next;
    sram_addr_write <= sram_addr_write_next;
  end
end

always @(*) begin
  case (write_stage)
  WRITE_IDLE: begin
    if (mode == WRITE) begin
      write_stage_next = WRITE1;
    end else begin
      write_stage_next = WRITE_IDLE;
    end
    sram_addr_write_next = 0;
  end
  WRITE1: begin
    if (mode == WRITE) begin
      write_stage_next = COM;
    end else begin
      write_stage_next = IDLE;
    end
    sram_addr_write_next = 0;
  end
  WRITE2: begin
    if (mode == WRITE) begin
      write_stage_next = COM;
    end else begin
      write_stage_next = IDLE;
    end
    sram_addr_write_next = 7'd40;
  end
  WRITE3: begin
    if (mode == WRITE) begin
      write_stage_next = COM;
    end else begin
      write_stage_next = IDLE;
    end
    sram_addr_write_next = 7'd80;
  end
  COM: begin
    if (dram_read_addr == width / 3 - 1) begin
      write_stage_next = WRITE2;
    end else if (dram_read_addr == (width << 1) / 3 - 1) begin
      write_stage_next = WRITE3;
    end else if (dram_read_addr == (width) - 1) begin
      write_stage_next = WRITE_IDLE;
    end else if (mode == WRITE) begin
      write_stage_next = COM;
    end else begin
      write_stage_next = IDLE;
    end
    sram_addr_write_next = sram_addr_write + 1;
  end
  endcase
end

// ----- mode: DECODE ----- //



endmodule
