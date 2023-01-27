`timescale 1ns / 1ps

module lineBuffer_tb();
    
    parameter DATA_WIDTH = 8;
    parameter IMG_WIDTH = 512;
    
    reg clk,rst;
    reg [DATA_WIDTH-1:0]inPixel;
    reg inPixelValid;
    reg outPixelReady;
    wire [DATA_WIDTH-1:0]outPixel;

lineBuffer dut(
    .clk(clk),
    .rst(rst),
    .inPixel(inPixel),
    .inPixelValid(inPixelValid),
    .outPixelReady(outPixelReady), //When high, send data stored in buffer
    .outPixel(outPixel)
);

integer i;
integer outPixelCount;

initial begin
    clk = 1'b1;
    #10 rst = 1'b1;
    #10 rst = 1'b0;
    outPixelCount = 1'b0;
    
    for(i=0;i<IMG_WIDTH;i=i+1)
    begin
        @(posedge clk);
        inPixel <= i;
        inPixelValid <= 1'b1;
    end
    @(posedge clk);
    inPixelValid <= 1'b0;
    #10;
    
    @(posedge clk);
    outPixelReady <= 1'b1;
    
    while(outPixelCount < IMG_WIDTH-1)
    begin
        @(posedge clk);
            outPixelCount <= outPixelCount + 1'b1;
    end
            
    @(posedge clk);
    outPixelReady <= 1'b0; 
    $stop;       
    
    $monitor("clk = %b\t outPixel = %d\t",clk,outPixel);
//    #100;
//    $finish;
end

always #5 clk <= ~clk;
endmodule
