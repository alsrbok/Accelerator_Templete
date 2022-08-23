`timescale 1ns / 1ps

module PE_tb();

    parameter IN_BITWIDTH = 16;    
    parameter OUT_BITWIDTH = 16;        
    parameter ACTV_ADDR_BITWIDTH = 5;   
    parameter ACTV_DEPTH = 32;         
    parameter WGT_ADDR_BITWIDTH = 5;
    parameter WGT_DEPTH = 32;
    parameter PSUM_ADDR_BITWIDTH = 5;
    parameter PSUM_DEPTH = 32;

    reg clk;
    reg reset; reg en;
    reg actv_en; reg [ACTV_ADDR_BITWIDTH-1:0] actv_addr1, actv_addr2; reg [IN_BITWIDTH-1:0] actv_data1, actv_data2;
    reg wgt_en; reg [WGT_ADDR_BITWIDTH-1:0] wgt_addr1, wgt_addr2; reg [IN_BITWIDTH-1:0] wgt_data1,wgt_data2;
    reg psum_en; reg [PSUM_ADDR_BITWIDTH-1:0] psum_addr1, psum_addr2;
    wire [OUT_BITWIDTH-1:0] psum_out1, psum_out2;

    PE #(.IN_BITWIDTH(IN_BITWIDTH), .OUT_BITWIDTH(OUT_BITWIDTH), .ACTV_ADDR_BITWIDTH(ACTV_ADDR_BITWIDTH), .ACTV_DEPTH(ACTV_DEPTH),
     .WGT_ADDR_BITWIDTH(WGT_ADDR_BITWIDTH), .WGT_DEPTH(WGT_DEPTH), .PSUM_ADDR_BITWIDTH(PSUM_ADDR_BITWIDTH), .PSUM_DEPTH(PSUM_DEPTH)) pe(
     .clk(clk), .reset(reset), .en(en), .actv_en(actv_en), .actv_addr1(actv_addr1), .actv_addr2(actv_addr2), .actv_data1(actv_data1), 
     .actv_data2(actv_data2), .wgt_en(wgt_en), .wgt_addr1(wgt_addr1), .wgt_addr2(wgt_addr2), .wgt_data1(wgt_data1), .wgt_data2(wgt_data2),
     .psum_en(psum_en), .psum_addr1(psum_addr1), .psum_addr2(psum_addr2), .psum_out1(psum_out1), .psum_out2(psum_out2)
     );

    integer i=0;

    always
        #5 clk = ~clk;
    
    initial begin
        clk = 0;
        reset = 1;

        #10 reset = 0;
        // 1) fill buffer1 of actv, wgt
        for(i=0; i<32; i=i+1)begin
            if(i==0) begin #10 en=0; actv_en=1; wgt_en=1; actv_addr1=0; wgt_addr1=0; actv_data1=1; wgt_data1=1; end
            else begin #10 actv_addr1=actv_addr1+1; wgt_addr1=wgt_addr1+1; wgt_data1=wgt_data1+1; end
        end

        // 2) use MAC with buffer1 of actv, wgt, psum && fill buffer2 of actv, wgt
        for(i=0; i<34; i=i+1)begin
            if(i==0) begin #10 en=1; actv_en=0; wgt_en=0; psum_en=1; actv_addr1=0; wgt_addr1=0; psum_addr1=0; actv_addr2=0; wgt_addr2=0; actv_data2=1; wgt_data2=1; end
            else if(i<=4) begin #10 actv_addr1=actv_addr1+1; wgt_addr1=wgt_addr1+1; psum_addr1=psum_addr1+1; 
                actv_addr2=actv_addr2+1; wgt_addr2=wgt_addr2+1; actv_data2=actv_data2+1; wgt_data2=wgt_data2+1; end
            else if(i<=15) begin #10 actv_addr1=actv_addr1+1; wgt_addr1=wgt_addr1+1; psum_addr1=psum_addr1+1; actv_addr2=actv_addr2+1; actv_data2=actv_data2+1; end
            else if(i==16) begin #10 /*en=0;*/psum_addr1=psum_addr1+1; actv_addr2=actv_addr2+1; actv_data2=actv_data2+1; end
            else if(i==17) begin #10 /*en=1;*/actv_addr1=actv_addr1+1; wgt_addr1=wgt_addr1+1; psum_addr1=0; actv_addr2=actv_addr2+1; actv_data2=actv_data2+1; end
            else if(i<=19) begin #10 actv_addr1=actv_addr1+1; wgt_addr1=wgt_addr1+1; psum_addr1=psum_addr1+1; actv_addr2=actv_addr2+1; actv_data2=actv_data2+1; end
            else begin #10 actv_addr1=actv_addr1+1; wgt_addr1=wgt_addr1+1; psum_addr1=psum_addr1+1; end
        end

        // 3) use MAC with buffer2 of actv, wgt, psum && fill buffer1 of actv,wgt and send data to upper hierarchy(psum_out1) from rf_psum buffer1
        for(i=0; i<24; i=i+1) begin
            if(i==0) begin #10 actv_en=1; wgt_en=1; psum_en=0; actv_addr1=0; wgt_addr1=0; psum_addr1=0; actv_data1=1; wgt_data1=2; actv_addr2=0; wgt_addr2=0; psum_addr2=0; end
            else if(i<=5) begin #10 actv_addr1=actv_addr1+1; wgt_addr1=wgt_addr1+1; psum_addr1=psum_addr1+1; actv_data1=actv_data1+1;
                actv_addr2=actv_addr2+1; wgt_addr2=wgt_addr2+1; psum_addr2=psum_addr2+1; end
            else if(i==6) begin #10 actv_addr1=actv_addr1+1; wgt_addr1=wgt_addr1+1; psum_addr1=psum_addr1+1; actv_data1=actv_data1+1;
                wgt_addr2=0; psum_addr2=0; end
            else if(i==7) begin #10 actv_addr1=actv_addr1+1; wgt_addr1=wgt_addr1+1; psum_addr1=psum_addr1+1; actv_data1=actv_data1+1;
                actv_addr2=actv_addr2+1; wgt_addr2=wgt_addr2+1; psum_addr2=psum_addr2+1;end
            else if(i<=11) begin #10 wgt_addr1=wgt_addr1+1; psum_addr1=psum_addr1+1; actv_addr2=actv_addr2+1; wgt_addr2=wgt_addr2+1; psum_addr2=psum_addr2+1; end
            else if(i==12) begin #10 wgt_addr1=wgt_addr1+1; psum_addr1=psum_addr1+1; wgt_addr2=0; psum_addr2=0; end
            else if(i<=15) begin #10 wgt_addr1=wgt_addr1+1; psum_addr1=psum_addr1+1; actv_addr2=actv_addr2+1; wgt_addr2=wgt_addr2+1; psum_addr2=psum_addr2+1; end
            else if(i<=17) begin #10 actv_addr2=actv_addr2+1; wgt_addr2=wgt_addr2+1; psum_addr2=psum_addr2+1; end
            else if(i==18) begin #10 wgt_addr2=0; psum_addr2=0; end
            else begin #10 actv_addr2=actv_addr2+1; wgt_addr2=wgt_addr2+1; psum_addr2=psum_addr2+1; end

        end

        //reset
        #10 reset = 1;
        #50 reset = 0;

        $stop;
    end

endmodule
