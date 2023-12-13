`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MetalGear
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    etc_rgb_decoder_th 
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
module etc_rgb_decoder_th(
    sclk,
    //rsrt, do not need this
    // input
    rtr,
    mode,
    block,
    
    // output
    color_rts,
    baseColor_0,
    baseColor_1,
    baseColor_2,
    baseColor_3
    );

`include "etc_param.vh"
input sclk;
//input rsrt;

input rtr;
input[63:0] block;
input[2 :0] mode;

output color_rts;
output[8 * 3 - 1:0] baseColor_0;
output[8 * 3 - 1:0] baseColor_1;
output[8 * 3 - 1:0] baseColor_2;
output[8 * 3 - 1:0] baseColor_3;

wire[1:0] bits_60_59;
wire[1:0] bits_57_56;
wire[3:0] bits_55_52;

wire[3:0] bits_51_48;
wire[3:0] bits_47_44;
wire[3:0] bits_43_40;
wire[3:0] bits_39_36;
wire[3:0] bits_62_59;

wire[2:0] bits_58_56;
wire      bits_52;
wire      bits_51;
wire[3:0] bits_49_47;

wire[3:0] bits_46_43;
wire[3:0] bits_42_39;
wire[3:0] bits_38_35;


wire      bits_32;
wire      bits_34;
wire[1:0] bits_35_34;
wire[1:0] bits_34_33;

assign bits_60_59 = block[60:59];
assign bits_57_56 = block[57:56];
assign bits_55_52 = block[55:52];

assign bits_51_48 = block[51:48];
assign bits_47_44 = block[47:44];
assign bits_43_40 = block[43:40];
assign bits_39_36 = block[39:36];
assign bits_62_59 = block[62:59];

assign bits_58_56 = block[58:56];
assign bits_52    = block[52];
assign bits_51    = block[51];
assign bits_49_47 = block[49:47];

assign bits_46_43 = block[46:43];
assign bits_42_39 = block[42:39];
assign bits_38_35 = block[38:35];

assign bits_32    = block[32];
assign bits_34    = block[34];
assign bits_35_34 = block[35:34];
assign bits_34_33 = block[34:33];



reg[8 * 3 - 1:0] baseColor_0_q0;
reg[8 * 3 - 1:0] baseColor_1_q0;
reg[8 * 3 - 1:0] baseColor_2_q0;
reg[2:0] dIndex;
reg      bigger;
reg[3:0] tmode_color_red;
reg[3:0] hmode_color_green;
reg[3:0] hmode_color_blue;
always@(*) begin

    baseColor_0_q0 = 24'd0;
    baseColor_1_q0 = 24'd0;
    baseColor_2_q0 = 24'd0;
    dIndex         = 3'd0;
    bigger         = 1'b0;
    if (rtr && mode == `TMode) begin
        dIndex = (bits_35_34 << 1'b1 | bits_32);
        tmode_color_red       = (bits_60_59 << 2'd2 | bits_57_56);
        baseColor_0_q0[7 : 0] = {2{tmode_color_red}};
        baseColor_0_q0[15: 8] = {2{bits_55_52}};
        baseColor_0_q0[23:16] = {2{bits_51_48}};
        
        baseColor_2_q0[7 : 0] = {2{bits_47_44}};
        baseColor_2_q0[15: 8] = {2{bits_43_40}};
        baseColor_2_q0[23:16] = {2{bits_39_36}};
    end
    else if (rtr && mode == `HMode) begin
        dIndex = ((bits_34 << 2'd2) | bits_32);
        hmode_color_green     = (bits_58_56 << 1 | bits_52);
        hmode_color_blue      = (bits_51 << 2'd3 | bits_49_47);
        baseColor_0_q0[7 : 0] = {2{bits_62_59}};
        baseColor_0_q0[15: 8] = {2{hmode_color_green}};
        baseColor_0_q0[23:16] = {2{hmode_color_blue}};
        
        baseColor_1_q0[7 : 0] = {2{bits_46_43}};
        baseColor_1_q0[15: 8] = {2{bits_42_39}};
        baseColor_1_q0[23:16] = {2{bits_38_35}};
    end
    
    bigger = {baseColor_0_q0[7:0], baseColor_0_q0[15:8], baseColor_0_q0[23:16]}>=
             {baseColor_1_q0[7:0], baseColor_1_q0[15:8], baseColor_1_q0[23:16]};
end


reg[2:0] dIndex_2;
always@(*) begin
    dIndex_2 = 3'd0;
    if (rtr && mode == `HMode) begin
        dIndex_2 = dIndex | bigger;
    end
end

reg[6:0] d;
always@(*) begin
    d = 7'd0;
    if (rtr && mode == `TMode) begin
    case(dIndex)
        3'd0 : d = 7'd3;
        3'd1 : d = 7'd6;
        3'd2 : d = 7'd11;
        3'd3 : d = 7'd16;
        3'd4 : d = 7'd23;
        3'd5 : d = 7'd32;
        3'd6 : d = 7'd41;
        3'd7 : d = 7'd64;
    default:
        d = 7'd0;
    endcase
    end
    else begin
        case(dIndex_2)
        3'd0 : d = 7'd3;
        3'd1 : d = 7'd6;
        3'd2 : d = 7'd11;
        3'd3 : d = 7'd16;
        3'd4 : d = 7'd23;
        3'd5 : d = 7'd32;
        3'd6 : d = 7'd41;
        3'd7 : d = 7'd64;
        default:
        d = 7'd0;
        endcase
    end
end

reg[10 * 3 - 1:0] baseColor_0_q;
reg[10 * 3 - 1:0] baseColor_1_q;
reg[10 * 3 - 1:0] baseColor_2_q;
reg[10 * 3 - 1:0] baseColor_3_q;
always@(*) begin
        
        baseColor_0_q[9 : 0]  = 30'd0;
        baseColor_0_q[19:10]  = 30'd0;
        baseColor_0_q[29:20]  = 30'd0;

        baseColor_1_q[9 : 0]  = 30'd0;
        baseColor_1_q[19:10]  = 30'd0;
        baseColor_1_q[29:20]  = 30'd0;

        baseColor_2_q[9 : 0]  = 30'd0;
        baseColor_2_q[19:10]  = 30'd0;
        baseColor_2_q[29:20]  = 30'd0;

        baseColor_3_q[9 : 0]  = 30'd0;
        baseColor_3_q[19:10]  = 30'd0;
        baseColor_3_q[29:20]  = 30'd0;
    
    if (rtr && mode == `TMode) begin
        baseColor_0_q[9 : 0] = baseColor_0_q0[7  : 0];
        baseColor_0_q[19:10] = baseColor_0_q0[15 : 8];
        baseColor_0_q[29:20] = baseColor_0_q0[23 :16];
    
        baseColor_1_q[9 : 0] = baseColor_2_q0[7  : 0] + d;
        baseColor_1_q[19:10] = baseColor_2_q0[15 : 8] + d;
        baseColor_1_q[29:20] = baseColor_2_q0[23 :16] + d;
        
        baseColor_1_q[9 : 0] = clamp0_255(baseColor_1_q[9 : 0]);
        baseColor_1_q[19:10] = clamp0_255(baseColor_1_q[19:10]);
        baseColor_1_q[29:20] = clamp0_255(baseColor_1_q[29:20]);
        
        baseColor_2_q[9 : 0] = baseColor_2_q0[7  : 0];
        baseColor_2_q[19:10] = baseColor_2_q0[15 : 8];
        baseColor_2_q[29:20] = baseColor_2_q0[23 :16];
        
        baseColor_3_q[9 : 0] = (baseColor_2_q0[7  : 0] > d) ? (baseColor_2_q0[7 : 0] - d) : 10'd0;
        baseColor_3_q[19:10] = (baseColor_2_q0[15 : 8] > d) ? (baseColor_2_q0[15: 8] - d) : 10'd0;
        baseColor_3_q[29:20] = (baseColor_2_q0[23 :16] > d) ? (baseColor_2_q0[23:16] - d) : 10'd0;
        
        baseColor_3_q[9 : 0] = clamp0_255(baseColor_3_q[9 : 0]);
        baseColor_3_q[19:10] = clamp0_255(baseColor_3_q[19:10]);
        baseColor_3_q[29:20] = clamp0_255(baseColor_3_q[29:20]);
    end
    else if (rtr && mode == `HMode) begin
        baseColor_0_q[9 : 0] = baseColor_0_q0[7  :0] + d;
        baseColor_0_q[19:10] = baseColor_0_q0[15 :8] + d;
        baseColor_0_q[29:20] = baseColor_0_q0[23:16] + d;
        
        baseColor_0_q[9 : 0] = clamp0_255(baseColor_0_q[9 : 0]);
        baseColor_0_q[19:10] = clamp0_255(baseColor_0_q[19:10]);
        baseColor_0_q[29:20] = clamp0_255(baseColor_0_q[29:20]);
    
        baseColor_1_q[9 : 0] = (baseColor_0_q0[7 : 0] > d) ?  baseColor_0_q0[7  :0] - d : 10'd0;
        baseColor_1_q[19:10] = (baseColor_0_q0[15: 8] > d) ?  baseColor_0_q0[15: 8] - d : 10'd0;
        baseColor_1_q[29:20] = (baseColor_0_q0[23:16] > d) ?  baseColor_0_q0[23:16] - d : 10'd0;
        
        baseColor_1_q[9 : 0] = clamp0_255(baseColor_1_q[9 : 0]);
        baseColor_1_q[19:10] = clamp0_255(baseColor_1_q[19:10]);
        baseColor_1_q[29:20] = clamp0_255(baseColor_1_q[29:20]);
        
        baseColor_2_q[9 : 0] = baseColor_1_q0[7  :0] + d;
        baseColor_2_q[19:10] = baseColor_1_q0[15 :8] + d;
        baseColor_2_q[29:20] = baseColor_1_q0[23:16] + d;

        baseColor_2_q[9 : 0] = clamp0_255(baseColor_2_q[9 : 0]);
        baseColor_2_q[19:10] = clamp0_255(baseColor_2_q[19:10]);
        baseColor_2_q[29:20] = clamp0_255(baseColor_2_q[29:20]);

        baseColor_3_q[9 : 0] = (baseColor_1_q0[7 : 0] > d) ?  baseColor_1_q0[7  :0] - d : 10'd0;
        baseColor_3_q[19:10] = (baseColor_1_q0[15: 8] > d) ?  baseColor_1_q0[15: 8] - d : 10'd0;
        baseColor_3_q[29:20] = (baseColor_1_q0[23:16] > d) ?  baseColor_1_q0[23:16] - d : 10'd0;

        baseColor_3_q[9 : 0] = clamp0_255(baseColor_3_q[9 : 0]);
        baseColor_3_q[19:10] = clamp0_255(baseColor_3_q[19:10]);
        baseColor_3_q[29:20] = clamp0_255(baseColor_3_q[29:20]);
    end
end

reg valid;
reg[8 * 3 - 1:0] baseColor_0_d;
reg[8 * 3 - 1:0] baseColor_1_d;
reg[8 * 3 - 1:0] baseColor_2_d;
reg[8 * 3 - 1:0] baseColor_3_d;

assign color_rts   = valid && rtr;
assign baseColor_0 = baseColor_0_d;
assign baseColor_1 = baseColor_1_d;
assign baseColor_2 = baseColor_2_d;
assign baseColor_3 = baseColor_3_d;

always@(posedge sclk) begin
    baseColor_0_d <= 24'd0;
    baseColor_1_d <= 24'd0;
    baseColor_2_d <= 24'd0;
    baseColor_3_d <= 24'd0;
    valid         <= 1'b0;
    if (rtr && mode == `TMode) begin
        valid                <= 1'b1;
        baseColor_0_d[7 : 0] <= baseColor_0_q[7 : 0];
        baseColor_0_d[15: 8] <= baseColor_0_q[17:10];
        baseColor_0_d[23:16] <= baseColor_0_q[27:20];

        baseColor_1_d[7 : 0] <= baseColor_1_q[7 : 0];
        baseColor_1_d[15: 8] <= baseColor_1_q[17:10];
        baseColor_1_d[23:16] <= baseColor_1_q[27:20];
        
        baseColor_2_d[7 : 0] <= baseColor_2_q[7 : 0];
        baseColor_2_d[15: 8] <= baseColor_2_q[17:10];
        baseColor_2_d[23:16] <= baseColor_2_q[27:20];
        
        baseColor_3_d[7 : 0] <= baseColor_3_q[7 : 0];
        baseColor_3_d[15: 8] <= baseColor_3_q[17:10];
        baseColor_3_d[23:16] <= baseColor_3_q[27:20];
    end
    else if (rtr && mode == `HMode) begin
        valid                <= 1'b1;
        baseColor_0_d[7 : 0] <= baseColor_0_q[7 : 0];
        baseColor_0_d[15: 8] <= baseColor_0_q[17:10];
        baseColor_0_d[23:16] <= baseColor_0_q[27:20];

        baseColor_1_d[7 : 0] <= baseColor_1_q[7 : 0];
        baseColor_1_d[15: 8] <= baseColor_1_q[17:10];
        baseColor_1_d[23:16] <= baseColor_1_q[27:20];

        baseColor_2_d[7 : 0] <= baseColor_2_q[7 : 0];
        baseColor_2_d[15: 8] <= baseColor_2_q[17:10];
        baseColor_2_d[23:16] <= baseColor_2_q[27:20];

        baseColor_3_d[7 : 0] <= baseColor_3_q[7 : 0];
        baseColor_3_d[15: 8] <= baseColor_3_q[17:10];
        baseColor_3_d[23:16] <= baseColor_3_q[27:20];
    end
end

endmodule
