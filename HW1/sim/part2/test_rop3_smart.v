`timescale 1ns/1ns
`define CYCLE 10
`define END_CYCLE 8000
`define PATH_INPUT   "../../pat/data/rop3_lut16_input.dat"
`define N 4
module test_rop3_smart ();

//-------------------
// Waveform dump
//-------------------
initial begin
    $fsdbDumpfile("test_rop3_smart.fsdb");
    $fsdbDumpvars; 
end

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

wire dout_valid_0;
wire [`N-1:0] result_0;
wire dout_valid_1;
wire [`N-1:0] result_1;

rop3_lut16 #(.N(`N)) ROP3_U0
(
  .clk(clk),
  .din_valid(din_valid),
  .din(din),
  .sel(sel),
  .mode(mode),
  .dout_valid(dout_valid_0),
  .result(result_0)
);

rop3_smart #(.N(`N)) ROP3_U1
(
  .clk(clk),
  .din_valid(din_valid),
  .din(din),
  .sel(sel),
  .mode(mode),
  .dout_valid(dout_valid_1),
  .result(result_1)
);

//-------------------
// Feeding input
//-------------------
// 1. 
// This testbench should generate all the modes listed in Table I and all possible 
// combinations of P, S and D. Try to use for-loop to generate these input 
// stimuluses. 
// 2. 
// This testbench should send identical inputs to both modules (rop3_lut16 & 
// rop3_smart), and compare their computation results. A reference testing 
// architecture is shown in Figure 3. 

// reg din_valid;
// reg  [4*`N-1:0] din;
// reg  [4:0]   sel;
// reg  [7:0]   mode;

reg first_flag;
initial begin
    din_valid = 0;
    din = 0;
    sel = 0;
    mode = 0;
    first_flag = 0;
    repeat(1) @(posedge clk);
    
    first_flag = 1;
    input_gen(8'h00);
    input_gen(8'h11);
    input_gen(8'h33);
    input_gen(8'h44);
    input_gen(8'h55);
    input_gen(8'h5A);
    input_gen(8'h66);
    input_gen(8'h88);
    input_gen(8'hBB);
    input_gen(8'hC0);
    input_gen(8'hCC);
    input_gen(8'hEE);
    input_gen(8'hF0);
    input_gen(8'hFB);
    input_gen(8'hFF);
end
//-------------------
// Compare output
//-------------------
reg [63:0] err_cnt;
reg [63:0] pas_cnt;
reg [63:0] pat_cnt;
initial begin
    err_cnt = 0;
    pas_cnt = 0;
    pat_cnt = 0;
    wait(first_flag);
    
    output_check(mode);
    output_check(mode);
    output_check(mode);
    output_check(mode);
    output_check(mode);

    output_check(mode);
    output_check(mode);
    output_check(mode);
    output_check(mode);
    output_check(mode);

    output_check(mode);
    output_check(mode);
    output_check(mode);
    output_check(mode);
    output_check(mode);

    


    if (err_cnt === 0) begin
      $display("PASS: %d pattern pass", pas_cnt);
    end else begin
      $display("FAIL: %d pattern pass", pas_cnt);
      $display("FAIL: %d pattern different", err_cnt);
    end

    $finish;
end


function [63:0] loopsize;
    input [63:0] n;
    begin
        loopsize = (64'd1 << n) - 1'b1;  // 2^N
    end
endfunction

//change loopsize of input_gen and output_check to `N(`N~4`N) get faster verification.
task input_gen;
    input [7:0] mode_d;
    integer i, j;
    begin
    din_valid <= 0;
    sel <= 0;
    mode <= mode_d;
        for (i = 0; i <= 5'b11111 ; i = i + 1) begin
            for (j = 0; j <= loopsize(4*`N); j = j + 1) begin
                din_valid <= 1;
                din <= din + 1;
                @(posedge clk);
            end
            sel <= sel + 1;
        end
    din_valid <= 0;
    sel <= 0;
    mode_d <= 0;
    end
endtask

task output_check;
    input [7:0]mode_display;
    integer i ,j;
    begin
        $display("======================================");
        $display("            check mode: %h            ", mode_display);
        $display("======================================");
        for (i = 0; i <= 5'b11111; i = i + 1) begin
            for (j = 0; j <= loopsize(4*`N); j = j + 1) begin
                
                // note that X will make while loop jump out.
                while (!(dout_valid_0 === 1'b1 && dout_valid_1 === 1'b1)) begin
                    @(negedge clk);
                end
                if (result_0 === result_1) begin
                  //$display("[PASS] LUT = %h, SMART = %h, pat_%d", result_0, result_1, pat_cnt);
                  //$display("[PASS] pat_%d", pat_cnt);
                  pas_cnt = pas_cnt + 1;
                end else begin
                  $display("[FAIL] LUT = %h, SMART = %h, time = [%0t]", result_0, result_1, $time);
                  err_cnt = err_cnt + 1;
                end
                pat_cnt = pat_cnt + 1;
                @(posedge clk);
            end
        end
    end
endtask;

endmodule //test_rop3_smart