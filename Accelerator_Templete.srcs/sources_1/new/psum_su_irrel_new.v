
//------------------------------------------------------------+
// Project: Spatial Accelerator
// Module:  psum_su_irrel_new
// Description:
//		This module handles the irrelevant(for psum) parameters on spatial unrolling.
//		It gets the COL*ROW*16bits size of psum_out from pe arrray, then calculates the result of psum, saving it in the reg psum_su
//      It sends output(512bits/cycle) to psum_gbf_db when psum_cal_ready sets to 1'b1
//		** RTL analysis looks like a heavy design.**
//
// History: 2022.08.25 by Min-Gyu Park (alsrbok@snu.ac.kr)
//------------------------------------------------------------+
`timescale 1ns / 1ps

module psum_su_irrel_new#(parameter ROW       = 16,   //PE array row size
                parameter COL                   = 16,   //PE array column size
                parameter OUT_BITWIDTH          = 16,   //For psum data bitwidth
                parameter DATA_BITWIDTH        = 512)  //psum_gbf's data bitwidth
              ( input clk, reset, short_clk, pe_psum_en,
                input [OUT_BITWIDTH*ROW*COL-1:0] din,
                input [ROW*COL-1 : 0] su_info,              // 256 size bit mask : mark 1 to make addition 
                output reg [DATA_BITWIDTH-1 : 0]  dout,
                output reg psum_ready
    );

    localparam unit = DATA_BITWIDTH/OUT_BITWIDTH;    //512/16=32 numbers of psum send to psum_gbf simultaneously
    reg [OUT_BITWIDTH-1 : 0] psum_su[0 : unit-1];
    //reg [$clog2(unit)-1 : 0] idx = {($clog2(unit)-1){1'b0}};                   //5bits is for 2^5=32
    integer idx = 0;
    integer i;

    always@(posedge short_clk) begin
        if(reset) begin
            for(i=0;i<unit;i=i+1)
                psum_su[i] <= 0;
            idx <= 0;
            psum_ready <= 1'b0;
        end
        else if(pe_psum_en) begin
            if(idx<unit) begin                      //When psum_su is full(idx=32) send to psum_gbf first
                for(i=0;i<ROW*COL;i=i+1) begin
                    if(su_info[i])
                        psum_su[idx] = psum_su[idx]+ din[OUT_BITWIDTH*i +: OUT_BITWIDTH];
                end
                $display("%0t ns : updated psum_su / idx = %d / %d", $time, psum_su[idx], idx);
                idx = idx+1;
            end
        end
    end


    always@(posedge clk) begin
        if(reset) begin
            for(i=0;i<unit;i=i+1)
                psum_su[i] <= 0;
            idx <= 0;
            psum_ready <= 1'b0;
        end
        else if(idx==unit) begin
            psum_ready = 1'b1;
            for(i=0;i<unit;i=i+1) begin
                dout[OUT_BITWIDTH*i +: OUT_BITWIDTH] = psum_su[i];
                psum_su[i] = {OUT_BITWIDTH{1'b0}};
            end
            idx = 0;
            $display("%0t ns : dout / psum_su[0] / idx / psum_ready = %h / %d / %d / %d", $time, dout, psum_su[0], idx, psum_ready);
        end
        else
            dout = 0;
            psum_ready = 1'b0;
    end


endmodule