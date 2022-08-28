
//------------------------------------------------------------+
// Project: Spatial Accelerator
// Module: simple_dp_ram
// Description:
//		Simple Dual-port RAM(with ena, enb pin) wrapper (N_DELAY = 1. Bandwidth = 512bits/cycle)
//		FPGA = 1: Use the generated RAM 
//		Otherwise: Use a RAM modeling
//
// History: 2022.08.19 by Min-Gyu Park (alsrbok@snu.ac.kr)
//------------------------------------------------------------+

`timescale 1ns / 1ps

//`define FPGA 0
module simple_dp_ram #(parameter DATA_BITWIDTH    = 512,
                parameter ADDR_BITWIDTH         = 5,
                parameter DEPTH                 = 32 )
              ( input clk, ena, enb, wea,
                input [ADDR_BITWIDTH-1 : 0] addra, addrb,
                input [DATA_BITWIDTH-1 : 0] dia, 
                output reg [DATA_BITWIDTH-1 : 0] dob
    );


    //`ifdef FPGA
    //------------------------------------------------------------------------+
	// Implement ip generate block ram
	//------------------------------------------------------------------------+
    /*
        generate
		if((DATA_BITWIDTH == 512) && (DEPTH == 32)) begin: gen_gbf_16x1024
			gbf_16x1024 u_gbf_32x512( 
				.clk(clk), .ena(ena), .enb(enb), .wea(wea),
				.addra(addra), .addrb(addrb),
				.dia(dia), .dob(dob)
			 );
		end
	    endgenerate
    */
    //`else 
    //------------------------------------------------------------------------+
	// Memory modeling
	//------------------------------------------------------------------------+
    reg [DATA_BITWIDTH-1 : 0] mem[0 : DEPTH-1];

    //write when ena is 1 (by using only port A)
    always @(posedge clk) begin
        if(ena) begin
            if(wea)
                mem[addra] <= dia;
        end
    end

    //read when enb is 1 (by using only port B)
    always @(posedge clk) begin
        if(enb) begin
            dob <= mem[addrb];
        end
    end


    //`endif




endmodule