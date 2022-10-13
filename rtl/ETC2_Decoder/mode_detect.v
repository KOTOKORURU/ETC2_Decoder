`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: LickAss
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    mode_detect 
// Project Name:   ETC2 Decoder
// Target Devices: Spartan6
// Tool versions: 
// Description:    For Mode Detection
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mode_detect(
      sclk,
      rsrt,
      // input
      block,
      flags,
      mode_rtr,
      //output
      mode,
      mode_rts
    );

`include "etc_param.vh"

input mode_rtr;
input sclk;
input rsrt;

input[63:0] block;
input       flags;

output[2:0] mode;
output      mode_rts;

reg signed[7:0]  red;
reg signed[7:0]  green;
reg signed[7:0]  blue;
reg signed[7:0]  rDiff;
reg signed[7:0]  gDiff;
reg signed[7:0]  bDiff;
wire bits_33;
wire punchThrough;

wire[4:0] bits_63_59;
wire[4:0] bits_55_51;
wire[4:0] bits_47_43;
wire[2:0] bits_50_48;
wire[2:0] bits_58_56;
wire[2:0] bits_42_40;

assign bits_33      = block[33];
assign punchThrough = flags;
assign bits_63_59   = block[63:59];
assign bits_55_51   = block[55:51];
assign bits_47_43   = block[47:43];
assign bits_58_56   = block[58:56];
assign bits_50_48   = block[50:48];
assign bits_42_40   = block[42:40];


always @(*) begin
    red    = 8'd0;
    green  = 8'd0;
    blue   = 8'd0;
    rDiff  = 8'd0;
    gDiff  = 8'd0;
    bDiff  = 8'd0;

    if(rsrt) begin
        red    = 8'd0;
        green  = 8'd0;
        blue   = 8'd0;
        rDiff  = 8'd0;
        gDiff  = 8'd0;
        bDiff  = 8'd0;

    end
    else if(((bits_33 != 1'b0) || (punchThrough != 1'b0)) && mode_rtr) begin
        rDiff  = bits_58_56 << 3'd5;
        gDiff  = bits_50_48 << 3'd5;
        bDiff  = bits_42_40 << 3'd5;
        rDiff  = rDiff >>> 3'd5;
        gDiff  = gDiff >>> 3'd5;
        bDiff  = bDiff >>> 3'd5;
        red    = {4'b0, bits_63_59} + rDiff;
        green  = {4'b0, bits_55_51} + gDiff;
        blue   = {4'b0, bits_47_43} + bDiff;
    end
end

reg[2:0] mode_d;
reg      mode_rts_d;

// 1 clk delay
always@(posedge sclk) begin
    mode_rts_d <= 1'b0;
    
    mode_d     <= `Differential;
    if(rsrt) begin
        mode_rts_d <= 1'b0;
        mode_d     <= `Differential;
    end
    else if(mode_rtr) begin
        mode_rts_d  <= 1'b1;
        if((bits_33 == 1'b0) && (punchThrough == 1'b0)) begin
            mode_d <= `Individual;
        end
        else if(red < 8'd0 || red > 8'd31) begin
            mode_d <= `TMode;
        end
        else if(green < 8'd0 || green > 8'd31) begin
            mode_d <= `HMode;
        end
        else if(blue < 8'd0 || blue > 8'd31) begin
            mode_d <= `Planar;
        end
    end
end

assign mode_rts = mode_rts_d && mode_rtr;
assign mode     = mode_d;

endmodule
