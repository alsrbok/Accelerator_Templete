`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/06 16:12:07
// Design Name: 
// Module Name: rf_psum_dpdb
// Project Name: 
// Target Devices: Dual Port, Doudble Buffer Asynchronous register file for psum (In zigzag, Memory Bandwidth should be match with Data Bitwidth on register file)
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rf_psum_dpdb #( parameter DATA_BITWIDTH = 16,
			 parameter ADDR_BITWIDTH = 5,
             parameter DEPTH = 32 ) //default register size is 16*32=512bits
		   ( input clk,
			 input reset1,
             input reset2,
			 input read_req1,
             input read_req2,
			 input write_en1,
             input write_en2,
			 input [ADDR_BITWIDTH-1 : 0] r_addr1,
			 input [ADDR_BITWIDTH-1 : 0] w_addr1,
			 input [DATA_BITWIDTH-1 : 0] w_data1,
             input [ADDR_BITWIDTH-1 : 0] r_addr2,
			 input [ADDR_BITWIDTH-1 : 0] w_addr2,
			 input [DATA_BITWIDTH-1 : 0] w_data2,
			 output  [DATA_BITWIDTH-1 : 0] r_data1,
             output  [DATA_BITWIDTH-1 : 0] r_data2
    );
	
	reg [DATA_BITWIDTH-1 : 0] mem1 [0 : DEPTH - 1]; // default - 512-bit memory.
    reg [DATA_BITWIDTH-1 : 0] mem2 [0 : DEPTH - 1]; // default - 512-bit memory.
	reg [DATA_BITWIDTH-1 : 0] data1;
    reg [DATA_BITWIDTH-1 : 0] data2;

    integer i;

	always@(posedge clk)
		begin : READ1
			if(reset1)
				data1 = 0;
			else begin
				if(read_req1) begin
					data1 = mem1[r_addr1];
//					$display("Read Address to SPad:%d",r_addr);
				end 
                //else begin
				//	data = 10101; //Random default value to verify model
				//end
			end
		end
	
	assign r_data1 = data1;

	always@(posedge clk)
		begin : WRITE1
			if(reset1) begin
				for (i=0; i<=DEPTH; i=i+1)
					mem1[i] = 0;
			end
			else begin
				if(write_en1) begin
					mem1[w_addr1] = w_data1;
				end
			end
		end
    
    always@(posedge clk)
		begin : READ2
			if(reset2)
				data2 = 0;
			else begin
				if(read_req2) begin
					data2 = mem2[r_addr2];
//					$display("Read Address to SPad:%d",r_addr);
				end 
                //else begin
				//	data = 10101; //Random default value to verify model
				//end
			end
		end
	
	assign r_data2 = data2;


	always@(posedge clk)
		begin : WRITE2
			if(reset2) begin
				for (i=0; i<=DEPTH; i=i+1)
					mem2[i] = 0;
			end
			else begin
				if(write_en2) begin
					mem2[w_addr2] = w_data2;
				end
			end
		end

endmodule
