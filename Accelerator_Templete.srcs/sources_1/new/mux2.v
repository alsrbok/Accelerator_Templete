`timescale 1ns / 1ps

module mux2 #( parameter WIDTH = 16)
	(
    input [WIDTH-1:0] zero,
    input [WIDTH-1:0] one,
    input sel,
    output [WIDTH-1:0] out
    );
	
	assign out = sel ? one : zero;
	
endmodule
