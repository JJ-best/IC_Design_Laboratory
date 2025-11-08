//====================================================================================
//  Module Description: 4x4 matrix multiplxiation for zebranet accelerator
//  Owner             : Vision Circuits and Systems Lab, National Tsing Hua University
//====================================================================================
module matmul #(
    parameter BW_MATMUL = 2*`BITWIDTH+$clog2(4/`N)
)(
    input [4*`BITWIDTH-1:0] feature,
    input [4*4/`N*`BITWIDTH-1:0] weight,
    output signed [BW_MATMUL*4-1:0] matmul_out
);

wire signed [`BITWIDTH-1:0] weight00, weight01, weight02, weight03;
wire signed [`BITWIDTH-1:0] weight10, weight11, weight12, weight13;
wire signed [`BITWIDTH-1:0] weight20, weight21, weight22, weight23;
wire signed [`BITWIDTH-1:0] weight30, weight31, weight32, weight33;

assign {weight00, weight01, weight02, weight03,
        weight10, weight11, weight12, weight13,
        weight20, weight21, weight22, weight23,
        weight30, weight31, weight32, weight33} = weight;

wire signed [`BITWIDTH-1:0] feature0, feature1, feature2, feature3;
assign {feature0, feature1, feature2, feature3} = feature;
    
reg signed [BW_MATMUL-1:0] product0, product1, product2, product3;
assign matmul_out = {product0, product1, product2, product3};

always@*begin
    product0 = weight00*feature0 + weight01*feature1 + weight02*feature2 + weight03*feature3;
    product1 = weight10*feature0 + weight11*feature1 + weight12*feature2 + weight13*feature3;
    product2 = weight20*feature0 + weight21*feature1 + weight22*feature2 + weight23*feature3;
    product3 = weight30*feature0 + weight31*feature1 + weight32*feature2 + weight33*feature3;
end

endmodule