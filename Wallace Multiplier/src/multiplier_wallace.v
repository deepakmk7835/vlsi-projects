`timescale 1ns / 1ps

module multiplier_wallace(
    input clk,
    input [3:0] a,
    input [3:0] b,
    output [7:0] prod
    );
    
    reg [3:0] a_reg = 0;
    reg [3:0] b_reg = 0;
    reg [7:0] prod_reg = 0;
    
    wire [3:0] part_prod [3:0];
    
    wire [7:0] final_prod;
    
    wire [4:0] carry;
    
    always@(posedge clk)
    begin
        a_reg <= a;
        b_reg <= b;
        prod_reg <= final_prod;
    end
   
      
    //Calculation of partial product
    partial_product pp1 (.a(a_reg), .b(b_reg[0]), .pp(part_prod[0]));
    partial_product pp2 (.a(a_reg), .b(b_reg[1]), .pp(part_prod[1]));
    partial_product pp3 (.a(a_reg), .b(b_reg[2]), .pp(part_prod[2]));
    partial_product pp4 (.a(a_reg), .b(b_reg[3]), .pp(part_prod[3]));
    
    //Addition of partial product
    
    assign final_prod[0] = part_prod[0][0];
    assign {carry[0],final_prod[1]} = part_prod[0][1] + part_prod[1][0];
    assign {carry[1],final_prod[2]} = part_prod[0][2] + part_prod[1][1] + part_prod[2][0] + carry[0];
    assign {carry[2],final_prod[3]} = part_prod[0][3] + part_prod[1][2] + part_prod[2][1] + part_prod[3][0] + carry[1];
    assign {carry[3],final_prod[4]} = part_prod[1][3] + part_prod[2][2] + part_prod[3][1] + carry[2];
    assign {carry[4],final_prod[5]} = part_prod[2][3] + part_prod[3][2] + carry[3];
    assign final_prod[7:6] = part_prod[3][3] + carry[4];
    
    assign prod = prod_reg;
endmodule
