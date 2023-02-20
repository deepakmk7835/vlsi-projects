`timescale 1ns/1ps

//Baud Rate = 9600 bits per sec
//FPGA Clock = 100MHz
//Clock Cycles Per Bit = 100000000/9600 = 10417

module UARTRX #(
	parameter DATA_WIDTH = 8,
	parameter CLOCKS_PER_BIT = 10417
)(
	input clk,
	input rst,
	input UART_RX 
);

localparam IDLE = 2'b00,
           RX   = 2'b01,
           STOP = 2'b10;

reg [DATA_WIDTH-1:0]rxBuff;
reg [$clog2(DATA_WIDTH)-1:0]dataBits;
reg [$clog2(10417)-1:0]count;
reg [$clog2(DATA_WIDTH)-1:0]index;
reg uartRxReg;
wire fallEdgeDetected;
reg startCount;

reg [1:0]pState;

assign startBitDetected = ~UART_RX && uartRxReg;
assign stopBitDetected = UART_RX && ~uartRxReg;

always@(posedge clk)begin
	uartRxReg <= UART_RX;
end


always@(posedge clk)begin
	if(rst)begin
		count <= 'h0;
		index <= 'h0;
		dataBits <= 'h0;
	end else begin
		case(pState)
			`IDLE: begin
				if(startBitDetected) begin
					if(count < (CLOCKS_PER_BIT/2)-1)begin
						count <= count + 1'b1;
						pState <= `IDLE;
					end else if(count == (CLOCKS_PER_BIT/2)-1)begin
						count <= 'h0;
						pState <= `RX;
					end
				end
			end

			`RX: begin
				if(dataBits < (DATA_WIDTH-1) && count < CLOCKS_PER_BIT-1)begin
					count <= count + 1'b1;
					pState <= `RX;
				end else if(dataBits < (DATA_WIDTH-1) && count == CLOCKS_PER_BIT-1)begin
					count <= 'h0;
					rxBuff[index] <= UART_RX;
					index <= index + 1'b1;
					dataBits <= dataBits + 1'b1;
					pState <= `RX;
				end else begin
					dataBits <= 'h0;
					index <= 'h0;
					pState <= `STOP;
				end
			end

			`STOP: begin
				if(stopBitDetected)begin
					pState <= `IDLE;
				end
			end
		endcase
	end
end

endmodule
