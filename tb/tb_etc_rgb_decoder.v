`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:05:06 09/23/2022
// Design Name:   etc_address_generator
// Module Name:   D:/etc_hw/ise_proj/etc_decoder/tb/tb_etc_rgb_decoder.v
// Project Name:  etc_decoder
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: etc_address_generator
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_etc_rgb_decoder;

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
	//TODO: Change the value dynamically
	//data = 64'hf387b98341197667;   // block 662 TMODE
	//data = 64'h75f95d4273003010;   // block 699 HMODE
	//data = 64'h4554453200fef0e0;   // block 0 Differential
	//data = 64'h47582425E600411B;   // block 320 Individual
	data = 64'h5f91045b86f674a5;     // block 590 Planar
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


wire[7:0] r;
wire[7:0] g;
wire[7:0] b;
wire[7:0] a;
etc_rgb_decoder etc_rgb_decoder_inst(
	.sclk(sclk),
	.rsrt(rst),
	// input
	.rtr(mode_valid),
	.mode(mode),
	.block(data),
	
	.flag_punchThrough(flags),
	.aplha(1'b1),
	.pixIdx(pixIdx),
	
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
    $monitor("@time %t: mode=%d, flag=%d, baseValid=%d, block=%x, pixIdx=%d,red=%d, green=%d, blue=%d, aplha=%d",
	$time, mode, flags, valid_s2, data, pixIdx, red, green, blue, aplha);
end

endmodule

