`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:24:12 11/27/2020 
// Design Name: 
// Module Name:    scytale_decryption 
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
//////////////////////////////////////////////////////////////////////////////////
module scytale_decryption#(
			parameter D_WIDTH = 8, 
			parameter KEY_WIDTH = 8, 
			parameter MAX_NOF_CHARS = 50,
			parameter START_DECRYPTION_TOKEN = 8'hFA
		)(
			// Clock and reset interface
			input clk,		// system clock
			input rst_n,	// negated reset
			
			// Input interface
			input[D_WIDTH - 1:0] data_i,	// The encrypted message
			input valid_i,					// Input enable
			
			// Decryption Keys
			input[KEY_WIDTH - 1 : 0] key_N,		// Matrix columns
			input[KEY_WIDTH - 1 : 0] key_M,		// Matrix rows
			
			// Output interface
			output reg busy,					// Indicates processing is taking place
			output reg[D_WIDTH - 1:0] data_o,	// The decrypted message
			output reg valid_o,					// Output enable
    );

// TODO: Implement Scytale Decryption here



endmodule
