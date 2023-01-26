`timescale 1ns / 1ps

module FIFO #(
    parameter FIFO_DEPTH = 16,
    parameter DATA_WIDTH = 8,
    parameter THRESHOLD = 8
)(
    input clk,
    input rst,
    input [DATA_WIDTH-1:0]inPixel,
    input inPixelValid,
    input outPixelReady,
    output [DATA_WIDTH-1:0]outPixel,
    output outPixelValid,
    output progFull
);
    reg [DATA_WIDTH-1:0]fifo[FIFO_DEPTH-1:0];
    reg [$clog2(FIFO_DEPTH):0]wrPtr,rdPtr;
    reg [DATA_WIDTH-1:0]fifoRdData;
    reg outPixelValidReg;
    reg [$clog2(FIFO_DEPTH)-1:0]fifoContent;
    
    always@(posedge clk)
    begin
        if(rst)begin
            wrPtr <= 1'b0;
        end else if(inPixelValid)begin
            fifo[wrPtr] <= inPixel;
            wrPtr <= wrPtr + 1'b1;
        end
    end
    
    always@(posedge clk)
    begin
        if(rst)begin
            rdPtr <= 1'b0;
            fifoRdData <= 'h0;
            outPixelValidReg <= 1'b0;
        end else if(fifoContent > 0 && rdPtr < FIFO_DEPTH && outPixelReady)begin
            fifoRdData <= fifo[rdPtr];
            rdPtr <= rdPtr + 1'b1;
            outPixelValidReg <= 1'b1;
        end else begin
            rdPtr <= 1'b0;
            outPixelValidReg <= 1'b0;
        end
    end
    
    always@(posedge clk)
    begin
       if(rst)begin
            fifoContent <= 'h0;
       end else if(inPixelValid && fifoContent < FIFO_DEPTH-1) begin
            fifoContent <= fifoContent + 1'b1;
       end else if(outPixelReady && fifoContent > 1'b0)begin
            fifoContent <= fifoContent - 1'b1;
       end
    end
    
    assign outPixel = fifoRdData;
    assign outPixelValid = outPixelValidReg;
    assign progFull = (fifoContent > THRESHOLD);
endmodule
