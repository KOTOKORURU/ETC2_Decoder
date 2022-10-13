`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yuhao
// 
// Create Date:    21:09:51 09/02/2022 
// Design Name: 
// Module Name:    tb_data_fetch 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Verilog Test Fixture created by ISE for module: etc_data_fetcher
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module tb_data_fetch();

reg sclk;
reg rst;

reg write_finish;

wire[63:0] data;
wire[7:0]  blockX;
wire[7:0]  blockY;
wire[4:0]  pixIdx;
wire image_finished;
wire valid;
wire vaild_addr;
wire[31:0] address;
reg[2:0] cnt;
initial
	begin 
	sclk          = 1'b1;
	write_finish <= 1'b0;
	cnt          <= 3'd0;
	rst          <= 1'b1;
	#40
    rst          <=  1'b0;
	end

always #10 sclk = ~sclk;

always@(posedge sclk) begin
	
	if(!rst && valid) begin
		if(cnt != 3'd5)begin
			cnt          <= cnt + 1'd1;
			write_finish <= 1'b0;
		end
		else begin
			cnt          <= 3'd0;
			write_finish <= valid;
		end
	end
	else begin
		cnt          <= 1'b0;
		write_finish <= valid;
	end
end

etc_data_fetcher data_fetcher
(
	.sclk(sclk),
	.rsrt(rst),
	.write_finish(write_finish),
	
	.image_finished(image_finished),
	.blockX_out(blockX),
	.blockY_out(blockY),
	.pixIdx_out(pixIdx),
	.valid(valid),
	.block_out(data)
);

etc_address_generator etc_address_generator_inst
(
	.sclk(sclk),
	.rsrt(rst),
	.addr_rtr(valid),

	// input
	.blockX(blockX),
	.blockY(blockY),
	.pixIdx(pixIdx),
	.width(32'd128),

	// output
	.out_addr(address),
	.addr_valid(vaild_addr)
);
	
initial begin
    $timeformat(-9, 0, "ns", 6);
    $monitor("@time %t: pixIdx=%d, blockX=%d, blockY=%d, valid=%d, address=%d, data=%x", 
	$time, pixIdx, blockX, blockY, valid, address, data);
end
endmodule
