`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yuhao
//
// Create Date:   20:26:09 09/10/2022
// Design Name:   mode_detect
// Module Name:   D:/etc_hw/ise_proj/etc_decoder/tb/tb_planner_decode.v
// Project Name:  etc_decoder
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: etc_rgb_decoder_planar
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_planner_decode;

// Inputs
reg sclk;
reg rst;
reg [63:0] data;
reg flags;
reg valid;

// Outputs
wire [2:0] mode;
wire mode_rts;

initial begin

	sclk  = 1'b1;
	//data  = 64'h5f91045b86f674a5; // block 589 Planar
	data = 64'h5F93046AA31D701B; // block 761 Planar
	flags = 1'b0;
	rst  <= 1'b1;
	valid = 1'b0;

	#40;
	rst   <= 1'b0;
	valid <= 1'b1;

end

always #10 sclk = ~sclk;

wire valid_s2;
reg[3:0] pixIdx;
reg pix_valid;
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

	mode_detect mode_detect_inst (
		.sclk(sclk),
		.rsrt(rst),
		// input
		.block(data),
		.flags(flags),
		.mode_rtr(valid),
		// output
		.mode(mode), 
		.mode_rts(mode_rts)
	);

wire [2:0] mode_out;
wire mode_valid;
assign mode_out   = mode;
assign mode_valid = mode_rts;

wire[23:0] baseColor_0;
wire[23:0] baseColor_1;
wire[23:0] baseColor_2;

etc_rgb_decoder_planar plannar_inst(
	
	.sclk(sclk),
	.rsrt(rst),
	// input
	.rtr(mode_rts),
	.mode(mode),
	.block(data),
	
	// output
	.color_rts(baseColor_valid),
	.baseColor_0(baseColor_0),
	.baseColor_1(baseColor_1),
	.baseColor_2(baseColor_2)
    );

/*

wire[7:0] red_0;
wire[7:0] green_0;
wire[7:0] blue_0;

wire[7:0] red_1;
wire[7:0] green_1;
wire[7:0] blue_1;

wire[7:0] red_2;
wire[7:0] green_2;
wire[7:0] blue_2;

assign red_0   = baseColor_0[7:0];
assign green_0 = baseColor_0[15:8];
assign blue_0  = baseColor_0[23:16];

assign red_1   = baseColor_1[7:0];
assign green_1 = baseColor_1[15:8];
assign blue_1  = baseColor_1[23:16];

assign red_2   = baseColor_2[7:0];
assign green_2 = baseColor_2[15:8];
assign blue_2  = baseColor_2[23:16];

initial begin
    $timeformat(-9, 0, "ns", 6);
    $monitor("@time %t: mode=%d, baseValid=%d, block=%x, red_0=%d, green_0=%d, blue_0=%d, red_1=%d, green_1=%d, blue_2=%d, red_2=%d, green_2=%d, blue_2=%d", 
	$time, mode, baseColor_valid, data, red_0, green_0, blue_0, red_1, green_1, blue_1, red_2, green_2, blue_2);
end
*/

wire[7:0] r;
wire[7:0] g;
wire[7:0] b;
wire[7:0] a;
etc_rgb_decoder_planar_generator plannar_generator_inst(
	.sclk(sclk),
	.rsrt(rst),
	.rtr(baseColor_valid),
	
	.aplha(1'b1),
	.pixIdx(pixIdx),
	.baseColor_0(baseColor_0),
	.baseColor_1(baseColor_1),
	.baseColor_2(baseColor_2),

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

initial begin
    $timeformat(-9, 0, "ns", 6);
    $monitor("@time %t: mode=%d, baseValid=%d, block=%x, pixIdx=%d,red=%d, green=%d, blue=%d, aplha=%d",
	$time, mode, valid_s2, data, pixIdx, red, green, blue, aplha);
end

endmodule

