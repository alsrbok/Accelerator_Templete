`timescale 1ns / 1ps

module rf_psum_sync_dpdb_tb();

    parameter DATA_BITWIDTH = 16;
	parameter ADDR_BITWIDTH = 5;
    parameter DEPTH = 32;

    reg clk;
	reg reset;
	reg en1;				
	reg out_en;			
	reg [ADDR_BITWIDTH-1 : 0] addr1;
	reg [DATA_BITWIDTH-1 : 0] w_data1;
    reg [ADDR_BITWIDTH-1 : 0] addr2;
	reg [DATA_BITWIDTH-1 : 0] w_data2;
	wire [DATA_BITWIDTH-1 : 0] r_data1; 
    wire [DATA_BITWIDTH-1 : 0] r_data2;
    wire [DATA_BITWIDTH-1 : 0] out1;    
    wire [DATA_BITWIDTH-1 : 0] out2;

    integer i=0;

    rf_psum_sync_dpdb #(.DATA_BITWIDTH(DATA_BITWIDTH), .ADDR_BITWIDTH(ADDR_BITWIDTH), .DEPTH(DEPTH)) rf_psum_sync_dpdb(.clk(clk), .reset(reset), .en1(en1),
     .out_en(out_en), .addr1(addr1), .w_data1(w_data1), .addr2(addr2), .w_data2(w_data2), .r_data1(r_data1), .r_data2(r_data2), .out1(out1), .out2(out2));

    always
        #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;

        #10 reset = 0;
        //use buffer1 for MAC (buffer2 is idle)
        for(i=0; i<=DEPTH; i=i+1)begin
            if(i==0) begin #10 en1=1; out_en=0; addr1=0; w_data1=0; end
            else if(i==1) begin #10 out_en=1; addr1=addr1+1; w_data1=w_data1+1; end
            else begin #10 addr1=addr1+1; w_data1=w_data1+1; end
        end

        //use buffer2 for MAC & send data from buffer1 to upper hierarchy(out1)
        for(i=0; i<=DEPTH; i=i+1)begin
            if(i==0) begin #10 en1=0; out_en=0; addr1=0; addr2=0; w_data2=33; end
            else if(i==1) begin #10 out_en=1; addr1=addr1+1; addr2=addr2+1; w_data2=w_data2+1; end
            else begin #10 addr1=addr1+1; addr2=addr2+1; w_data2=w_data2+1; end
        end

        //use buffer1 for MAC & send data from buffer2 to upper hierarchy(out2)
        for(i=0; i<=DEPTH; i=i+1)begin
            if(i==0) begin #10 en1=1; out_en=0; addr1=0; addr2=0; w_data1=66; end
            else if(i==1) begin #10 out_en=1; addr1=addr1+1; addr2=addr2+1; w_data1=w_data1+1; end
            else begin #10 addr1=addr1+1; addr2=addr2+1; w_data1=w_data1+1; end
        end

        //reset
        #10 reset = 1;
        #50 reset = 0;

        $stop;
    end

endmodule
