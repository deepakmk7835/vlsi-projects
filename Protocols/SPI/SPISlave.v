`timescale 1ns/1ps

module SPISlave #(
	parameter DATA_WIDTH = 8
)(
	input sclk,
	input rst,
	input mosi,
	input cs,
	output miso
);

localparam IDLE = 2'b00,
	DATA_RX = 2'b01,
	DATA_TX = 2'b10;

reg misoReg;
reg [DATA_WIDTH-1:0]dataOut;
reg [DATA_WIDTH-1:0]mosiData;
reg [3:0]T;

reg [1:0]pState, nState;

reg [$clog2(DATA_WIDTH)-1:0]count;

assign miso = misoReg;

initial begin
	dataOut = 8'd12;
end

always@(posedge sclk)begin
	if(rst)begin
		count <= 'h0;
	end else if(count < T-1)begin
		count <= count + 1'b1;
	end else begin
		count <= 'h0;
	end 
end

always@(*)begin
	nState = pState;
	case(pState)
		IDLE: begin
			if(!cs && ~mosi)
				nState = DATA_TX;
			else if(!cs && mosi)
				nState = DATA_RX;
		end

		DATA_TX: begin
			if(count == T-1)begin
				nState = IDLE;
			end
		end

		DATA_RX: begin
			if(count == T-1)begin
				nState = IDLE;
			end
		end
	endcase
end

always@(posedge sclk or posedge rst)begin
	if(rst)begin
		pState <= IDLE;
	end else begin
		pState <= nState;
	end
end

always@(*)begin
	if(rst)begin
		misoReg <= 0;
	end else begin
		case(pState)
			DATA_RX: begin
			     T = 8;
				mosiData[7-count] = mosi;
			end

			DATA_TX: begin
			     T = 8;
				misoReg = dataOut[7-count];
			end
		endcase
	end
end

endmodule
