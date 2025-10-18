//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module decoder
#
(
  parameter SRAM_DATA_WIDTH = 4,
  parameter SRAM_ADDR_WIDTH = 7,
  parameter DATA_WIDTH = 8
)
(
  input clk,
  input rst_n,
  input [DATA_WIDTH-1:0] width,               // image width
  input enable,                               // decoder enable
  input [SRAM_DATA_WIDTH-1:0] SRAM_data,      // data read from sram
  output reg SRAM_enable,
  output reg [SRAM_ADDR_WIDTH-1:0] SRAM_addr,
  output wire valid,                           // valid ASCII code
  output reg [DATA_WIDTH-1:0] out,            // decoded ASCII code
  output wire done                             // finish decoding 3-row of image
);

// read 3 rows to start to decode 
// e.g.
// access address 0, 40, 80 and store the data in buffer -> decode -> 
// access address 1, 41, 81 -> decode ... -> done
// remember to calculate where is the end of the row to output done

// address generator
reg [1:0]state;
reg [1:0]state_next;

localparam IDLE = 2'b00;
localparam READ1 = 2'b01;
localparam READ2 = 2'b10;
localparam READ3 = 2'b11;

reg [(SRAM_ADDR_WIDTH-1):0]count;
wire [(SRAM_ADDR_WIDTH-1):0]base_addr;
wire [(SRAM_ADDR_WIDTH-1):0]second_addr;
wire [(SRAM_ADDR_WIDTH-1):0]third_addr;

reg [(SRAM_DATA_WIDTH-1):0] data_buffer [0:2];
wire decode_mode;

wire [3:0] data_buffer0_dbg = data_buffer[0];
wire [3:0] data_buffer1_dbg = data_buffer[1];
wire [3:0] data_buffer2_dbg = data_buffer[2];


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    state <= IDLE;
  end else begin
    state <= state_next;
  end
end

always @(*) begin
  case (state)
  IDLE: begin
    if (enable) begin
      state_next = READ1;
    end else begin
      state_next = IDLE;
    end
    SRAM_addr = 0;
    SRAM_enable = 0;
  end
  READ1: begin
    if (enable) begin
      state_next = READ2;
    end else begin
      state_next = IDLE;
    end
    
    SRAM_addr = base_addr;
    SRAM_enable = 1;
  end
  READ2: begin
    if (enable) begin
      state_next = READ3;
    end else begin
      state_next = IDLE;
    end
    
    SRAM_addr = second_addr;
    SRAM_enable = 1;
  end
  READ3: begin
    if (enable) begin
      state_next = READ1;
    end else begin
      state_next = IDLE;
    end
    
    SRAM_addr = third_addr;
    SRAM_enable = 1;
  end
  endcase
end


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    count <= 0;
  end else if ((state == IDLE || state == READ3) && enable) begin
    count <= count + 1;
  end else if (!enable) begin
    count <= 0;
  end else begin
    count <= count;
  end
end
assign base_addr = count - 1;
assign second_addr = base_addr + 7'd40;
assign third_addr = base_addr + 7'd80;

// ----- data buffer and decode ----- //

integer i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (i=0; i<3; i=i+1) begin
      data_buffer[i] <= 0;
    end 
  end else if (state == READ2) begin
    data_buffer[0] <= SRAM_data;
    data_buffer[1] <= data_buffer[1];
    data_buffer[2] <= data_buffer[2];
  end else if (state == READ3) begin
    data_buffer[0] <= data_buffer[0];
    data_buffer[1] <= SRAM_data;
    data_buffer[2] <= data_buffer[2];
  end else if (state == READ1) begin
    data_buffer[0] <= data_buffer[0];
    data_buffer[1] <= data_buffer[1];
    data_buffer[2] <= SRAM_data;
  end else begin
    data_buffer[0] <= data_buffer[0];
    data_buffer[1] <= data_buffer[1];
    data_buffer[2] <= data_buffer[2];
  end
end

assign decode_mode = data_buffer[0][0];
always @(*) begin
  if (decode_mode) begin // decode mode == 1
    out = {data_buffer[1][0], data_buffer[2][0], data_buffer[0][1], data_buffer[1][1], data_buffer[2][1], data_buffer[0][2], data_buffer[1][2], data_buffer[2][2]};
  end else begin
    out = {data_buffer[0][1], data_buffer[0][2], data_buffer[1][0], data_buffer[1][1], data_buffer[1][2], data_buffer[2][0], data_buffer[2][1], data_buffer[2][2]};
  end
end

assign valid = (state == READ2 && second_addr != 7'd40)? 1 : 0;

reg [(DATA_WIDTH-1):0]valid_data;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    valid_data <= 0;
  end else if (!enable) begin
    valid_data <= 0;
  end else if (valid) begin
    valid_data <= valid_data + 1;
  end else begin
    valid_data <= valid_data;
  end
end
assign done = (valid_data == width/3)? 1 : 0;
endmodule
