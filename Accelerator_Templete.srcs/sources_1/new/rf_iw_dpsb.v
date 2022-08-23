`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/06 13:40:31
// Design Name: 
// Module Name: rf_iw_dpsb
// Project Name: 
// Target Devices: Dual Port, Single Buffer Asynchronous register file for input and weight
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

module rf_iw_dpsb #( parameter DATA_BITWIDTH = 16,
			 parameter ADDR_BITWIDTH = 5,
             parameter DEPTH = 32 ) //default register size is 16*32=512bits
		   ( input clk,
			 input reset,
			 input read_req, //control logic of rf generate request signal with proper r_addr
			 input write_en, // I,W : control logic of global buffer (upper hierarchy mem) generate write_en signal with w_addr & w_data (transfer data from hierarcy i+1 -> i)
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
			if(write_en && !reset) begin
				mem[w_addr] = w_data;
			end
		end

endmodule