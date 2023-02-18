`timescale 1ns/1ps

module I2CSlave #(
	parameter DATA_WIDTH = 8,
	parameter SLV_ADDR = 10
)(
    input rst,
	input sclk,
	input dclk,
	inout sda
);

localparam IDLE     =    11'b000000_0000_1,
        START       =    11'b000000_0001_0,
        SLVADDR     =    11'b000000_0010_0,
        ADDRACK     =    11'b000000_0100_0,
        REGADDR     =    11'b000000_1000_0,
        REGACK      =    11'b000001_0000_0,
        DATARECV    =    11'b000010_0000_0,
        DATAACK     =    11'b000100_0000_0,
        DATASEND    =    11'b001000_0000_0,
        DATASENTACK =    11'b010000_0000_0,
        STOP        =    11'b100000_0000_0;

 reg [31:0]regFile[31:0]; //32 Register, each 32-bit wide
 reg [10:0] pState, nState;

 reg [7:0]regAddress;
 reg [6:0]slvAddr;
 
 reg [4:0]T;

 reg [DATA_WIDTH-1:0]dataOut;
 reg [DATA_WIDTH-1:0]dataReg;
 reg sdaReg;
 
 reg sdaV2;

 reg readEn;
 reg writeEn;
 reg dataAck;
 
 wire fallEdgeDetected;
 wire riseEdgeDetected;
 
 integer count;

assign sda = sdaReg;
assign fallEdgeDetected = sdaV2 && ~sda;
assign riseEdgeDetected = ~sdaV2 && sda;

initial begin
    regFile[1] <= 32'd3;
end

always@(posedge dclk)begin
    sdaV2 <= sda;
end

 always@(posedge dclk)begin
	 if(readEn)begin
		dataOut <= regFile[regAddress];
	 end
	 
	 if(writeEn)begin
		 regFile[regAddress] <= dataReg;
	 end
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

 always@(*)begin
	 nState = pState;
		 case(pState)
			 IDLE: begin
				nState = START;
			 end

			 START: begin
				 if(fallEdgeDetected)begin
					 nState = SLVADDR;
				 end					 
			 end

			 SLVADDR: begin
				if(count == T-1)
		       		nState = ADDRACK;			
			 end

			 ADDRACK: begin
				 if(count == T-1)
					 nState = REGADDR;
			 end

			 REGADDR: begin
				 if(count == T-1)
					 nState = REGACK;
			 end

			 REGACK: begin
				 if(count == T-1)begin
					 if(writeEn)
					 	nState = DATARECV;
					 else if(readEn)
						 nState = DATASEND;
				end	
			 end

			 DATARECV: begin
				 if(count == T-1)
					 nState = DATAACK;
			 end

			 DATAACK: begin
				 if(count == T-1)
					 nState = STOP;
			 end

			 DATASEND: begin
				if(count == T-1)
				       nState = DATASENTACK;	       
			 end

			 DATASENTACK: begin
				 if(count == T-1)begin
				 	dataAck = sda;
					 nState = STOP;
				 end
			 end

			 STOP: begin
			     if(riseEdgeDetected)
				    nState = START;
			 end
			 
		 endcase
 end

 always@(posedge dclk or posedge rst)begin
	 if(rst)begin
		 pState <= IDLE;
	 end else begin
		 pState <= nState;
	 end 
 end

always@(*)begin
	 if(rst)begin
		 sdaReg = 'bz;
	 end else begin
		 case(pState)
		     IDLE: begin
		      sdaReg = 'bz;
		     end
		     
		     START: begin
		      sdaReg = 'bz;
		     end
		     
			 SLVADDR: begin
				 T = 8;
				 if(count <= T-2)begin //Receive SLAVEADDR 7-bit wide
					slvAddr[6-count] = sda;
				end else if(sda) begin //check whether it is a write request or read request
				 	readEn = 1;
				 	writeEn = 0;
				end else begin
					writeEn = 1;
					readEn = 0;
				end	
			 end

			 ADDRACK: begin
				 T = 1;
				 if(slvAddr ==  SLV_ADDR) //If SLVADDR matches current device address then send ACK
				 	sdaReg = 1'b0; //ACK
				 else 
					 sdaReg = 1'b1;//NACK
			 end

			 REGADDR: begin
				 T = 8;
				 sdaReg = 'bz;
				 if(count <= T-1)begin
					 regAddress[7-count] = sda;
			     end
			 end

			 REGACK: begin
				 T = 1;
				 if(regAddress >= 0 && regAddress < 8'd32) //If SLVADDR matches current device address then send ACK
				 	sdaReg = 1'b0; //ACK
				 else 
					 sdaReg = 1'b1;//NACK
			 end

			 DATARECV: begin
				 T = 8;
				 sdaReg = 'bz;
				 if(count <= T-1)
					 dataReg[7-count] = sda;
			 end

			 DATAACK: begin
				 T = 1;
				 sdaReg = 1'b0;
			 end

			 DATASEND: begin
				 T = 8;
				 sdaReg = dataOut[7-count];
			 end

			 DATASENTACK: begin
				 T = 1;
				 sdaReg = 'bz;
			 end

			 STOP: begin
				 T = 1;
				 sdaReg = 'bz;
			 end
			 
		 endcase
	 end
 end


endmodule

