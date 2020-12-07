`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:33:04 11/23/2020 
// Design Name: 
// Module Name:    zigzag_decryption 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - Implement busy port
// Revision 0.03 - Doc Comments Added
//////////////////////////////////////////////////////////////////////////////////
module zigzag_decryption #(
				parameter D_WIDTH = 8,
				parameter KEY_WIDTH = 16,
				parameter MAX_NOF_CHARS = 50,
				parameter START_DECRYPTION_TOKEN = 8'hFA
			)(
			// Clock and reset interface
			input clk,		// system clock
			input rst_n,	// negated reset
			
			// Input interface
			input[D_WIDTH - 1:0] data_i,	// The encrypted message
			input valid_i,					// Input enable
			
			// Decryption Key
			input[KEY_WIDTH - 1 : 0] key,
			
			// Output interface
			output reg busy,					// Indicates processing is taking place
			output reg[D_WIDTH - 1:0] data_o,	// The decrypted message
			output reg valid_o					// Output enable
	);

// TODO: Implement ZigZag Decryption here


endmodule
