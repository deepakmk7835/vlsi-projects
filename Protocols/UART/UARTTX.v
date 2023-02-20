`timescale 1ns/1ps

//Baud Rate = 9600 bits per sec
//FPGA Clock = 100MHz
//Clock Cycles Per Bit = 100000000/9600 = 10417

module UARTTX #(
	parameter DATA_WIDTH = 8,
	parameter CLOCKS_PER_BIT = 10417
)(
	input clk,
	input rst,
	input wrEn,
	input [DATA_WIDTH-1:0]dataIn,
	input newTXN,
	output uartBus
);

localparam IDLE  = 2'b00,
           START = 2'b01,
           TX    = 2'b10,
           STOP  = 2'b11;

reg [DATA_WIDTH-1:0]dataInReg;
reg [$clog2(10417)-1:0]count;
reg [$clog2(DATA_WIDTH)-1:0]dataBits;
reg uartBusReg;

reg [1:0]pState;

always@(posedge clk)begin
	if(wrEn)
		dataInReg <= dataIn;
end

//Next State Logic

always@(posedge clk)begin
	if(rst) begin
		uartBusReg <= 1'b1;
		dataBits <= 'h0;
	end else begin
		case(pState)
			IDLE: begin
				uartBusReg <= 1'b1;
				if(newTXN)
					pState <= START;		
			end
	
			START: begin
				uartBusReg <= 1'b0;
				pState <= TX;
			end
	
			TX: begin
				if(count < CLOCKS_PER_BIT - 1 && dataBits <= DATA_WIDTH-1)begin
					count <= count + 1'b1;
					pState <= TX;
				end else if(count == CLOCKS_PER_BIT - 1 && dataBits <= DATA_WIDTH-1)begin
					uartBusReg <= dataInReg[dataBits];
					dataBits <= dataBits + 1'b1;
					count <= 'h0;
					pState <= TX;
				end else begin
					dataBits <= 'h0;
					count <= 'h0;
					pState <= STOP;
				end	
			end
	
			STOP: begin
				if(count < CLOCKS_PER_BIT - 1) begin
					count <= count + 1'b1;
					pState <= STOP;
				end else if(count == CLOCKS_PER_BIT - 1)begin
					uartBusReg <= 1'b1;
					count <= 'h0;
					pState <= IDLE;
				end
			end
		endcase
	end
end

endmodule
