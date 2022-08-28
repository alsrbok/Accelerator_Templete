//------------------------------------------------------------+
// Project: Spatial Accelerator
// Module: PE_new_array
// Description:
//		PE_array with PE_new
//
// History: 2022.08.18 by Min-Gyu Park (alsrbok@snu.ac.kr)
//------------------------------------------------------------+
`timescale 1ns / 1ps

module PE_new_array #(parameter ROW         = 16,   //PE array row size
            parameter COL                   = 16,   //PE array column size
            parameter IN_BITWIDTH           = 16,   //For activation. weight, partial psum
            parameter OUT_BITWIDTH          = 16,   //For psum
            parameter ACTV_ADDR_BITWIDTH    = 2,   //Decide rf_input memory size
            parameter ACTV_DEPTH            = 4,    //ACTV_DEPTH = 2^(ACTV_ADDR_BITWIDTH)
            parameter WGT_ADDR_BITWIDTH     = 2,
            parameter WGT_DEPTH             = 4,
            parameter PSUM_ADDR_BITWIDTH    = 2,
            parameter PSUM_DEPTH            = 4)
          ( input clk,
            input reset, input [ROW*COL-1:0] MAC_en, //enalbe signal for MAC from control logic
            input [ROW*COL-1:0] actv_sel, actv_en, input [ACTV_ADDR_BITWIDTH*ROW*COL-1:0] actv_addr1, actv_addr2, input [IN_BITWIDTH*ROW*COL-1:0] actv_data1, actv_data2,
            input [ROW*COL-1:0] wgt_sel, wgt_en, input [WGT_ADDR_BITWIDTH*ROW*COL-1:0] wgt_addr1, wgt_addr2, input [IN_BITWIDTH*ROW*COL-1:0] wgt_data1,wgt_data2,
            input [ROW*COL-1:0] psum_en, input [PSUM_ADDR_BITWIDTH*ROW*COL-1:0] psum_addr1, psum_addr2, psum_write_addr,
            output [OUT_BITWIDTH*ROW*COL-1:0] psum_out
    );

    wire [OUT_BITWIDTH*ROW*COL-1:0] psum1, psum2;

    genvar i,j;

    generate
        for(i=0; i<ROW; i=i+1) begin : Row
            for(j=0; j<COL; j=j+1) begin : Col
                PE_new #(.IN_BITWIDTH(IN_BITWIDTH), .OUT_BITWIDTH(OUT_BITWIDTH), .ACTV_ADDR_BITWIDTH(ACTV_ADDR_BITWIDTH), .ACTV_DEPTH(ACTV_DEPTH), .WGT_ADDR_BITWIDTH(WGT_ADDR_BITWIDTH), .WGT_DEPTH(WGT_DEPTH), 
                .PSUM_ADDR_BITWIDTH(PSUM_ADDR_BITWIDTH), .PSUM_DEPTH(PSUM_DEPTH)) pe_new(.clk(clk), .reset(reset), .MAC_en(MAC_en[COL*i+j]), .actv_sel(actv_sel[COL*i+j]), .actv_en(actv_en[COL*i+j]), .wgt_sel(wgt_sel[COL*i+j]), .wgt_en(wgt_en[COL*i+j]), .psum_en(psum_en[COL*i+j]),
                .actv_addr1(actv_addr1[ACTV_ADDR_BITWIDTH*(COL*i+j+1)-1 : ACTV_ADDR_BITWIDTH*(COL*i+j)]), .actv_addr2(actv_addr2[ACTV_ADDR_BITWIDTH*(COL*i+j+1)-1 : ACTV_ADDR_BITWIDTH*(COL*i+j)]), 
                .actv_data1(actv_data1[IN_BITWIDTH*(COL*i+j+1)-1 : IN_BITWIDTH*(COL*i+j)]), .actv_data2(actv_data2[IN_BITWIDTH*(COL*i+j+1)-1 : IN_BITWIDTH*(COL*i+j)]),
                .wgt_addr1(wgt_addr1[WGT_ADDR_BITWIDTH*(COL*i+j+1)-1 : WGT_ADDR_BITWIDTH*(COL*i+j)]), .wgt_addr2(wgt_addr2[WGT_ADDR_BITWIDTH*(COL*i+j+1)-1 : WGT_ADDR_BITWIDTH*(COL*i+j)]),
                .wgt_data1(wgt_data1[IN_BITWIDTH*(COL*i+j+1)-1 : IN_BITWIDTH*(COL*i+j)]), .wgt_data2(wgt_data2[IN_BITWIDTH*(COL*i+j+1)-1 : IN_BITWIDTH*(COL*i+j)]),
                .psum_addr1(psum_addr1[PSUM_ADDR_BITWIDTH*(COL*i+j+1)-1 : PSUM_ADDR_BITWIDTH*(COL*i+j)]), .psum_addr2(psum_addr2[PSUM_ADDR_BITWIDTH*(COL*i+j+1)-1 : PSUM_ADDR_BITWIDTH*(COL*i+j)]),
                .psum_write_addr(psum_write_addr[PSUM_ADDR_BITWIDTH*(COL*i+j+1)-1 : PSUM_ADDR_BITWIDTH*(COL*i+j)]), 
                .psum_out1(psum1[OUT_BITWIDTH*(COL*i+j+1)-1 : OUT_BITWIDTH*(COL*i+j)]), .psum_out2(psum2[OUT_BITWIDTH*(COL*i+j+1)-1 : OUT_BITWIDTH*(COL*i+j)])
                );

                mux2 #(.WIDTH(OUT_BITWIDTH)) mux(.zero(psum1[OUT_BITWIDTH*(COL*i+j+1)-1 : OUT_BITWIDTH*(COL*i+j)]), .one(psum2[OUT_BITWIDTH*(COL*i+j+1)-1 : OUT_BITWIDTH*(COL*i+j)]), 
                .sel(psum_en[COL*i+j]), .out(psum_out[OUT_BITWIDTH*(COL*i+j+1)-1 : OUT_BITWIDTH*(COL*i+j)])
                );
            end
        end
    endgenerate


endmodule
