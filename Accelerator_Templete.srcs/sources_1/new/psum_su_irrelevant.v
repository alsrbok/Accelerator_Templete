
//------------------------------------------------------------+
// Project: Spatial Accelerator
// Module:  psum_su_irrelevant
// Description:
//		This module handles the irrelevant(for psum) parameters on spatial unrolling.
//		It gets the COL*ROW*16bits size of psum_out from pe arrray, then calculates the result of psum, saving it in the reg psum_su
//      It sends output 512bits/cycle to psum_gbf_db when en(=psum_gbf_en1a or psum_gbf_en2a) is on. 
//		
//
// History: 2022.08.23 by Min-Gyu Park (alsrbok@snu.ac.kr)
//------------------------------------------------------------+
`timescale 1ns / 1ps

module psum_su_irrelevant #(parameter ROW       = 16,   //PE array row size
                parameter COL                   = 16,   //PE array column size
                parameter OUT_BITWIDTH          = 16,   //For psum data bitwidth
                parameter DATA_BITWIDTH        = 512)  //psum_gbf's data bitwidth
              ( input clk, pe_psum_en,
                input [OUT_BITWIDTH*ROW*COL-1:0] din,
                input [ROW*COL*ROW*COL-1 : 0] su_info,      // 256*256 size bit mask : mark 1 to make addition 
                input [7 : 0] su_rel_num,                   // 8bits = log2(ROW*COL) : relevant parameter number of psum on spatial unrolling
                output reg [DATA_BITWIDTH-1 : 0]  dout,
                output reg psum_cal_ready,
                output reg [DATA_BITWIDTH/OUT_BITWIDTH-1 : 0] we    //Write Byte input for psym_gbf_db(demux to we1a, we1b)
    );

    reg [OUT_BITWIDTH-1 : 0] psum_su[0 : ROW*COL-1];
    reg psum_su_finish;

    integer i,j;
    localparam unit = DATA_BITWIDTH/OUT_BITWIDTH;    //512/16=32 numbers of psum send to psum_gbf simultaneously
    //integer cycle = su_rel_num/unit+1;            //required number of cycles to send the whole psum_su data
    //integer remainder = su_rel_num%unit;          //number of psum_su remainder at the last cycle
    integer k=0;
    
    always@(posedge clk) begin
        if(pe_psum_en) begin
            if(su_rel_num != 0) begin
                for(i=0; i<su_rel_num; i=i+1) begin
                    for(j=0; j<ROW*COL; j=j+1) begin
                        if(su_info[ROW*COL*i+j])
                            psum_su[i] = psum_su[i] + din[OUT_BITWIDTH*j +: OUT_BITWIDTH];  // iterative addition can require tremendous time.. => check the simulation
                    end
                end
            end
            psum_su_finish = 1'b1;
        end
    end

    always@(posedge clk) begin
        if(psum_su_finish) begin
            if(su_rel_num==0) begin
                if(k<8) begin
                    for(i=0; i<unit; i=i+1)
                        dout[i*OUT_BITWIDTH +: OUT_BITWIDTH] <= psum_su[k*unit+i];
                    psum_cal_ready <= 1'b1;
                    we <= ~0;
                    if(k<7)
                        k <= k+1;
                    else
                        psum_su_finish = 1'b0;
                end
            end
            /*
            else if(su_rel_num< unit) begin
                for(i=0; i<su_rel_num; i=i+1) 
                    dout[i*OUT_BITWIDTH +: OUT_BITWIDTH] <= psum_su[unit+i];
                psum_cal_ready <= 1'b1;
                psum_su_finish = 1'b0;
            end
            */
            else begin
                if(k<su_rel_num/unit) begin
                    for(i=0; i<unit; i=i+1)
                        dout[i*OUT_BITWIDTH +: OUT_BITWIDTH] <= psum_su[k*unit+i];
                    psum_cal_ready <= 1'b1;
                    we <= ~0;
                    k <= k+1;
                end
                else if(k==su_rel_num/unit) begin
                    //for(i=0; i< su_rel_num%unit; i=i+1)
                    for(i=0; i<unit; i=i+1)
                        dout[i*OUT_BITWIDTH +: OUT_BITWIDTH] <= psum_su[k*unit+i];
                    psum_cal_ready <= 1'b1;
                    for(i=0; i< su_rel_num%unit; i=i+1)
                        we[i] <= 1'b1;
                    //we <= {{(su_rel_num%unit){1'b1}}};
                    psum_su_finish = 1'b0;
                end
            end
        end
    
    end


endmodule