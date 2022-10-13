`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yuhao
// 
// Create Date:    20:21:33 09/04/2022 
// Design Name: 
// Module Name:    tb_decode_id 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
module tb_decode_id();


reg sclk;
reg rst;
reg[63:0] data;
reg valid;
reg flags;
reg[3:0] pixIdx;
reg pix_valid;
initial begin 

	sclk      = 1'b1;
	flags     = 1'b0;
	//data   = 64'h4554453200fef0e0; // block 0 Differential
	//data      = 64'h47582425E600411B;   // block 320 Individual
	//data = 64'h9a997107431398df;
	//data = 64'hbfa880239177d5a0;
	data = 64'h433B1242000FF11E; // block 10
	valid     <= 1'b0;
	rst       <= 1'b1;
	#40
	rst       <= 1'b0;
	valid     <= 1'b1;
	pix_valid <= 4'd0;
	pixIdx    <= 1'd0;

end

always #10 sclk = ~sclk;

wire mode_valid;
wire[2:0] mode;
wire baseColor_valid;
wire isflipped;
wire[23:0] baseColor_0;
wire[23:0] baseColor_1;

wire[7:0] red_0;
wire[7:0] green_0;
wire[7:0] blue_0;

wire[7:0] red_1;
wire[7:0] green_1;
wire[7:0] blue_1;

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

 etc_rgb_decoder_id id_inst
(
	.sclk(sclk),
	.rsrt(rst),
	// input
	.rtr(mode_valid),
	.mode(mode),
	.block(data),
	
	// output
	.color_rts(baseColor_valid),
	.flipped(isflipped),
	.baseColor_0(baseColor_0),
	.baseColor_1(baseColor_1)
);
//assign red_0   = baseColor_0[7:0];
//assign green_0 = baseColor_0[15:8];
//assign blue_0  = baseColor_0[23:16];

//assign red_1   = baseColor_1[7:0];
//assign green_1 = baseColor_1[15:8];
//assign blue_1  = baseColor_1[23:16];



wire[7:0] r;
wire[7:0] g;
wire[7:0] b;
wire[7:0] a;
etc_rgb_decoder_id_generator id_generator_inst
(
	.sclk(sclk),
	.rsrt(rst),
	.rtr(baseColor_valid),
	
	.flipped(isflipped),
	.flag_punchThrough(flags),
	.aplha(1'b1),
	.pixIdx(pixIdx),
	.block(data),
	.baseColor_0(baseColor_0),
	.baseColor_1(baseColor_1),

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
    $monitor("@time %t: mode=%d, baseValid=%d, flipped=%d, block=%x, red_0=%d, green_0=%d, blue_0=%d, red_1=%d, green_1=%d, blue_1=%d", 
	$time, mode, baseColor_valid, isflipped, data, red_0, green_0, blue_0, red_1, green_1, blue_1);
end
*/


initial begin
    $timeformat(-9, 0, "ns", 6);
    $monitor("@time %t: mode=%d, baseValid=%d, flipped=%d, block=%x, pixIdx=%d,red=%d, green=%d, blue=%d, aplha=%d",
	$time, mode, valid_s2, isflipped, data, pixIdx, red, green, blue, aplha);
end

endmodule
