`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MetalGear
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    etc_rgb_decoder_id 
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
module etc_rgb_decoder_id
(
	sclk,
	rsrt,
	// input
	rtr,
	mode,
	block,
	
	// output
	color_rts,
	flipped,
	baseColor_0,
	baseColor_1
);

`include "etc_param.vh"

input sclk;
input rsrt;

input rtr;
input[63:0] block;
input[0 :2] mode;

output color_rts;
output flipped;
output[8 * 3 - 1:0] baseColor_0;
output[8 * 3 - 1:0] baseColor_1;

wire[3:0] bits_63_60;
wire[3:0] bits_55_52;
wire[3:0] bits_47_44;

wire[3:0] bits_59_56;
wire[3:0] bits_51_48;
wire[3:0] bits_43_40;

wire[4:0] bits_63_59;
wire[4:0] bits_55_51;
wire[4:0] bits_47_43;

wire signed[7:0] dr;
wire signed[7:0] dg;
wire signed[7:0] db;

// Color 0
assign bits_63_60   = bits_63_59[4:1];
assign bits_55_52   = bits_55_51[4:1];
assign bits_47_44   = bits_47_43[4:1];

assign bits_63_59   = block[63:59];
assign bits_55_51   = block[55:51];
assign bits_47_43   = block[47:43];

// Color1
assign bits_59_56   = block[59:56];
assign bits_51_48   = block[51:48];
assign bits_43_40   = block[43:40];


// dr, dg, db
assign dr = block[58:56] << 3'd5;
assign dg = block[50:48] << 3'd5;
assign db = block[42:40] << 3'd5;

reg[23:0] baseColor_0_q;
reg[23:0] baseColor_1_q;
reg signed[7:0] dr_d;
reg signed[7:0] dg_d;
reg signed[7:0] db_d;



always@(*) begin

	baseColor_0_q = 24'd0;
	baseColor_1_q = 24'd0;
	if (rsrt) begin
		baseColor_0_q = 24'd0;
		baseColor_1_q = 24'd0;
	end
	else if (mode == `Individual && rtr) begin
		baseColor_0_q[7 : 0] = {2{bits_63_60}};
		baseColor_0_q[15: 8] = {2{bits_55_52}};
		baseColor_0_q[23:16] = {2{bits_47_44}};
		
		baseColor_1_q[7 : 0] = {2{bits_59_56}};
		baseColor_1_q[15: 8] = {2{bits_51_48}};
		baseColor_1_q[23:16] = {2{bits_43_40}};
	end
	else if (mode == `Differential && rtr)begin
		baseColor_0_q[7 : 0] = {bits_63_59, bits_63_59[4:2]};
		baseColor_0_q[15: 8] = {bits_55_51, bits_55_51[4:2]};
		baseColor_0_q[23:16] = {bits_47_43, bits_47_43[4:2]};
		dr_d = (dr >>> 3'd5);
		dg_d = (dg >>> 3'd5);
		db_d = (db >>> 3'd5);
		baseColor_1_q[7 : 0] = {3'b0, bits_63_59} + dr_d;
		baseColor_1_q[15: 8] = {3'b0, bits_55_51} + dg_d;
		baseColor_1_q[23:16] = {3'b0, bits_47_43} + db_d;
	end
end

reg signed[23:0] baseColor_1_q1;

always@(*) begin
	baseColor_1_q1 = 24'd0;
	if (mode == `Differential && rtr) begin
		baseColor_1_q1[7 : 0] = {baseColor_1_q[4 : 0], baseColor_1_q[4 : 2]};
		baseColor_1_q1[15: 8] = {baseColor_1_q[12: 8], baseColor_1_q[12:10]};
		baseColor_1_q1[23:16] = {baseColor_1_q[20:16], baseColor_1_q[20:18]};
	end

end

reg[23:0] baseColor_0_d;
reg[23:0] baseColor_1_d;
reg vld_s1;
reg flipped_d;

// Output
assign flipped     = flipped_d;
assign color_rts   = vld_s1 && rtr;
assign baseColor_0 = baseColor_0_d;
assign baseColor_1 = baseColor_1_d;

// 1 clk delay
always@(posedge sclk) begin
	baseColor_0_d <= 24'd0;
	baseColor_1_d <= 24'd0;
	vld_s1        <= 1'b0;
	if (rsrt) begin
		baseColor_0_d <= 24'd0;
		baseColor_1_d <= 24'd0;
		vld_s1        <= 1'b0;
	end
	else if (rtr) begin
		baseColor_0_d <= baseColor_0_q;
		baseColor_1_d <= baseColor_1_q;
		if (mode == `Differential) begin 
			baseColor_1_d <= baseColor_1_q1;
		end
		vld_s1        <= 1'b1;
		flipped_d     <= block[32];
	end
end

endmodule
