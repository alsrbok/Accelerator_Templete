
//------------------------------------------------------------+
// Project: Spatial Accelerator
// Module:  psum_gbf_db_new
// Description:
//		Global Buffer Module for Activation and Weight (Do not use Byte Write)
//		It contains two sram_wrappers = Double buffering
//		
//
// History: 2022.08.25 by Min-Gyu Park (alsrbok@snu.ac.kr)
//------------------------------------------------------------+
`timescale 1ns / 1ps

module psum_gbf_db_new #(parameter DATA_BITWIDTH  = 512,
                        parameter ADDR_BITWIDTH   = 12,
                        parameter DEPTH           = 32 )
              ( input clk, en1a, en1b, we1a, we1b, en2a, en2b, we2a, we2b,
                input [ADDR_BITWIDTH-1 : 0] addr1a, addr1b, addr2a, addr2b,
                input [DATA_BITWIDTH-1 : 0] w_data1a, w_data1b, w_data2a, w_data2b,
                output [DATA_BITWIDTH-1 : 0] r_data1b, r_data2b
    );

    wire [DATA_BITWIDTH-1 : 0] di1a, do1a, di2a, do2a;

    assign di2a=do2a+w_data2a;
    assign di1a=do1a+w_data1a;
    always @(*) begin
        $monitor("changed signal, %0t ns : en1a / di1a / do1a / w_data1a  = %d / %h / %h / %h  ", $time, en1a, di1a, do1a, w_data1a);
        $monitor("changed signal, %0t ns : en1b / di2a / do2a / w_data2a  = %d / %h / %h / %h  ", $time, en2a, di2a, do2a, w_data2a);
    end

    true_dp_ram #(.DATA_BITWIDTH(DATA_BITWIDTH), .ADDR_BITWIDTH(ADDR_BITWIDTH), .DEPTH(DEPTH), .MEM_INIT_FILE("psum_gbf_init.mem")) psum_gbf_buffer1(.clk(clk), .ena(en1a),
    .enb(en1b), .wea(we1a), .web(we1b), .addra(addr1a), .addrb(addr1b), .dia(w_data1a), .dib(w_data1b), .doa(do1a), .dob(r_data1b));

    true_dp_ram #(.DATA_BITWIDTH(DATA_BITWIDTH), .ADDR_BITWIDTH(ADDR_BITWIDTH), .DEPTH(DEPTH), .MEM_INIT_FILE("psum_gbf_init.mem")) psum_gbf_buffer2(.clk(clk), .ena(en2a),
    .enb(en2b), .wea(we2a), .web(we2b), .addra(addr2a), .addrb(addr2b), .dia(w_data2a), .dib(w_data2b), .doa(do2a), .dob(r_data2b));


endmodule
