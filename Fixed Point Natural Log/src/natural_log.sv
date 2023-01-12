`timescale 1ns/1ps

/*
 * ln(1+x) = (1+65481x - 32093x^2 + 18601x^3 - 8517x^4 + 1954x^5)/65536;
 */

module natural_log #(
	parameter DATA_WIDTH = 8,
	parameter INT_WIDTH = 4,
	parameter FRAC_WIDTH = 4
)(
	input clk,
	input rst,
	input [INT_WIDTH-1:-FRAC_WIDTH]inp,
	output [8*INT_WIDTH-1:-10*FRAC_WIDTH]outp
);

	//32-bit,48-bit, 64-bit, 80-bit, 96-bit to store result
	localparam x_coeff = 65481;
	localparam x2_coeff = 32093;
	localparam x3_coeff = 18601;
	localparam x4_coeff = 8517;
	localparam x5_coeff = 1954;
	localparam denom = 65536; //16-bit required
	
	localparam x_mul = 8'b0000_0100;

	reg [INT_WIDTH-1:-FRAC_WIDTH]x;
	
	always@(posedge clk)
	begin
		x <= inp;
	end		

	reg [31:-8]x2;
	reg [47:-8]x3;
	reg [63:-8]x4;
	reg [79:-8]x5;

	reg [32:-8*2] pp1;
	reg [47:-8] pp2;
	reg [63:-8] pp3;
	reg [79:-8] pp4;
	reg [95:-8] pp5;
	reg [95:-8] temp;

	reg [95:-8]res;

	always@(posedge clk)
	begin
		x2 <= x * x;
		x3 <= x2 * x;
		x4 <= x3 * x;
		x5 <= x4 * x;
//		$monitor("x2 = %.5f\tx3 = %.5f\tx_mul = %.5f\tx_mul_bin = %b\t",x2 * (2.0 ** -8.0), x3 * (2.0 ** -8.0), $itor(x_mul * (2.0 ** -4.0)), x_mul);
	end

	always@(posedge clk)
	begin
		pp1 <= x_coeff * x;
		pp2 <= x2 * x2_coeff;
		pp3 <= x3 * x3_coeff;
		pp4 <= x4 * x4_coeff;
		pp5 <= (x5 * x5_coeff);
		temp <= pp5 + {1'b1,{20{1'b0}}};
	
//        res <= (temp) * x_mul;
        res <= temp >> 16;
//		$monitor("pp5_bin = %b\t x_mul = %.5f\t",pp5, $itor(x_mul * (2.0 ** -4.0)));
//        $monitor("res = %.5f\toutp=%.5f\t",$itor(res * (2.0 ** -38.0)),$itor(outp * (2.0 ** -38.0)));
		$monitor("pp1 = %.5f\t pp2=%.5f\t pp3=%.5f\t pp4=%.5f\t pp5=%.5f\t temp=%.5f\tres=%.5f\t res_bin = %b\toutp=%.5f\toutp=%b\t",$itor(pp1*(2.0 ** -4.0)), $itor(pp2 *(2.0 ** -8.0)), $itor(pp3 * (2.0 ** -12.0)), $itor(pp4 * (2.0 ** -16.0)), $itor(pp5*(2.0 ** -20.0)), $itor(temp*(2.0 ** -20.0)),$itor(res*(2.0 ** -26.0)),res,$itor(outp*(2.0 ** -38.0)),outp);
	end

	assign outp = res;
endmodule
