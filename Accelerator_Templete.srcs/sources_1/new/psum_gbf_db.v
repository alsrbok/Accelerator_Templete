
//------------------------------------------------------------+
// Project: Spatial Accelerator
// Module:  psum_gbf_db
// Description:
//		Global Buffer Module for Activation and Weight
//		It contains two sram_wrappers = Double buffering
//		
//
// History: 2022.08.23 by Min-Gyu Park (alsrbok@snu.ac.kr)
//------------------------------------------------------------+
`timescale 1ns / 1ps

module psum_gbf_db #(parameter NUM_COL     = 32, //Use 16*32 = 512bits DATA BITWIDTH
                parameter COL_WIDTH        = 16,
                parameter DATA_BITWIDTH    = NUM_COL*COL_WIDTH,
                parameter ADDR_BITWIDTH    = 5,
                parameter DEPTH            = 32 )
              ( input clk, en1a, en1b, en2a, en2b, 
                input [NUM_COL-1:0] we1a, we1b, we2a, we2b,
                input [ADDR_BITWIDTH-1 : 0] addr1a, addr1b, addr2a, addr2b,
                input [DATA_BITWIDTH-1 : 0] w_data1a, w_data2a, w_data1b, w_data2b,
                output reg [DATA_BITWIDTH-1 : 0]  r_data1b, r_data2b
    );

    wire [DATA_BITWIDTH-1 : 0] di1a, do1a, di2a, do2a;

    assign di2a=do2a+w_data2a;
    assign di1a=do1a+w_data1a;

    psum_gbf_wrapper #(.NUM_COL(NUM_COL), .COL_WIDTH(COL_WIDTH), .DATA_BITWIDTH(DATA_BITWIDTH), .ADDR_BITWIDTH(ADDR_BITWIDTH), .DEPTH(DEPTH)) psum_gbf_buffer1(.clk(clk),
    .ena(en1a), .enb(en1b), .wea(we1a), .web(we1b), .addra(addr1a), .addrb(addr1b), .dia(di1a), .dib(w_data1b), .doa(do1a), .dob(r_data1b));

    psum_gbf_wrapper #(.NUM_COL(NUM_COL), .COL_WIDTH(COL_WIDTH), .DATA_BITWIDTH(DATA_BITWIDTH), .ADDR_BITWIDTH(ADDR_BITWIDTH), .DEPTH(DEPTH)) psum_gbf_buffer2(.clk(clk),
    .ena(en2a), .enb(en2b), .wea(we2a), .web(we2b), .addra(addr2a), .addrb(addr2b), .dia(di2a), .dib(w_data2b), .doa(do2a), .dob(r_data2b));


endmodule