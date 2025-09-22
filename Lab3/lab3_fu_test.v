//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

// `timescale 1ns/1ps // set the timescale for the simulation
module lab3_fu_test;  // module of testbench

parameter CYCLE = 10; // use CYCLE to describe the clock period
parameter DATA_WIDTH = 16; // data width
parameter INS_WIDTH = 5;
///// declare input(reg) and output(wire) /////

// use reg to declare inputs of the circuit //
// ex: reg [4:0] gray_in; or reg [SIZE-1:0] gray_in
reg clk;
reg rst_n;
reg signed [DATA_WIDTH-1:0] A;
reg signed [DATA_WIDTH-1:0] B;
reg [INS_WIDTH-1:0] instruction;
parameter LARGE_NUMBER = 10000;

// use wire to declare outputs of the circuit //
// ex: wire [4:0] bin_out;
wire signed [DATA_WIDTH-1:0] F_o;

///// instantiate  module /////
// instantiate the module you finished in following format //
// module_name #(.parameter1(5),.parameter2(3)) unit_name (.port1(...), .port2(...), ...); //
// ex: gray2bin #(.SIZE(7)) U0 (.bin(x),.gray(y),.clk(z));
lab3_fu #(
  .DATA_WIDTH(16), .INS_WIDTH(5)
) FU (
  .clk(clk),
  .rst_n(rst_n),
  .A(A),
  .B(B),
  .instruction(instruction),
  .F_o(F_o)
);


// use the following commands to dump the waveform of the simulation //
//initial begin
//  $fsdbDumpfile("gray.fsdb"); // "gray.fsdb" can be replaced into any name you want
//  $fsdbDumpvars;              // but make sure in .fsdb format
//end
//
// initial begin
//   $dumpfile("fu.vcd");
//   $dumpvars();
// end
initial begin
  $fsdbDumpfile("lab3.fsdb"); // "gray.fsdb" can be replaced into any name you want
  $fsdbDumpvars;              // but make sure in .fsdb format
end




// the following command generates the behavior of the clock signal and system control
// #(x1) means delay x1 time, the time unit is declared at `timescale
always #(CYCLE/2) clk = ~clk; //clk toggles every half cycle
// System block set only clock, reset signal and the timeout finish. 
initial begin
  // 1. set the initial state of the clk and reset, ex: clk=0;
clk = 0;
  // 2. set your reset behavior
rst_n = 1;
@(posedge clk);
rst_n = 0; //rst_n active
repeat(2) @(posedge clk);
rst_n = 1;

  // 3. call finish function when the simulation runs time out.
  //    Proper constrain simulation time at beginning helps you reduce the debugging period.
  //    $finish <- this command indicates that the simulation is over
  //    Ex. #(CYCLE*LARGE_NUMBER) $finish;
# (CYCLE * LARGE_NUMBER) $finish;
end

// pattern feeding block, control when and what pattern to feed to the circuit.
// this block can be considered as a behavior model of a verification module or other modules interfacing your circuit.
// pattern feeding block, control when and what pattern to feed to the circuit.
// this block can be considered as a behavior model of a verification module or other modules interfacing your circuit.
parameter PAT_NUM = 320;
reg [(DATA_WIDTH-1):0] pat_a [0:(PAT_NUM-1)];
reg [(DATA_WIDTH-1):0] pat_b [0:(PAT_NUM-1)];
reg [(INS_WIDTH-1):0]  pat_i [0:(PAT_NUM-1)];
reg [(DATA_WIDTH-1):0] pat_g [0:(PAT_NUM-1)];
reg [15:0] t1;   // 16 bits
reg [15:0] t2;   // 16 bits
reg [7:0]  t3;   //  8 bits
reg [15:0] t4;   // 16 bits

integer fd;
integer idx;
integer r;

initial begin
  fd = $fopen("golden2.dat", "r");
  idx = 0;
  r= 0;
  if (fd == 0) begin
    $display("File open failed!");
    $finish;
  end

  while (!$feof(fd)) begin

    r = $fscanf(fd, "%4h_%4h_%2h_%4h\n", t1, t2, t3, t4);

    $display("r = %d", r);
    if (r == 4) begin
      pat_a[idx] = t1;
      pat_b[idx] = t2;
      pat_i[idx] = t3;
      pat_g[idx] = t4;
      idx = idx + 1;
    end else begin
      $display("Warning: Invalid line format at index %0d", idx);
    end
  end
  $display("//---------------------------------------//");
  $display("Loaded %0d test patterns from golden2.dat", idx);
  $display("//---------------------------------------//");
  $fclose(fd);
end



integer i;
initial begin
  // 1. set the initial state of the testing signal
  // 2. finish your testbench here, you should verify all functions in ALU with different combination of input signals
  // 3. you can use wait or @(negedge clk), to control when to feed your pattern
  // ex: wait(rst_n==1) do something.../ @(negedge clk) do something...
  //    You can check the testbench in lab2 for full demenstration.
  // 4. you can use for or while loop to generate all possible inputs to verify your answer
  // ex: for(i=0;i<50;i=i+1)begin   // no i++ in verilog
  // 5. Besides generating patterns in testbench, you can also read patterns from external file.
  //    You can check the testbench in lab2 for full demenstration.
  // ex: reg [bitwidth:0] pattern_ary [0:pat_num];
  //     $readmemh("pattern.dat",pattern_ary);
  // It's suggested to use the method in 5, since we can generate patterns and results from other software(your algorithm),
  // and verify your circuit with reference algorithm. A reference pattern "golden.dat" is provided for (A=100,B=-201) requirement.
  // You can check the testbench in lab2 for full demenstration.
A = 0;
B = 0;
instruction = 0;
i = 0;

wait (rst_n == 0);
wait (rst_n == 1);
for (i = 0; i < PAT_NUM; i = i + 1) begin
  A = pat_a[i];
  B = pat_b[i];
  instruction = pat_i[i];
  @(posedge clk);
end
end 

reg [(INS_WIDTH-1):0]i_tmp[0:1];
always @(posedge clk) begin
  if (~rst_n) begin
    i_tmp[0] <= 0;
    i_tmp[1] <= i_tmp[0];
  end else begin
    i_tmp[0] <= instruction;
    i_tmp[1] <= i_tmp[0];
  end
  
end
// output result checking block, control when to sample and verify the result.
// this block can be considered as a behavior model of a verification module or other modules interfacing your circuit.
integer j;
integer err;
initial begin
  err = 0;
 wait (rst_n == 0);
 wait (rst_n == 1);
  repeat(2) @(posedge clk);
  for (j = 0; j < PAT_NUM; j = j + 1) begin
    if (F_o === pat_g[j]) begin
      $display("[PASS]: OUT_PAT = %h, GOLD_PAT = %h [PAT: %d], InsType: %d", F_o, pat_g[j], j, i_tmp[1]);
    end else begin
      $display("[FAIL]: OUT_PAT = %h, GOLD_PAT = %h [PAT: %d], InsType: %d", F_o, pat_g[j], j, i_tmp[1]);
      err = err + 1;
    end
    @(posedge clk);
  end
  
  if (err == 0) begin
    $display("ALL PASS");
  end else begin
    $display("%d Pattern Fail.", err);
  end
  // 0. Use the same control technique to control when to sample output result.
  // 1. use $display command to show the state of signal
  // ex: $display("x = %b", x); %b means to display x in binary, you can try %d, %h or others.
  // 2. you can also write the result to a text file and verify the result with other program
  // ex: integer  fp_w;
  //     fp_w = $fopen("data_in.txt");
  //     $fwrite(fp_w, "%d %d %d\n", a, b, c);
  //     $fdisplay(fp_w, "xxxxxxxxxxx %d", a);
  // 3. when displaying result, timing stamp is an important infomation, you can get time stamp with $time
  // ex: $display("%t happens xxx", $time);
  // As the suggestion in pattern feeding block, you can read the results generated from other software,
  // rather than write the same operations in testbench and circuit. It's useless to verify difference between a+b and a+b.
end

// Besides fixed pattern, you can use $random to generate random integer
// ex: a={$random} % 32   //return 0~31
// ex: a= min+{$random}%(max-min+1); // return min~ max

endmodule