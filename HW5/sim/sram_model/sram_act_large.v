//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2025 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module sram_act_large #(     //for activation
parameter CH_NUM = 8,
parameter ACT_PER_ADDR = 1,
parameter BW_PER_ACT = 10
)
(
input clk,
input [CH_NUM*ACT_PER_ADDR-1:0] wordmask,  //8 bits
input csb,  //chip enable
input wsb,  //write enable
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] wdata, //write data 112 bits
input [6-1:0] waddr, //write address
input [6-1:0] raddr, //read address

output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] rdata //read data 112 bits
);

reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] _rdata;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] mem [0:64-1];
wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] bit_mask;

assign bit_mask = {{10{wordmask[7]}}, {10{wordmask[6]}}, {10{wordmask[5]}}, {10{wordmask[4]}}, {10{wordmask[3]}}, {10{wordmask[2]}}, {10{wordmask[1]}}, {10{wordmask[0]}}};

always @(posedge clk) begin
    if(~csb && ~wsb) begin
        mem[waddr] <= (wdata & ~(bit_mask)) | (mem[waddr] & bit_mask);
    end
end

always @(posedge clk) begin
    if(~csb) begin
        _rdata <= mem[raddr];
    end
end

always @* begin
    rdata = #(1) _rdata;
end

task load_act(
    input integer index,
    input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] param_input
);
    mem[index] = param_input;
endtask

task reset_sram;
    integer i;
    begin
        for(i=0;i<64;i=i+1)begin
            mem[i] = 112'bX;
        end
    end
endtask

endmodule