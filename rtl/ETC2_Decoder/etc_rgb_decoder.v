`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MetalGear
// Engineer: Yuhao(KOTOKORURU)
// 
// Create Date:    20:52:56 08/31/2022 
// Design Name: 
// Module Name:    etc_rgb_decoder 
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
module etc_rgb_decoder(
    sclk,
    rsrt,
    // input
    rtr,
    mode,
    block,
    
    flag_punchThrough,
    aplha,
    pixIdx,
    
    // output
    color_rts,
    r,
    g,
    b,
    a
    );
`include "etc_param.vh"

input sclk;
input rtr;
input rsrt;
input[2 :0] mode;
input[63:0] block;

input flag_punchThrough;
input aplha;
input[3:0] pixIdx;

// output
output color_rts;
output[7:0] r;
output[7:0] g;
output[7:0] b;
output[7:0] a;


wire color_rts_planar;
wire [7:0] r_planar;
wire [7:0] g_planar;
wire [7:0] b_planar;
wire [7:0] a_planar;

wire color_rts_th;
wire [7:0] r_th;
wire [7:0] g_th;
wire [7:0] b_th;
wire [7:0] a_th;

wire color_rts_id;
wire [7:0] r_id;
wire [7:0] g_id;
wire [7:0] b_id;
wire [7:0] a_id;

assign color_rts = color_rts_id || color_rts_th || color_rts_planar;

assign r = ((mode == `Individual) || (mode == `Differential)) ? r_id :
           ((mode == `TMode ) || (mode == `HMode))            ? r_th:
           (mode == `Planar)                                  ? r_planar:
           8'd0;

assign g = ((mode == `Individual) || (mode == `Differential)) ? g_id :
           ((mode == `TMode ) || (mode == `HMode))            ? g_th:
           (mode == `Planar)                                  ? g_planar:
           8'd0;

assign b = ((mode == `Individual) || (mode == `Differential)) ? b_id :
           ((mode == `TMode ) || (mode == `HMode))            ? b_th:
           (mode == `Planar)                                  ? b_planar:
           8'd0;

assign a = ((mode == `Individual) || (mode == `Differential)) ? a_id :
           ((mode == `TMode ) || (mode == `HMode))            ? a_th:
           (mode == `Planar)                                  ? a_planar:
           8'd0;

/*
assign r = r_d;
assign g = g_d;
assign b = b_d;
assign a = a_d;


reg[7:0] r_d;
reg[7:0] g_d;
reg[7:0] b_d;
reg[7:0] a_d;

always@(posedge sclk) begin
    r_d <= 8'd0;
    g_d <= 8'd0;
    b_d <= 8'd0;
    a_d <= 8'd0;
    if (rsrt) begin
        r_d <= 8'd0;
        g_d <= 8'd0;
        b_d <= 8'd0;
        a_d <= 8'd0;
    end
    else if (color_rts) begin
        casez(mode)
            3'b00?: begin
                r_d <= r_id;
                g_d <= g_id;
                b_d <= b_id;
                a_d <= a_id;
            end
            3'b01?: begin
                r_d <= r_th;
                g_d <= g_th;
                b_d <= b_th;
                a_d <= a_th;
            end
            3'b100 : begin
                r_d <= r_planar;
                g_d <= g_planar;
                b_d <= b_planar;
                a_d <= a_planar;
            end
        endcase
    end
end

*/


etc_id_decoder etc_id_decoder_inst(
    .sclk(sclk),
    .rsrt(rsrt),
    // input
    .rtr(rtr),
    .mode(mode),
    .block(block),
    .aplha(aplha),
    .flag_punchThrough(flag_punchThrough),
    .pixIdx(pixIdx),

    // output
    .color_rts(color_rts_id),
    .r(r_id),
    .g(g_id),
    .b(b_id),
    .a(a_id)
);



etc_th_decoder etc_th_decoder_inst(
    .sclk(sclk),
    //rsrt,
    // input
    .rtr(rtr),
    .mode(mode),
    .block(block),
    
    .flag_punchThrough(flag_punchThrough),
    .aplha(aplha),
    .pixIdx(pixIdx),
    
    // output
    .color_rts(color_rts_th),
    .r(r_th),
    .g(g_th),
    .b(b_th),
    .a(a_th)
    );

etc_plannar_decoder etc_plannar_decoder_inst(
    .sclk(sclk),
    .rsrt(rsrt),
    // input
    .rtr(rtr),
    .mode(mode),
    .block(block),
    .aplha(aplha),
    .pixIdx(pixIdx),
    
    // output
    .color_rts(color_rts_planar),
    .r(r_planar),
    .g(g_planar),
    .b(b_planar),
    .a(a_planar)
    );


endmodule
