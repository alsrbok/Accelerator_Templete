//------------------------------------------------------------+
// Project: Spatial Accelerator
// Module: rf_psum_sync_dpdb_new
// Description:
//		Synchronized Dual-Port Double-Buffer RF for Psum
//		PSUM need different type of register file due to zero initialization.
//
// History: 2022.08.13 by Min-Gyu Park (alsrbok@snu.ac.kr)
//------------------------------------------------------------+
`timescale 1ns / 1ps

module rf_psum_sync_dpdb_new #( parameter DATA_BITWIDTH = 16,
			 parameter ADDR_BITWIDTH = 2,
             parameter DEPTH = 4 ) //default register size is 16*4=561bits
		   ( input clk,
			 input reset,
			 input en1,				// en1 : control logic gives en1 signal = use buffer1 to communicate with MAC (buffer2 communicate with upper hierarchy mem or not(maybe need more signal))
			 input out_en,			// psum_en : MAC gives psum_en signal = update memory with out value of MAC(= w_data value of rf_psum)
			 input [ADDR_BITWIDTH-1 : 0] addr1,
			 input [DATA_BITWIDTH-1 : 0] w_data1,
			 input [ADDR_BITWIDTH-1 : 0] w_addr1,
             input [ADDR_BITWIDTH-1 : 0] addr2,
			 input [DATA_BITWIDTH-1 : 0] w_data2,
			 input [ADDR_BITWIDTH-1 : 0] w_addr2,
			 output reg [DATA_BITWIDTH-1 : 0] r_data1, //read from mem1 send to MAC (partial psum)
             output reg [DATA_BITWIDTH-1 : 0] r_data2,
             output reg [DATA_BITWIDTH-1 : 0] out1,    //read from mem1 send to upper hierarchy mem(=global buffer)
             output reg [DATA_BITWIDTH-1 : 0] out2
    );
	
	reg [DATA_BITWIDTH-1 : 0] mem1 [0 : DEPTH - 1]; // default - 64-bits memory.
    reg [DATA_BITWIDTH-1 : 0] mem2 [0 : DEPTH - 1]; // default - 64-bits memory.
	reg init1, init2; // for setting mem to 0 at first time of communciation with MAC

    integer i;

	always@(posedge clk)
		begin : BUFFER1
			if(reset) begin
                r_data1 = 0;
                out1 = 0;
				init1 = 0;
			end
			else begin
				if(en1) begin
					if(!init1) begin // initially set mem1 to 0 for new dataset
						for (i=0; i<=DEPTH; i=i+1)
							mem1[i] = 0;
						init1 = 1;
					end
                    r_data1 = mem1[addr1]; // addr1 is used for partial psum location of current temporal mapping
					if(out_en)
						mem1[w_addr1] = w_data1; //en1 should be maintain one more cycle than DEPTH to write final data on mem1
				end
                else begin
					init1 = 0;
                    out1 = mem1[addr1];    // addr1 is used for mem1 location which should be send to upper hierarchy mem
                end
			end
		end
    
	always@(posedge clk)
		begin : BUFFER2
			if(reset) begin
                r_data2 = 0;
                out2 = 0;
				init2 =0;
			end
			else begin
				if(!en1) begin
					if(!init2) begin
						for (i=0; i<=DEPTH; i=i+1)
							mem2[i] = 0;
						init2 = 1;
					end
                    r_data2 = mem2[addr2];
					if(out_en)
						mem2[w_addr2] = w_data2;
				end
                else begin
					init2 = 0;
                    out2 = mem2[addr2];
                end
			end
		end

endmodule

