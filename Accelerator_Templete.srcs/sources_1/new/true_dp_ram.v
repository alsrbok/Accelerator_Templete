
//------------------------------------------------------------+
// Project: Spatial Accelerator
// Module: true_dp_ram
// Description:
//		True Dual-port RAM(with ena, enb pin) wrapper (N_DELAY = 1, WRITE_FIRST. Bandwidth = 512bits/cycle)
//		FPGA = 1: Use the generated RAM 
//		Otherwise: Use a RAM modeling
//
// History: 2022.08.19 by Min-Gyu Park (alsrbok@snu.ac.kr)
//------------------------------------------------------------+

`timescale 1ns / 1ps

//`define FPGA 0
module true_dp_ram #(parameter DATA_BITWIDTH   = 512,
                parameter ADDR_BITWIDTH         = 12,
                parameter DEPTH                 = 2880,
                parameter MEM_INIT_FILE = "psum_gbf_init.mem" )
              ( input clk, ena, enb, wea, web,
                input [ADDR_BITWIDTH-1 : 0] addra, addrb,
                input [DATA_BITWIDTH-1 : 0] dia, dib, 
                output reg [DATA_BITWIDTH-1 : 0] doa, dob
    );


    //`ifdef FPGA
    //------------------------------------------------------------------------+
	// Implement ip generate block ram
	//------------------------------------------------------------------------+
    /*
        generate
		if((DATA_BITWIDTH == 512) && (DEPTH == 2880)) begin: gen_sram_1440kb
			sram_1440kb u_sram_1440kb( 
				.clk(clk), .ena(ena), .enb(enb), .wea(wea), .web(web),
				.addra(addra), .addrb(addrb),
				.dia(dia), .dib(dib), .doa(doa), .dob(dob)
			 );
		end

        if((DATA_BITWIDTH == 512) && (DEPTH == 32)) begin: gen_psum_gbf_512x32
			psum_gbf_512x32 u_psum_gbf_512x32( 
				.clk(clk), .ena(ena), .enb(enb), .wea(wea), .web(web),
				.addra(addra), .addrb(addrb),
				.dia(dia), .dib(dib), .doa(doa), .dob(dob)
			 );
		end
	    endgenerate
    */
    //`else 
    //------------------------------------------------------------------------+
	// Memory modeling
	//------------------------------------------------------------------------+
    reg [DATA_BITWIDTH-1 : 0] mem[0 : DEPTH-1];

    initial begin
        if (MEM_INIT_FILE != "") begin
            $display("intialize the true_dp_ram");
            $readmemh(MEM_INIT_FILE, mem);
        end
    end

    //port A (write first=blocking) /cf)read-first = non-blocking
    always @(posedge clk) begin
        if(ena) begin
            if(wea) begin
                mem[addra] = dia;
                $display("in true_dp_ram A port, %0t ns : mem[addra]  = %h / %d ", $time, mem[addra], addra);
            end
            doa = mem[addra];
            $display("in true_dp_ram A port, %0t ns : doa  = %h ", $time, doa);
        end
    end

    //read when enb is 1 (by using only port B)
    always @(posedge clk) begin
        if(enb) begin
            if(web)
                mem[addrb] = dib;
            dob = mem[addrb];
        end
    end


    //`endif




endmodule