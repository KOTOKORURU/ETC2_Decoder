`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MetalGear
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    tft_color 
// Project Name:   ETC2 Decoder
// Target Devices: Spartan6
// Tool versions: 
// Description:    Main Decode&Present Block
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module tft_color
(
  sclk,
  srst,
  
  hsync,
  vsync,
  rgb,
  
  tft_bl,
  tft_clk,
  tft_de
);

input sclk;
input srst; // effective on Low Level

output hsync;
output vsync;
output [15:0] rgb;

output tft_bl;
output tft_clk;
output tft_de;

wire tft_sclk_33m;
wire tft_clk_50m;
wire locked;
wire rst_n;

wire [15:0] pix_data;
wire [10:0]  pix_x;
wire [10:0]  pix_y;
wire temp_pll_clk;


assign rst_n = locked & srst;

pll_ip pll_ip_inst
(
    .RESET(~srst),
    // Clock in ports
    .CLK_IN1(sclk),      // IN
    // Clock out ports
    .CLK_OUT1(tft_sclk_33m),     // OUT
    .CLK_OUT2(tft_clk_50m),
    // Status and control signals
    .LOCKED(locked) // OUT
);


//!!!! we need oddr2 because we can not connect to pll of FPGA directly!!!!!
ODDR2 #
(
   .DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
   .INIT(1'b0),    // Sets initial state of the Q output to 1'b0 or 1'b1
   .SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
)
ODDR2_inst (      
   .Q(tft_clk),   // 1-bit DDR output data
   .C0(temp_pll_clk),   // 1-bit clock input
   .C1(~temp_pll_clk),   // 1-bit clock input
   .CE(1'b1), // 1-bit clock enable input
   .D0(1'b1), // 1-bit data input (associated with C0)
   .D1(1'b0), // 1-bit data input (associated with C1)
   .R(1'b0),   // 1-bit reset input
   .S(1'b0)    // 1-bit set input
);

wire rd_en;
wire image_start;
wire[31:0] address;
wire decode_finished;
wire [15:0] etc_rgb;
tft_pix tft_pix_inst
(
 .tft_sclk_33m(tft_sclk_33m),
 .srst(rst_n),

 .pix_x(pix_x),
 .pix_y(pix_y),
 .decode_finished(decode_finished),
 .etc_rgb(etc_rgb),

 // output
 //.rd_en(rd_en),
 .image_start(image_start),
 .address(address),
 .pix_data(pix_data)
);

tft_ctrl tft_ctrl_inst
(
 .tft_sclk_33m(tft_sclk_33m),
 .srst(rst_n),
 .pix_data(pix_data),
 .decode_finished(decode_finished),
 
 //output
 .pix_x(pix_x),
 .pix_y(pix_y),
 
 .vsync(vsync),
 .hsync(hsync),
 .rgb_data(rgb),
 .tft_screen_de(tft_de),
 .tft_back_light(tft_bl),
 .tft_screen_clk(temp_pll_clk)
);

etc_decoder etc_decoder_inst (
    .vga_clk(tft_sclk_33m), 
    .sclk(tft_clk_50m), 
    .rst(~rst_n), 
    .rd_en(image_start), 
    .read_addr(address), 
    .rgb(etc_rgb),
    //.address_tb(tb_write_address),
    .decode_finished(decode_finished)
);


endmodule
