`timescale 1ns / 1ps

module I2CController #(
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst,
    input wrEn,
    input [DATA_WIDTH-1:0]slvAddr,
	input [DATA_WIDTH-1:0]regAddr,
    input [DATA_WIDTH-1:0]dataIn
//    output [DATA_WIDTH-1:0]dataOut
    );
    
    wire sclk_net;
    wire sclk_net_top;
    wire dclk_net_top;
    wire [DATA_WIDTH-1:0]sda_net;
    
    //Clock Divider FPGA 100MHz clock to I2C 1MHz clock
    clk_top(
	   .clk(clk), //100MHz clock
	   .rst(rst),
	   .sclk(sclk_net_top), //1MHz clock
	   .dclk(dclk_net_top)
    );
    
    //I2C Master
    I2CMaster i2cmst(
        .clk(sclk_net_top),
	    .dclk(dclk_net_top),
	    .rst(rst),
	    .wrEn(wrEn),
	    .dataIn(dataIn), //SLVDATA
	    .slvAddr(slvAddr),
	    .regAddr(regAddr),
	    .sda(sda_net),
	    .sclk(sclk_net)
    );
    
    I2CSlave i2cslv(
        .rst(rst),
	    .sclk(sclk_net),
	    .dclk(dclk_net_top),
	    .sda(sda_net)
    );
    
endmodule

