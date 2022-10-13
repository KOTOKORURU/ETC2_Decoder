
// tb for mode detector

`timescale 1ns/1ns

module tb_mode_detect();

reg sclk;
reg rst;
reg[63:0] data;
reg valid;
reg flags;

initial
	begin 
	sclk   = 1'b1;
	rst    <= 1'b1;
	flags  = 1'b0;
	//data   = 64'h4554453200fef0e0; // block 0 differential
	//data   = 64'hf387b98341197667;   // block 662 TMODE
	//data   = 64'h47582425E600411B;   // block 320 individual
	data  = 64'h5f91045b86f674a5; // block 589 plannar
	valid  = 1'b0;
	#20
	rst    <= 1'b0;
	valid  <= 1'b1;
	end

always #10 sclk = ~sclk;

wire mode_valid;
wire[2:0] mode;

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

endmodule

