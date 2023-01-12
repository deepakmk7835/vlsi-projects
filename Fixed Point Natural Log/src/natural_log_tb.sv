`timescale 1ns / 1ps

module natural_log_tb();

    localparam SF = 2.0 ** -4.0;
    localparam SF2 = 2.0 ** -38.0;
    
    parameter DATA_WIDTH = 8;
	parameter INT_WIDTH = 4;
	parameter FRAC_WIDTH = 4;
	
	
	
	reg clk;
    reg rst;
    reg [INT_WIDTH-1:-FRAC_WIDTH]inp;
    reg [INT_WIDTH-1:-FRAC_WIDTH]inp_temp;
    wire [8*INT_WIDTH-1:-10*FRAC_WIDTH]outp;
    
    natural_log dut(
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
        
        inp = 8'b0010_0000;
//        inp_temp = inp - 8'b0001_0000;
        
        $monitor("inp = %.5f \t outp = %.5f\n",$itor(inp * SF), $itor(outp * SF2));
        #100;
        $finish;
    end
    
    always #5 clk <= ~clk;
endmodule
