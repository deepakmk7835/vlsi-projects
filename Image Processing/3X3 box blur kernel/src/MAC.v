`timescale 1ns / 1ps

module MAC #(
    parameter DATA_WIDTH=8
)(
    input clk,
    input rst,
    input [3*3*DATA_WIDTH-1:0]inPixel,//Total 24*3 = 72 bits 
    input inPixelValid,
    output [DATA_WIDTH-1:0]outPixel, // 1 8-bit output
    output outPixelValid
);
    reg [DATA_WIDTH-1:0]kernel[8:0];
    reg [2*DATA_WIDTH-1:0]resMatrix[8:0];
    reg [3*DATA_WIDTH-1:0]matrixSum,matrixSumReg;
    reg [2*DATA_WIDTH-1:0]resMatrixBy9;
    reg resMatrixValid;
    reg matrixSumValid;
    reg resMatrixBy9Valid;
    integer i;
    
    initial begin
        for(i=0;i<9;i=i+1)begin
            kernel[i] <= 8'h1;
        end
    end
    
    always@(posedge clk)
    begin
            for(i=0;i<9;i=i+1)begin
                resMatrix[i] <= inPixel[i*8+:8] * kernel[i];
            end
            resMatrixValid <= inPixelValid;
    end
    
    always@(*)begin
        if(rst)begin
            matrixSumReg = 'h0;
        end else begin
            matrixSumReg = 'h0;
            for(i=0;i<9;i=i+1)begin
                matrixSumReg = matrixSumReg + resMatrix[i];
            end
        end
    end
    
    always@(posedge clk)begin
        matrixSum <= matrixSumReg;
        matrixSumValid <= resMatrixValid;
    end
    
    always@(posedge clk)
    begin
        if(rst)begin
            resMatrixBy9Valid <= 0;
            resMatrixBy9 <= 0;
        end else begin
            resMatrixBy9 <= matrixSum / 9;
            resMatrixBy9Valid <= matrixSumValid;
        end
    end
    
    assign outPixel = resMatrixBy9;
    assign outPixelValid = resMatrixBy9Valid;
endmodule
