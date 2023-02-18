`timescale 1ns/1ps

`define IDLE 2'b00
`define TX   2'b01
`define RX   2'b10

module SPIMaster #(
	parameter DATA_WIDTH = 8
)(
	input clk,
	input rst,
	input [DATA_WIDTH-1:0]dataIn,
	input newTXN,
	input wrEn, //1-Write TXN, 0-Read TXN
	input miso,
	output mosi,
	output sclk,
	output cs
);

 reg [DATA_WIDTH:0]dataInReg;
 reg [1:0]pState, nState;
 reg [$clog2(DATA_WIDTH):0]count;
 reg mosiReg;
 reg csReg;
 reg sclkReg;
 reg [DATA_WIDTH-1:0]misoData;
 reg [3:0]T;

 assign mosi = mosiReg;
 assign sclk = sclkReg;
 assign cs = csReg;

 always@(negedge clk) begin
	 if(rst)begin
		 dataInReg <= 'h0;
	 end else if(wrEn) begin
		 dataInReg <= {wrEn,dataIn};
	 end
 end

 always@(negedge clk)begin
	 if(rst)begin
		 count <= 'h0;
	 end else if(count < T-1)begin
		 count <= count + 1'b1;
	 end else begin
		 count <= 'h0;
	 end
 end

//Next State Logic

always@(*)begin
	nState = pState;
	case(pState)
		`IDLE: begin
			if(newTXN && wrEn)begin
				nState = `TX;
			end else if(newTXN && ~wrEn) begin
				nState = `RX;
			end
		end

		`TX: begin
			if(count == T-1)begin
				nState = `IDLE;
			end
		end
		
		`RX: begin
			if(count == T-1)begin
				nState = `IDLE;
			end
		end
	endcase	
end

always@(negedge clk or posedge rst)begin
	if(rst)begin
		pState <= `IDLE;
	end else begin
		pState <= nState;
	end
end

//Output Logic

always@(*)begin
	if(rst)begin
		mosiReg = 0;
	end else begin
		case(pState)
			`IDLE: begin
				sclkReg = 1;
				csReg = 1;
			end

			`TX: begin
				sclkReg = clk;
				csReg = 0;
				T = 9;
				mosiReg = dataInReg[8-count];
			end

			`RX: begin
				sclkReg = clk;
				csReg = 0;
				T = 8;
				misoData[7-count] = miso;
			end
		endcase
	end
end

endmodule
