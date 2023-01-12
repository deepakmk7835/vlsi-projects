`timescale 1ns / 1ps

module exponent #(
    parameter DATA_WIDTH = 8,
    parameter INT_WIDTH = 4,
    parameter FRAC_WIDTH = 4,
    parameter PP_INT_WIDTH = INT_WIDTH + 8'd8,    //8-bits of dx & 4-bits of inputtotal = 12 + 1-bit of overflow
    parameter PP_FRAC_WIDTH = 8'd24 + FRAC_WIDTH
)(
    input clk,
    input rst,
    input [INT_WIDTH-1:-FRAC_WIDTH]inp,
    output [PP_INT_WIDTH+4:-PP_FRAC_WIDTH]outp
    );
    
    localparam SF = 2.0 ** -24.0;
    localparam SF2 = 2.0 ** -28.0;
    
    localparam PROD_INT_WIDTH= 2*INT_WIDTH;
    localparam PROD_FRAC_WIDTH = 2*FRAC_WIDTH;
    localparam BIAS_INT_WIDTH = 2*INT_WIDTH;
    localparam BIAS_FRAC_WIDTH = 2*FRAC_WIDTH;
    localparam EXP_INT_WIDTH = 27;
    
    localparam COEFF_INT_WIDTH = 8;
    localparam COEFF_FRAC_WIDTH = 24;
    
    localparam SUM_INT_WIDTH = 9;
    localparam SUM_FRAC_WIDTH = 24;
    
//    localparam PP_INT_WIDTH = INT_WIDTH + 8'd8;    //8-bits of dx & 4-bits of inputtotal = 12 + 1-bit of overflow
//    localparam PP_FRAC_WIDTH = 8'd24 + FRAC_WIDTH; //24-bits of dx & 4-bits of input hence total FRAC_BITS after prod = 28-bits
    
    localparam e_a = 12'b0001_1010_0110; //0.5 in decimal, Fixed point Q4.4, hence 0000.1000
    localparam d0 = 32'b0000_0000_1001_1011_0100_0101_1011_0000;//156; //0.6065321 in decimal, hence 1001.1100
    localparam d1 = 32'b0000_0000_1001_1011_0100_1001_1111_0100;//155;
    localparam d2 = 32'b0000_0000_0100_1101_0111_0111_0111_0111;//77;
    localparam d3 = 32'b0000_0000_0001_1010_0111_1101_0010_1000;//26;
    localparam d4 = 32'b0000_0000_0000_0101_0110_1100_0001_0110;
    localparam d5 = 32'b0000_0000_0000_0010_0010_0010_0010_0010; //Q8.24
    
    reg [SUM_INT_WIDTH:-SUM_FRAC_WIDTH]sum1,sum2,sum3,sum4,sum5;
    
    reg [PP_INT_WIDTH-1:-PP_FRAC_WIDTH]pp1;
    reg [PP_INT_WIDTH:-PP_FRAC_WIDTH]pp2;
    reg [PP_INT_WIDTH+1:-PP_FRAC_WIDTH]pp3;
    reg [PP_INT_WIDTH+2:-PP_FRAC_WIDTH]pp4;
    reg [PP_INT_WIDTH+3:-PP_FRAC_WIDTH]pp5;
    reg [PP_INT_WIDTH+4:-PP_FRAC_WIDTH]pp6;
    
    reg [INT_WIDTH-1:-FRAC_WIDTH]a;
    
     always@(posedge clk)
       begin
           a <= inp;
       end
       
//       initial begin
//               $display("d0 = %.5f \t d1 = %.5f \t d2 = %.5f \t d3 = %.5f \t d4 = %.5f \t d5 = %.5f \t ",$itor(d0 * (SF)),$itor(d1 * SF),$itor(d2 * SF),$itor(d3 * SF),$itor(d4 * SF),$itor(d5 * SF));
//               $monitor("pp1 = %.5f \t pp2 = %.5f \t pp3 = %.5f \t pp4 = %.5f \t pp5 = %.5f\t pp6 = %.5f \t",$itor(pp1*SF2), $itor(pp2*SF2), $itor(pp3*SF2), $itor(pp4*SF2), $itor(pp5*SF2),$itor(pp6*(2.0 ** -32.0)));
//            end
       
           always@(posedge clk)
       begin
           pp1 <= d5*a;
           sum1 <= d4 + pp1[COEFF_INT_WIDTH-1:-COEFF_FRAC_WIDTH];
           pp2 <= a *(sum1);
           sum2 <= d3 + pp2[COEFF_INT_WIDTH-1:-COEFF_FRAC_WIDTH];
           pp3 <= a * (sum2);
           sum3 <= d2 + pp3[COEFF_INT_WIDTH-1:-COEFF_FRAC_WIDTH];
           pp4 <= a * (sum3);
           sum4 <= d1 + pp4[COEFF_INT_WIDTH-1:-COEFF_FRAC_WIDTH];
           pp5 <= a * (sum4);
           sum5 <= d0 + pp5[COEFF_INT_WIDTH-1:-COEFF_FRAC_WIDTH];
           pp6 <= e_a * sum5;
       end
   
       
       assign outp = pp6;
    
endmodule
