`timescale 1ns / 1ps

//MOORE MACHINE APPROACH//
module division(
    input clk,
    input rst,
    input [15:0] xin,
    input [15:0] yin,
    input inp_valid,
    output outp_valid,
    output [15:0] quotient
    );
    
    `define INIT 2'b00
    `define CALC 2'b01
    `define UNDO 2'b10
    `define DONE 2'b11
    
    reg [2:0] state;
    
    reg [15:0] xin_reg;
    reg [15:0] yin_reg;
    
    reg outp_valid_reg;
    reg [15:0] quotient_reg;
    
    assign outp_valid = outp_valid_reg;
    assign quotient = quotient_reg;
    
    always@(posedge clk)
    begin
        if(rst) begin
            quotient_reg <= 16'h0;
            outp_valid_reg <= 1'b0;
            state <= `INIT;
        end else begin
            case(state)
            `INIT: begin
                xin_reg <= xin;
                yin_reg <= yin;
                quotient_reg <= 16'h0;
                if(inp_valid) begin
                    state <= `CALC;
                end
            end
            
            `CALC: begin
                xin_reg <= xin_reg - yin_reg; 
                quotient_reg <= quotient_reg + 1;
                if(xin_reg >= yin_reg) begin
                    state <= `CALC;
                end else begin
                    state <= `UNDO;
                end
            end
            
            `UNDO: begin
                xin_reg <= xin_reg + yin_reg;
                quotient_reg <= quotient_reg - 1;
                state <= `DONE;
            end
            
            `DONE: begin
                outp_valid_reg <= 1'b1;
                state <= `INIT;
            end
            
            default: begin
                state <= `INIT;
            end
            endcase
            
        end
    end
    
    
endmodule
