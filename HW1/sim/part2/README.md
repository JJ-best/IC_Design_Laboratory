# Part2
## spyglass
To pass spyglass
- remember set sgdc file
- `set_option enable_save_restore false` in tcl file
## Testbench(Part2, Part3)
### initial block
Call the task to generate input.
```verilog
//-------------------
// Generate input
//-------------------
integer i, j;
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
    input_gen(8'h01);
    input_gen(8'h02);
    ...
end
```
Call the task to check the output.
```verilog
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
    ...
    $finish
end
```

---
### function loopsize()
Used to defined how many iteration we need in loop for complete set of `[4N-1:0]din` input. The loopsize may be $2^{4N}$ for loop(4*`N).
```verilog
function [63:0] loopsize;
    input [63:0] n;
    begin
        loopsize = (64'd1 << n) - 1'b1;  // 2^N
    end
endfunction
```

---
### task inputgen
This task used to input the complete set of `sel` and `din` with specific mode.
```verilog
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
```

---
### task outputcheck
This task will check whether the answer comes from LUT and SMART same when the `dout_valid` is high.
```verilog
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
                  $display("[PASS] LUT = %h, SMART = %h", result_0, result_1);
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
```