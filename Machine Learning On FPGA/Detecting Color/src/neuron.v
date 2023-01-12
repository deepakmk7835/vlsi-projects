module neuron #(
	parameter DATA_WIDTH = 8,
	parameter SIGMOID_DEPTH = 5
)(
	input clk,
	input rst,
	input [DATA_WIDTH-1:0]R,
	input [DATA_WIDTH-1:0]G,
	input [DATA_WIDTH-1:0]B,
	input [2*DATA_WIDTH-1:0]w1,
	input [2*DATA_WIDTH-1:0]w2,
	input [2*DATA_WIDTH-1:0]w3,
	input [2*DATA_WIDTH-1:0]bias,
	output [DATA_WIDTH-1:0]out
);

	reg [3*DATA_WIDTH:0] sum;
	reg [4:0]sum_2;
	
	reg [DATA_WIDTH-1:0]mem[2**SIGMOID_DEPTH-1:0];
	
	reg [SIGMOID_DEPTH-1:0]mem_addr,mem_addr1;
	
	//wire [SIGMOID_DEPTH-1:0]temp_sum;
	
	reg mem_addr_valid;

	initial begin
		$readmemb("sigmoid_init_values.mif",mem);
	end
	
	reg sum_valid;
	
	always@(posedge clk)
	begin
		if(rst)begin
			sum <= 'h0;
			sum_valid <= 0;
		end else begin
			sum <= (R * w1) + (G * w2) + (B * w3) + bias;
			sum_2 <= sum;
			sum_valid <= 1;
		end 
	end
	
	//assign temp_sum = sum[32:28];
	
	always@(posedge clk)
	begin
	   if(rst) begin
	       mem_addr1 <= 0;
	       mem_addr_valid <= 0;
	   end else if(sum_valid)begin
	       if($signed(sum) < -16) begin
               mem_addr1 <= 'h0;
               //temp_sum <= sum[4*DATA_WIDTH-:SIGMOID_DEPTH];
               mem_addr_valid <= 1;
           end else if($signed(sum) > 16)begin
               mem_addr1 <= 5'd31;
               //temp_sum <= sum[4*DATA_WIDTH-:SIGMOID_DEPTH];
               mem_addr_valid <= 1;
           end else begin
               mem_addr1 <= $signed(sum[4*DATA_WIDTH-:SIGMOID_DEPTH]) + 2**(SIGMOID_DEPTH-1);
//                mem_addr1 <= sum + 2**(SIGMOID_DEPTH-1);
               //temp_sum <= sum[14:10];
               mem_addr_valid <= 1;
           end
	   end else begin
	       mem_addr1 <= 0;
	       mem_addr_valid <= 0;
	   end
	end
	
	always@(posedge clk)
	begin
	   mem_addr <= (mem_addr_valid)?mem_addr1:{5{1'b0}};
	end

	assign out = mem[mem_addr];	

endmodule
