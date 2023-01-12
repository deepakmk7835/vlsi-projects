`timescale 1ns / 1ps

module partial_product(
    input b,
    input [3:0]a,
    output [3:0]pp
    );
    
    assign pp[0] = b & a[0];
    assign pp[1] = b & a[1];
    assign pp[2] = b & a[2];
    assign pp[3] = b & a[3];
endmodule
