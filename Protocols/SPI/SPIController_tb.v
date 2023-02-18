`timescale 1ns / 1ps

module SPIController_tb();

parameter DATA_WIDTH = 8;

reg clk;
reg rst;
reg wrEn;
reg [DATA_WIDTH-1:0]dataIn;
reg newTXN;

SPIController dut(
    .clk(clk),
    .rst(rst),
    .wrEn(wrEn),
    .dataIn(dataIn),
    .newTXN(newTXN)
);

initial begin
    clk = 1'b0;
    rst = 1'b1;
    #10;
    rst = 1'b0;
    
    wrEn = 1;
    dataIn = 8'd10;
    newTXN = 1;
    
    #100;
    $finish;
end

always #5 clk = ~clk;

endmodule

