`timescale 1ns/1ps

module NNs #(
	parameter DATA_WIDTH = 8
)(
	input clk,
	input rst,
	input [DATA_WIDTH-1:0]R,
	input [DATA_WIDTH-1:0]G,
	input [DATA_WIDTH-1:0]B,
    output [DATA_WIDTH-1:0]R_out,
	output [DATA_WIDTH-1:0]G_out,
	output [DATA_WIDTH-1:0]B_out
);

	wire [DATA_WIDTH-1:0]NN1_out;
	wire [DATA_WIDTH-1:0]NN2_out;
	wire [DATA_WIDTH-1:0]NN3_out;
	wire [DATA_WIDTH-1:0]NN4_out;

	reg[DATA_WIDTH-1:0]out_reg;

	neuron NN1(
		.clk(clk),
		.rst(rst),
		.R(R),
		.G(G),
		.B(B),
		.w1(29),
		.w2(-45),
		.w3(-87),
		.bias(-18227),
		.out(NN1_out)
	);
	
	neuron NN2(
		.clk(clk),
		.rst(rst),
		.R(R),
		.G(G),
		.B(B),
		.w1(-361),
		.w2(126),
		.w3(371),
		.bias(2845),
		.out(NN2_out)
	);

	neuron NN3(
		.clk(clk),
		.rst(rst),
		.R(R),
		.G(G),
		.B(B),
		.w1(-313),
		.w2(96),
		.w3(337),
		.bias(4513),
		.out(NN3_out)
	);

	neuron NN4(
		.clk(clk),
		.rst(rst),
		.R(NN1_out),
		.G(NN2_out),
		.B(NN3_out),
		.w1(51),
		.w2(-158),
		.w3(-129),
		.bias(41760),
		.out(NN4_out)
	);
	
	always@(posedge clk)begin
		if(NN4_out > 127)begin
			out_reg <= 8'd255;
		end else begin
			out_reg <= 8'd0;
		end
	end

	assign R_out = out_reg;
	assign G_out = out_reg;
	assign B_out = out_reg;
endmodule

