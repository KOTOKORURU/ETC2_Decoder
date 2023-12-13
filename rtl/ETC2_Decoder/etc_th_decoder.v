`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MetalGear
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    etc_th_decoder 
// Project Name:   ETC2 Decoder
// Target Devices: Spartan6
// Tool versions: 
// Description:    Decode Image
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module etc_th_decoder(
    sclk,
    //rsrt,
    // input
    rtr,
    mode,
    block,
    
    flag_punchThrough,
    aplha,
    pixIdx,
    
    // output
    color_rts,
    r,
    g,
    b,
    a
    );

input sclk;
input rtr;
input[2 :0] mode;
input[63:0] block;

input flag_punchThrough;
input aplha;
input[3:0] pixIdx;

// output
output color_rts;
output[7:0] r;
output[7:0] g;
output[7:0] b;
output[7:0] a;

wire color_rts_0;
wire [23:0] baseColor_0;
wire [23:0] baseColor_1;
wire [23:0] baseColor_2;
wire [23:0] baseColor_3;

etc_rgb_decoder_th etc_rgb_decoder_th_inst (
    .sclk(sclk),
    .rtr(rtr),
    .mode(mode),
    .block(block),
    .color_rts(color_rts_0),
    .baseColor_0(baseColor_0),
    .baseColor_1(baseColor_1),
    .baseColor_2(baseColor_2),
    .baseColor_3(baseColor_3)
    );


etc_rgb_decoder_th_generator etc_rgb_decoder_th_generator_inst(
    .sclk(sclk),
    //.rsrt(rst),
    .rtr(color_rts_0),
    
    .flag_punchThrough(flag_punchThrough),
    .aplha(aplha),
    .pixIdx(pixIdx),
    .block(block),
    .baseColor_0(baseColor_0),
    .baseColor_1(baseColor_1),
    .baseColor_2(baseColor_2),
    .baseColor_3(baseColor_3),

    // output
    .color_rts(color_rts),
    .r(r),
    .g(g),
    .b(b),
    .a(a)
);



endmodule
