`timescale 1ns / 1ps

module I2CController_tb();
parameter DATA_WIDTH = 8;

reg clk;
reg rst;
reg wrEn;
reg newTXN;
reg [DATA_WIDTH-2:0]slvAddr;
reg [DATA_WIDTH-1:0]regAddr;
reg [DATA_WIDTH-1:0]dataIn;

I2CController dut(
    .clk(clk),
    .rst(rst),
    .wrEn(wrEn),
    .newTXN(newTXN),
    .slvAddr(slvAddr),
	.regAddr(regAddr),
    .dataIn(dataIn)
//    output [DATA_WIDTH-1:0]dataOut
    );
    
    initial begin
        clk = 1'b0;
        rst = 1'b1;
        #10;
        rst = 1'b0;
        
        wrEn = 1'b0;
        newTXN = 1'b1;
        slvAddr = 7'd10;
        regAddr = 8'd1;
//        dataIn = 8'd3;
        
//        #1000;
//        wrEn = 1'b0;
        
//        #2000;
        #100;
        $finish;
    end
    
    always #5 clk <= ~clk;
endmodule

