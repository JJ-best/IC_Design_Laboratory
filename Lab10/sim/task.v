//========== task definition ===========//
task load_instruction;
    $readmemh(`INST_FILE, inst);
endtask

task load_wgt;
begin
    $readmemh(`WEIGHT_FILE1, wgt_mem_test, 0);
    $readmemh(`WEIGHT_FILE0, wgt_mem, 0*MAX_CHANNEL);
    $readmemh(`WEIGHT_FILE1, wgt_mem, 1*MAX_CHANNEL);
    $readmemh(`WEIGHT_FILE2, wgt_mem, 2*MAX_CHANNEL);
    $readmemh(`WEIGHT_FILE3, wgt_mem, 3*MAX_CHANNEL);
    $readmemh(`WEIGHT_FILE4, wgt_mem, 4*MAX_CHANNEL);
    $readmemh(`WEIGHT_FILE5, wgt_mem, 5*MAX_CHANNEL);
    $readmemh(`WEIGHT_FILE6, wgt_mem, 6*MAX_CHANNEL);
    $readmemh(`WEIGHT_FILE7, wgt_mem, 7*MAX_CHANNEL);
end
endtask

task load_bias;
begin
    $readmemh(`BIAS_FILE0, bias_mem, 0*MAX_CHANNEL);
    $readmemh(`BIAS_FILE1, bias_mem, 1*MAX_CHANNEL);
    $readmemh(`BIAS_FILE2, bias_mem, 2*MAX_CHANNEL);
    $readmemh(`BIAS_FILE3, bias_mem, 3*MAX_CHANNEL);
    $readmemh(`BIAS_FILE4, bias_mem, 4*MAX_CHANNEL);
    $readmemh(`BIAS_FILE5, bias_mem, 5*MAX_CHANNEL);
    $readmemh(`BIAS_FILE6, bias_mem, 6*MAX_CHANNEL);
    $readmemh(`BIAS_FILE7, bias_mem, 7*MAX_CHANNEL);
end
endtask

task load_inter_feature;
begin
    $readmemh(`OUT_ACT_FILE0, inter_feature_mem, 0*INTER_FEATURE_MEM_SIZE);
    $readmemh(`OUT_ACT_FILE1, inter_feature_mem, 1*INTER_FEATURE_MEM_SIZE);
    $readmemh(`OUT_ACT_FILE2, inter_feature_mem, 2*INTER_FEATURE_MEM_SIZE);
    $readmemh(`OUT_ACT_FILE3, inter_feature_mem, 3*INTER_FEATURE_MEM_SIZE);
    $readmemh(`OUT_ACT_FILE4, inter_feature_mem, 4*INTER_FEATURE_MEM_SIZE);
    $readmemh(`OUT_ACT_FILE5, inter_feature_mem, 5*INTER_FEATURE_MEM_SIZE);
    $readmemh(`OUT_ACT_FILE6, inter_feature_mem, 6*INTER_FEATURE_MEM_SIZE);
    $readmemh(`OUT_ACT_FILE7, inter_feature_mem, 7*INTER_FEATURE_MEM_SIZE);
end
endtask


task load_act;
begin
    $readmemh(`IN_ACT_FILE, external_img_input_mem);
end
endtask

task load_fl;
begin
    $readmemh(`ACT_FL_FILE, act_fl_mem);
    $readmemh(`PARAM_FL_FILE, param_fl_mem); 
end
endtask

task load_golden;
begin
    $readmemh(`GOLD_FILE, golden_img_output_mem);
end
endtask



task input_block_preparation; 
    integer chin_idx, x_idx, y_idx;
    begin
        // decode current pixel position
        if (`INF_MODE == 0) begin 
            // forget directly
            pixel_x_idx_in = block_x_idx_in*(`BLK_WIDTH-`TOTAL_LAYER*2);
            pixel_y_idx_in = block_y_idx_in*`BLK_HEIGHT;
        end else begin 
            // reuse externally
            pixel_x_idx_in = block_x_idx_in*`BLK_WIDTH;
            pixel_y_idx_in = block_y_idx_in*`BLK_HEIGHT;
        end 
        $display("Prepare block Y: [%d], X: [%d]", block_y_idx_in, block_x_idx_in);
        // $display("(Frame pixel bias In) Y = %d, X = %d", pixel_y_idx_in, pixel_x_idx_in);
        // $display("-->(Frame pixel bias In) Y = %d, X = %d", pixel_y_idx_in, pixel_x_idx_in);
        // block buffer preparation 
        for (chin_idx=0; chin_idx<BASE_CHANNEL; chin_idx=chin_idx+1)begin
            for (y_idx=0; y_idx<`BLK_HEIGHT; y_idx=y_idx+1)begin
                for (x_idx=0; x_idx<`BLK_WIDTH; x_idx=x_idx+1)begin
                    if (chin_idx<3) begin
                        // read from external_img_input_mem & store into internal_block_mem_0
                        internal_block_mem_0[chin_idx*`BLK_HEIGHT*`BLK_WIDTH + y_idx*`BLK_WIDTH + x_idx] = external_img_input_mem[chin_idx*(`IMG_HEIGHT+`TOTAL_LAYER*2)*(`IMG_WIDTH+`TOTAL_LAYER*2) + (pixel_y_idx_in+y_idx)*(`IMG_WIDTH+`TOTAL_LAYER*2) + (pixel_x_idx_in+x_idx)];
                    end else begin 
                        // zero padding for 3-ch input
                        internal_block_mem_0[chin_idx*`BLK_HEIGHT*`BLK_WIDTH + y_idx*`BLK_WIDTH + x_idx] = 0;
                    end
                end
            end
        end 
    end
endtask

task engine_config;
    reg [BW_FL-1:0] in_fl_1ch, out_fl_1ch;
    begin
        // instruction
        {Relu, srcSRAM, resSRAM, dstSRAM, CHout, CHin} = inst[layer_idx_in];
        // $display("Instruction for layer [%d]: ReLU = %d, srcSRAM = %d, resSRAM = %d, dstSRAM = %d, CHout = %d, CHin = %d", 
        //        layer_idx_in, Relu, srcSRAM, resSRAM, dstSRAM, CHout, CHin);
        if (`INF_MODE == 0) begin
            // forget directly
            blkW_out = `BLK_WIDTH - 2*(layer_idx_in + 1);
            blkH_out = `BLK_HEIGHT; 
        end else begin
            // reuse internally/externally
            blkW_out = `BLK_WIDTH;
            blkH_out = `BLK_HEIGHT; 
        end
        relu = Relu[0];
        // frational length 
        wgt_fl = param_fl_mem[layer_idx_in*2]; bias_fl = param_fl_mem[layer_idx_in*2+1]; 


        in_fl_1ch = act_fl_mem[layer_idx_in*2]; out_fl_1ch = act_fl_mem[layer_idx_in*2+1]; 
        in_fl = {in_fl_1ch, in_fl_1ch, in_fl_1ch, in_fl_1ch};
        out_fl = {out_fl_1ch, out_fl_1ch, out_fl_1ch, out_fl_1ch};
        // idt_fl = ; // don't care for this case
    end
endtask

task conv_layer_inference;
    integer chout_idx, chin_idx, x_idx, y_idx;
    integer inner_chout_idx, inner_chin_idx;
    integer signed cur_y_bias;
    integer y_boundary;
    parameter VIR_BLK_MEM_SIZE = (`BLK_HEIGHT+2)*(`BLK_WIDTH+2)*BASE_CHANNEL;
    // parameter LOCAL_FIFO_SIZE = (`BLK_WIDTH*2+2)*BASE_CHANNEL;
    reg [`BITWIDTH-1:0] virtual_input_block [0:VIR_BLK_MEM_SIZE-1];  // simplifed: virtual input block
    // reg [`BITWIDTH-1:0] locally_register_fifo [0:LOCAL_FIFO_SIZE-1]; // advanced:  locally register fifo interface for 3x3 tile input 
    reg signed [`BITWIDTH-1:0] px0, px1, px2, px3, px4, px5, px6, px7, px8;
    reg signed [`BITWIDTH-1:0] kx0, kx1, kx2, kx3, kx4, kx5, kx6, kx7, kx8;
    begin
        // Phase-1: virtual block preparation (input block padding)
        if (`INF_MODE == 0) begin // forget directly
            for (chin_idx=0; chin_idx<CHin; chin_idx=chin_idx+1) begin
                // read first row from row-direction along-stripe reuse buffer
                for (y_idx=0; y_idx<2; y_idx=y_idx+1) begin
                    for (x_idx=0; x_idx<(blkW_out+2); x_idx=x_idx+1) begin
                        virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ] = internal_reuse_mem_y [ layer_idx_in*BASE_CHANNEL*`BLK_WIDTH*2 + chin_idx*`BLK_WIDTH*2 + y_idx*`BLK_WIDTH + x_idx ];
                    end
                end
                // read block data from block buffer
                for (y_idx=2; y_idx<(blkH_out+2); y_idx=y_idx+1) begin
                    for (x_idx=0; x_idx<(blkW_out+2); x_idx=x_idx+1) begin
                        // if (chin_idx==0)begin
                        //     $display("Y=%d, X=%d, val=%d",y_idx, x_idx, $signed(internal_block_mem_0 [ chin_idx*`BLK_HEIGHT*`BLK_WIDTH + (y_idx-2)*`BLK_WIDTH + x_idx]) );
                        // end
                        case(1)
                            (srcSRAM == 0): virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ] = internal_block_mem_0 [ chin_idx*`BLK_HEIGHT*`BLK_WIDTH + (y_idx-2)*`BLK_WIDTH + x_idx];
                            (srcSRAM == 1): virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ] = internal_block_mem_1 [ chin_idx*`BLK_HEIGHT*`BLK_WIDTH + (y_idx-2)*`BLK_WIDTH + x_idx];
                            (srcSRAM == 2): virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ] = internal_block_mem_2 [ chin_idx*`BLK_HEIGHT*`BLK_WIDTH + (y_idx-2)*`BLK_WIDTH + x_idx];
                        endcase
                    end
                end
            end
        end else begin
            cur_y_bias = block_y_idx_in*`BLK_HEIGHT - (layer_idx_in+1)*2;
            // $display("y_bias_in = %d", cur_y_bias);
            // if (layer_idx_in==0)begin
            //     $display("==================== Read Y from %d to %d", cur_y_bias, cur_y_bias+blkH_out+2-1);
            // end
            for (chin_idx=0; chin_idx<CHin; chin_idx=chin_idx+1) begin
                // read first column from column-direction across-stripe reuse buffer (internal)
                for (y_idx=0; y_idx<(blkH_out+2); y_idx=y_idx+1) begin // 178 ?
                    for (x_idx=0; x_idx<2; x_idx=x_idx+1) begin
                        case(1)
                            (`INF_MODE == 1): virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ] = internal_reuse_mem_x[ layer_idx_in*BASE_CHANNEL*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 + chin_idx*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 + (cur_y_bias + y_idx)*2 + x_idx ]; //internally
                            (`INF_MODE == 2): virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ] = external_reuse_mem_x[ layer_idx_in*BASE_CHANNEL*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 + chin_idx*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 + (cur_y_bias + y_idx)*2 + x_idx ]; //externally
                        endcase
                        // if(chin_idx==0 && layer_idx_in==0)begin
                        //     $display("read address for layer:[%d], ch:[%d], y:[%d], x:[%d] = %d, value = %h (%d) ", layer_idx_in, chin_idx, y_idx, x_idx, layer_idx_in*BASE_CHANNEL*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 + chin_idx*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 + (cur_y_bias + y_idx)*2 + x_idx, virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ], $signed(virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ]) );
                        // end
                    end
                end
                // read first row from row-direction along-stripe reuse buffer
                for (y_idx=0; y_idx<2; y_idx=y_idx+1) begin
                    for (x_idx=2; x_idx<(blkW_out+2); x_idx=x_idx+1) begin
                        virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ] = internal_reuse_mem_y [ layer_idx_in*BASE_CHANNEL*`BLK_WIDTH*2 + chin_idx*`BLK_WIDTH*2 + y_idx*`BLK_WIDTH + (x_idx-2) ];
                    end
                end
                // read block data from block buffer
                for (y_idx=2; y_idx<(blkH_out+2); y_idx=y_idx+1) begin
                    for (x_idx=2; x_idx<(blkW_out+2); x_idx=x_idx+1) begin
                        case(1)
                            (srcSRAM == 0): virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ] = internal_block_mem_0 [ chin_idx*`BLK_HEIGHT*`BLK_WIDTH + (y_idx-2)*`BLK_WIDTH + (x_idx-2) ];
                            (srcSRAM == 1): virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ] = internal_block_mem_1 [ chin_idx*`BLK_HEIGHT*`BLK_WIDTH + (y_idx-2)*`BLK_WIDTH + (x_idx-2) ];
                            (srcSRAM == 2): virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ] = internal_block_mem_2 [ chin_idx*`BLK_HEIGHT*`BLK_WIDTH + (y_idx-2)*`BLK_WIDTH + (x_idx-2) ];
                        endcase
                        // if (layer_idx_in==7)begin
                        //     $display( "chin_idx = %d, y= %d, x = %d, val = %h", chin_idx, y_idx, x_idx, virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ] );
                        // end
                    end
                end
            end
        end
        
        // Phase-2: send activations & weights to engine
        for (chout_idx=0; chout_idx<CHout; chout_idx=chout_idx+OUT_CHANNEL) begin
            for (chin_idx=0; chin_idx<CHin; chin_idx=chin_idx+IN_CHANNEL) begin
                for (y_idx=0; y_idx<blkH_out; y_idx=y_idx+1) begin
                    for (x_idx=0; x_idx<blkW_out; x_idx=x_idx+1) begin
                        @(negedge clk); // inner loops perform data concatenation for one cycle 
                        conv_din_enable = 1;
                        for (inner_chout_idx=0; inner_chout_idx<OUT_CHANNEL; inner_chout_idx=inner_chout_idx+1) begin
                            for (inner_chin_idx=0; inner_chin_idx<IN_CHANNEL; inner_chin_idx=inner_chin_idx+1) begin
                                // send weight 
                                if (inner_chin_idx<CHin)begin
                                    // OUT_CHANNEL*IN_CHANNEL*9*`BITWIDTH
                                    weight[ ( ((OUT_CHANNEL-1)- inner_chout_idx)*IN_CHANNEL + ((IN_CHANNEL-1)-inner_chin_idx) )*9*`BITWIDTH +: 9*`BITWIDTH ] = wgt_mem[ layer_idx_in*MAX_CHANNEL + (chout_idx+inner_chout_idx) ] [ ( (CHin-1) - (chin_idx + inner_chin_idx) )*9*`BITWIDTH +: 9*`BITWIDTH ]; 
                                end else begin // special case for first layer
                                    weight[ ( ((OUT_CHANNEL-1)- inner_chout_idx)*IN_CHANNEL + ((IN_CHANNEL-1)-inner_chin_idx) )*9*`BITWIDTH +: 9*`BITWIDTH ] = 0;
                                end
                                {kx0, kx1, kx2, kx3, kx4, kx5, kx6, kx7, kx8} = weight[ ( ((OUT_CHANNEL-1)- inner_chout_idx)*IN_CHANNEL + ((IN_CHANNEL-1)-inner_chin_idx) )*9*`BITWIDTH +: 9*`BITWIDTH ];
                                // $display("Cout = %d, Cin = %d, kernel = %d, %d, %d, %d, %d, %d, %d, %d, %d", (chout_idx+inner_chout_idx), (chin_idx + inner_chin_idx), kx0, kx1, kx2, kx3, kx4, kx5, kx6, kx7, kx8);
                                // $display("(hex) kernel = %h, %h, %h, %h, %h, %h, %h, %h, %h", kx0, kx1, kx2, kx3, kx4, kx5, kx6, kx7, kx8);
                                // send bias
                                // OUT_CHANNEL*`BITWIDTH
                                bias[ ( (OUT_CHANNEL-1)- inner_chout_idx)*`BITWIDTH +: `BITWIDTH ] = bias_mem[ layer_idx_in*MAX_CHANNEL + (chout_idx+inner_chout_idx) ]; 
                                // send activation
                                px0 = virtual_input_block[ (chin_idx+inner_chin_idx)*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + (y_idx+0)*(`BLK_WIDTH+2) + (x_idx+0) ]; px1 = virtual_input_block[ (chin_idx+inner_chin_idx)*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + (y_idx+0)*(`BLK_WIDTH+2) + (x_idx+1) ]; px2 = virtual_input_block[ (chin_idx+inner_chin_idx)*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + (y_idx+0)*(`BLK_WIDTH+2) + (x_idx+2) ];
                                px3 = virtual_input_block[ (chin_idx+inner_chin_idx)*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + (y_idx+1)*(`BLK_WIDTH+2) + (x_idx+0) ]; px4 = virtual_input_block[ (chin_idx+inner_chin_idx)*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + (y_idx+1)*(`BLK_WIDTH+2) + (x_idx+1) ]; px5 = virtual_input_block[ (chin_idx+inner_chin_idx)*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + (y_idx+1)*(`BLK_WIDTH+2) + (x_idx+2) ];
                                px6 = virtual_input_block[ (chin_idx+inner_chin_idx)*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + (y_idx+2)*(`BLK_WIDTH+2) + (x_idx+0) ]; px7 = virtual_input_block[ (chin_idx+inner_chin_idx)*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + (y_idx+2)*(`BLK_WIDTH+2) + (x_idx+1) ]; px8 = virtual_input_block[ (chin_idx+inner_chin_idx)*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + (y_idx+2)*(`BLK_WIDTH+2) + (x_idx+2) ];
                                if (inner_chin_idx<CHin)begin
                                    in_activation[((IN_CHANNEL-1)-inner_chin_idx)*9*`BITWIDTH +: 9*`BITWIDTH] = {px0, px1, px2, px3, px4, px5, px6, px7, px8}; // IN_CHANNEL*9*`BITWIDTH
                                end else begin
                                    in_activation[((IN_CHANNEL-1)-inner_chin_idx)*9*`BITWIDTH +: 9*`BITWIDTH] = 0;
                                end
                                // if( (chin_idx+inner_chin_idx)==0 && (chout_idx+inner_chout_idx)==0 && layer_idx_in==0 &&  ( x_idx< 4 || x_idx> (blkW_out-3) )  && y_idx > (blkH_out-5) ) begin
                                //     $display("Cout = %d, Cin = %d, Y_out = %d, X_out = %d,  pixel = %d, %d, %d, %d, %d, %d, %d, %d, %d", (chout_idx+inner_chout_idx), (chin_idx+inner_chin_idx),  y_idx, x_idx, px0, px1, px2, px3, px4, px5, px6, px7, px8);
                                //     $display("(hex) pixel = %h, %h, %h, %h, %h, %h, %h, %h, %h", px0, px1, px2, px3, px4, px5, px6, px7, px8);
                                // end
                            end
                        end
                        // $display("Y: [%d], X: [%d], Chout: [%d], Chin: [%d], bias = %h, weight: %h, in_act: %h", y_idx, x_idx, chout_idx, chin_idx, bias, weight, in_activation);
                
                    end
                end
            end
        end
        @(negedge clk); conv_din_enable = 0;
        // wait pipeline finished
        #(`CYCLE*POST_LATENCY);
        // Phase-3: prepare reuse buffer for next block inference 
        if (`INF_MODE == 0) begin // forget directly
            for (chin_idx=0; chin_idx<BASE_CHANNEL; chin_idx=chin_idx+1) begin
                // copy data to row-direction along-stripe reuse buffer
                for (y_idx=blkH_out; y_idx<(blkH_out+2); y_idx=y_idx+1) begin
                    for (x_idx=0; x_idx<(blkW_out+2); x_idx=x_idx+1) begin
                        // if (layer_idx_in==0 && chin_idx==0) begin
                        //     $display("y = %d, x = %d, value = %d", y_idx, x_idx, $signed(virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ]) );
                        // end
                        internal_reuse_mem_y [ layer_idx_in*BASE_CHANNEL*`BLK_WIDTH*2 + chin_idx*`BLK_WIDTH*2 + (y_idx-blkH_out)*`BLK_WIDTH + x_idx ] = virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ] ;
                    end
                end
            end
        end else begin
            y_boundary = blkH_out;
            if (pixel_y_idx_in+`BLK_HEIGHT > `IMG_HEIGHT) begin
                y_boundary = blkH_out + 2;
                // $display("padding!");
            end
            // if (layer_idx_in==0)begin
            //     $display("==================== Store Y from %d to %d", cur_y_bias, cur_y_bias+y_boundary-1);
            // end
            for (chin_idx=0; chin_idx<BASE_CHANNEL; chin_idx=chin_idx+1) begin
                // copy data to row-direction along-stripe reuse buffer
                for (y_idx=blkH_out; y_idx<(blkH_out+2); y_idx=y_idx+1) begin
                    for (x_idx=2; x_idx<(blkW_out+2); x_idx=x_idx+1) begin
                        internal_reuse_mem_y [ layer_idx_in*BASE_CHANNEL*`BLK_WIDTH*2 + chin_idx*`BLK_WIDTH*2 + (y_idx-blkH_out)*`BLK_WIDTH + (x_idx-2) ] = virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ] ;
                    end
                end
                //  copy data to column-direction across-stripe reuse buffer 
                for (y_idx=0; y_idx<(y_boundary); y_idx=y_idx+1) begin
                    for (x_idx=blkW_out; x_idx<(blkW_out+2); x_idx=x_idx+1) begin
                        if ( (cur_y_bias + y_idx) >= 0 ) begin
                            case(1)
                                (`INF_MODE == 1): internal_reuse_mem_x[ layer_idx_in*BASE_CHANNEL*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 + chin_idx*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 +  (cur_y_bias + y_idx)*2 + (x_idx-blkW_out) ] = virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ]; //internally
                                (`INF_MODE == 2): external_reuse_mem_x[ layer_idx_in*BASE_CHANNEL*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 + chin_idx*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 +  (cur_y_bias + y_idx)*2 + (x_idx-blkW_out) ] = virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ]; //externally
                            endcase
                            // if(chin_idx==0 && layer_idx_in==0)begin
                            //     $display("store address for layer:[%d], ch:[%d], y:[%d], x:[%d] = %d, value = %h (%d)", layer_idx_in, chin_idx, y_idx, x_idx, layer_idx_in*BASE_CHANNEL*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 + chin_idx*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 +  (cur_y_bias + y_idx)*2 + (x_idx-blkW_out), virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ], $signed(virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ]) );
                            // end
                            // if ( layer_idx_in*BASE_CHANNEL*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 + chin_idx*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 +  (cur_y_bias + y_idx)*2 + (x_idx-blkW_out) >= 348 && layer_idx_in*BASE_CHANNEL*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 + chin_idx*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 +  (cur_y_bias + y_idx)*2 + (x_idx-blkW_out) <= 351) begin
                            //     $display("layer:[%d], ch:[%d], y:[%d], x:[%d] = %d, value = %h (%d)", layer_idx_in, chin_idx, y_idx, x_idx, layer_idx_in*BASE_CHANNEL*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 + chin_idx*(`IMG_HEIGHT+(`TOTAL_LAYER*2))*2 +  (cur_y_bias + y_idx)*2 + (x_idx-blkW_out), virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ], $signed(virtual_input_block [ chin_idx*(`BLK_HEIGHT+2)*(`BLK_WIDTH+2) + y_idx*(`BLK_WIDTH+2) + x_idx ]) );
                            // end
                        end
                    end
                end
            end
        end

    end
endtask



task per_layer_output_block_preparation;
    integer chout_idx, x_idx, y_idx;
    integer inner_chout_idx;
    begin
        for (chout_idx=0; chout_idx<CHout; chout_idx=chout_idx+OUT_CHANNEL) begin
            for (y_idx=0; y_idx<blkH_out; y_idx=y_idx+1) begin
                for (x_idx=0; x_idx<blkW_out; x_idx=x_idx+1) begin
                    wait(conv_dout_valid);
                    @(negedge clk); // inner loops perform data concatenation for one cycle 
                    for (inner_chout_idx=0; inner_chout_idx<OUT_CHANNEL; inner_chout_idx=inner_chout_idx+1) begin
                        // if (layer_idx_out==7) begin
                        //     $display("[Ch_out = %d, Y_out = %d, X_out = %d], Act_out = %h", (chout_idx+inner_chout_idx), y_idx, x_idx, out_acivation[ inner_chout_idx*`BITWIDTH +: `BITWIDTH]);
                        // end
                        case(1)
                            (dstSRAM == 0): internal_block_mem_0 [ (chout_idx+inner_chout_idx)*`BLK_HEIGHT*`BLK_WIDTH + y_idx*`BLK_WIDTH + x_idx ] = out_acivation[ ( (OUT_CHANNEL-1) - inner_chout_idx)*`BITWIDTH +: `BITWIDTH];
                            (dstSRAM == 1): internal_block_mem_1 [ (chout_idx+inner_chout_idx)*`BLK_HEIGHT*`BLK_WIDTH + y_idx*`BLK_WIDTH + x_idx ] = out_acivation[ ( (OUT_CHANNEL-1) - inner_chout_idx)*`BITWIDTH +: `BITWIDTH];
                            (dstSRAM == 2): internal_block_mem_2 [ (chout_idx+inner_chout_idx)*`BLK_HEIGHT*`BLK_WIDTH + y_idx*`BLK_WIDTH + x_idx ] = out_acivation[ ( (OUT_CHANNEL-1) - inner_chout_idx)*`BITWIDTH +: `BITWIDTH];
                            (dstSRAM == 3): virtual_block_output [ (chout_idx+inner_chout_idx)*`BLK_HEIGHT*`BLK_WIDTH + y_idx*`BLK_WIDTH + x_idx ] = out_acivation[ ( (OUT_CHANNEL-1) - inner_chout_idx)*`BITWIDTH +: `BITWIDTH]; // special case handle for last layer
                        endcase
                    end
                end
            end
        end
    end
endtask

task block_out_per_layer_result_check;
    integer chout_idx, x_idx, y_idx;
    reg signed [`BITWIDTH-1:0] computed_pixel;
    reg signed [`BITWIDTH-1:0] golden_pixel;
    begin
       if (`INF_MODE == 0) begin 
            // forget directly
            pixel_x_idx_out = (block_x_idx_out+1)* BLK_O_WIDTH + (`TOTAL_LAYER-(layer_idx_out+1))*2 - blkW_out;
            pixel_y_idx_out = block_y_idx_out*BLK_O_HEIGHT - (layer_idx_out+1)*2; // pixel shift bias 
        end else begin 
            // reuse externally/internally
            pixel_x_idx_out = block_x_idx_out* BLK_O_WIDTH - (layer_idx_out+1)*2; // pixel shift bias
            pixel_y_idx_out = block_y_idx_out*BLK_O_HEIGHT - (layer_idx_out+1)*2; // pixel shift bias
        end 
        // $display("(Frame pixel bias) Y = %d, X = %d", pixel_y_idx_out, pixel_x_idx_out);
        // $display(" boundary Y: %d", (`IMG_HEIGHT+((`TOTAL_LAYER-1)-layer_idx_in)*2));
        for (chout_idx=0; chout_idx<CHout; chout_idx=chout_idx+1) begin
            for (y_idx=0; y_idx<blkH_out; y_idx=y_idx+1) begin
                for (x_idx=0; x_idx<blkW_out; x_idx=x_idx+1) begin
                    case(1)
                        (dstSRAM == 0): computed_pixel = internal_block_mem_0 [  chout_idx *`BLK_HEIGHT*`BLK_WIDTH + y_idx*`BLK_WIDTH + x_idx ] ;
                        (dstSRAM == 1): computed_pixel = internal_block_mem_1 [  chout_idx *`BLK_HEIGHT*`BLK_WIDTH + y_idx*`BLK_WIDTH + x_idx ] ;
                        (dstSRAM == 2): computed_pixel = internal_block_mem_2 [  chout_idx *`BLK_HEIGHT*`BLK_WIDTH + y_idx*`BLK_WIDTH + x_idx ] ;
                    endcase

                    golden_pixel = inter_feature_mem[ layer_idx_out*INTER_FEATURE_MEM_SIZE + chout_idx*(`IMG_HEIGHT+((`TOTAL_LAYER-1)-layer_idx_in)*2)*(`IMG_WIDTH+((`TOTAL_LAYER-1)-layer_idx_in)*2) 
                                    + (pixel_y_idx_out + y_idx)*(`IMG_WIDTH+((`TOTAL_LAYER-1)-layer_idx_in)*2)  + (pixel_x_idx_out + x_idx) ];
                    // $display("Block pos: (C=%d, Y=%d, X=%d), computed val = %h, computed val = %d", chout_idx, y_idx, x_idx, computed_pixel, computed_pixel);
                    // $display("--> Frame pos: (C=%d, Y=%d, X=%d), expected val = %h", chout_idx, pixel_y_idx_out+y_idx, pixel_x_idx_out+x_idx, golden_pixel);
                    if (pixel_y_idx_out+y_idx >= 0 && pixel_x_idx_out+x_idx >= 0) begin
                        if (computed_pixel!==golden_pixel)begin
                            $display("Error!! (block level) channel=%d, h=%d, w=%d. ", chout_idx, y_idx, x_idx );
                            $display("(frame level) h=%d, w=%d", pixel_y_idx_out+y_idx, pixel_x_idx_out + x_idx);
                            $display("Expect: %h, computed: %h", golden_pixel, computed_pixel);
                            $display("Expect: %d, computed: %d", golden_pixel, computed_pixel);
                            $finish;
                        end
                        // end else begin
                        //     if( x_idx==(blkW_out-1) && chout_idx==0 ) begin
                        //         $display("Pass stripe x_range=[%d to %d] (y=[%d])", pixel_x_idx_out, pixel_x_idx_out+x_idx, y_idx);
                        //     end
                        // end
                        // end else begin
                        //     $display("Pass @ (block level) channel=%d, h=%d, w=%d.",chout_idx, y_idx, x_idx );
                        //     // $display("(frame level) h=%d, w=%d", pixel_y_idx_out+y_idx, pixel_x_idx_out + x_idx);
                        // end 
                    end
                    // end else begin
                    //         if( x_idx==(blkW_out-1) && chout_idx==0 ) begin
                    //             $display("--> Skip stripe x_range=[%d to %d] (y=[%d])", pixel_x_idx_out, pixel_x_idx_out+x_idx, y_idx);
                    //         end
                    // end
                end
            end
        end
        $display("Pass intermediate layer [%d]!", layer_idx_out);
    end
endtask


task block_out_per_model_result_check;
    integer chout_idx, x_idx, y_idx;
    reg [`BITWIDTH-1:0] computed_pixel;
    reg [`BITWIDTH-1:0] golden_pixel;
    begin
        // do pixel shuffle and send to external memory!
        // decode pixel position
        if (`INF_MODE == 0) begin 
            // forget directly
            pixel_x_idx_out = block_x_idx_out* BLK_O_WIDTH*4;
            pixel_y_idx_out = block_y_idx_out*BLK_O_HEIGHT*4 - `TOTAL_LAYER*2*4;
        end else begin 
            // reuse externally/internally
            pixel_x_idx_out = block_x_idx_out* BLK_O_WIDTH*4 - `TOTAL_LAYER*2*4;
            pixel_y_idx_out = block_y_idx_out*BLK_O_HEIGHT*4 - `TOTAL_LAYER*2*4;
        end
        // $display("(Frame pixel bias Out) Y_HR = %d, X_HR = %d", pixel_y_idx_out, pixel_x_idx_out);
        // $display("(Frame pixel bias Out) Y_LR = %d, X_LR = %d", pixel_y_idx_out/4, pixel_x_idx_out/4);
        // pixel shuffle 
        // $display("Do Pixel Shuffle.");
        for (chout_idx=0; chout_idx<3; chout_idx=chout_idx+1) begin
            for (y_idx=0; y_idx<blkH_out*4; y_idx=y_idx+1) begin
                for (x_idx=0; x_idx<blkW_out*4; x_idx=x_idx+1) begin
                    external_img_output_mem [ chout_idx*IMG_O_HEIGHT*IMG_O_WIDTH + (pixel_y_idx_out+y_idx)*IMG_O_WIDTH + (pixel_x_idx_out+x_idx) ] 
                        = virtual_block_output [ ( chout_idx*16 + (y_idx%4)*4 + (x_idx%4) )*`BLK_HEIGHT*`BLK_WIDTH + (y_idx/4)*`BLK_WIDTH + (x_idx/4) ];
                    `ifdef CHECK_RESULT_MODEL
                        computed_pixel = external_img_output_mem [ chout_idx*IMG_O_HEIGHT*IMG_O_WIDTH + (pixel_y_idx_out+y_idx)*IMG_O_WIDTH + (pixel_x_idx_out+x_idx) ];
                        golden_pixel = golden_img_output_mem [ chout_idx*IMG_O_HEIGHT*IMG_O_WIDTH + (pixel_y_idx_out+y_idx)*IMG_O_WIDTH + (pixel_x_idx_out+x_idx) ];
                        if (pixel_y_idx_out+y_idx >= 0 && pixel_x_idx_out+x_idx >= 0) begin
                            if (computed_pixel!==golden_pixel)begin
                                $display("Error!! channel=%d, h=%d, w=%d.", ( chout_idx*16 + (y_idx%4)*4 + (x_idx%4) ), (y_idx/4), (x_idx/4) );
                                $display("Expect: %h, computed: %h", golden_pixel, computed_pixel);
                                $display("HR img: ch = %d, y = %d, x = %d", chout_idx, y_idx, x_idx);
                                $display("HR img: ch = %d, y = %d, x = %d", chout_idx, pixel_y_idx_out+y_idx, pixel_x_idx_out+x_idx);
                                $finish;
                            end 
                        end
                    `endif
                end
            end
        end
        $display("Pass model for block Y: [%d], X: [%d]", block_y_idx_out, block_x_idx_out);
        $display("============================================================>");
    end
endtask


task write_image;
    integer out_file;
    integer img_ch_idx, img_h_idx, img_w_idx;
    reg signed [`BITWIDTH-1:0] act_out;
    reg signed [`BITWIDTH:0] q_value;
    reg [8-1:0] px_out;
    reg signed [BW_FL-1:0] fl_out;
    reg signed [`BITWIDTH:0] val_0p5;
    reg signed [`BITWIDTH:0] upper_bound;
    begin
        $display("write image\n");
        out_file = $fopen("./result/img_out.dat");
        for(img_ch_idx=0;img_ch_idx<3;img_ch_idx=img_ch_idx+1)begin
            for(img_h_idx=0;img_h_idx<IMG_O_HEIGHT;img_h_idx=img_h_idx+1)begin
                for(img_w_idx=0;img_w_idx<IMG_O_WIDTH;img_w_idx=img_w_idx+1)begin
                    px_out = external_img_output_mem [ img_ch_idx*IMG_O_HEIGHT*IMG_O_WIDTH + img_h_idx*IMG_O_WIDTH + img_w_idx ];
                    px_out = px_out ^ 8'b1000_0000;
                    if(img_w_idx==0)
                        $fwrite(out_file,"%h",px_out);
                    else 
                        $fwrite(out_file,"_%h",px_out);
                end
                $fwrite(out_file,"\n");
            end
        end
        $fclose(out_file);
    end
endtask