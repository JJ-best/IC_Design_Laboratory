//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module fir1_parallel
#(parameter N=32)
(
input      clk,
input      rst_n,
input      enable,
input      [N-1:0]x0,
input      [N-1:0]x1,
output reg busy,
output reg valid,
output reg [N-1:0]y0,
output reg [N-1:0]y1
);

localparam IDLE = 0, // idle
           LOAD = 1, // load first 7 data
           EVA  = 2; // evaluation sum
reg [N-1:0] y_n;
reg [5:0] state, state_n;
reg [5:0] cnt, cnt_n;
reg valid_n;
reg busy_n;


// ===== finite state machine ===== //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    state <= IDLE;
  end else begin
    state <= state_n;
  end
end

always @(*) begin
  case (state)
  IDLE: begin
    state_n = (enable)? LOAD : IDLE;
  end
  LOAD: begin
    state_n = (state == LOAD && cnt == 8)? EVA : LOAD;
  end
  EVA: begin
    state_n = (enable)? EVA : IDLE;
  end
  endcase
end


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cnt <= 0;
  end else begin
    cnt <= cnt_n;
  end
end

always @(*) begin
    if (cnt == 8) begin
      cnt_n = cnt;
    end else if (enable) begin
      cnt_n = cnt + 1;
    end else begin
      cnt_n = 0;
    end
end


// control signal
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    busy <= 0;
    valid <= 0;
  end else begin
    busy <= busy_n;
    valid <= valid_n;
  end
end
always @(*) begin
 busy_n = 0; // will not busy, ii = 1

  if (state == EVA) begin
    valid_n = 1;
  end else begin
    valid_n = 0;
  end
end
// ===== finite state machine ===== //

// ===== shift registers ===== //
reg [(N-1):0] pipe1 [0:8];
reg [(N-1):0] pipe2 [0:8];
integer i;
integer j;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 8; i >= 0; i = i - 1) begin
        pipe1[i] <= 0;
        pipe2[i] <= 0;
      end
    end else if (state == EVA || state == LOAD) begin
      for (i = 8; i >= 0; i = i - 1) begin // 9 stage shift register
        if (i == 0) begin
          pipe2[i] <= x1; // x[n+1]
        end else begin
          pipe2[i] <= pipe2[i-1];
        end
      end
      for (j = 7; j >= 0; j = j - 1) begin // 9 stage shift register
        if (j == 0) begin
          pipe1[j] <= x0; // x[n]
        end else begin
          pipe1[j] <= pipe1[j-1];
        end
      end
    end
end
// ===== shift registers ===== //

// ===== combinational logic ===== //


localparam a0 = -32'd157;
localparam a1 = 32'd380;
localparam a2 = -32'd399;
localparam a3 = -32'd838;
localparam a4 = 32'd3466;
localparam a5 = -32'd4548;
localparam a6 = -32'd1987;
localparam a7 = 32'd36857;
localparam a8 = 32'd36857;
localparam a9 = -32'd1987;
localparam a10 = -32'd4548;
localparam a11 = 32'd3466;
localparam a12 = -32'd838;
localparam a13 = -32'd399;
localparam a14 = 32'd380;
localparam a15 = -32'd157;

reg [(N-1):0] mul3[0:7];
reg [(N-1):0] mul2[0:7];
reg [(N-1):0] mul1[0:7];
reg [(N-1):0] mul0[0:7];
reg [(N-1):0] add1;
reg [(N-1):0] add2;
always @(*) begin
    mul3[7] = pipe2[8] * a15;// x[2n-15] * a15
    mul3[6] = pipe2[7] * a13;
    mul3[5] = pipe2[6] * a11;
    mul3[4] = pipe2[5] * a9;
    mul3[3] = pipe2[4] * a7;
    mul3[2] = pipe2[3] * a5;
    mul3[1] = pipe2[2] * a3;
    mul3[0] = pipe2[1] * a1; // x[2n-1] * a1

    mul2[7] = pipe1[7] * a14;// x[2n-14] * a14
    mul2[6] = pipe1[6] * a12;
    mul2[5] = pipe1[5] * a10;
    mul2[4] = pipe1[4] * a8;
    mul2[3] = pipe1[3] * a6;
    mul2[2] = pipe1[2] * a4;
    mul2[1] = pipe1[1] * a2;
    mul2[0] = pipe1[0] * a0;// x[2n] * a0

    mul1[7] = pipe2[7] * a14;// x[2n-13] * a14
    mul1[6] = pipe2[6] * a12;
    mul1[5] = pipe2[5] * a10;
    mul1[4] = pipe2[4] * a8;
    mul1[3] = pipe2[3] * a6;
    mul1[2] = pipe2[2] * a4;
    mul1[1] = pipe2[1] * a2;
    mul1[0] = pipe2[0] * a0;// x[2n+1] * a0

    mul0[7] = pipe1[7] * a15;// x[2n-14] * a15
    mul0[6] = pipe1[6] * a13;
    mul0[5] = pipe1[5] * a11;
    mul0[4] = pipe1[4] * a9;
    mul0[3] = pipe1[3] * a7;
    mul0[2] = pipe1[2] * a5;
    mul0[1] = pipe1[1] * a3;
    mul0[0] = pipe1[0] * a1; // x[2n] * a1

    add2 = mul3[7] + mul3[6] + mul3[5] + mul3[4] + mul3[3] + mul3[2] + mul3[1] + mul3[0]
         + mul2[7] + mul2[6] + mul2[5] + mul2[4] + mul2[3] + mul2[2] + mul2[1] + mul2[0]; // y[2n]

    add1 = mul1[7] + mul1[6] + mul1[5] + mul1[4] + mul1[3] + mul1[2] + mul1[1] + mul1[0]
         + mul0[7] + mul0[6] + mul0[5] + mul0[4] + mul0[3] + mul0[2] + mul0[1] + mul0[0]; // y[2n+1]

end

always @(posedge clk) begin
    y1 <= add2 >> 16;
    y0 <= add1 >> 16;
end

endmodule
