`timescale 1ns / 1ps

module lineBuffer #(
    parameter DATA_WIDTH = 8,
    parameter IMG_WIDTH = 512
)(
    input clk,
    input rst,
    input [DATA_WIDTH-1:0]inPixel,
    input inPixelValid,
    input outPixelReady, //When high, send data stored in buffer
    output [3*DATA_WIDTH-1:0]outPixel
);

reg [DATA_WIDTH-1:0]buffer[IMG_WIDTH-1:0];
reg [$clog2(IMG_WIDTH)-1:0]wtptr;
reg [$clog2(IMG_WIDTH)-1:0]rdptr;
reg [3*DATA_WIDTH-1:0]outPixelReg;

//Write Logic
always@(posedge clk)
begin
    if(rst)begin
        wtptr <= 1'b0;
    end else if(inPixelValid)begin
        buffer[wtptr] <= inPixel;
        wtptr <= wtptr + 1'b1;
    end
end

//Read Logic
always@(posedge clk)
begin
    if(rst)begin
        rdptr <= 1'b0;
        outPixelReg <= 'h0;
    end else if(outPixelReady && rdptr < IMG_WIDTH-2)begin
        outPixelReg <= {buffer[rdptr], buffer[rdptr+1], buffer[rdptr+2]};
        rdptr <= rdptr + 1'b1;
    end
end

assign outPixel = outPixelReg; 
 
endmodule
