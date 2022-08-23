
//------------------------------------------------------------+
// Project: Spatial Accelerator
// Module: sram_db
// Description:
//		SRAM Module
//		It contains two sram_wrappers = Double buffering
//		
//
// History: 2022.08.19 by Min-Gyu Park (alsrbok@snu.ac.kr)
//------------------------------------------------------------+

module sram_db #(parameter DATA_BITWIDTH = 512,
                parameter ADDR_BITWIDTH = 12,
                parameter DEPTH = 2880 )
              ( input clk, en1a, en1b, we1a, we1b, en2a, en2b, we2a, we2b,
                input [ADDR_BITWIDTH-1 : 0] addr1a, addr1b, addr2a, addr2b,
                input [DATA_BITWIDTH-1 : 0] w_data1a, w_data1b, w_data2a, w_data2b,
                output reg [DATA_BITWIDTH-1 : 0] r_data1a, r_data1b, r_data2a, r_data2b
    );

    sram_wrapper #(.DATA_BITWIDTH(DATA_BITWIDTH), .ADDR_BITWIDTH(ADDR_BITWIDTH), .DEPTH(DEPTH)) sram_buffer1(.clk(clk), .ena(en1a),
    .enb(en1b), .wea(we1a), .web(we1b), .addra(addr1a), .addrb(addr1b), .dia(w_data1a), .dib(w_data1b), .doa(r_data1a), .dob(r_data1b));

    sram_wrapper #(.DATA_BITWIDTH(DATA_BITWIDTH), .ADDR_BITWIDTH(ADDR_BITWIDTH), .DEPTH(DEPTH)) sram_buffer2(.clk(clk), .ena(en2a),
    .enb(en2b), .wea(we2a), .web(we2b), .addra(addr2a), .addrb(addr2b), .dia(w_data2a), .dib(w_data2b), .doa(r_data2a), .dob(r_data2b));


endmodule