//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module trafficlight
#(parameter RED_TIME=4'd3, GREEN_TIME=4'd2, YELLOW_TIME=4'd1)
(
  // input
  input clk,
  input rst_n,  // synchronous negative reset
  input enable,
  // output
  output reg [1:0] out_state
);

// FSM
localparam IDLE=2'd0, RED=2'd1, GREEN=2'd2, YELLOW=2'd3;

reg [1:0] out_state_next;
reg [1:0] count;
always @(*) begin
  case (out_state)
    IDLE: begin
      if (~enable) begin
        out_state_next = IDLE;
      end else begin
        out_state_next = RED;
      end
    end
    RED: begin
      if (~enable) begin
        out_state_next = IDLE;
      end else if (count == RED_TIME) begin
        out_state_next = GREEN;
      end else begin
        out_state_next = RED;
      end
    end
    GREEN: begin
      if (~enable) begin
        out_state_next = IDLE;
      end else if (count == GREEN_TIME) begin
        out_state_next = YELLOW;
      end else begin
        out_state_next = GREEN;
      end
    end
    YELLOW: begin
      if (~enable) begin
        out_state_next = IDLE;
      end else if (count == YELLOW_TIME) begin
        out_state_next = RED;
      end else begin
        out_state_next = YELLOW;
      end
    end
  endcase
end

always @(posedge clk) begin
  if (~rst_n) begin
    out_state <= IDLE;
  end else begin
    out_state <= out_state_next;
  end
end


always @(posedge clk) begin
  if (~rst_n) begin
    count <= 1;
  end else if (out_state == IDLE) begin
    count <= 1;
  end else if (out_state != out_state_next) begin 
    count <= 1; // reset count for switch state moment
  end else begin
    count <= count + 1'b1;
  end
end

endmodule
