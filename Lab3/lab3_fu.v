//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module lab3_fu
#(
  parameter DATA_WIDTH = 16,
  parameter INS_WIDTH = 5
)
(
  input clk,
  input rst_n,
  input signed [DATA_WIDTH-1:0] A,
  input signed [DATA_WIDTH-1:0] B,
  input [INS_WIDTH-1:0] instruction,
  output reg signed [DATA_WIDTH-1:0] F_o
);

reg signed [DATA_WIDTH-1:0] F;

always@(*) begin // instruction table
  case(instruction)
    5'b00000 : begin F = A;      end //0
    5'b00001 : begin F = A+1;    end
    5'b00010 : begin F = A+(~B); end
    5'b00011 : begin F = A+~B+1;  end //3
    5'b00100 : begin F = A+B;    end //4
    5'b00101 : begin F = A+B+1;  end
    5'b00110 : begin F = B;      end //6
    5'b00111 : begin F = A-1;    end
    5'b01000 : begin F = A&B;    end
    5'b01001 : begin F = A|B;    end
    5'b01010 : begin F = A^B;    end
    5'b01011 : begin F = ~A;     end
    5'b10000 : begin F = B>>1;   end
    5'b10001 : begin F = B<<1;   end
    5'b10010 : begin F = {B[0], B[(DATA_WIDTH-1):1]}; end
    5'b10011 : begin F = {B[(DATA_WIDTH-2):0], B[(DATA_WIDTH-1)]}; end
    default  : begin F = 0;      end
  endcase
end

always@(posedge clk) begin
  if(~rst_n) begin
    F_o <= 0;
  end
  else begin
    F_o <= F;
  end
end

endmodule
