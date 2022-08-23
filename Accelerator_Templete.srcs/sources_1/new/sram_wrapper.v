
//------------------------------------------------------------+
// Project: Spatial Accelerator
// Module: sram_wrapper
// Description:
//		True Dual-port RAM(with ena, enb pin) wrapper (N_DELAY = 1, WRITE_FIRST. Bandwidth = 512bits/cycle)
//		FPGA = 1: Use the generated RAM 
//		Otherwise: Use a RAM modeling
//
// History: 2022.08.19 by Min-Gyu Park (alsrbok@snu.ac.kr)
//------------------------------------------------------------+

`timescale 1ns / 1ps

`define FPGA 0
module sram_wrapper #(parameter DATA_BITWIDTH = 512,
                parameter ADDR_BITWIDTH = 12,
                parameter DEPTH = 2880 )
              ( input clk, ena, enb, wea, web,
                input [ADDR_BITWIDTH-1 : 0] addra, addrb,
                input [DATA_BITWIDTH-1 : 0] dia, dib, 
                output reg [DATA_BITWIDTH-1 : 0] doa, dob
    );


    `ifdef FPGA
    //------------------------------------------------------------------------+
	// Implement ip generate block ram
	//------------------------------------------------------------------------+
        generate
		if((DATA_BITWIDTH == 2880) && (DEPTH == 512)) begin: gen_sram_1440kb
			sram_1440kb u_sram_1440kb( 
				.clka(clk), .clkb(clk), .ena(ena), .enb(enb), .wea(wea), .web(web),
				.addra(addra), .addrb(addrb),
				.dia(dia), .dib(dib), .doa(doa), .dob(dob)
			 );
		end
	    endgenerate
    `else 
    //------------------------------------------------------------------------+
	// Memory modeling
	//------------------------------------------------------------------------+
    reg [DATA_BITWIDTH-1 : 0] mem[0 : DEPTH-1];

    //port A (write first=blocking) /cf)read-first = non-blocking
    always @(posedge clk) begin
        if(ena) begin
            if(wea)
                mem[addra] = dia;
            doa = mem[addra]
        end
    end

    //read when enb is 1 (by using only port B)
    always @(posedge clk) begin
        if(enb) begin
            if(web)
                mem[addrb] = dib;
            dob = mem[addrb]
        end
    end


    `endif




endmodule