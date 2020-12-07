`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:17:08 11/23/2020 
// Design Name: 
// Module Name:    ceasar_decryption 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - Doc Comments Added
// Revision 0.03 - Implement busy port, fix typo in module name
//////////////////////////////////////////////////////////////////////////////////
module caesar_decryption #(
				parameter D_WIDTH = 8,
				parameter KEY_WIDTH = 16
			)(
			// Clock and reset interface
			input clk,		// system clock
			input rst_n,	// negated reset
			
			// Input interface
			input[D_WIDTH - 1:0] data_i, // The encrypted message
			input valid_i, // Data in enable
			
			// Decryption Key
			input[KEY_WIDTH - 1 : 0] key, // The number of characters to shift
			
			// Output interface
			output reg busy,
			output reg[D_WIDTH - 1:0] data_o, // The decrypted message
			output reg valid_o // Data out Enable
	);

// TODO: Implement Caesar Decryption here

endmodule
