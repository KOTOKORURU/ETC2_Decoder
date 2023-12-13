`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MetalGear
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    etc_rgb_decoder_planar_generator 
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
module etc_rgb_decoder_planar_generator(
    sclk,
    rsrt,
    rtr,

    aplha,
    pixIdx,
    baseColor_0,
    baseColor_1,
    baseColor_2,

    // output
    color_rts,
    r,
    g,
    b,
    a
    );
`include "etc_param.vh"
input sclk;
input rsrt;
input rtr;

input aplha;
input[3 :0] pixIdx;
input[8 * 3 - 1:0] baseColor_0;
input[8 * 3 - 1:0] baseColor_1;
input[8 * 3 - 1:0] baseColor_2;

// output
output color_rts;
output[7:0] r;
output[7:0] g;
output[7:0] b;
output[7:0] a;

reg[1:0] localX;
reg[1:0] localY;

reg signed[9:0] baseColorDeta_1_r_ext;
reg signed[9:0] baseColorDeta_1_g_ext;
reg signed[9:0] baseColorDeta_1_b_ext;

reg signed[9:0] baseColorDeta_2_r_ext;
reg signed[9:0] baseColorDeta_2_g_ext;
reg signed[9:0] baseColorDeta_2_b_ext;

always@(*) begin
    localX = 3'd0;
    localY = 3'd0;
    baseColorDeta_1_r_ext = 10'd0;
    baseColorDeta_1_g_ext = 10'd0;
    baseColorDeta_1_b_ext = 10'd0;
    baseColorDeta_2_r_ext = 10'd0;
    baseColorDeta_2_g_ext = 10'd0;
    baseColorDeta_2_b_ext = 10'd0;
    if (rtr) begin
        localX = pixIdx >> 2'd2;
        localY = pixIdx & 2'd3;
        // r
        if (baseColor_1[7:0] < baseColor_0[7:0]) baseColorDeta_1_r_ext = ~{baseColor_0[7:0] - baseColor_1[7:0]} + 1'b1;
        else baseColorDeta_1_r_ext = baseColor_1[7:0] - baseColor_0[7:0];

        if (baseColor_2[7:0] < baseColor_0[7:0]) baseColorDeta_2_r_ext = ~{baseColor_0[7:0] - baseColor_2[7:0]} + 1'b1;
        else baseColorDeta_2_r_ext =   baseColor_2[7:0] - baseColor_0[7:0];

        // g
        if (baseColor_1[15:8] < baseColor_0[15:8]) baseColorDeta_1_g_ext = ~{baseColor_0[15:8] - baseColor_1[15:8]} + 1'b1;
        else baseColorDeta_1_g_ext = baseColor_1[15:8] - baseColor_0[15:8];

        if (baseColor_2[15:8] < baseColor_0[15:8]) baseColorDeta_2_g_ext = ~{baseColor_0[15:8] - baseColor_2[15:8]} + 1'b1;
        else baseColorDeta_2_g_ext = baseColor_2[15:8] - baseColor_0[15:8];

        // b
        if (baseColor_1[23:16] < baseColor_0[23:16]) baseColorDeta_1_b_ext = ~{baseColor_0[23:16] - baseColor_1[23:16]} + 1'b1;
        else baseColorDeta_1_b_ext = baseColor_1[23:16] - baseColor_0[23:16];

        if (baseColor_2[23:16] < baseColor_0[23:16]) baseColorDeta_2_b_ext = ~{baseColor_0[23:16] - baseColor_2[23:16]} + 1'b1;
        else baseColorDeta_2_b_ext = baseColor_2[23:16] - baseColor_0[23:16];

    end
end

reg signed[9:0] r_q;
reg signed[9:0] g_q;
reg signed[9:0] b_q;

always@(*) begin
    r_q     = 10'd0;
    g_q     = 10'd0;
    b_q     = 10'd0;
    if (rtr) begin
        r_q = (localX * (baseColorDeta_1_r_ext) + localY * (baseColorDeta_2_r_ext) + ((baseColor_0[7 : 0]) << 2'd2) + 2'd2) >> 2'd2;
        g_q = (localX * (baseColorDeta_1_g_ext) + localY * (baseColorDeta_2_g_ext) + ((baseColor_0[15: 8]) << 2'd2) + 2'd2) >> 2'd2;
        b_q = (localX * (baseColorDeta_1_b_ext) + localY * (baseColorDeta_2_b_ext) + ((baseColor_0[23:16]) << 2'd2) + 2'd2) >> 2'd2;
        
        r_q = clamp0_255(r_q);
        g_q = clamp0_255(g_q);
        b_q = clamp0_255(b_q);
    end
end

reg valid_d;
reg signed[7:0] r_d;
reg signed[7:0] g_d;
reg signed[7:0] b_d;
reg [7:0]       a_d;

assign color_rts = valid_d && rtr;
assign r = r_d;
assign g = g_d;
assign b = b_d;
assign a = a_d;

always@(posedge sclk) begin
    r_d     <= 8'd0;
    g_d     <= 8'd0;
    b_d     <= 8'd0;
    a_d     <= 8'd0;
    valid_d <= 1'b0;
    if (rtr) begin
        valid_d       <= 1'b1;
        r_d           <= r_q;
        g_d           <= g_q;
        b_d           <= b_q;
        if (aplha) a_d <= 8'd255;
    end
end

endmodule
