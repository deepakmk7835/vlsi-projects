`timescale 1ns / 1ps
module PE_final(
    input clk,
    input rst,
    input [31:0] inst, //Instruction comes from ROM from TOP module
    input inst_valid,
    output reg [31:0]final_result,
    output reg [3:0]nzcv_flags,
    output reg jump_detected,
    output reg [15:0]jump_addr
    );
    
    //processor will contain 32GPRs
    reg [15:0] gpreg[31:0];
    
    reg [31:0] inst_s1, inst_s2;
    
    //using define directive to divide 32-bit instruction
    
    `define opcode      inst[31:27]
    `define dest  	    inst[26:22]
    `define src1   	    inst[21:17]
    `define src2    	inst[15:11]
    `define mode_sel    inst[16]

    //`define mode_sel_s2 inst_s2[16]
    
//    //define directive for load-store instructions
    
    `define addr_imm    inst[21:11]
    `define addr_reg    inst[21:17]
    `define str_data    inst[26:22]
    
    //Instruction opcode
    
    `define MOV             5'b00000
    `define ADD             5'b00001
    `define SUB             5'b00010
    `define MUL             5'b00011
    `define LOAD_MEM_I      5'b00100
    `define LOAD_MEM_REG    5'b00101
    `define STORE_MEM_I     5'b00110
    `define STORE_MEM_REG   5'b00111
    `define JMP             5'b01000
    `define DIV             5'b01001
    `define AND             5'b01010
    `define OR              5'b01011
    `define NOT             5'b01100
    `define XOR             5'b01101
    `define NAND            5'b01110
    `define NOR             5'b01111
    `define XNOR            5'b10000
    `define NOP             5'b11111
    
    
    reg [15:0] pc=0;
        
    wire [15:0] PCf;
    wire [31:0] IRf;
    
    wire [10:0] addrn;
    wire we;
    wire [15:0] data_in;
    wire [15:0] data_out;
    
    reg [10:0] addr_reg=0;
    reg we_reg=0;
    reg [15:0] data_in_reg=0;

    reg [4:0] opcode_s1, opcode_s2;
    reg [4:0] dest_s1, dest_s2, dest_s3;

    //Data memory 2K depth, 2Bytes wide memory i.e. 4KB RAM, helps in load/store of temp data
    blk_mem_gen_0 RAM (.clka(clk), .addra(addrn) , .wea(we), .dina(data_in), .douta(data_out));

    reg [15:0] src1_s1, src2_s1;
    reg [15:0] src1_s2, src2_s2;

    always@(posedge clk)
	begin
		if(rst) begin
			inst_s1 <= 'h0;
			inst_s2 <= 'h0;
		end else begin
			inst_s1 <= inst;
			inst_s2 <= inst_s1;
		end
	end

    
	//STAGE 1 (DECODE)
   //In this stage 32-bit instruction will decoded to get src1, src1, dest,
   //opcode
   //Lets divide the DECODE STAGE into 2 STAGES (extract opcode and dest in
   //1 cycle) and lets call sub-stage 1 as pre-decode
   //In 2nd stage (extract src1 and src2) lets call sub-stage 2 as decode
   //Every new instruction will be decoded in 2 cycles
   //cycle 1 ----- dest, opcode
   //cycle 2 ----- src1, src2
   //

reg input_valid;
 wire [31:0] result;
 //Conditional flags (N-Negative, Z-Zero, C-Carry, V-Overflow)
 wire [3:0] nzcv;

   //ALU submodule
   ALU alu1 (.clk(clk), .rst(rst), .src1(src1_s1), .src2(src2_s1), .input_valid(input_valid), .opcode(opcode_s2), .result_reg_final(result), .nzcv_reg_final(nzcv));

 
//STAGE1 (2 Cycles)
//SUB_STAGE1 - PRE-DECODE
//

//reg [4:0]  opcode_s2;
reg [31:0] result_s3;
reg [15:0] imm_data;

always@(posedge clk)
begin
	if(inst_valid) begin
	opcode_s1 <= `opcode;
	opcode_s2 <= opcode_s1;
	dest_s1 <= `dest;
	imm_data <= inst[15:0];
	src1_s1 <= (`mode_sel)?inst[15:0]:gpreg[`src1];
	src2_s1 <= (`mode_sel)?inst[15:0]:gpreg[`src2];
	end
	
	result_s3 <= result;
	final_result <= result_s3;
	nzcv_flags <= nzcv;
end

integer i;

always@(posedge clk)
begin
	if(rst) begin
		for(i=0; i< 32;i = i+1) begin //Use concatination, remove for loop
                    gpreg[i] <= 0;
                end
	end else if(inst_valid) begin
		case(opcode_s1)	
		`MOV: begin
			gpreg[dest_s1] <= imm_data;

		end
		
		`ADD: begin
			input_valid <= 1;
			gpreg[dest_s1] <= result;
		end
		
		`SUB: begin
              gpreg[dest_s1] <= result_s3;
          end
          
          `MUL: begin
              gpreg[dest_s1] <= result_s3;
          end
          
          `DIV: begin
              gpreg[dest_s1] <= result_s3; //Only quotient
          end
          
          `LOAD_MEM_I: begin                           //loadi r0, #addr_imm
              we_reg <= 1'b0;
              addr_reg <= `addr_imm;
              gpreg[dest_s1] <= data_out;
          end
          
          `LOAD_MEM_REG: begin                         //loadreg r0, r1
              we_reg <= 1'b0;
              addr_reg <= gpreg[`addr_reg];
              gpreg[dest_s1] <= data_out;
          end
          
          `STORE_MEM_I: begin
              we_reg <= 1'b1;
              addr_reg <= `addr_imm;
              data_in_reg <= gpreg[`src1];
          end
          
          `STORE_MEM_REG: begin
              we_reg <= 1'b1;
              addr_reg <= gpreg[`addr_reg];
              data_in_reg <= gpreg[`str_data];
          end
          
          `JMP: begin
              jump_addr <= inst_s1[15:0];
              jump_detected <= 1'b1;
          end
          
          `AND: begin
              gpreg[dest_s1] <= result_s3;
          end
          
          `OR: begin
              gpreg[dest_s1] <= result_s3;
          end
          
          `NOT: begin
              gpreg[dest_s1] <= result_s3;
          end
          
          `XOR: begin
              gpreg[dest_s1] <= result_s3;
          end
          
          `NOR: begin
              gpreg[dest_s1] <= result_s3;
          end
          
          `NAND: begin
              gpreg[dest_s1] <= result_s3;
          end
          
          `XNOR: begin
              gpreg[dest_s1] <= result_s3;
          end
          
          `NOP: begin
              we_reg <= 1'b0;
              gpreg[dest_s1] <= 32'h0;
          end
          
          default: begin
              gpreg[dest_s1] <= 32'h0;
          end
          
          endcase
	end
end

endmodule
