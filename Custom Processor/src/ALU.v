`timescale 1ns / 1ps


module ALU(
    input clk,
    input rst,
    input [4:0] opcode,
    input input_valid,
    input [15:0] src1,
    input [15:0] src2,
    output reg [31:0] result_reg_final,
    output reg [3:0]nzcv_reg_final
    );
        
    //Instruction opcode
    
    `define ADD             5'b00001
    `define SUB             5'b00010
    `define MUL             5'b00011
    `define DIV             5'b01001
    `define AND             5'b01010
    `define OR              5'b01011
    `define NOT             5'b01100
    `define XOR             5'b01101
    `define NAND            5'b01110
    `define NOR             5'b01111
    `define XNOR            5'b10000
    
    reg carry_bit;
    
//    reg [31:0] result_reg = 0;
//    reg [3:0] nzcv_reg = 0;
    
    reg [31:0] result_reg;
    reg [4:0] nzcv_reg;
    
    wire inp_valid, start, outp_valid;
    wire [15:0] quotient;
    
    reg inp_valid_reg = 0, start_reg;
    //reg [31:0] quotient_reg;
    
    division div_uut (.clk(clk), .rst(rst), .inp_valid(inp_valid), .outp_valid(outp_valid), .xin(src1), .yin(src2), .quotient(quotient));
    
    assign inp_valid = inp_valid_reg;
    
    reg [15:0] src1_reg, src2_reg, temp1, temp2;
    reg [31:0] prod, prod_reg, prod_reg_s2;
    
    always@(posedge clk) begin
        if(rst) begin
            prod <= 32'h0;
            prod_reg <= 32'h0;
        end else begin
            src1_reg <= src1;
            src2_reg <= src2;
            prod <= src1_reg * src2_reg;
            result_reg_final <= result_reg;
            nzcv_reg_final <= nzcv_reg;
        end
    end
    
    always @ (*)
        begin
        if(rst) begin
            inp_valid_reg = 0;
            result_reg = 'h0;
            nzcv_reg = 'h0;
        end else if(input_valid)begin
            case (opcode)            
            `ADD: begin
                inp_valid_reg = 0;
                {carry_bit,result_reg[15:0]} = src1 + src2;
                nzcv_reg = {result_reg[15], ~|result_reg, carry_bit, !src1[15] && !src2[15] && result_reg[15] ||
                                 src1[15] && src2[15] && !result_reg[15]};
            end
            
            `SUB: begin
                inp_valid_reg = 0;
                {carry_bit,result_reg[15:0]} = src1 - src2;
                nzcv_reg = {result_reg[15], ~|result_reg, carry_bit, !src1[15] && src2[15] && !result_reg[15] ||
                                 src1[15] && !src2[15] && result_reg[15]};
            end
            
            `MUL: begin
               inp_valid_reg = 0;
               result_reg = prod;
               nzcv_reg = {result_reg[15], ~|result_reg, 1'b0, 1'b0};
            end
            
            `DIV: begin
                inp_valid_reg = 1'b1;
                if(outp_valid) begin
                    result_reg = quotient;
                    inp_valid_reg = 1'b0;
                end else begin
                    result_reg = 'h0;
                end
                nzcv_reg = {1'b0, ~|result_reg, 1'b0, 1'b0};
            end
            
            `AND: begin
                inp_valid_reg = 0;
                result_reg = src1 & src2;
                nzcv_reg = 4'b0000;
            end
            
            `OR: begin
                inp_valid_reg = 0;
                result_reg = src1 | src2;
                nzcv_reg = 4'b0000;
            end
            
            `NOT: begin
                inp_valid_reg = 0;
                result_reg = ~src1;
                nzcv_reg = 4'b0000;
            end
            
            `XOR: begin
                inp_valid_reg = 0;
                result_reg = src1 ^ src2;
                nzcv_reg = 4'b0000;
            end
            
            `NOR: begin
                result_reg = ~(src1 | src2);
                inp_valid_reg = 0;
                nzcv_reg = 4'b0000;
            end
            
            `NAND: begin
                inp_valid_reg = 0;
                result_reg = ~(src1 & src2);
                nzcv_reg = 4'b0000;
            end
            
            `XNOR: begin
                inp_valid_reg = 0;
                result_reg = ~(src1 ^ src2);
                nzcv_reg = 4'b0000;
            end
            
            default: begin
                inp_valid_reg = 0;
                result_reg = 32'h0;
                nzcv_reg = 4'b0000;
            end
            
            endcase
        end
    end
    
    //assign result = result_reg;
    //assign nzcv = nzcv_reg;
    
endmodule
