`timescale 1ns / 1ps

module exponent_tb();
    parameter DATA_WIDTH = 8;
    parameter INT_WIDTH = 4;
    parameter FRAC_WIDTH = 4;
    parameter PP_INT_WIDTH = INT_WIDTH + 8'd8;   //8-bits of dx & 4-bits of inputtotal = 12 + 1-bit of overflow
    parameter PP_FRAC_WIDTH = 8'd24 + FRAC_WIDTH;
    
    parameter SF = 2.0 ** -24.0;
    parameter SF2 = 2.0 ** -32.0;
    
    reg clk;
    reg rst;
    reg [INT_WIDTH-1:-FRAC_WIDTH]inp;
    wire [PP_INT_WIDTH+4:-PP_FRAC_WIDTH]outp;
    
    exponent dut(
        .clk(clk),
        .rst(rst),
        .inp(inp),
        .outp(outp)
    );
    
    initial begin
        clk = 1;
        #10;
        rst = 1;
        #10;
        rst = 0;
        inp = 8'b0001_0000;
        #10;
//        inp = 8'b0010_0000;
        
        $monitor("inp_a = %.5f \t oup = %.5f\t",$itor(inp * (2.0 ** -4.0)), $itor(outp * SF2));
    end
    
    always #5 clk <= ~clk;
    
endmodule
