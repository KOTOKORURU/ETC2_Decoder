`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MetalGear
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    etc_decoder 
// Project Name:   ETC2 Decoder
// Target Devices: Spartan6
// Tool versions: 
// Description:    Main ETC2 Decode Block
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module etc_decoder(
    vga_clk,
    sclk,
    rst,
    rd_en,
    read_addr,
    rgb,
    //address_tb,
    decode_finished
    );

input vga_clk;
input sclk;
input rst;
input rd_en;
input[31:0] read_addr;
output[15:0] rgb;
//output[31:0] address_tb; // for test
output decode_finished;


wire valid;
wire image_finished;
wire[63:0] data;
wire[7:0]  blockX;
wire[7:0]  blockY;
wire[4:0]  pixIdx;

parameter WIDTH = 32'd128;
parameter FLAG_PASSTHROUGH = 1'b0;

assign decode_finished = image_finished;


reg write_finish;
wire write_finish_d;
always@(posedge sclk) begin
    write_finish <= 1'b0;
    if (rst) begin
        write_finish <= 1'b0;
    end
    else begin
        write_finish <= write_finish_d;
    end
end


etc_data_fetcher data_fetcher
(
    .sclk(sclk),
    .rsrt(rst),
    .write_finish(write_finish),
    
    // output
    .image_finished(image_finished),
    .blockX_out(blockX),
    .blockY_out(blockY),
    .pixIdx_out(pixIdx),
    .valid(valid),
    .block_out(data)
);

wire mode_valid;
wire[2:0] mode;

mode_detect mode_detect_inst
(
      .sclk(sclk),
      .rsrt(rst),
      // input
      .block(data),
      .flags(FLAG_PASSTHROUGH),
      .mode_rtr(valid),
      //output
      .mode(mode),
      .mode_rts(mode_valid)
);

wire[7:0] r;
wire[7:0] g;
wire[7:0] b;
wire[7:0] a;
wire color_valid;

etc_rgb_decoder etc_rgb_decoder_inst
(
    .sclk(sclk),
    .rsrt(rst),
    // input
    .rtr(mode_valid),
    .mode(mode),
    .block(data),
    
    .flag_punchThrough(FLAG_PASSTHROUGH),
    .aplha(1'b1),
    .pixIdx(pixIdx),
    
    // output
    .color_rts(color_valid),
    .r(r),
    .g(g),
    .b(b),
    .a(a)
);

wire addr_valid;
wire[31:0] address;

etc_address_generator address_inst
(
    .sclk(sclk),
    .rsrt(rst),
    .addr_rtr(color_valid),

    // input
    .blockX(blockX),
    .blockY(blockY),
    .pixIdx(pixIdx),
    .width(WIDTH),

    // output
    .out_addr(address),
    .addr_valid(addr_valid)
);

assign read = image_finished && rd_en;


etc_img_store etc_img_store_inst(
    .vga_clk(vga_clk),
    .sclk(sclk),
    .rsrt(rst),
    .rgb_rtr(addr_valid),

    // write data to RAM
    .r(r),
    .g(g),
    .b(b),
    .write_addr(address),
    
    // read data to LCD
    .read_addr(read_addr),
    .image_finished(read),

    // output
    .rgb_present(rgb),
    .write_finish(write_finish_d)/*,
    .write_addr_tb(address_tb)*/
    );

endmodule
