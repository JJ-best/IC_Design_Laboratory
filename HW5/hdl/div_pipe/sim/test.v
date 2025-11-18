module test ;
    parameter    N = 24 ;
    parameter    M = 18 ;
    reg          clk;
    reg          srst_n ;
    reg          data_rdy ;
    reg [N-1:0]  dividend ;
    reg [M-1:0]  divisor ;

    wire         res_rdy ;
    wire [N-1:0] merchant ;
    wire [M-1:0] remainder ;

initial begin
	$dumpfile("div.vcd");
	$dumpvars();
end
    //clock
    always begin
        clk = 0 ; #5 ;
        clk = 1 ; #5 ;
    end

    //driver
    initial begin
        srst_n      = 1'b0 ;
        #8 ;
        srst_n      = 1'b1 ;

        #55 ;
        @(negedge clk ) ;
        data_rdy  = 1'b1 ;
                dividend  = 25;      divisor      = 5;
        #10 ;   dividend  = 16;      divisor      = 3;
        #10 ;   dividend  = 10;      divisor      = 4;
        #10 ;   dividend  = 15;      divisor      = 1;
        repeat(32)    #10   dividend   = dividend + 1 ;
        divisor      = 7;
        repeat(32)    #10   dividend   = dividend + 1 ;
        divisor      = 5;
        repeat(32)    #10   dividend   = dividend + 1 ;
        divisor      = 4;
        repeat(32)    #10   dividend   = dividend + 1 ;
        divisor      = 6;
        repeat(32)    #10   dividend   = dividend + 1 ;
    end

    //对输入延迟，便于数据结果同周期对比，完成自校验
    reg  [N-1:0]   dividend_ref [N-1:0];
    reg  [M-1:0]   divisor_ref [N-1:0];
    always @(posedge clk) begin
        dividend_ref[0] <= dividend ;
        divisor_ref[0]  <= divisor ;
    end

    genvar         i ;
    generate
        for(i=1; i<=N-1; i=i+1) begin : LOOP
            always @(posedge clk) begin
                dividend_ref[i] <= dividend_ref[i-1];
                divisor_ref[i]  <= divisor_ref[i-1];
            end
        end
    endgenerate

    //自校验
    reg  error_flag ;
    always @(posedge clk) begin
    # 1 ;
        if (merchant * divisor_ref[N-1] + remainder != dividend_ref[N-1] && res_rdy) begin      //testbench 中可直接用乘号而不考虑运算周期
            error_flag <= 1'b1 ;
        end
        else begin
            error_flag <= 1'b0 ;
        end
    end

    //module instantiation
    div  #(.N(N), .M(M))
    u_divider
     (
      .clk              (clk),
      .srst_n             (srst_n),
      .rdy         (data_rdy), // input valid
      .dividend         (dividend),
      .divisor          (divisor),
      .valid          (res_rdy),
      .merchant         (merchant),
      .remainder        (remainder));

   //simulation finish
   initial begin
      forever begin
         #100;
         if ($time >= 10000)  $finish ;
      end
   end

endmodule // test