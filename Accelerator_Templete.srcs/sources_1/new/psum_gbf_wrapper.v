
//------------------------------------------------------------+
// Project: Spatial Accelerator
// Module: psum_gbf_wrapper
// Description:
//		True Dual-port RAM(with ena, enb pin) wrapper (Byte Write Enable with 8 bits, N_DELAY = 1. Bandwidth = 512bits/cycle)
//		FPGA = 1: Use the generated RAM 
//		Otherwise: Use a RAM modeling
//
// History: 2022.08.23 by Min-Gyu Park (alsrbok@snu.ac.kr)
//------------------------------------------------------------+

`timescale 1ns / 1ps

`define FPGA 0
module psum_gbf_wrapper #(parameter NUM_COL     = 32, //Use 16*32 = 512bits DATA BITWIDTH
                parameter COL_WIDTH             = 16,
                parameter DATA_BITWIDTH         = NUM_COL*COL_WIDTH,
                parameter ADDR_BITWIDTH         = 5,
                parameter DEPTH                 = 32 )
              ( input clk, ena, enb, 
                input [NUM_COL-1:0] wea, web,
                input [ADDR_BITWIDTH-1 : 0] addra, addrb,
                input [DATA_BITWIDTH-1 : 0] dia, dib,
                output reg [DATA_BITWIDTH-1 : 0] doa, dob
    );


    `ifdef FPGA
    //------------------------------------------------------------------------+
	// Implement ip generate block ram
	//------------------------------------------------------------------------+
        generate
		if((DATA_BITWIDTH == 512) && (DEPTH == 32)) begin: gen_gbf_16x1024
			psum_gbf_16x1024 u_psum_gbf_32x512( 
				.clk(clk), .enaA(ena), .enaB(enb), .weA(wea), .weB(web),
				.addrA(addra), .addrB(addrb),
				.dinA(dia), .dinB(dib), .doutA(doa), .doutB(dob)
			 );
		end
	    endgenerate
    `else 
    //------------------------------------------------------------------------+
	// Memory modeling
	//------------------------------------------------------------------------+
    reg [DATA_BITWIDTH-1 : 0] mem[0 : DEPTH-1];

    //port A operation : get data from "psum_rf_irrelevant" module :: accumulate the value with update via dia = doa+w_dataa
    always @(posedge clk) begin
        if(ena) begin
            for(i=0;i<NUM_COL;i=i+1) begin
                if(wea[i]) begin
                   mem[addra][i*COL_WIDTH +: COL_WIDTH] <= dia[i*COL_WIDTH +: COL_WIDTH]
                end
            end
            doa <= mem[addra]
        end
    end

    //port B opration : send/get data to/from sram
    always @(posedge clk) begin
        if(enb) begin
            for(i=0;i<NUM_COL;i=i+1) begin
                if(web[i]) begin
                   mem[addrb][i*COL_WIDTH +: COL_WIDTH] <= dib[i*COL_WIDTH +: COL_WIDTH]
                end
            end
            dob <= mem[addrb]
        end
    end


    `endif

endmodule