`timescale 1ns / 1ps

module MAC_tb();
    
    parameter DATA_WIDTH=8;
    
    reg clk,rst;
    reg [3*3*DATA_WIDTH-1:0]inPixel;
    reg inPixelValid;
    wire [DATA_WIDTH-1:0]outPixel;
    wire outPixelValid;
    
MAC dut(
    .clk(clk),
    .rst(rst),
    .inPixel(inPixel),//Total 24*3 = 72 bits 
    .inPixelValid(inPixelValid),
    .outPixel(outPixel), // 1 8-bit output
    .outPixelValid(outPixelValid)
);

initial begin
    clk = 1'b0;
    #10; rst = 1'b1;
    #10; rst = 1'b0;
    
    inPixel <= {9{8'h1}};
    inPixelValid <= 1'b1;
    
    #10; inPixelValid <= 1'b0;
    
    $monitor("inPixel = %d \t outPixel = %d\t",inPixel,inPixelValid);
    #100;
    $finish;
end

always #5 clk <= ~clk;
endmodule
