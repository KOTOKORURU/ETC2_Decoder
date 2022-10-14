`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: LickAss
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    etc_plannar_decoder 
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
module etc_plannar_decoder(
    sclk,
    rsrt,
    // input
    rtr,
    mode,
    block,
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
input rsrt;

// input
input rtr;
input aplha;
input[3 :0] pixIdx;
input[63:0] block;
input[0 :2] mode;

// output
output color_rts;
output[7:0] r;
output[7:0] g;
output[7:0] b;
output[7:0] a;

wire baseColor_valid;
wire[8 * 3 - 1:0] baseColor_0;
wire[8 * 3 - 1:0] baseColor_1;
wire[8 * 3 - 1:0] baseColor_2;

etc_rgb_decoder_planar plannar_inst(
    
    .sclk(sclk),
    .rsrt(rsrt),
    // input
    .rtr(rtr),
    .mode(mode),
    .block(block),
    
    // output
    .color_rts(baseColor_valid),
    .baseColor_0(baseColor_0),
    .baseColor_1(baseColor_1),
    .baseColor_2(baseColor_2)
    );

etc_rgb_decoder_planar_generator plannar_generator_inst(
    .sclk(sclk),
    .rsrt(rsrt),
    .rtr(baseColor_valid),
    
    .aplha(aplha),
    .pixIdx(pixIdx),
    .baseColor_0(baseColor_0),
    .baseColor_1(baseColor_1),
    .baseColor_2(baseColor_2),

    // output
    .color_rts(color_rts),
    .r(r),
    .g(g),
    .b(b),
    .a(a)
    );

endmodule
