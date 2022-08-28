
//------------------------------------------------------------+
// Project: Spatial Accelerator
// Module:  psum_gbf_su
// Description:
//		psum_gbf_db_new + psum_su_irrel_new
//		It gets the COL*ROW*16bits size of psum_out from pe arrray.
//      One buffer accumulate psum value on psum_gbf and communicate with 
//
// History: 2022.08.25 by Min-Gyu Park (alsrbok@snu.ac.kr)
//------------------------------------------------------------+
`timescale 1ns / 1ps

module psum_gbf_su #(   parameter DATA_BITWIDTH     = 512,  //psum_gbf's data bitwidth
                        parameter ADDR_BITWIDTH     = 12,   //psum_gbf's addr bitwidth
                        parameter DEPTH             = 32,   //psum_gbf's depth
                        parameter ROW               = 16,   //PE array row size
                        parameter COL               = 16,   //PE array column size
                        parameter OUT_BITWIDTH      = 16)  //For psum data bitwidth
              ( input clk, reset, short_clk, pe_psum_en,
                input [ROW*COL-1 : 0] su_info,             // 256 size bit mask : mark 1 to make addition 
                input en1a, en1b, we1a, we1b, en2a, en2b, we2a, we2b,
                input [ADDR_BITWIDTH-1 : 0] addr1a, addr1b, addr2a, addr2b,
                input [DATA_BITWIDTH-1 : 0]  w_data1b, w_data2b,
                input [OUT_BITWIDTH*ROW*COL-1:0] din,
                output psum_ready,
                output [DATA_BITWIDTH-1 : 0] r_data1b, r_data2b
    );

    wire [DATA_BITWIDTH-1 : 0] psum_su, w_w_data1a, w_w_data2a;
    wire w_psum_ready;
    wire [DATA_BITWIDTH-1 : 0] out1b, out2b;

    psum_su_irrel_new #(.ROW(ROW), .COL(COL), .OUT_BITWIDTH(OUT_BITWIDTH), .DATA_BITWIDTH(DATA_BITWIDTH)) comp1(.clk(clk), .reset(reset),
    .short_clk(short_clk), .pe_psum_en(pe_psum_en), .din(din), .su_info(su_info), .dout(psum_su), .psum_ready(w_psum_ready));

    demux2 #(.WIDTH(DATA_BITWIDTH)) su_to_gbf(.d_in(psum_su), .sel(en2a), .zero(w_w_data1a), .one(w_w_data2a));

    psum_gbf_db_new #(.DATA_BITWIDTH(DATA_BITWIDTH), .ADDR_BITWIDTH(ADDR_BITWIDTH), .DEPTH(DEPTH)) comp2(.clk(clk), .en1a(en1a), .en1b(en1b),
    .we1a(we1a), .we1b(we1b), .en2a(en2a), .en2b(en2b), .we2a(we2a), .we2b(we2b), .addr1a(addr1a), .addr1b(addr1b), .addr2a(addr2a), .addr2b(addr2b),
    .w_data1a(w_w_data1a), .w_data1b(w_data1b), .w_data2a(w_w_data2a), .w_data2b(w_data2b), .r_data1b(out1b), .r_data2b(out2b));

    assign r_data1b = out1b;
    assign r_data2b = out2b;
    assign psum_ready = w_psum_ready;



endmodule
