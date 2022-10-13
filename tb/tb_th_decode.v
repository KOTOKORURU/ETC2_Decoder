`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:34:26 09/14/2022
// Design Name:   etc_rgb_decoder_th
// Module Name:   D:/etc_hw/ise_proj/etc_decoder/tb/tb_th_decode.v
// Project Name:  etc_decoder
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: etc_rgb_decoder_th
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_th_decode;

reg sclk;
reg rst;
reg[63:0] data;
reg valid;
reg flags;
reg[3:0] pixIdx;
reg pix_valid;

initial begin 

	sclk   = 1'b1;
	flags  = 1'b0;
	data   = 64'hf387b98341197667;   // block 662 TMODE
	//data     = 64'h75f95d4273003010;   // block 699 HMODE
	valid  <= 1'b0;
	rst    <= 1'b1;
	#40
	rst    <= 1'b0;
	valid  <= 1'b1;
	pixIdx    <= 4'd0;
	pix_valid <= 1'd1;
end

always #10 sclk = ~sclk;

wire mode_valid;
wire[2:0] mode;

wire valid_s2;
//wire pixVaild = valid_s2 | valid;
always@(posedge sclk) begin
	if(rst) begin
		pixIdx    <= 4'd0;
		pix_valid <= 1'd1;
	end
	else if(pixIdx != 4'd15 && valid_s2 == 1'b1 && pix_valid) begin
		pixIdx     <= pixIdx + 1'd1;
		pix_valid  <= 1'b0;
		valid      <= ~valid_s2;
	end
	else if(valid_s2) begin
		pixIdx <= 4'd0;
		valid  <= 1'b0;
	end

	if(pix_valid == 1'b0) begin
		pix_valid <= ~pix_valid;
		valid     <= ~valid;
		pixIdx    <= pixIdx;
	end
end

mode_detect mode_detect_inst(
      .sclk(sclk),
	  .rsrt(rst),
	  // input
	  .block(data),
	  .flags(flags),
	  .mode_rtr(valid),
	  //output
	  .mode(mode),
	  .mode_rts(mode_valid)
    );

wire color_rts_1;
wire [23:0] baseColor_0;
wire [23:0] baseColor_1;
wire [23:0] baseColor_2;
wire [23:0] baseColor_3;

wire[7:0] red_0;
wire[7:0] green_0;
wire[7:0] blue_0;

wire[7:0] red_1;
wire[7:0] green_1;
wire[7:0] blue_1;

wire[7:0] red_2;
wire[7:0] green_2;
wire[7:0] blue_2;

wire[7:0] red_3;
wire[7:0] green_3;
wire[7:0] blue_3;

etc_rgb_decoder_th etc_rgb_decoder_th_inst (
	.sclk(sclk), 
	.rtr(mode_valid), 
	.mode(mode), 
	.block(data), 
	.color_rts(color_rts_1), 
	.baseColor_0(baseColor_0), 
	.baseColor_1(baseColor_1), 
	.baseColor_2(baseColor_2), 
	.baseColor_3(baseColor_3)
	);

assign red_0   = baseColor_0[7:0];
assign green_0 = baseColor_0[15:8];
assign blue_0  = baseColor_0[23:16];

assign red_1   = baseColor_1[7:0];
assign green_1 = baseColor_1[15:8];
assign blue_1  = baseColor_1[23:16];

assign red_2   = baseColor_2[7:0];
assign green_2 = baseColor_2[15:8];
assign blue_2  = baseColor_2[23:16];

assign red_3   = baseColor_3[7:0];
assign green_3 = baseColor_3[15:8];
assign blue_3  = baseColor_3[23:16];


wire[7:0] r;
wire[7:0] g;
wire[7:0] b;
wire[7:0] a;
etc_rgb_decoder_th_generator etc_rgb_decoder_th_generator_inst(
	.sclk(sclk),
	//.rsrt(rst),
	.rtr(color_rts_1),
	
	.flag_punchThrough(flags),
	.aplha(1'b1),
	.pixIdx(pixIdx),
	.block(data),
	.baseColor_0(baseColor_0),
	.baseColor_1(baseColor_1),
	.baseColor_2(baseColor_2),
	.baseColor_3(baseColor_3),

	// output
	.color_rts(valid_s2),
	.r(r),
	.g(g),
	.b(b),
	.a(a)
);

wire[7:0] red;
wire[7:0] green;
wire[7:0] blue;
wire[7:0] aplha;

assign red   = valid_s2 ? r : 8'd0;
assign green = valid_s2 ? g : 8'd0;
assign blue  = valid_s2 ? b : 8'd0;
assign aplha = valid_s2 ? a : 8'd0;


/*
initial begin
    $timeformat(-9, 0, "ns", 6);
    $monitor("@time %t: mode=%d, baseValid=%d, block=%x, \
	red_0=%d, green_0=%d, blue_0=%d, red_1=%d, green_1=%d, blue_1=%d, red_2=%d, green_2=%d, blue_2=%d, red_3=%d, green_3=%d, blue_3=%d", 
	$time, mode, color_rts, data, red_0, green_0, blue_0, red_1, 
	green_1, blue_1, red_2, green_2, blue_2, red_3, green_3, blue_3);
end
*/

initial begin
    $timeformat(-9, 0, "ns", 6);
    $monitor("@time %t: mode=%d, flag=%d, baseValid=%d, block=%x, pixIdx=%d,red=%d, green=%d, blue=%d, aplha=%d",
	$time, mode, flags, valid_s2, data, pixIdx, red, green, blue, aplha);
end

endmodule