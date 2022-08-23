//------------------------------------------------------------+
// Project: Spatial Accelerator
// Module: top_wo_control
// Description:
//		Top Module without control logic
//		Inputs : inputs of top module(clk, reset ..) , outputs of control logic(MAC_en, en/sel/addr..)
//		Outputs : X
//    It can be checked by a testbench which regulates the control logic outputs
//
//
// History: 2022.08.23 by Min-Gyu Park (alsrbok@snu.ac.kr)
//------------------------------------------------------------+

module top_wo_control #(
                //For SRAM parameter
                parameter SRAM_DATA_BITWIDTH = 512,
                parameter SRAM_ADDR_BITWIDTH = 12,
                parameter SRAM_DEPTH = 2880,
                //For Weight Global Buffer parameter
                parameter WGT_GBF_DATA_BITWIDTH = 512,
                parameter WGT_GBF_ADDR_BITWIDTH = 5,
                parameter WGT_GBF_DEPTH = 32,
                //For Activation Global Buffer parameter
                parameter ACTV_GBF_DATA_BITWIDTH = 512,
                parameter ACTV_GBF_ADDR_BITWIDTH = 5,
                parameter ACTV_GBF_DEPTH = 32,
                //For PE array
                parameter ROW = 16,       //PE array row size
                parameter COL = 16,                 //PE array column size
                parameter IN_BITWIDTH = 16,         //For activation. weight, partial psum
                parameter OUT_BITWIDTH = 16,        //For psum
                parameter ACTV_ADDR_BITWIDTH = 2,   //Decide rf_input memory size
                parameter ACTV_DEPTH = 4,          //ACTV_DEPTH = 2^(ACTV_ADDR_BITWIDTH)
                parameter WGT_ADDR_BITWIDTH = 2,
                parameter WGT_DEPTH = 4,
                parameter PSUM_ADDR_BITWIDTH = 2,
                parameter PSUM_DEPTH = 4 
                )
              ( //inputs from the top_module
                input clk, reset,
                //inputs for sram from the control logic
                input sram_en1a, sram_en1b, sram_we1a, sram_we1b, sram_en2a, sram_en2b, sram_we2a, sram_we2b,
                input [SRAM_ADDR_BITWIDTH-1 : 0] sram_addr1a, sram_addr1b, sram_addr2a, sram_addr2b,
                input [SRAM_DATA_BITWIDTH-1 : 0] sram_w_data1a, sram_w_data1b, sram_w_data2a, sram_w_data2b,
                //inputs for weight global buffer from the contol logic
                input wgt_gbf_en1a, wgt_gbf_en1b, wgt_gbf_we1a, wgt_gbf_en2a, wgt_gbf_en2b, wgt_gbf_we2a,
                input [WGT_GBF_ADDR_BITWIDTH-1 : 0] wgt_gbf_addr1a, wgt_gbf_addr1b, wgt_gbf_addr2a, wgt_gbf_addr2b,
                //inputs for activation global buffer from the contol logic
                input actv_gbf_en1a, actv_gbf_en1b, actv_gbf_we1a, actv_gbf_en2a, actv_gbf_en2b, actv_gbf_we2a,
                input [ACTV_GBF_ADDR_BITWIDTH-1 : 0] actv_gbf_addr1a, actv_gbf_addr1b, actv_gbf_addr2a, actv_gbf_addr2b,
                //inputs for PE array from the control logic
                input [ROW*COL-1:0] MAC_en, //enalbe signal for MAC from control logic
                input [ROW*COL-1:0] actv_sel, actv_en, input [ACTV_ADDR_BITWIDTH*ROW*COL-1:0] actv_addr1, actv_addr2,
                input [ROW*COL-1:0] wgt_sel, wgt_en, input [WGT_ADDR_BITWIDTH*ROW*COL-1:0] wgt_addr1, wgt_addr2,
                input [ROW*COL-1:0] psum_en, input [PSUM_ADDR_BITWIDTH*ROW*COL-1:0] psum_addr1, psum_addr2, psum_write_addr,
                output [OUT_BITWIDTH*ROW*COL-1:0] psum_out
                
    );

  wire [SRAM_DATA_BITWIDTH-1 : 0] r_data1a, r_data1b, r_data2a, r_data2b; //for outputs of sram connected to the mux2
  wire [WGT_GBF_DATA_BITWIDTH-1 : 0] wgt_gbf_w_data1a, wgt_gbf_w_data2a; //for inputs of weight global buffer from the sram
  wire [ACTV_GBF_DATA_BITWIDTH-1 : 0] actv_gbf_w_data1a, actv_gbf_w_data2a; // for inputs of activation global buffer from the sram
  wire [WGT_GBF_DATA_BITWIDTH-1 : 0] wgt_gbf_r_data1b, wgt_gbf_r_data2b; // for outputs of wgt_gbf connected to the mux2
  wire [ACTV_GBF_DATA_BITWIDTH-1 : 0] actv_gbf_r_data1b, actv_gbf_r_data2b; // for outputs of wgt_gbf connected to the mux2
  wire [IN_BITWIDTH*ROW*COL-1:0] actv_data1, actv_data2; // for inputs of pe_array from the demux2
  wire [IN_BITWIDTH*ROW*COL-1:0] wgt_data1, wgt_data2; // for inputs of pe_array from the demux2

endmodule