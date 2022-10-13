`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: LickAss
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    tft_pix 
// Project Name:   ETC2 Decoder
// Target Devices: Spartan6
// Tool versions: 
// Description:    Generate pix to Present on Present
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module tft_pix
(
    tft_sclk_33m,
    srst,

    pix_x,
    pix_y,
    decode_finished,
    etc_rgb,
    
    //output
    //rd_en,
    image_start,
    address,
    pix_data
);

parameter   H_VALID =   10'd800 ,
            V_VALID =   10'd480 ;

parameter   RED     =   16'hF800,
            ORANGE  =   16'hFC00,
            YELLOW  =   16'hFFE0,
            GREEN   =   16'h07E0,
            CYAN    =   16'h07FF,
            BLUE    =   16'h001F,
            PURPPLE =   16'hF81F,
            BLACK   =   16'h0000,
            WHITE   =   16'hFFFF,
            GRAY    =   16'hD69A;

parameter   HEIGHT   =   10'd128,
            WIDTH    =   10'd128,
            PIC_SIZE =   16'd16384;

input tft_sclk_33m;
input srst;

input [10:0] pix_x;
input [10:0] pix_y;
input [15:0] etc_rgb;
input decode_finished;


output [15:0] pix_data;
output [31:0] address;
output image_start;

reg rd_en;
reg [31:0] read_addr;
reg [15:0] rgb;
assign image_start = decode_finished &&(((pix_x >= (((H_VALID - HEIGHT)/2) - 1'b1))
                      && (pix_x < (((H_VALID - HEIGHT)/2) + HEIGHT - 1'b1))) 
                      &&((pix_y >= ((V_VALID - WIDTH)/2))
                      && ((pix_y < (((V_VALID - WIDTH)/2) + WIDTH)))));

assign pix_data = (rd_en == 1'b1) ? etc_rgb : rgb;
assign address  = read_addr;


always@(posedge tft_sclk_33m) begin
    if(!srst) begin
        read_addr <= 31'd0;
        rd_en     <= 1'b0;
    end
    else begin
        if(read_addr == (PIC_SIZE - 1'd1)) begin
            read_addr <= 31'd0;
            rd_en     <= 1'b0;
        end
        else if(image_start) begin
            read_addr <= read_addr + 2'd1;
            rd_en     <= 1'b1;
        end
        else begin
            read_addr <= read_addr;
            rd_en     <= 1'b0;
        end
    end
end


always@(posedge tft_sclk_33m) begin
    if(!srst)
        rgb <= 16'd0;
    if(decode_finished) begin
    if(( pix_x >= 0) && (pix_x < H_VALID / 10 * 1))
        rgb <= RED;
    else if(( pix_x >= (H_VALID / 10 * 1)) && (pix_x < (H_VALID / 10 * 2)))
        rgb <= ORANGE;
    else if(( pix_x >= (H_VALID / 10 * 2)) && (pix_x < (H_VALID / 10 * 3)))
        rgb <= YELLOW;
    else if(( pix_x >= (H_VALID / 10 * 3)) && (pix_x < (H_VALID / 10 * 4)))
        rgb <= GREEN;
    else if(( pix_x >= (H_VALID / 10 * 4)) && (pix_x < (H_VALID / 10 * 5)))
        rgb <= CYAN;
    else if(( pix_x >= (H_VALID / 10 * 5)) && (pix_x < (H_VALID / 10 * 6)))
        rgb <= BLUE;
    else if(( pix_x >= (H_VALID / 10 * 6)) && (pix_x < (H_VALID / 10 * 7)))
        rgb <= PURPPLE;
    else if(( pix_x >= (H_VALID / 10 * 7)) && (pix_x < (H_VALID / 10 * 8)))
        rgb <= BLACK;
    else if(( pix_x >= (H_VALID / 10 * 8)) && (pix_x < (H_VALID / 10 * 9)))
        rgb <= WHITE;
    else if(( pix_x >= (H_VALID / 10 * 9)) && (pix_x < (H_VALID)))
        rgb <= GRAY;
    else
        rgb <= BLACK;
    end
end

endmodule
