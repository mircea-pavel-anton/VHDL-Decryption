`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:12:00 11/23/2020 
// Design Name: 
// Module Name:    demux 
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

module demux #(
		parameter MST_DWIDTH = 32,
		parameter SYS_DWIDTH = 8
	)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		//Select interface
		input[1:0] select,
		
		// Input interface
		input [MST_DWIDTH -1 : 0]			data_i,
		input								valid_i,
		
		//output interfaces
		output reg [SYS_DWIDTH - 1 : 0]		data0_o,
		output reg							valid0_o,
		
		output reg [SYS_DWIDTH - 1 : 0]		data1_o,
		output reg							valid1_o,
		
		output reg [SYS_DWIDTH - 1 : 0]		data2_o,
		output reg							valid2_o
    );
	
	
	// TODO: Implement DEMUX logic
	

endmodule
