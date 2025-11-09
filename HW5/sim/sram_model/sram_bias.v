//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2025 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module sram_bias #(       //for bias
parameter BIAS_PER_ADDR = 1,
parameter BW_PER_PARAM = 10
)
(
input clk,
input csb,  //chip enable
input wsb,  //write enable
input [BIAS_PER_ADDR*BW_PER_PARAM-1:0] wdata, //write data
input [7-1:0] waddr, //write address
input [7-1:0] raddr, //read address

output reg [BIAS_PER_ADDR*BW_PER_PARAM-1:0] rdata
);

reg [BIAS_PER_ADDR*BW_PER_PARAM-1:0] mem [0:80-1];
reg [BIAS_PER_ADDR*BW_PER_PARAM-1:0] _rdata;

always @(posedge clk) begin
    if(~csb && ~wsb)
        mem[waddr] <= wdata;
end

always @(posedge clk) begin
    if(~csb)
        _rdata <= mem[raddr];
end

always @* begin
    rdata = #(1) _rdata;
end

task load_param(
    input integer index,
    input [BIAS_PER_ADDR*BW_PER_PARAM-1:0] param_input
);
    mem[index] = param_input;
endtask

endmodule
