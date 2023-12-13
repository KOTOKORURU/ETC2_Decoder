`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MetalGear
// Engineer: Yuhao(KOTOKORURU)
//
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    etc_img_store 
// Project Name:   ETC2 Decoder
// Target Devices: Spartan6
// Tool versions: 
// Description:    For Image Store
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module etc_img_store(
    vga_clk,
    sclk,
    rsrt,
    rgb_rtr,
    
    
    r,
    g,
    b,
    write_addr,
    read_addr,
    image_finished,

    // output
    rgb_present,
    write_finish/*,
    write_addr_tb // for test*/
    );

input vga_clk;
input sclk;
input rsrt;
input rgb_rtr;
input image_finished;

input[7:0] r;
input[7:0] g;
input[7:0] b;

input[31:0] write_addr;
input[31:0] read_addr;

output[15:0] rgb_present;
output write_finish;
//output[31:0] write_addr_tb;


reg write_valid;
wire[15:0] rgb_merged;

assign rgb_merged = { {r[7:3]}, {g[7:2]}, {b[7:3]} };
//assign rgb_present = rgb_rtr ? rgb_merged  : 16'd0; // for test
//assign write_addr_tb = rgb_rtr? write_addr : 32'd0; // for test

assign write_finish = rgb_rtr && write_valid;


always@(*) begin
    write_valid = 1'b0;
    if (rsrt)         write_valid = 1'b0;
    else if (rgb_rtr) write_valid = 1'b1;
end


rom128x128x32 ram_fifo (
  .clka(sclk), // input clka
  .ena(rgb_rtr), // input ena
  .wea(rgb_rtr), // input [0 : 0] wea
  .addra(write_addr), // input [13 : 0] addra
  .dina(rgb_merged), // input [15 : 0] dina
  // read data to LCD
  .clkb(vga_clk), // input clkb
  .enb(image_finished), // input enb
  .addrb(read_addr), // input [13 : 0] addrb
  .doutb(rgb_present) // output [15 : 0] doutb
);

endmodule
