`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MetalGear
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    etc_rgb_decoder_planar 
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
module etc_rgb_decoder_planar(
    sclk,
    rsrt,

    // input
    rtr,
    mode,
    block,

    // output
    color_rts,
    baseColor_0,
    baseColor_1,
    baseColor_2
    );

`include "etc_param.vh"
input sclk;
input rsrt;

input rtr;
input[63:0] block;
input[0 :2] mode;

output color_rts;
output[8 * 3 - 1:0] baseColor_0;
output[8 * 3 - 1:0] baseColor_1;
output[8 * 3 - 1:0] baseColor_2;


wire[5:0] bits_62_57;
wire      bits_56;
wire[5:0] bits_54_49;
wire      bits_48;
wire[1:0] bits_44_43;
wire[2:0] bits_41_39;

wire[4:0] bits_38_34;
wire      bits_32;
wire[6:0] bits_31_25;
wire[5:0] bits_24_19;

wire[5:0] bits_18_13;
wire[6:0] bits_12_6;
wire[5:0] bits_5_0;

assign bits_62_57 = block[62:57];
assign bits_56    = block[56];
assign bits_54_49 = block[54:49];
assign bits_48    = block[48];
assign bits_44_43 = block[44:43];
assign bits_41_39 = block[41:39];

assign bits_38_34 = block[38:34];
assign bits_32    = block[32];
assign bits_31_25 = block[31:25];
assign bits_24_19 = block[24:19];

assign bits_18_13 = block[18:13];
assign bits_12_6  = block[12:6];
assign bits_5_0   = block[5:0];

reg valid;
reg[8 * 3 - 1:0] baseColor_0_d;
reg[8 * 3 - 1:0] baseColor_1_d;
reg[8 * 3 - 1:0] baseColor_2_d;

assign color_rts   = valid && rtr;
assign baseColor_0 = baseColor_0_d;
assign baseColor_1 = baseColor_1_d;
assign baseColor_2 = baseColor_2_d;

always@(posedge sclk) begin
    baseColor_0_d <= 24'd0;
    baseColor_1_d <= 24'd0;
    baseColor_2_d <= 24'd0;
    valid         <= 1'b0;
    if (mode == `Planar && rtr) begin
        valid <= 1'b1;
        baseColor_0_d[7 : 0] <= {bits_62_57[5:0], bits_62_57[5:4]};
        baseColor_0_d[15: 8] <= {bits_56, bits_54_49[5:0], bits_56};
        baseColor_0_d[23:16] <= {bits_48, bits_44_43[1:0], bits_41_39[2:0], 
                                 bits_48, bits_44_43[1]};

        baseColor_1_d[7 : 0] <= {bits_38_34[4:0], bits_32, bits_38_34[4:3]};
        baseColor_1_d[15: 8] <= {bits_31_25[6:0], bits_31_25[6]};
        baseColor_1_d[23:16] <= {bits_24_19[5:0], bits_24_19[5:4]};
        
        baseColor_2_d[7 : 0] <= {bits_18_13[5:0], bits_18_13[5:4]};
        baseColor_2_d[15: 8] <= {bits_12_6[6:0], bits_12_6[6]};
        baseColor_2_d[23:16] <= {bits_5_0[5:0], bits_5_0[5:4]};
    end
end

endmodule
