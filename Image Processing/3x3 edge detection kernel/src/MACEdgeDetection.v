`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.01.2023 17:24:00
// Design Name: 
// Module Name: MACEdgeDetection
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MACEdgeDetection #(
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
        kernel[0] = 0;
        kernel[1] = -1;
        kernel[2] = 0;
        kernel[3] = -1;
        kernel[4] = 4;
        kernel[5] = -1;
        kernel[6] = 0;
        kernel[7] = -1;
        kernel[8] = 0;
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
        
    assign outPixel = matrixSum;
    assign outPixelValid = matrixSumValid;
endmodule
