`timescale 1ns / 1ps

module top_tb();
    
    parameter DATA_WIDTH = 8;
    parameter IMG_WIDTH = 512;
    parameter IMG_SIZE = 512 * 512;
    
    reg clk,rst;
    reg [DATA_WIDTH-1:0]inPixel;
    reg inPixelValid;
    wire [DATA_WIDTH-1:0]outPixel;
    wire outPixelValid;
    wire rdBuffEmpty;
    
top dut(
    .clk(clk),
    .rst(rst),
    .inPixel(inPixel),
    .inPixelValid(inPixelValid),
    .outPixel(outPixel),
    .outPixelValid(outPixelValid),
    .rdBuffEmpty(rdBuffEmpty)
);

integer i;
integer inPixelCount;

initial begin
    clk <= 1'b0;
    #10 rst <= 1'b1;
    #10 rst <= 1'b0;
    inPixelCount = 1'b0;
    inPixelValid = 1'b0;
    
    for(i=0;i<4*IMG_WIDTH;i=i+1)begin
        @(posedge clk);
            inPixel <= i;
            inPixelValid <= 1'b1;
    end
    
    inPixelCount = inPixelCount + 4*512;
    inPixelValid = 1'b0;
    
    while(inPixelCount < IMG_SIZE)begin
    @(posedge rdBuffEmpty);
    for(i=0;i<IMG_WIDTH;i=i+1)begin
        @(posedge clk);
        inPixel <= i+1;
        inPixelValid <= 1'b1;
    end
    inPixelCount = inPixelCount + IMG_WIDTH;
    inPixelValid = 1'b0;
    end
    
    inPixelCount = IMG_SIZE;
    
    @(posedge clk);
    inPixelValid <= 1'b0;
    
    #100;
    $finish;
end

//always@(posedge rdBuffEmpty)
//begin
//    for(i=0;i<IMG_WIDTH;i=i+1)begin
//        @(posedge clk);
//        inPixel <= i+1;
//        inPixelValid <= 1'b1;
//    end
//    inPixelValid <= 1'b0;
//end

always #5 clk <= ~clk;
endmodule
