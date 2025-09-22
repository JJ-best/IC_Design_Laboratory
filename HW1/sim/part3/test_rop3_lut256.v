`timescale 1ns/1ns
`define CYCLE 10
`define N 8
module test_rop3_smart ();

//-------------------
// Waveform dump
//-------------------
initial begin
    $fsdbDumpfile("test_rop3_lut256.fsdb");
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

rop3_lut256 #(.N(`N)) ROP3_U0
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
    input_gen(8'h03);
    input_gen(8'h04);
    input_gen(8'h05);
    input_gen(8'h06);
    input_gen(8'h07);
    input_gen(8'h08);
    input_gen(8'h09);
    input_gen(8'h0A);
    input_gen(8'h0B);
    input_gen(8'h0C);
    input_gen(8'h0D);
    input_gen(8'h0E);
    input_gen(8'h0F);
    input_gen(8'h10);
    input_gen(8'h11);
    input_gen(8'h12);
    input_gen(8'h13);
    input_gen(8'h14);
    input_gen(8'h15);
    input_gen(8'h16);
    input_gen(8'h17);
    input_gen(8'h18);
    input_gen(8'h19);
    input_gen(8'h1A);
    input_gen(8'h1B);
    input_gen(8'h1C);
    input_gen(8'h1D);
    input_gen(8'h1E);
    input_gen(8'h1F);
    input_gen(8'h20);
    input_gen(8'h21);
    input_gen(8'h22);
    input_gen(8'h23);
    input_gen(8'h24);
    input_gen(8'h25);
    input_gen(8'h26);
    input_gen(8'h27);
    input_gen(8'h28);
    input_gen(8'h29);
    input_gen(8'h2A);
    input_gen(8'h2B);
    input_gen(8'h2C);
    input_gen(8'h2D);
    input_gen(8'h2E);
    input_gen(8'h2F);
    input_gen(8'h30);
    input_gen(8'h31);
    input_gen(8'h32);
    input_gen(8'h33);
    input_gen(8'h34);
    input_gen(8'h35);
    input_gen(8'h36);
    input_gen(8'h37);
    input_gen(8'h38);
    input_gen(8'h39);
    input_gen(8'h3A);
    input_gen(8'h3B);
    input_gen(8'h3C);
    input_gen(8'h3D);
    input_gen(8'h3E);
    input_gen(8'h3F);
    input_gen(8'h40);
    input_gen(8'h41);
    input_gen(8'h42);
    input_gen(8'h43);
    input_gen(8'h44);
    input_gen(8'h45);
    input_gen(8'h46);
    input_gen(8'h47);
    input_gen(8'h48);
    input_gen(8'h49);
    input_gen(8'h4A);
    input_gen(8'h4B);
    input_gen(8'h4C);
    input_gen(8'h4D);
    input_gen(8'h4E);
    input_gen(8'h4F);
    input_gen(8'h50);
    input_gen(8'h51);
    input_gen(8'h52);
    input_gen(8'h53);
    input_gen(8'h54);
    input_gen(8'h55);
    input_gen(8'h56);
    input_gen(8'h57);
    input_gen(8'h58);
    input_gen(8'h59);
    input_gen(8'h5A);
    input_gen(8'h5B);
    input_gen(8'h5C);
    input_gen(8'h5D);
    input_gen(8'h5E);
    input_gen(8'h5F);
    input_gen(8'h60);
    input_gen(8'h61);
    input_gen(8'h62);
    input_gen(8'h63);
    input_gen(8'h64);
    input_gen(8'h65);
    input_gen(8'h66);
    input_gen(8'h67);
    input_gen(8'h68);
    input_gen(8'h69);
    input_gen(8'h6A);
    input_gen(8'h6B);
    input_gen(8'h6C);
    input_gen(8'h6D);
    input_gen(8'h6E);
    input_gen(8'h6F);
    input_gen(8'h70);
    input_gen(8'h71);
    input_gen(8'h72);
    input_gen(8'h73);
    input_gen(8'h74);
    input_gen(8'h75);
    input_gen(8'h76);
    input_gen(8'h77);
    input_gen(8'h78);
    input_gen(8'h79);
    input_gen(8'h7A);
    input_gen(8'h7B);
    input_gen(8'h7C);
    input_gen(8'h7D);
    input_gen(8'h7E);
    input_gen(8'h7F);
    input_gen(8'h80);
    input_gen(8'h81);
    input_gen(8'h82);
    input_gen(8'h83);
    input_gen(8'h84);
    input_gen(8'h85);
    input_gen(8'h86);
    input_gen(8'h87);
    input_gen(8'h88);
    input_gen(8'h89);
    input_gen(8'h8A);
    input_gen(8'h8B);
    input_gen(8'h8C);
    input_gen(8'h8D);
    input_gen(8'h8E);
    input_gen(8'h8F);
    input_gen(8'h90);
    input_gen(8'h91);
    input_gen(8'h92);
    input_gen(8'h93);
    input_gen(8'h94);
    input_gen(8'h95);
    input_gen(8'h96);
    input_gen(8'h97);
    input_gen(8'h98);
    input_gen(8'h99);
    input_gen(8'h9A);
    input_gen(8'h9B);
    input_gen(8'h9C);
    input_gen(8'h9D);
    input_gen(8'h9E);
    input_gen(8'h9F);
    input_gen(8'hA0);
    input_gen(8'hA1);
    input_gen(8'hA2);
    input_gen(8'hA3);
    input_gen(8'hA4);
    input_gen(8'hA5);
    input_gen(8'hA6);
    input_gen(8'hA7);
    input_gen(8'hA8);
    input_gen(8'hA9);
    input_gen(8'hAA);
    input_gen(8'hAB);
    input_gen(8'hAC);
    input_gen(8'hAD);
    input_gen(8'hAE);
    input_gen(8'hAF);
    input_gen(8'hB0);
    input_gen(8'hB1);
    input_gen(8'hB2);
    input_gen(8'hB3);
    input_gen(8'hB4);
    input_gen(8'hB5);
    input_gen(8'hB6);
    input_gen(8'hB7);
    input_gen(8'hB8);
    input_gen(8'hB9);
    input_gen(8'hBA);
    input_gen(8'hBB);
    input_gen(8'hBC);
    input_gen(8'hBD);
    input_gen(8'hBE);
    input_gen(8'hBF);
    input_gen(8'hC0);
    input_gen(8'hC1);
    input_gen(8'hC2);
    input_gen(8'hC3);
    input_gen(8'hC4);
    input_gen(8'hC5);
    input_gen(8'hC6);
    input_gen(8'hC7);
    input_gen(8'hC8);
    input_gen(8'hC9);
    input_gen(8'hCA);
    input_gen(8'hCB);
    input_gen(8'hCC);
    input_gen(8'hCD);
    input_gen(8'hCE);
    input_gen(8'hCF);
    input_gen(8'hD0);
    input_gen(8'hD1);
    input_gen(8'hD2);
    input_gen(8'hD3);
    input_gen(8'hD4);
    input_gen(8'hD5);
    input_gen(8'hD6);
    input_gen(8'hD7);
    input_gen(8'hD8);
    input_gen(8'hD9);
    input_gen(8'hDA);
    input_gen(8'hDB);
    input_gen(8'hDC);
    input_gen(8'hDD);
    input_gen(8'hDE);
    input_gen(8'hDF);
    input_gen(8'hE0);
    input_gen(8'hE1);
    input_gen(8'hE2);
    input_gen(8'hE3);
    input_gen(8'hE4);
    input_gen(8'hE5);
    input_gen(8'hE6);
    input_gen(8'hE7);
    input_gen(8'hE8);
    input_gen(8'hE9);
    input_gen(8'hEA);
    input_gen(8'hEB);
    input_gen(8'hEC);
    input_gen(8'hED);
    input_gen(8'hEE);
    input_gen(8'hEF);
    input_gen(8'hF0);
    input_gen(8'hF1);
    input_gen(8'hF2);
    input_gen(8'hF3);
    input_gen(8'hF4);
    input_gen(8'hF5);
    input_gen(8'hF6);
    input_gen(8'hF7);
    input_gen(8'hF8);
    input_gen(8'hF9);
    input_gen(8'hFA);
    input_gen(8'hFB);
    input_gen(8'hFC);
    input_gen(8'hFD);
    input_gen(8'hFE);
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
    output_check(mode);

    if (err_cnt === 0) begin
      $display("ALL PASS");
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
                  //$display("[PASS] LUT = %h, SMART = %h", result_0, result_1);
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