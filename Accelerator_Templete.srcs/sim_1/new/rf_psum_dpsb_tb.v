`timescale 1ns / 1ps

module rf_psum_dpsb_tb();

    parameter DATA_BITWIDTH = 16;
    parameter ADDR_BITWIDTH  = 5;
    parameter DEPTH  = 32;

    reg clk;
    reg reset;
    reg read_req;
    reg write_en;
    reg [ADDR_BITWIDTH-1 : 0] r_addr;
    reg [ADDR_BITWIDTH-1 : 0] w_addr;
    reg [DATA_BITWIDTH-1 : 0] w_data;
    wire [DATA_BITWIDTH-1 : 0] r_data;

    integer i=0;
    integer j=0;

    rf_psum_dpsb #(.DATA_BITWIDTH(DATA_BITWIDTH), .ADDR_BITWIDTH(ADDR_BITWIDTH), .DEPTH(DEPTH)) rf_psum_dpsb(.clk(clk), .reset(reset),
	.read_req(read_req), .write_en(write_en), .r_addr(r_addr), .w_addr(w_addr), .w_data(w_data), .r_data(r_data));

    always
        #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 0;

        //case 1 : all temporal mapping is consist of relevant loop type
        #5 reset = 1;

        for(i=0; i <= DEPTH; i=i+1) begin
            if(i==0) begin #10 reset = 0; read_req = 1; r_addr = 2'b00000; end
            else if(i==1) begin #10 write_en = 1; w_addr = 2'b00000; w_data = i; r_addr = r_addr+1;end
            else if(i<DEPTH)begin #10 w_addr = w_addr+1; w_data = i; r_addr = r_addr+1;end
            else begin #10 w_addr = w_addr+1; w_data = i;end
        end

        //check for the write result on ram
        for(i=0; i<DEPTH; i=i+1) begin
            if(i==0) begin #10 r_addr = 2'b00000; $display("%0t ns : reg file_data = %d ", $time, r_data); end
            else begin #10 r_addr = r_addr+1; $display("%0t ns : reg file_data = %d ", $time, r_data); end 
        end

        //check for reset of rf_psum
        #10 reset = 1;
        #10 reset = 0;
        //case2 : 28 relevant loop type | 4 irrelevant loop type on the bottom
        for(j=0; j<4; j=j+1) begin
            for(i=0; i <= 28; i=i+1) begin
                if(i==0) begin #10 read_req = 1; r_addr = 2'b00000; end
                else if(i==1) begin #10 r_addr = r_addr+1; write_en = 1; w_addr = 2'b00000; w_data = i+r_data;end
                else if(i<28)begin #10 r_addr = r_addr+1; w_addr = w_addr+1; w_data = i+r_data;end
                else begin #10 w_addr = w_addr+1; w_data = i+r_data;end
            end
        end
        $stop;
    end

endmodule
