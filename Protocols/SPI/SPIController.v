`timescale 1ns / 1ps

module SPIController#(
	parameter DATA_WIDTH = 8
)(
    input clk,
    input rst,
    input wrEn,
    input [DATA_WIDTH-1:0]dataIn,
    input newTXN
);

wire misoNet;
wire mosiNet;
wire sclkNet;
wire csNet;

SPIMaster spimst(
	.clk(clk),
	.rst(rst),
	.dataIn(dataIn),
	.newTXN(newTXN),
	.wrEn(wrEn), //1-Write TXN, 0-Read TXN
	.miso(misoNet),
	.mosi(mosiNet),
	.sclk(sclkNet),
	.cs(csNet)
);

SPISlave spislv(
	.sclk(sclkNet),
	.rst(rst),
	.mosi(mosiNet),
	.cs(csNet),
	.miso(misoNet)
);
endmodule

