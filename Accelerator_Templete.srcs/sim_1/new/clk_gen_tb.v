`timescale 1ns / 1ps

module clk_gen_tb;
    reg clk,reset;
    wire clk_out;
 
    clk_gen t1(clk,reset,clk_out);

    initial
        clk= 1'b0;
    always
        #5  clk=~clk; 

    initial begin
        #5 reset=1'b1;
        #10 reset=1'b0;
        #5000 $finish;
    end
 
    initial
        $monitor("clk=%b,reset=%b,clk_out=%b",clk,reset,clk_out);
 

endmodule