`timescale 1ns / 1ps

module PE #(parameter IN_BITWIDTH = 16,         //For activation. weight, partial psum
            parameter OUT_BITWIDTH = 16,        //For psum
            parameter ACTV_ADDR_BITWIDTH = 5,   //Decide rf_input memory size
            parameter ACTV_DEPTH = 32,          //ACTV_DEPTH = 2^(ACTV_ADDR_BITWIDTH)
            parameter WGT_ADDR_BITWIDTH = 5,
            parameter WGT_DEPTH = 32,
            parameter PSUM_ADDR_BITWIDTH = 5,
            parameter PSUM_DEPTH = 32)
          ( input clk,
            input reset, input en, //enalbe signal for MAC from control logic
            input actv_en, input [ACTV_ADDR_BITWIDTH-1:0] actv_addr1, actv_addr2, input [IN_BITWIDTH-1:0] actv_data1, actv_data2,
            input wgt_en, input [WGT_ADDR_BITWIDTH-1:0] wgt_addr1, wgt_addr2, input [IN_BITWIDTH-1:0] wgt_data1,wgt_data2,
            input psum_en, input [PSUM_ADDR_BITWIDTH-1:0] psum_addr1, psum_addr2,
            output [OUT_BITWIDTH-1:0] psum_out1, psum_out2
    );

    wire [IN_BITWIDTH-1:0] actv1, actv2, actv;
    wire [IN_BITWIDTH-1:0] wgt1, wgt2, wgt;
    wire [IN_BITWIDTH-1:0] psum_in1, psum_in2, psum_in;
    wire [OUT_BITWIDTH-1:0] psum1, psum2, psum;
    wire out_en;

    //register file for activation
    rf_iw_sync_dpdb #(.DATA_BITWIDTH(IN_BITWIDTH), .ADDR_BITWIDTH(ACTV_ADDR_BITWIDTH), .DEPTH(ACTV_DEPTH)
     ) rf_actv(.clk(clk), .reset(reset), .write_en1(actv_en), .addr1(actv_addr1), .w_data1(actv_data1), 
     .addr2(actv_addr2), .w_data2(actv_data2), .r_data1(actv1), .r_data2(actv2));

    mux2 #(.WIDTH(IN_BITWIDTH)) actv_mux(.zero(actv1), .one(actv2), .sel(actv_en), .out(actv));

    //register file for weight
    rf_iw_sync_dpdb #(.DATA_BITWIDTH(IN_BITWIDTH), .ADDR_BITWIDTH(WGT_ADDR_BITWIDTH), .DEPTH(WGT_DEPTH)
     ) rf_wgt(.clk(clk), .reset(reset), .write_en1(wgt_en), .addr1(wgt_addr1), .w_data1(wgt_data1), 
     .addr2(wgt_addr2), .w_data2(wgt_data2), .r_data1(wgt1), .r_data2(wgt2));

    mux2 #(.WIDTH(IN_BITWIDTH)) wgt_mux(.zero(wgt1), .one(wgt2), .sel(wgt_en), .out(wgt));

    //register file for psum
    rf_psum_sync_dpdb #(.DATA_BITWIDTH(OUT_BITWIDTH), .ADDR_BITWIDTH(PSUM_ADDR_BITWIDTH), .DEPTH(PSUM_DEPTH)
     ) rf_psum(.clk(clk), .reset(reset), .en1(psum_en), .out_en(out_en), .addr1(psum_addr1), .w_data1(psum1),
     .addr2(psum_addr2), .w_data2(psum2), .r_data1(psum_in1), .r_data2(psum_in2), .out1(psum_out1), .out2(psum_out2));

    mux2 #(.WIDTH(IN_BITWIDTH)) psum_mux(.zero(psum_in2), .one(psum_in1), .sel(psum_en), .out(psum_in));
    demux2 #(.WIDTH(OUT_BITWIDTH)) psum_demux(.d_in(psum), .sel(psum_en), .zero(psum2), .one(psum1));

    //MAC for PE
    MAC #(.IN_BITWIDTH(IN_BITWIDTH), .OUT_BITWIDTH(OUT_BITWIDTH)
     ) mac(.a_in(actv), .w_in(wgt), .sum_in(psum_in), .en(en), .clk(clk), .out(psum), .out_en(out_en));

endmodule
