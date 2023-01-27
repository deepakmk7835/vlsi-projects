`timescale 1ns / 1ps

module topWrapper #(
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst,
    input [DATA_WIDTH-1:0]inPixel,
    input inPixelValid,
    input outPixelReady,
    output [DATA_WIDTH-1:0]outPixel,
    output outPixelValid,
    output inPixelReady,
    output interrupt
    );
    
    wire [DATA_WIDTH-1:0]topOutPixel;
    wire topOutPixelValid;
    wire axis_prog_full;
    
    top topDut(
        .clk(clk),
        .rst(rst),
        .inPixel(inPixel),
        .inPixelValid(inPixelValid),
        .outPixel(topOutPixel),
        .outPixelValid(topOutPixelValid),
        .rdBuffEmpty(topRdBuffEmpty)
    );
    
 outputBuffer OB(
  .wr_rst_busy(),        // output wire wr_rst_busy
  .rd_rst_busy(),        // output wire rd_rst_busy
  .s_aclk(clk),                  // input wire s_aclk
  .s_aresetn(!rst),            // input wire s_aresetn
  .s_axis_tvalid(topOutPixelValid),    // input wire s_axis_tvalid
  .s_axis_tready(),    // output wire s_axis_tready
  .s_axis_tdata(topOutPixel),      // input wire [7 : 0] s_axis_tdata
  .m_axis_tvalid(outPixelValid),    // output wire m_axis_tvalid
  .m_axis_tready(outPixelReady),    // input wire m_axis_tready
  .m_axis_tdata(outPixel),      // output wire [7 : 0] m_axis_tdata
  .axis_prog_full(fifoFull)  // output wire axis_prog_full
);
    
//    FIFO outFIFO(
//        .clk(clk),
//        .rst(rst),
//        .inPixel(topOutPixel),
//        .inPixelValid(topOutPixelValid),
//        .outPixelReady(outPixelReady),
//        .outPixel(outPixel),
//        .outPixelValid(outPixelValid),
//        .progFull(fifoFull)
//    );
    
    assign inPixelReady = !fifoFull;
    assign interrupt = topRdBuffEmpty;
endmodule
