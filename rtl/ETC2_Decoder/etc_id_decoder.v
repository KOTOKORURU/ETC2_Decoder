`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: LickAss
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    etc_id_decoder 
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
module etc_id_decoder(
    sclk,
    rsrt,
    // input
    rtr,
    mode,
    block,
    aplha,
    flag_punchThrough,
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

input rtr;
input[63:0] block;
input[0 :2] mode;

input flag_punchThrough;
input aplha;
input[3 :0] pixIdx;

output color_rts;
output[7:0] r;
output[7:0] g;
output[7:0] b;
output[7:0] a;

wire baseColor_valid;
wire is_flipped;
wire[23:0] baseColor_0;
wire[23:0] baseColor_1;

etc_rgb_decoder_id etc_rgb_decoder_id_inst
(
    .sclk(sclk),
    .rsrt(rsrt),
    // input
    .rtr(rtr),
    .mode(mode),
    .block(block),
    
    // output
    .color_rts(baseColor_valid),
    .flipped(is_flipped),
    .baseColor_0(baseColor_0),
    .baseColor_1(baseColor_1)
);


etc_rgb_decoder_id_generator etc_rgb_decoder_id_generator
(
    .sclk(sclk),
    .rsrt(rsrt),
    .rtr(baseColor_valid),
    
    .flipped(is_flipped),
    .flag_punchThrough(flag_punchThrough),
    .aplha(aplha),
    .pixIdx(pixIdx),
    .block(block),
    .baseColor_0(baseColor_0),
    .baseColor_1(baseColor_1),

    // output
    .color_rts(color_rts),
    .r(r),
    .g(g),
    .b(b),
    .a(a)
);


endmodule
