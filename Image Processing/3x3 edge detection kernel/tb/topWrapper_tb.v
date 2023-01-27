`timescale 1ns / 1ps

module topWrapper_tb();
    
    parameter DATA_WIDTH = 8;
    parameter IMG_HEADER = 1080;
    parameter IMG_SIZE = 512 * 512;
    
    reg clk,rst;
    reg [DATA_WIDTH-1:0]inPixel;
    reg inPixelValid;
    reg outPixelReady;
    wire [DATA_WIDTH-1:0]outPixel;
    wire outPixelValid;
    wire inPixelReady;
    wire interrupt;
    
    integer inPixelCount;
    integer outPixelCount;
    
topWrapper dut(
    .clk(clk),
    .rst(rst),
    .inPixel(inPixel),
    .inPixelValid(inPixelValid),
    .outPixelReady(1'b1),
    .outPixel(outPixel),
    .outPixelValid(outPixelValid),
    .inPixelReady(inPixelReady),
    .interrupt(interrupt)
    );
    
    integer i;
    integer inFile;
    integer outFile;
    reg [DATA_WIDTH-1:0]inFileData;
    
    initial begin
        clk = 1'b0;
        #10; rst = 1'b1;
        #10; rst = 1'b0;
        inPixelValid = 1'b0;
        
        inPixelCount = 'h0;
        outPixelCount = 'h0;
        outPixelReady = 'h0;
        
        inFile = $fopen("lena_gray.bmp","rb");
        outFile = $fopen("lena-out.bmp","wb");
        
        for(i=0;i<IMG_HEADER;i=i+1)begin
                $fscanf(inFile,"%c",inFileData);
                $fwrite(outFile,"%c",inFileData);
        end
        
        for(i=0;i<4*512;i=i+1)begin
            @(posedge clk);
            $fscanf(inFile,"%c",inPixel);
//            inPixel <= inFileData;
            inPixelValid <= 1'b1;
        end
        
        inPixelCount = inPixelCount + 4*512;
        
        @(posedge clk);
        inPixelValid <= 1'b0;
                
        while(inPixelCount < IMG_SIZE)begin
            @(posedge interrupt);
            for(i=0;i<512;i=i+1)begin
                @(posedge clk);
                $fscanf(inFile,"%c",inPixel);
//                inPixel <= inFileData;
                inPixelValid <= 1'b1;
            end 
            
            inPixelCount = inPixelCount + 512;
            
            @(posedge clk);
            inPixelValid <= 1'b0;
            
        end
        
        @(posedge clk);
        inPixelValid <= 1'b0;
        
        @(posedge interrupt);
        for(i=0;i<512;i=i+1)begin
            @(posedge clk);
            inPixel <= 0;
            inPixelValid <= 1'b1;
        end 
        
        inPixelCount = inPixelCount + 512;
        
        @(posedge clk);
        inPixelValid <= 1'b0;
                
        @(posedge interrupt);
        for(i=0;i<512;i=i+1)begin
            @(posedge clk);
            inPixel <= 0;
            inPixelValid <= 1'b1;
        end 
        
        inPixelCount = inPixelCount + 512;
        @(posedge clk);
        inPixelValid <= 1'b0;
        $fclose(inFile);
        
    end
    
    always@(posedge clk)begin
        if(outPixelValid)begin
            $fwrite(outFile,"%c",outPixel);
            outPixelCount <= outPixelCount + 1'b1;
        end
        if(outPixelCount == IMG_SIZE)begin
            $fclose(outFile);
            $stop;
        end
    end
    
    always #5 clk <= ~clk;
endmodule
