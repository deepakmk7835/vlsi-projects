`timescale 1ns/1ps
module clk_top(
	input clk,
	input rst,
	output clk1,
	output clk2
);

wire clkOutReg;

clock_divider(
	.clk(clk),
	.rst(rst),
	.clkOut(clkOutReg)
);

clock_divider_4Mto1M(
	.clk(clkOutReg),
	.rst(rst),
	.clkOut(clk1),
	.refClkOut(clk2)
);
endmodule
