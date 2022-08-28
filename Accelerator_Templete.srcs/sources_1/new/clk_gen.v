
//------------------------------------------------------------+
// Project: Spatial Accelerator
// Module:  clk_gen
// Description:
//		It generates the long clk for overall top module.
//		only psum_su_irrel_new module use original clk.
//      
//		
//
// History: 2022.08.25 by Min-Gyu Park (alsrbok@snu.ac.kr)
//------------------------------------------------------------+
`timescale 1ns / 1ps

module clk_gen #(   parameter CLK_REG_WIDTH = 6,     // Width of the register required
                    parameter CLK_N         = 34)    // We will divide by 34 for example in this case
              ( input clk, reset, 
                output clk_out);
    
    reg [CLK_REG_WIDTH-1:0] r_reg;
    wire [CLK_REG_WIDTH-1:0] r_nxt;
    reg clk_track;
    
    always @(posedge clk or posedge reset)
    
    begin
    if (reset) begin
        r_reg <= 0;
        clk_track <= 1'b0;
    end
    
    else if (r_nxt == CLK_N) begin
        r_reg <= 0;
        clk_track <= ~clk_track;
    end
    
    else 
        r_reg <= r_nxt;
    end
    
    assign r_nxt = r_reg+1;   	      
    assign clk_out = clk_track;
endmodule