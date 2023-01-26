`timescale 1ns / 1ps

module FIFO_tb();
    

    parameter FIFO_DEPTH = 16;
    parameter DATA_WIDTH = 8;
    parameter THRESHOLD = 8;
    
    reg clk,rst;
    reg [DATA_WIDTH-1:0]inPixel;
    reg inPixelValid;
    reg wr_rd_en;
    wire [DATA_WIDTH-1:0]outPixel;
    wire outPixelValid;
    wire progFull;
    
FIFO dut(
    .clk(clk),
    .rst(rst),
    .inPixel(inPixel),
    .inPixelValid(inPixelValid),
    .wr_rd_en(wr_rd_en),
    .outPixel(outPixel),
    .outPixelValid(outPixelValid),
    .progFull(progFull)
);

integer i;

initial begin
    clk = 1'b0;
    #10; rst = 1'b1;
    #10; rst = 1'b0;
    
    @(posedge clk);
        wr_rd_en = 1'b1;
    
    for(i=0;i<FIFO_DEPTH;i=i+1)begin
        @(posedge clk);
            if(!progFull)begin
                inPixel <= i;
                inPixelValid <= 1'b1;
            end
    end
    
    @(posedge clk);
        inPixelValid <= 1'b0;
    
    @(negedge inPixelValid);
        wr_rd_en = 1'b0;
        
    #100;
    $finish;
end

always #5 clk <= ~clk;
endmodule
