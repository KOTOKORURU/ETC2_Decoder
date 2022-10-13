`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:11:55 08/06/2022 
// Design Name: 
// Module Name:    etc_param 
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

`define Individual   3'b000
`define Differential 3'b001
`define TMode        3'b010
`define HMode        3'b011
`define Planar       3'b100

function automatic [7:0] clamp0_255;
  input [9:0] data;
  reg [7:0] data_out;
  begin
    casez ({data[9:8]})
      2'b01: data_out = 8'hff;
      2'b1?: data_out = 8'h00;
      default: data_out = data[7:0];
    endcase
    clamp0_255 = data_out;
  end
endfunction