`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MetalGear
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    tft_ctrl 
// Project Name:   ETC2 Decoder
// Target Devices: Spartan6
// Tool versions: 
// Description:    Generate vsync&hsync for Presenting on LCD
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module tft_ctrl
(
    tft_sclk_33m,
    srst,
    pix_data,
    decode_finished,
    
    pix_x,
    pix_y,
    
    hsync,
    vsync,
    
    rgb_data,
    tft_back_light,
    tft_screen_clk,
    tft_screen_de
);
parameter H_SYNC  = 11'd1,
          H_BACK  = 11'd46,
          H_FRONT = 11'd210,
          H_VALID = 11'd800,
          H_TOTAL = H_SYNC + H_FRONT + H_VALID + H_BACK;
          
parameter V_SYNC  = 11'd1,
          V_BACK  = 11'd23,
          V_FRONT = 11'd22,
          V_VALID = 11'd480,
          V_TOTAL = V_SYNC + V_BACK + V_FRONT + V_VALID;

input tft_sclk_33m;
input srst;
input [15:0] pix_data;
input decode_finished;

output [10:0] pix_x;
output [10:0] pix_y;
output hsync;
output vsync;
output [15:0] rgb_data;
output tft_back_light;
output tft_screen_clk;
output tft_screen_de;

wire rgb_valid;
wire pix_data_valid;

reg [10:0] cnt_v;
reg [10:0] cnt_h;

assign tft_screen_clk = tft_sclk_33m;
assign tft_back_light = srst;
assign tft_screen_de = rgb_valid;

always@(posedge tft_sclk_33m) begin
    if(!srst || (cnt_h == H_TOTAL - 10'd1) || !decode_finished)
        cnt_h <= 11'd0;
    else
        cnt_h <= cnt_h + 10'd1;
end

always@(posedge tft_sclk_33m) begin
    if(!srst || (cnt_v == V_TOTAL - 10'd1 && cnt_h == H_TOTAL - 10'd1) || !decode_finished)
        cnt_v <= 11'd0;
    else if (cnt_h == H_TOTAL - 10'd1)
        cnt_v <= cnt_v + 10'd1;
    else
        cnt_v <= cnt_v;
end

assign vsync = ( cnt_v <= V_SYNC - 1'd1) ? 1'b1 : 1'b0;
assign hsync = ( cnt_h <= H_SYNC - 1'd1) ? 1'b1 : 1'b0;


assign rgb_valid = (cnt_h >= (H_SYNC + H_BACK)) && (cnt_h < (H_SYNC + H_BACK + H_VALID)) &&
                   (cnt_v >= (V_SYNC + V_BACK)) && (cnt_v < (V_SYNC + V_BACK + V_VALID)) ? 1'b1 : 1'b0; 
                   
assign pix_data_valid = (cnt_h >= (H_SYNC + H_BACK - 10'd1)) && (cnt_h < (H_SYNC + H_BACK + H_VALID - 10'd1)) &&
                        (cnt_v >= (V_SYNC + V_BACK)) && (cnt_v < (V_SYNC + V_BACK + V_VALID)) ? 1'b1 : 1'b0; 
            
assign pix_x = (pix_data_valid) ? 
            (cnt_h - H_BACK - H_SYNC + 10'd1) : 11'h3ff;

assign pix_y = (pix_data_valid) ?
            (cnt_v - V_BACK - V_SYNC) : 11'h3ff;

assign rgb_data = (rgb_valid) ? pix_data : 16'h0000;


endmodule
