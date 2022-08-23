`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/05 14:29:20
// Design Name: 
// Module Name: rf_psum_dpsb
// Target Devices: Dual Port, Single Buffer Asynchronous register file for psum (In zigzag, Memory Bandwidth should be match with Data Bitwidth on register file)
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


module rf_psum_dpsb #( parameter DATA_BITWIDTH = 16,
			 parameter ADDR_BITWIDTH = 5,
             parameter DEPTH = 32 ) //default register size is 16*32=512bits
		   ( input clk,
			 input reset,
			 input read_req, //control logic of rf generate request signal with proper r_addr
			 input write_en, // O : control logic of global buffer (upper hierarchy mem) generate reset signal | control logic of rf generate write_en, w_addr to save partial psum data
			 input [ADDR_BITWIDTH-1 : 0] r_addr,
			 input [ADDR_BITWIDTH-1 : 0] w_addr,
			 input [DATA_BITWIDTH-1 : 0] w_data,
			 output  [DATA_BITWIDTH-1 : 0] r_data
    );
	
	reg [DATA_BITWIDTH-1 : 0] mem [0 : DEPTH - 1]; // default - 512-bit memory.
	reg [DATA_BITWIDTH-1 : 0] data;

	always@(posedge clk)
		begin : READ
			if(reset)
				data = 0;
			else begin
				if(read_req) begin
					data = mem[r_addr];
//					$display("Read Address to SPad:%d",r_addr);
				end 
                //else begin
				//	data = 10101; //Random default value to verify model
				//end
			end
		end
	
	assign r_data = data;
	
	integer i;

	always@(posedge clk)
		begin : WRITE
			if(reset) begin
				for (i=0; i<=DEPTH; i=i+1)
					mem[i] = 0;
			end
			else begin
				if(write_en) begin
					mem[w_addr] = w_data;
				end
			end
		end

endmodule