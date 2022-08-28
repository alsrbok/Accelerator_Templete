`timescale 1ns / 1ps

module psum_gbf_su_tb ();

    parameter DATA_BITWIDTH     = 512;  //psum_gbf's data bitwidth
    parameter ADDR_BITWIDTH     = 12;   //psum_gbf's addr bitwidth
    parameter DEPTH             = 32;   //psum_gbf's depth
    parameter ROW               = 16;   //PE array row size
    parameter COL               = 16;   //PE array column size
    parameter OUT_BITWIDTH      = 16; //For psum data bitwidth
    parameter CLK_REG_WIDTH     = 6;    // Width of the register required
    parameter CLK_N             = 34;
    reg short_clk, reset, pe_psum_en;
    reg [ROW*COL-1 : 0] su_info;             // 256 size bit mask : mark 1 to make addition 
    reg en1a, en1b, we1a, we1b, en2a, en2b, we2a, we2b;
    reg [ADDR_BITWIDTH-1 : 0] addr1a, addr1b, addr2a, addr2b;
    reg [DATA_BITWIDTH-1 : 0]  w_data1b, w_data2b;
    reg [OUT_BITWIDTH*ROW*COL-1:0] din;
    wire [DATA_BITWIDTH-1 : 0] r_data1b, r_data2b;
    
    wire clk;

    reg[OUT_BITWIDTH-1 : 0] i=0; // Assign 16bits i for din

    clk_gen #(.CLK_REG_WIDTH(CLK_REG_WIDTH), .CLK_N(CLK_N)) clk_gen(.clk(short_clk), .reset(reset), .clk_out(clk));

    psum_gbf_su #(.DATA_BITWIDTH(DATA_BITWIDTH), .ADDR_BITWIDTH(ADDR_BITWIDTH), .DEPTH(DEPTH), .ROW(ROW), .COL(COL), 
    .OUT_BITWIDTH(OUT_BITWIDTH)) psum_gbf_su(.clk(clk), .reset(reset), .short_clk(short_clk), .pe_psum_en(pe_psum_en), .su_info(su_info),
    .en1a(en1a), .en1b(en1b), .we1a(we1a), .we1b(we1b), .en2a(en2a), .en2b(en2b), .we2a(we2a), .we2b(we2b), .addr1a(addr1a), .addr1b(addr1b),
    .addr2a(addr2a), .addr2b(addr2b), .w_data1b(w_data1b), .w_data2b(w_data2b), .din(din), .r_data1b(r_data1b), .r_data2b(r_data2b));

    always
        #5 short_clk = ~short_clk;

    initial begin
        short_clk = 0;
        reset = 1;
        
        #10 reset <= 0; pe_psum_en <= 1'b1; su_info <={4{16'b1}};
        for(i=0;i<ROW*COL;i=i+1) begin din[OUT_BITWIDTH*i +: OUT_BITWIDTH]<= i+1; end
        #10 su_info <={4{16'b10}}; #10 su_info <={4{16'b100}}; #10 su_info <={4{16'b1000}}; #10 su_info <={4{16'b10000}};
        #10 su_info <={4{16'b100000}}; #10 su_info <={4{16'b1000000}}; #10 su_info <={4{16'b10000000}}; #10 su_info <={4{16'b100000000}};
        #10 su_info <={4{16'b1000000000}}; #10 su_info <={4{16'b10000000000}}; #10 su_info <={4{16'b100000000000}}; #10 su_info <={4{16'b1000000000000}};
        #10 su_info <={4{16'b10000000000000}}; #10 su_info <={4{16'b100000000000000}}; #10 su_info <={4{16'b1000000000000000}};
        //time 160ns

        #10 su_info <={{4{16'b1}},{4{16'b0}}}; #10 su_info <={{4{16'b10}},{4{16'b0}}}; #10 su_info <={{4{16'b100}},{4{16'b0}}}; #10 su_info <={{4{16'b1000}},{4{16'b0}}}; #10 su_info <={{4{16'b10000}},{4{16'b0}}};
        #10 su_info <={{4{16'b100000}},{4{16'b0}}}; #10 su_info <={{4{16'b1000000}},{4{16'b0}}}; #10 su_info <={{4{16'b10000000}},{4{16'b0}}}; #10 su_info <={{4{16'b100000000}},{4{16'b0}}};
        #10 su_info <={{4{16'b1000000000}},{4{16'b0}}}; #10 su_info <={{4{16'b10000000000}},{4{16'b0}}}; #10 su_info <={{4{16'b100000000000}},{4{16'b0}}}; #10 su_info <={{4{16'b1000000000000}},{4{16'b0}}};
        #10 su_info <={{4{16'b10000000000000}},{4{16'b0}}}; #10 su_info <={{4{16'b100000000000000}},{4{16'b0}}}; #10 su_info <={{4{16'b1000000000000000}},{4{16'b0}}};
        //time320ns

        //before posedge clk, setting enable signal of psum_dbf_db to correctly send it on following posedge clk **Check the latency**
        #10
        pe_psum_en=1'b0; en1a=1; en1b=0; we1a=0; we1b=0; en2a=0; en2b=1; we2a=0; we2b=0; addr1a=0; addr2b=0;

        #15 //at time 345ns, clk become 1

        #340 // at time 685ns, clk become 0
        we1a=1; en1b=1; addr1b=1;

        #340 //at time 1025ns, clk become 1 :: write calue to buffer1[0]

        #340 //at time 1365ns, clk become 0 : start to cal
        we1a=0;
        #5 pe_psum_en=1'b1;  su_info <={{4{16'b1}},{8{16'b0}}}; #10 su_info <={{4{16'b10}},{8{16'b0}}}; #10 su_info <={{4{16'b100}},{8{16'b0}}}; #10 su_info <={{4{16'b1000}},{8{16'b0}}}; #10 su_info <={{4{16'b10000}},{8{16'b0}}};
        #10 su_info <={{4{16'b100000}},{8{16'b0}}}; #10 su_info <={{4{16'b1000000}},{8{16'b0}}}; #10 su_info <={{4{16'b10000000}},{8{16'b0}}}; #10 su_info <={{4{16'b100000000}},{8{16'b0}}};
        #10 su_info <={{4{16'b1000000000}},{8{16'b0}}}; #10 su_info <={{4{16'b10000000000}},{8{16'b0}}}; #10 su_info <={{4{16'b100000000000}},{8{16'b0}}}; #10 su_info <={{4{16'b1000000000000}},{8{16'b0}}};
        #10 su_info <={{4{16'b10000000000000}},{8{16'b0}}}; #10 su_info <={{4{16'b100000000000000}},{8{16'b0}}}; #10 su_info <={{4{16'b1000000000000000}},{8{16'b0}}};

        #10 su_info <={{4{16'b1}},{12{16'b0}}}; #10 su_info <={{4{16'b10}},{12{16'b0}}}; #10 su_info <={{4{16'b100}},{12{16'b0}}}; #10 su_info <={{4{16'b1000}},{12{16'b0}}}; #10 su_info <={{4{16'b10000}},{12{16'b0}}};
        #10 su_info <={{4{16'b100000}},{12{16'b0}}}; #10 su_info <={{4{16'b1000000}},{12{16'b0}}}; #10 su_info <={{4{16'b10000000}},{12{16'b0}}}; #10 su_info <={{4{16'b100000000}},{12{16'b0}}};
        #10 su_info <={{4{16'b1000000000}},{12{16'b0}}}; #10 su_info <={{4{16'b10000000000}},{12{16'b0}}}; #10 su_info <={{4{16'b100000000000}},{12{16'b0}}}; #10 su_info <={{4{16'b1000000000000}},{12{16'b0}}};
        #10 su_info <={{4{16'b10000000000000}},{12{16'b0}}}; #10 su_info <={{4{16'b100000000000000}},{12{16'b0}}}; #10 su_info <={{4{16'b1000000000000000}},{12{16'b0}}};

        #10
        pe_psum_en=1'b0; en1a=1; we1a=0; addr1a=1;

        #15 //at time 1705ns, clk become 1

        #340 // at time 2045ns, clk become 0
        we1a=1; en1b=1; addr1b=1;

        #340 //at time 2385ns, clk become 1 :: write calue to buffer1[1]
        

        #340 //at time 2725ns, clk become 0 : start to cal
        we1a=0;
        addr1b=0;

        #340 //print r_data1b as a mem[0] value

        #340
        addr1b=1;

        #340 //print r_data1b as a mem[1] value


        $stop;
    end

    



endmodule