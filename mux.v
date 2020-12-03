`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:		A.C.S
// Engineer:	Anton Mircea-Pavel
// 
// Create Date:		23:12:00 11/23/2020 
// Design Name:
// Module Name:		demux
// Project Name:	Tema2_Decryption
// Target Devices:	N/A
// Tool versions:	N/A
// Description:		Mux block that routes the decrypted message from a decryptor 
//					block to the output of the system
//
// Dependencies:	N/A
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Doc Comments Added
//////////////////////////////////////////////////////////////////////////////////

module mux #(
		parameter D_WIDTH = 8
	)(
		// Clock and reset interface
		input clk,		// system clock
		input rst_n,	// reset signal
		
		//Select interface
		input[1:0] select,
		
		// Output interface
		output reg[D_WIDTH - 1 : 0]	data_o,		// System Output Data
		output reg					valid_o,	// System Output Enable

		//output interfaces
		input [D_WIDTH - 1 : 0]		data0_i,	// Caesar Dec. Output Data
		input						valid0_i,	// Caesar Dec. Output Enable

		input [D_WIDTH - 1 : 0]		data1_i,	// Scytale Dec. Output Data
		input						valid1_i,	// Scytale Dec. Output Enable

		input [D_WIDTH - 1 : 0]		data2_i,	// ZigZag Dec. Output Data
		input						valid2_i,	// ZigZag Dec. Output Enable
	);
	/////////////////////////// LOGIC OVERVIEW ///////////////////////////
	//	Everythin happens on the positive edge of the [clk] signal		//
	//																	//
	//	if [validX_i] is HIGH, where X is given by the [select] signal:	//
	//		store the [dataX_i] in a variable							//
	//	if [stored_data] is not null and [validX_i] is LOW				//
	//		set [valid_o] to HIGH										//
	//		set [data_o] to [stored_data]								//
	//////////////////////////////////////////////////////////////////////

endmodule
