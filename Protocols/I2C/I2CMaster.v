`timescale 1ns/1ps

`define IDLE    9'b0000_0000_1
`define START   9'b0000_0001_0
`define SLVADDR 9'b0000_0010_0
`define ADDRACK 9'b0000_0100_0
`define REGADDR 9'b0000_1000_0
`define REGACK  9'b0001_0000_0
`define DATA    9'b0010_0000_0
`define DATAACK 9'b0100_0000_0
`define STOP    9'b1000_0000_0

module I2CMaster #(
	parameter DATA_WIDTH = 8
)(
	input clk,
	input dclk,
	input rst,
	input wrEn,
	input [DATA_WIDTH-1:0]dataIn,
	input [DATA_WIDTH-1:0]slvAddr,
	input [DATA_WIDTH-1:0]regAddr,
	inout [DATA_WIDTH-1:0]sda,
	output sclk
);

reg [8:0]pState, nState;

reg sdaReg;
reg sclkReg;
reg noSdaAccess;

reg [DATA_WIDTH-1:0]SLV_ADDRESS;
reg [DATA_WIDTH-1:0]REG_ADDRESS;
reg [DATA_WIDTH-1:0]SLV_DATA;

assign sda = !noSdaAccess ? sdaReg : 8'bZZZZ_ZZZZ;
assign sclk = sclkReg;

reg [$clog2(DATA_WIDTH)-1:0]count;
reg [3:0]T;

always@(posedge dclk)begin
    if(wrEn)
        SLV_DATA <= dataIn;
    
    SLV_ADDRESS <= slvAddr;
    REG_ADDRESS <= regAddr;
end

always@(posedge dclk)begin
	if(rst)begin
		count <= 'h0;
	end else if(count < T-1)begin
		count <= count + 1'b1;
	end else begin
		count <= 'h0;
	end
end

reg [2:0]SPI_ACK;

//Next State Logic
always@(*)begin
	if(rst)begin
		nState <= `IDLE;
	end else begin
		case(pState)
			`IDLE: begin
				if(wrEn)
					nState <= `START;
			end

			`START: begin
				if(count == T-1)
					nState <= `SLVADDR; 
			end
			
			`SLVADDR: begin
				if(count == T-1)begin
					nState <= `ADDRACK;
				end				
			end

			`ADDRACK: begin
				if(count == T-1)begin
					SPI_ACK[0] <= sda;
					nState <= `REGADDR;
				end
			end

			`REGADDR: begin
				if(count == T-1)begin
					nState <= `REGACK;
				end
			end

			`REGACK: begin
				if(count == T-1)begin
					SPI_ACK[1] <= sda;
					nState <= `DATA;
				end
			end

			`DATA: begin
				if(count == T-1)begin
			               nState <= `DATAACK;
			       end	       
			end

			`DATAACK: begin
				if(count == T-1)begin	
					SPI_ACK[2] <= sda;
					nState <= `STOP;
				end
			end

			`STOP: begin
				if(count == T-1)
					nState <= `IDLE;	
			end
		endcase
	end
end

always@(posedge dclk)begin
	if(rst)begin
		pState <= `IDLE;
	end else begin
		pState <= nState;
	end
end

always@(*)begin
	if(rst)begin
		sdaReg <= 0;
		sclkReg <= 0;
		noSdaAccess <= 0;
	end else begin
		case(pState)
			`IDLE: begin
				sdaReg <= 1;
				sclkReg <= 1;
				T <= 4'd1;
				noSdaAccess <= 0;
			end 

			`START: begin
				sdaReg <= dclk;
				sclkReg <= 1;
				T <= 4'd1;
				noSdaAccess <= 0;
			end

			`SLVADDR: begin
				sclkReg <= clk;
				sdaReg <= SLV_ADDRESS[7-count];
				T <= 4'd8;
				noSdaAccess <= 0;
			end

			`ADDRACK: begin
				T <= 4'd1;
				sclkReg <= clk;
				noSdaAccess <= 1;
			end

			`REGADDR: begin
				sclkReg <= clk;
				sdaReg <= REG_ADDRESS[7-count];
				T <= 4'd8;
				noSdaAccess <= 0;
			end

			`REGACK: begin
				T <= 4'd1;
				sclkReg <= clk;
				noSdaAccess <= 1;
			end

			`DATA: begin
				sclkReg <= clk;
				sdaReg <= SLV_DATA[7-count];
				T <= 4'd8;
				noSdaAccess <= 0;
			end

			`DATAACK: begin
				T <= 4'd1;
				sclkReg <= clk;
				noSdaAccess <= 1;
			end

			`STOP: begin
				T <= 4'd1;
				sclkReg <= 1;
				sdaReg <= dclk;
				noSdaAccess <= 0;
			end
		endcase
	end
end

endmodule


