`timescale 1ns/1ps

module clock_divider(
	input clk,
	input rst,
	output clkOut
);

reg clkOutReg;
reg [3:0]count;

assign clkOut = clkOutReg;

always@(posedge clk)begin
	if(rst)begin
		count <= 'h0;
	end else if(count <= 4'd11) begin
		count <= count + 1'b1;
	end else begin
		count <= 'h0;
	end
end

always@(posedge clk)begin
	if(rst)begin
		clkOutReg <= 0;
	end else if(count == 4'd11)begin
		clkOutReg <= ~clkOutReg;
	end
end

endmodule
