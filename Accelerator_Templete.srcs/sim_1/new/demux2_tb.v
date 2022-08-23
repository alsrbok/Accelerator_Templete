
module  demux2_tb();

parameter WIDTH = 16;
reg [WIDTH-1:0]din;
reg sel;
wire [WIDTH-1:0]Y0;
wire [WIDTH-1:0]Y1;

demux2 #(.WIDTH(WIDTH)) demux2_test(.d_in(din), .sel(sel), .zero(Y0), .one(Y1));
initial
begin
#10 din=10; sel=1'bX;
#10 din=15; sel=1'b0;
#10 din=26; sel=1'b1;
#10 din=24; sel=1'b0;
#10 din=80; sel=1'b1;
end

endmodule
