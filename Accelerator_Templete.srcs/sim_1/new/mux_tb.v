module  mux2_tb();

parameter WIDTH = 16;
reg [WIDTH-1:0] in0;
reg [WIDTH-1:0] in1;
reg sel;
wire [WIDTH-1:0] out;


mux2 #(.WIDTH(WIDTH)) mux2_tb(.zero(in0), .one(in1), .sel(sel), .out(out));
initial
begin
#10 sel=1'bX; in0=12; in1=34;
#10 sel=1'b0; in0=1; in1=5;
#10 sel=1'b1; in0 =3; in1= 12;
end

endmodule