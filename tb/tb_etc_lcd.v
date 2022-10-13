`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:57:02 10/13/2022
// Design Name:   tft_color
// Module Name:   D:/etc_hw/ise_proj/etc_decoder/tb/tb_etc_lcd.v
// Project Name:  etc_decoder
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: tft_color
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_etc_lcd;

// Inputs
reg sclk;
reg srst;

// Outputs
wire hsync;
wire vsync;
wire [15:0] rgb;
wire tft_bl;
wire tft_clk;
wire tft_de;

initial begin
	// Initialize Inputs
	sclk = 1'b1;
	srst <= 1'b0;

	// Wait 100 ns for global reset to finish
	#40;
    srst <= 1'b1;
end

always  #10 sclk = ~sclk;

// Instantiate the Unit Under Test (UUT)
tft_color uut (
	.sclk(sclk), 
	.srst(srst), 
	.hsync(hsync), 
	.vsync(vsync), 
	.rgb(rgb), 
	.tft_bl(tft_bl), 
	.tft_clk(tft_clk), 
	.tft_de(tft_de)
);


      
endmodule

