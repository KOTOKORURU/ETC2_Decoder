`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MetalGear
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    etc_rgb_decoder_th_generator 
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
module etc_rgb_decoder_th_generator(
    sclk,
    //rsrt,
    rtr,
    
    flag_punchThrough,
    aplha,
    pixIdx,
    block,
    baseColor_0,
    baseColor_1,
    baseColor_2,
    baseColor_3,

    // output
    color_rts,
    r,
    g,
    b,
    a
    );

input sclk;
//input rsrt;
input rtr;

input flag_punchThrough;
input aplha;
input[3 :0] pixIdx;
input[63:0] block;
input[8 * 3 - 1:0] baseColor_0;
input[8 * 3 - 1:0] baseColor_1;
input[8 * 3 - 1:0] baseColor_2;
input[8 * 3 - 1:0] baseColor_3;

// output
output color_rts;
output[7:0] r;
output[7:0] g;
output[7:0] b;
output[7:0] a;

reg[1:0] index;
always@(*) begin
    index = 2'b0;

    //if (rsrt) begin
        //index = 2'b0;
    //end
    if (rtr) begin
        index = (block[pixIdx + 5'd16] << 1 | block[pixIdx]);
    end
end

reg valid;
reg[7:0] r_d;
reg[7:0] g_d;
reg[7:0] b_d;
reg[7:0] a_d;

assign color_rts = valid && rtr;
assign r = r_d;
assign g = g_d;
assign b = b_d;
assign a = a_d;

always@(posedge sclk) begin
    r_d   <= 8'd0;
    g_d   <= 8'd0;
    b_d   <= 8'd0;
    a_d   <= 8'd0;
    valid <= 1'b0;
    if ((index != 2 || flag_punchThrough == 1'b0) && rtr) begin
        case(index) 
        2'b00 : begin 
            r_d <= baseColor_0[7 : 0];
            g_d <= baseColor_0[15: 8];
            b_d <= baseColor_0[23:16];
        end
        2'b01 : begin
            r_d <= baseColor_1[7 : 0];
            g_d <= baseColor_1[15: 8];
            b_d <= baseColor_1[23:16];
        end
        2'b10 : begin
            r_d <= baseColor_2[7 : 0];
            g_d <= baseColor_2[15: 8];
            b_d <= baseColor_2[23:16];
            end
        2'b11 : begin
            r_d <= baseColor_3[7 : 0];
            g_d <= baseColor_3[15: 8];
            b_d <= baseColor_3[23:16];
            end
        endcase
        valid <= 1'b1;
    end
    
    if (aplha || flag_punchThrough == 1'b0) begin
        a_d <= 8'd255;
    end
end

endmodule
