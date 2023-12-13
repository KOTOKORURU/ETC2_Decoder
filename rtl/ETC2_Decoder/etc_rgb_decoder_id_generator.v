`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MetalGear
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    etc_rgb_decoder_id_generator 
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
module etc_rgb_decoder_id_generator
(
    sclk,
    rsrt,
    rtr,
    
    flipped,
    flag_punchThrough,
    aplha,
    pixIdx,
    block,
    baseColor_0,
    baseColor_1,

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

input flipped;
input flag_punchThrough;
input aplha;
input[3 :0] pixIdx;
input[63:0] block;
input[8 * 3 - 1:0] baseColor_0;
input[8 * 3 - 1:0] baseColor_1;

// output
output color_rts;
output[7:0] r;
output[7:0] g;
output[7:0] b;
output[7:0] a;

reg[1:0] index;
reg[2:0] tab;
reg selector;

always@(*)begin

    index    = 2'b0;
    tab      = 3'b0;
    selector = 1'b0;
    
    if (rsrt) begin
        index = 2'b0;
    end
    else if (rtr) begin
        index = (block[pixIdx + 5'd16] << 1 | block[pixIdx]);
        if ((flipped && (pixIdx[1:0] < 2'd2)) || (!flipped && (pixIdx[3] != 1'b1))) begin
            tab = block[39:37];
            selector = 1'b0;
        end
        else begin
            tab = block[36:34];
            selector = 1'b1;
        end
    end
end

reg signed[15:0] modifier;

reg[1:0] index_table;

always@(*) begin
    index_table = 2'd0;
    if (rtr) begin
        case(index)
            2'b00: index_table = 2'd2;
            2'b01: index_table = 2'd3;
            2'b10: index_table = 2'd1;
            2'b11: index_table = 2'd0;
        endcase
    end
end


always@(*) begin
    modifier = 16'd0;
    
    if (rtr) begin
        if (flag_punchThrough != 1'b0 && index_table == 2'b10)begin
            modifier = 16'd0;
        end
        else begin
            case({tab, index_table})
              5'b000_00: modifier = -16'sd8;
              5'b000_01: modifier = -16'sd2; 
              5'b000_10: modifier =  16'sd2;
              5'b000_11: modifier =  16'sd8;
              5'b001_00: modifier = -16'sd17;
              5'b001_01: modifier = -16'sd5;
              5'b001_10: modifier =  16'sd5;
              5'b001_11: modifier =  16'sd17;
              5'b010_00: modifier = -16'sd29;
              5'b010_01: modifier = -16'sd9;
              5'b010_10: modifier =  16'sd9;
              5'b010_11: modifier =  16'sd29;
              5'b011_00: modifier = -16'sd42;
              5'b011_01: modifier = -16'sd13;
              5'b011_10: modifier =  16'sd13;
              5'b011_11: modifier =  16'sd42;
              5'b100_00: modifier = -16'sd60;
              5'b100_01: modifier = -16'sd18;
              5'b100_10: modifier =  16'sd18;
              5'b100_11: modifier =  16'sd60;
              5'b101_00: modifier = -16'sd80;
              5'b101_01: modifier = -16'sd24;
              5'b101_10: modifier =  16'sd24;
              5'b101_11: modifier =  16'sd80;
              5'b110_00: modifier = -16'sd106;
              5'b110_01: modifier = -16'sd33;
              5'b110_10: modifier =  16'sd33;
              5'b110_11: modifier =  16'sd106;
              5'b111_00: modifier = -16'sd183;
              5'b111_01: modifier = -16'sd47;
              5'b111_10: modifier =  16'sd47;
              5'b111_11: modifier =  16'sd183;
            default:
                modifier = 16'd0;
            endcase
        end
    end
end

reg signed[15:0] r_q;
reg signed[15:0] g_q;
reg signed[15:0] b_q;
reg signed[15:0] a_q;

always@(*) begin
    r_q = 15'd0;
    g_q = 15'd0;
    b_q = 15'd0;
    a_q = 15'd0;
    
    if (rsrt) begin
        r_q = 15'd0;
        g_q = 15'd0;
        b_q = 15'd0;
        a_q = 15'd0;
    end
    
    if (rtr) begin
    
        if (selector) begin
            r_q = baseColor_1[7 : 0] + modifier;
            g_q = baseColor_1[15: 8] + modifier;
            b_q = baseColor_1[23:16] + modifier;
        end
        else begin
            r_q = baseColor_0[7 : 0] + modifier;
            g_q = baseColor_0[15: 8] + modifier;
            b_q = baseColor_0[23:16] + modifier;
        end
        
        if (aplha || flag_punchThrough) begin
            a_q = 8'd255;
        end
        
        r_q = clamp0_255(r_q);
        g_q = clamp0_255(g_q);
        b_q = clamp0_255(b_q);
        
    end
end

reg[7:0] r_d;
reg[7:0] g_d;
reg[7:0] b_d;
reg[7:0] a_d;
reg valid;

// 1 clk delay
always@(posedge sclk) begin

    r_d   <= 8'd0;
    g_d   <= 8'd0;
    b_d   <= 8'd0;
    a_d   <= 8'd0;
    valid <= 1'b0;
    
    if (rsrt) begin
        r_d   <= 8'd0;
        g_d   <= 8'd0;
        b_d   <= 8'd0;
        valid <= 1'b0;
    end

    if (rtr) begin
        valid <= 1'b1;
        r_d   <= r_q;
        g_d   <= g_q;
        b_d   <= b_q;
        a_d   <= a_q;
    end
end

assign r         = r_d;
assign g         = g_d;
assign b         = b_d;
assign a         = a_d;
assign color_rts = valid && rtr;


endmodule
