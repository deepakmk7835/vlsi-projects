`timescale 1ns/1ps

module clock_divider_4Mto1M(
	input clk,
	input rst,
	output clkOut,
	output refClkOut
);

reg [1:0]count;
reg clkOutReg;
reg refClkOutReg;

assign clkOut = clkOutReg;
assign refClkOut = refClkOutReg;

always@(posedge clk)
begin
	if(rst)begin
		count <= 'h0;
	end else begin
		count <= count + 1'b1;
	end
end

always@(posedge clk)
begin
	if(rst)begin
		clkOutReg <= 0;
		refClkOutReg <= 0;
	end else if(count == 2'b1)begin
		refClkOutReg <= 1;
	end else if(count == 2'd2)begin
		clkOutReg <= 1;
	end else if(count == 2'd3)begin
		refClkOutReg <= 0;
	end else begin
		clkOutReg <= 0;
	end
end

endmodule
