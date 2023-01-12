module top(
    input clk,
    input rst,
    output [159:0] final_result_flat,
    output [19:0] nzcv_flags_flat
    );
    
    //wire [15:0] PCf[4:0];
    wire [31:0] IRf[4:0];
    
    wire [31:0] final_result[4:0];
    wire [3:0] nzcv_flags[4:0];
    
//    reg [15:0] pc_0 = 0;
//    reg [15:0] pc_1 = 0;
//    reg [15:0] pc_2 = 0;
//    reg [15:0] pc_3 = 0;
//    reg [15:0] pc_4 = 0;
    
    reg [15:0] pc[4:0];
    
    reg [31:0] inst_reg[4:0];
    
    wire [15:0] jump_addr [4:0];
    wire [4:0]jump_detected;
    wire [4:0]rsta_busy;
    
    
    
    //Program memory 65K depth, 4Bytes wide memory i.e. 260KB ROM
//    blk_mem_gen_1 ROM_1 (.clka(clk), .addra(PCf[0]), .douta(IRf[0]));
//    blk_mem_gen_1 ROM_2 (.clka(clk), .addra(PCf[1]), .douta(IRf[1]));
//    blk_mem_gen_1 ROM_3 (.clka(clk), .addra(PCf[2]), .douta(IRf[2]));
//    blk_mem_gen_1 ROM_4 (.clka(clk), .addra(PCf[3]), .douta(IRf[3]));
//    blk_mem_gen_1 ROM_5 (.clka(clk), .addra(PCf[4]), .douta(IRf[4]));
    
    reg [15:0]pc_reg1[4:0];
    reg [15:0]pc_reg2[4:0];
    reg [15:0]pc_reg3[4:0];
    
    reg inst_valid[4:0];
    genvar i;
    
    generate 
        for(i=0; i < 5; i = i+1) begin :pc_loop
            always@(posedge clk) begin
                if(rst || rsta_busy[i]) begin
                    inst_reg[i] <= 32'h0;
                    pc[i] <= 16'h0;
                    pc_reg1[i] <= 16'h0;
                    pc_reg2[i] <= 16'h0;
                    pc_reg3[i] <= 16'h0;
                    inst_valid[i] <= 0;
                end else if(jump_detected[i]) begin
                    pc[i] <= jump_addr[i];
                    pc_reg1[i] <= pc[i];
                    pc_reg2[i] <= pc_reg1[i];
                    pc_reg3[i] <= pc_reg2[i];
                    inst_reg[i] <= IRf[i];
                    inst_valid[i] <= 1;
                end else begin
                    inst_reg[i] <= IRf[i];
                    pc[i] <= pc[i] + 1'b1;
                    pc_reg1[i] <= pc[i];
                    pc_reg2[i] <= pc_reg1[i];
                    pc_reg3[i] <= pc_reg2[i];
                    inst_valid[i] <= 1;
                end
            end
        end
    endgenerate
    
    
    //Program memory 65K depth, 4Bytes wide memory i.e. 260KB ROM
    genvar j;
    
    generate
        for(j=0; j < 5; j = j+1) begin :ROM
            blk_mem_gen_1 ROM (.clka(clk), .rsta(rst), .rsta_busy(rsta_busy[j]), .addra(pc_reg3[j]), .douta(IRf[j]));
        end 
    endgenerate
            
//    always@(posedge clk)
//     begin
////        if() begin
////           inst_reg[0] <= IRf[0];
////           pc_0 <= pc + 1;
////        end else begin
////            pc <= jump_addr;
////            inst_reg <= IRf;
////        end
        
//    end
    
    PE_final agent_1(.clk(clk), .rst(rst), .inst(inst_reg[0]), .inst_valid(inst_valid[0]), .final_result(final_result[0]), .nzcv_flags(nzcv_flags[0]), .jump_detected(jump_detected[0]), .jump_addr(jump_addr[0]));
    PE_final agent_2(.clk(clk), .rst(rst), .inst(inst_reg[1]), .inst_valid(inst_valid[1]), .final_result(final_result[1]), .nzcv_flags(nzcv_flags[1]), .jump_detected(jump_detected[1]), .jump_addr(jump_addr[1]));
    PE_final agent_3(.clk(clk), .rst(rst), .inst(inst_reg[2]), .inst_valid(inst_valid[2]), .final_result(final_result[2]), .nzcv_flags(nzcv_flags[2]), .jump_detected(jump_detected[2]), .jump_addr(jump_addr[2]));
    PE_final agent_4(.clk(clk), .rst(rst), .inst(inst_reg[3]), .inst_valid(inst_valid[3]), .final_result(final_result[3]), .nzcv_flags(nzcv_flags[3]), .jump_detected(jump_detected[3]), .jump_addr(jump_addr[3]));
    PE_final agent_5(.clk(clk), .rst(rst), .inst(inst_reg[4]), .inst_valid(inst_valid[4]), .final_result(final_result[4]), .nzcv_flags(nzcv_flags[4]), .jump_detected(jump_detected[4]), .jump_addr(jump_addr[4]));        
            
    assign final_result_flat = {final_result[0], final_result[1], final_result[2], final_result[3], final_result[4]};
    assign nzcv_flags_flat = {nzcv_flags[0], nzcv_flags[1], nzcv_flags[2], nzcv_flags[3], nzcv_flags[4]};        
//    assign PCf = pc;
    
endmodule
