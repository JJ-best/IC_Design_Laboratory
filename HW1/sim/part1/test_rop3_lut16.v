
`define CYCLE 10
`define END_CYCLE 8000
`define TEST_DATA_NUM 7500
`define TEST_result_NUM 2048
`define PATH_INPUT   "../../pat/data/rop3_lut16_input.dat"
`define PATH_GOLDEN  "../../pat/data/rop3_lut16_golden.dat"
`define N 8
module test_rop3_lut16;

//-------------
// create clk
//-------------
reg clk;
initial begin
    clk = 0;
    while(1) #(`CYCLE/2) clk = ~clk;
end


//-------------------
// RTL instantiation
//-------------------
reg din_valid;
reg  [4*`N-1:0] din;
reg  [4:0]   sel;
reg  [7:0]   mode;
wire dout_valid;
wire [`N-1:0] result;


rop3_lut16 #(.N(`N)) ROP3_U0
(
  .clk(clk),
  .din_valid(din_valid),
  .din(din),
  .sel(sel),
  .mode(mode),
  .dout_valid(dout_valid),
  .result(result)
);


//-------------------
// Waveform dump
//-------------------
initial begin
    $fsdbDumpfile("test_rop3_lut16.fsdb");
    $fsdbDumpvars; 
end


//-------------------
// Feeding input
//-------------------
integer fp_in;
integer input_read_status = 0;
integer input_i = 0;
reg [45:0] buff_in;

reg [4*`N-1:0] din_d, din_d2;
reg [7:0]   mode_d, mode_d2;
reg [4:0]   sel_d, sel_d2;



initial begin
    // input feeding init
    fp_in = $fopen(`PATH_INPUT, "r");
    din_valid = 1'hz;
    din       = {4*`N{1'bz}};
    mode      = 8'hzz;
    sel       = 5'hzz;

    // input feeding start
    while(input_i < `TEST_DATA_NUM) begin
        @(posedge clk); #1;
        {din_d2, mode_d2, sel_d2} = {din_d, mode_d, sel_d};
        {din_d, mode_d, sel_d} = {din, mode, sel};
        
        input_read_status = $fscanf(fp_in, "%b", buff_in);
        din_valid = 1'b1;
        {din, mode, sel} = buff_in;     

        input_i = input_i + 1;
    end

    // input feeding stop
    $fclose(fp_in);
    #(`CYCLE);
    din_valid = 1'hz;
    din  = {4*`N{1'bz}};
    mode      = 8'hzz;
    sel       = 5'hzz;
end




//-------------------
// Output comparision
//-------------------
integer golden_read_status = 0;
integer fp_gold;
integer output_i = 0;
integer total_error = 0;
reg [7:0] result_golden;
initial begin

    // output comparison init
    fp_gold = $fopen(`PATH_GOLDEN, "r");

    // output comparison start
    // two stage pipeline register delay
    #(`CYCLE*2);
    @(negedge clk);
    while(output_i < `TEST_result_NUM) begin
        @(negedge clk);
        if(dout_valid) begin    
            golden_read_status = $fscanf(fp_gold, "%b", result_golden);
            if (result_golden !== result) begin
                $display("!!!!! Comparison Fail @ pattern %0d !!!!!", output_i);
                $display("[pattern %0d]        mode=%2h, sel=%2h, {din_data}={%2h,%2h,%2h,%2h}, RTL=%2h, Answer=%2h",
                        output_i, mode_d2, sel_d2, din_d2[3*`N+:`N], din_d2[2*`N+:`N], din_d2[1*`N+:`N], din_d2[0*`N+:`N], result, result_golden);
                total_error = total_error + 1;
            end else begin
                $display(">>>>> Comparison Pass @ pattern %0d <<<<<", output_i);
            end

            output_i = output_i + 1;
        end
    end

    $fclose(fp_gold);
    if (total_error > 0) begin
        $display("\nxxxxxxxxxxx Comparison Fail xxxxxxxxxxx");
        $display("            Total %0d errors\n  Please check your error messages...", total_error);
        $display("xxxxxxxxxxx Comparison Fail xxxxxxxxxxx\n");

        if (total_error > `TEST_DATA_NUM*0.8) begin
            $display("! Hmm...There are so many errors, Did you make the output registered?\n");
        end
        
    end else begin
        $display("\n============= Congratulations =============");
        $display("    You can move on to the next part !");
        $display("============= Congratulations =============\n");
    end
    $finish;
end

// early termination of simulation 
initial begin
  #(`END_CYCLE*`CYCLE);
  $display("\n============= Error =============");
  $display(  "   Simulation takes too long...  ");
  $display("============= Error =============\n");
  $finish;

end

endmodule
