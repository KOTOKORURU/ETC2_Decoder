`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:15:57 10/08/2022
// Design Name:   etc_decoder
// Module Name:   D:/etc_hw/ise_proj/etc_decoder/tb/tb_etc_whole.v
// Project Name:  etc_decoder
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: etc_decoder
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////



module tb_etc_whole;
 integer dout;
// Inputs
reg vga_clk;
reg sclk;
reg rst;
reg rd_en;
reg [31:0] read_addr;
// 2355260ns -> to finish the image decode
initial begin
	// Initialize Inputs
	vga_clk = 1'b1;
	sclk    = 1'b1;
	rst    <= 1'b1;
	rd_en  <= 1'b0; // LCD read Enable
	read_addr = 0;
	//dout = $fopen("D:/etc_hw/ise_proj/etc_decoder/tb/color.txt", "w");
	#40
	rst   <= 1'b0;
end

always #10 sclk = ~sclk;
always #50 vga_clk = ~vga_clk;

// Outputs
wire [15:0] rgb;
//wire [31:0] tb_write_address;
wire decode_finished;
etc_decoder etc_decoder_inst (
	.vga_clk(vga_clk), 
	.sclk(sclk), 
	.rst(rst), 
	.rd_en(rd_en), 
	.read_addr(read_addr), 
	.rgb(rgb),
	//.address_tb(tb_write_address),
	.decode_finished(decode_finished)
);


always@(posedge vga_clk) begin
	if(rst) begin
		read_addr <= 31'd0;
		rd_en     <= 1'b0;
	end
	else begin
		if(rd_en) read_addr <= read_addr + 2'd1;
		else      rd_en     <= decode_finished; // && LCD_read_valid;
	end
end

/*
//Output color to text.
always@(posedge sclk) begin
	if(decode_finished) begin
		$fclose(dout);
	end
	else if((tb_write_address != 32'd0 && rgb != 16'd0) ||
	(tb_write_address == 32'd0 && rgb != 16'd0)) begin
		$fwrite(dout,"Address:%d  Rgb:%d\n", tb_write_address, rgb);
	end

end
*/

initial begin
    $timeformat(-9, 0, "ns", 6);
    $monitor("@time %t: address = %d, rgb = %d", $time, read_addr, rgb); // 0.1ns latency
end


endmodule

