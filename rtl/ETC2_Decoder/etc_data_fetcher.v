`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: LickAss
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    etc_data_fetcher 
// Project Name:   ETC2 Decoder
// Target Devices: Spartan6
// Tool versions: 
// Description:    For Source Data Fetch
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module etc_data_fetcher(
    sclk,
    rsrt,
    write_finish,
    image_finished,
    
    blockX_out,
    blockY_out,
    pixIdx_out,
    valid,
    block_out
    );

input sclk;
input rsrt;
input write_finish;

output valid;
output image_finished;
output [7 :0] blockX_out;
output [7 :0] blockY_out;
output [4 :0] pixIdx_out;
output [63:0] block_out;


reg[63:0] block;
reg[7 :0] blockX;
reg[7 :0] blockY;
reg[4 :0] pixIdx;
wire      [63:0] data_out;

reg block_finish;
reg block_valid;
reg addr_valid;
reg[10:0] blockIndx;
reg[1:0]  state;
reg[31:0] addr;
reg pix_valid;

parameter START       = 2'b00;
parameter BEGIN_FETCH = 2'b01;
parameter KEEP_BLOCK  = 2'b10;
parameter FINISH      = 2'b11;
parameter BLOCK_CNT   = 11'd1023;
parameter BLOCK_X     = 6'd32 - 1;
parameter BLOCK_Y     = 6'd32 - 1;

assign valid      = pix_valid && block_valid && ~write_finish;
assign blockX_out = blockX;
assign blockY_out = blockY;
assign pixIdx_out = pixIdx;
assign block_out  = block;
assign image_finished = (state == FINISH && rsrt != 1'b1) ? 1'b1 : 1'b0;
/* for 32 bit data output
always@(posedge sclk) begin
    if(rsrt) begin 
        state       <= UNKNOWN;
        addr_valid  <= 1'b0;
        addr        <= 32'd0;
        block_valid <= 1'b0;
    end
    else begin
    case(state)
    UNKNOWN : begin
        addr_valid      <= 1'b1;
        state           <= BEGIN_FETCH;
    end
    BEGIN_FETCH : begin
        addr_valid  <= 1'b1;
        block[31:0] <= dout_half;
        addr        <= addr + 1'd1;
        state       <= HALF_DATA;
    end
    HALF_DATA : begin
        addr_valid   <= 1'b0;
        block[63:32] <= dout_half;
        addr         <= addr + 1'd1;
        block_valid  <= 1'b1;
        state        <= KEEP_BLOCK;
    end
    KEEP_BLOCK : begin
        addr_valid <= addr_valid;
        addr       <= addr;
        block      <= block;
        state      <= KEEP_BLOCK;
        if(block_finish) begin 
            addr_valid   <= 1'b1;
            block_valid  <= 1'b0;
            state        <= BEGIN_FETCH;
        end
    end
    default:
        state <= UNKNOWN;
    endcase
    end
end
*/

// SM for data fetch
always@(posedge sclk) begin
    state <= START;
    if(rsrt) begin 
        addr_valid  <= 1'b1;
        addr        <= 32'd0;
        block_valid <= 1'b0;
        block       <= 64'd0;
        blockIndx   <= 11'd0;
        state       <= START;
    end
    else begin
    case(state)
    START : begin
        addr_valid      <= 1'b1;
        state           <= BEGIN_FETCH;
    end
    BEGIN_FETCH : begin
        addr_valid  <= 1'b0;
        block       <= data_out;
        state       <= KEEP_BLOCK;
        addr        <= addr + 4'd8;
        block_valid <= 1'b1;
    end
    KEEP_BLOCK : begin
        addr_valid <= addr_valid;
        addr       <= addr;
        block      <= block;
        state      <= KEEP_BLOCK;
        if(block_finish) begin
            addr_valid   <= 1'b1;
            block_valid  <= 1'b0;
            if(blockIndx == BLOCK_CNT) begin
                state    <= FINISH;
            end
            else begin
                blockIndx <= blockIndx + 1'd1;
                state     <= START;
            end
        end
    end
    FINISH : begin
        addr_valid  <= 1'b0;
        block       <= 64'd0;
        block_valid <= 1'b0;
        state       <= FINISH;
    end
    default:
        state <= FINISH;
    endcase
    end
end

// Update the Block
always@(posedge sclk) begin
    if(rsrt) begin
        blockX <= 8'd0;
        blockY <= 8'd0;
    end
    else if(block_finish) begin
        if(blockX < BLOCK_X ) begin
            blockX <= blockX + 1'd1;
        end
        else if(blockY < BLOCK_Y) begin
            blockY <= blockY + 1'd1;
            blockX <= 6'd0;
        end
    end
end

// Update the pix Id for Block
always@(posedge sclk) begin
    
    if(rsrt) begin
        pixIdx       <= 5'd0;
        pix_valid    <= 1'b0;
        block_finish <= 1'b0;
    end
    if(pixIdx > 4'd15) begin
        block_finish <= 1'b1;
        pixIdx       <= 5'd0;
    end
    else if(write_finish) begin
        pix_valid <= 1'b0;
        pixIdx    <= pixIdx + 1'd1;
    end
    else if(block_valid) begin
        pix_valid <= 1'b1;
        pixIdx    <= pixIdx;
    end
    
    if(block_finish) begin
        block_finish <= 1'b0;
    end
end

// Etc2 Compressed Image 128x128 -> 32x32
rom_1024x64 imageRom (
  .clka(sclk),      // input clka
  .ena(addr_valid), // input ena
  .addra(addr),     // input [31 : 0] addra
  .douta(data_out)  // output [63 : 0] douta
);

endmodule
