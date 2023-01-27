`timescale 1ns / 1ps

module top #(
    parameter DATA_WIDTH = 8,
    parameter IMG_WIDTH = 512
)(
    input clk,
    input rst,
    input [DATA_WIDTH-1:0]inPixel,
    input inPixelValid,
    output [DATA_WIDTH-1:0]outPixel,
    output outPixelValid,
    output rdBuffEmpty
);

    reg [3:0]buffInPixelValid;
    reg buffOutPixelReady[3:0];
    wire [3*DATA_WIDTH-1:0]buffOutPixel[3:0];
    reg [$clog2(IMG_WIDTH)-1:0]inPixelCount;
    reg [1:0]wrBuff,rdBuff;
    reg [$clog2(IMG_WIDTH)-1:0]outPixelCount;
    reg rdBuffEn;
    reg [$clog2(3*IMG_WIDTH)-1:0]rdBuffEnCount;
    reg rdBuffEmptyReg;
    reg [3*3*DATA_WIDTH-1:0]macInput;
    wire macInputValid;
    
    assign rdBuffEmpty = rdBuffEmptyReg;
    assign macInputValid = rdBuffEn;
    lineBuffer buff1(
        .clk(clk),
        .rst(rst),
        .inPixel(inPixel),
        .inPixelValid(buffInPixelValid[0]),
        .outPixelReady(buffOutPixelReady[0]),
        .outPixel(buffOutPixel[0])
    );
    
    lineBuffer buff2(
        .clk(clk),
        .rst(rst),
        .inPixel(inPixel),
        .inPixelValid(buffInPixelValid[1]),
        .outPixelReady(buffOutPixelReady[1]),
        .outPixel(buffOutPixel[1])
    );
    
    lineBuffer buff3(
        .clk(clk),
        .rst(rst),
        .inPixel(inPixel),
        .inPixelValid(buffInPixelValid[2]),
        .outPixelReady(buffOutPixelReady[2]),
        .outPixel(buffOutPixel[2])
    );
    
    lineBuffer buff4(
        .clk(clk),
        .rst(rst),
        .inPixel(inPixel),
        .inPixelValid(buffInPixelValid[3]),
        .outPixelReady(buffOutPixelReady[3]),
        .outPixel(buffOutPixel[3])
    );
    
    //Write Logic
    
    always@(posedge clk)begin
        if(rst)begin
            inPixelCount <= 'h0;
        end else if(inPixelValid)begin
            inPixelCount <= inPixelCount + 1'b1;
        end
    end
    
    always@(posedge clk)begin
        if(rst)begin
            wrBuff <= 'h0;
        end else if(inPixelValid && inPixelCount == IMG_WIDTH-1)begin
            wrBuff <= wrBuff + 1'b1;
        end
    end
    
    always@(*)begin
        buffInPixelValid = 'h0;
        buffInPixelValid[wrBuff] = inPixelValid;
    end
       
    //Read Logic
    
    always@(posedge clk)begin
        if(rst)begin
            rdBuffEnCount <= 'h0;
        end else if(inPixelValid && !rdBuffEn)begin
            rdBuffEnCount <= rdBuffEnCount + 1'b1;
        end else if(~inPixelValid && rdBuffEn)begin
            rdBuffEnCount <= rdBuffEnCount - 1'b1;
        end
    end
    
    always@(posedge clk)begin
        if(rst)begin
            rdBuffEn <= 1'b0;
        end else if(rdBuffEnCount >= 3*IMG_WIDTH-1)begin
            rdBuffEn <= 1'b1;
        end else if(outPixelCount == IMG_WIDTH-1)begin
            rdBuffEn <= 1'b0;
        end
    end
    
    always@(posedge clk)begin
        if(rst)begin
            rdBuff <= 1'b0;
        end else if(rdBuffEn && outPixelCount == IMG_WIDTH-1)begin
            rdBuff <= rdBuff + 1'b1;
        end
    end
    
    always@(posedge clk)begin
        if(rst)begin
            outPixelCount <= 'h0;
        end else if(rdBuffEn)begin
            outPixelCount <= outPixelCount + 1'b1;
        end
    end
    
    always@(*)begin
        if(rst)begin
            buffOutPixelReady[0] = 1'b0;
            buffOutPixelReady[1] = 1'b0;
            buffOutPixelReady[2] = 1'b0;
            buffOutPixelReady[3] = 1'b0;
        end else begin
            case(rdBuff)
            2'b00:begin
                buffOutPixelReady[0] = rdBuffEn;
                buffOutPixelReady[1] = rdBuffEn;
                buffOutPixelReady[2] = rdBuffEn;
                buffOutPixelReady[3] = 1'b0;
            end 
            
            2'b01:begin
                buffOutPixelReady[0] = 1'b0;
                buffOutPixelReady[1] = rdBuffEn;
                buffOutPixelReady[2] = rdBuffEn;
                buffOutPixelReady[3] = rdBuffEn;
            end
            
            2'b10:begin
                buffOutPixelReady[0] = rdBuffEn;
                buffOutPixelReady[1] = 1'b0;
                buffOutPixelReady[2] = rdBuffEn;
                buffOutPixelReady[3] = rdBuffEn;
            end
            
            2'b11:begin
                buffOutPixelReady[0] = rdBuffEn;
                buffOutPixelReady[1] = rdBuffEn;
                buffOutPixelReady[2] = 1'b0;
                buffOutPixelReady[3] = rdBuffEn;
            end
            endcase
        end
    end
    
    always@(posedge clk)begin
        if(rst)begin
            rdBuffEmptyReg <= 1'b0;
        end else if(rdBuffEn && outPixelCount == IMG_WIDTH-1)begin
            rdBuffEmptyReg <= 1'b1;
        end else begin
            rdBuffEmptyReg <= 1'b0;
        end
    end
    
    always@(*)
    begin
        if(rst)begin
            macInput = 'h0;
        end else begin
            case(rdBuff)
            2'b00:begin
                macInput = {buffOutPixel[2],buffOutPixel[1],buffOutPixel[0]};
//                macInputValid = 1'b1;
            end
            
            2'b01:begin
                macInput = {buffOutPixel[3],buffOutPixel[2],buffOutPixel[1]};
//                macInputValid = 1'b1;
            end
            
            2'b10:begin
                macInput = {buffOutPixel[0],buffOutPixel[3],buffOutPixel[2]};
//                macInputValid = 1'b1;
            end
            
            2'b11:begin
                macInput = {buffOutPixel[1],buffOutPixel[0],buffOutPixel[3]};
//                macInputValid = 1'b1;
            end
            endcase
        end
    end
    
    MACEdgeDetection dut(
    .clk(clk),
    .rst(rst),
    .inPixel(macInput),//Total 24*3 = 72 bits 
    .inPixelValid(macInputValid),
    .outPixel(outPixel), // 1 8-bit output
    .outPixelValid(outPixelValid)
);
endmodule
