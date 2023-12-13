`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MetalGear
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    etc_address_generator 
// Project Name:   ETC2 Decoder
// Target Devices: Spartan6
// Tool versions: 
// Description:    Generate Dst Address
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module etc_address_generator
(
    sclk,
    rsrt,
    addr_rtr,

    // input
    blockX,
    blockY,
    pixIdx,
    width,

    // output
    out_addr,
    addr_valid
);

input sclk;
input rsrt;
input addr_rtr;

// input
input[7:0] blockY;
input[7:0] blockX;
input[10:0] width;
input[3 :0] pixIdx;

// output
output       addr_valid;
output[31:0] out_addr;


reg[31:0] final_addr;
reg       valid;


assign out_addr   = final_addr;
assign addr_valid = valid && addr_rtr;

reg[31:0] curPos;
reg[31:0] addr;
reg[31:0] widthX2;
//reg[31:0] widthX3;

always@(*) begin
    curPos  = 32'd0;
    addr    = 32'd0;
    widthX2 = 32'd0;
    //widthX3 = 32'd0;
    
    if (addr_rtr) begin
        widthX2 = width << 1;
        //widthX3 = widthX2 + width;
        case(pixIdx)
        4'b0000: curPos = 32'd0;
        4'b0001: curPos = width;
        4'b0010: curPos = widthX2;
        4'b0011: curPos = widthX2 + width;
        4'b0100: curPos = 4'd1;
        4'b0101: curPos = 4'd1 + width;
        4'b0110: curPos = 4'd1 + widthX2;
        4'b0111: curPos = 4'd1 + widthX2 + width;
        4'b1000: curPos = 4'd2;
        4'b1001: curPos = 4'd2 + width;
        4'b1010: curPos = 4'd2 + widthX2;
        4'b1011: curPos = 4'd2 + widthX2 + width;
        4'b1100: curPos = 4'd3;
        4'b1101: curPos = 4'd3 + width;
        4'b1110: curPos = 4'd3 + widthX2;
        4'b1111: curPos = 4'd3 + widthX2 + width;
        endcase
        addr = (blockY * (width << 2) + (blockX << 2)) + curPos;
    end
end

/*
reg[31:0] addr_d;
always@(*) begin
    addr_d = 32'd0;
    
    if (addr_rtr) begin
        addr_d = addr + curPos;
    end
end
*/

always@(posedge sclk) begin
    final_addr <= 32'd0;
    valid      <= 1'b0;

    if (addr_rtr) begin
        final_addr <= addr;
        valid      <= 1'b1; 
    end
end

endmodule