`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/05 13:39:16
// Design Name: 
// Module Name: MAC
// Project Name: 
// Target Devices: 
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


module MAC #( parameter IN_BITWIDTH = 16,
			  parameter OUT_BITWIDTH = 16 )
			( input [IN_BITWIDTH-1 : 0] a_in,
			  input [IN_BITWIDTH-1 : 0] w_in,
			  input [IN_BITWIDTH-1 : 0] sum_in,
			  input en, clk,						//en : control logic give signal to calculate
			  output reg [OUT_BITWIDTH-1 : 0] out,
			  output reg out_en						//out_en : MAC make signal of output enable (It makes rf_psum to write output value to its memory)
			);
	
	reg [OUT_BITWIDTH-1:0] mult_out;
	
	always@(posedge clk) begin
		if(en) begin
			mult_out = a_in * w_in;
			out = mult_out + sum_in;
			out_en = 1'b1;
			$display("%0t ns : a_in / w_in / sum_in / out = %d / %d / %d / %d ", $time, a_in, w_in, sum_in, out);
		end
		else begin out = 0; out_en = 1'b0; end
	end
	
endmodule