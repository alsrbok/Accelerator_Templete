`timescale 1ns / 1ps

module rf_iw_sync_dpdb_tb();

    parameter DATA_BITWIDTH = 16;
	parameter ADDR_BITWIDTH = 5;
    parameter DEPTH = 32;

    reg clk;
	reg reset;
	reg write_en1;	
	reg [ADDR_BITWIDTH-1 : 0] addr1;
	reg [DATA_BITWIDTH-1 : 0] w_data1;
    reg [ADDR_BITWIDTH-1 : 0] addr2;
	reg [DATA_BITWIDTH-1 : 0] w_data2;
	wire [DATA_BITWIDTH-1 : 0] r_data1;
    wire [DATA_BITWIDTH-1 : 0] r_data2;

    integer i=0;
    
    rf_iw_sync_dpdb #(.DATA_BITWIDTH(DATA_BITWIDTH), .ADDR_BITWIDTH(ADDR_BITWIDTH), .DEPTH(DEPTH)) rf_iw_sync_dpdb(.clk(clk), .reset(reset), 
     .write_en1(write_en1), .addr1(addr1), .w_data1(w_data1), .addr2(addr2), .w_data2(w_data2), .r_data1(r_data1), .r_data2(r_data2));

    always
        #5 clk = ~clk;
    
    initial begin
        clk = 0;
        reset = 1;

        #10 reset = 0;
        //update buffer1
        for(i=0; i<DEPTH; i=i+1)begin
            if(i==0) begin #10 write_en1=1; addr1=0; w_data1=0; end
            else begin #10 addr1=addr1+1; w_data1=w_data1+1; end
        end

        //read from buffer1 and update buffer2
        for(i=0; i<DEPTH; i=i+1)begin
            if(i==0) begin #10 write_en1=0; addr1=0; addr2=0; w_data2=32; end
            else begin #10 addr1=addr1+1; addr2=addr2+1; w_data2=w_data2+1; end
        end

        //read from buffer2 and update buffer1
        for(i=0; i<DEPTH; i=i+1)begin
            if(i==0) begin #10 write_en1=1; addr1=0; addr2=0; w_data1=64; end
            else begin #10 addr1=addr1+1; addr2=addr2+1; w_data1=w_data1+1; end
        end

        //reset
        #10 reset = 1;
        #50 reset = 0;

        $stop;
    end


endmodule
