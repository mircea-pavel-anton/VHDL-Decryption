`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:		A.C.S
// Engineer:	Anton Mircea-Pavel
// 
// Create Date:		22:33:04 11/23/2020 
// Design Name: 
// Module Name:		zigzag_decryption 
// Project Name:	Tema2_Decryption
// Target Devices:	N/A
// Tool versions:	14.5
// Description:		This blocindex_odecrypts a zigzag-encrypted message and
//					sends it out, one character at a time
//
// Dependencies:	N/A
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
			// Clocindex_oand reset interface
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
	reg [D_WIDTH * MAX_NOF_CHARS - 1 : 0] message = 0;
	reg [D_WIDTH * MAX_NOF_CHARS - 1 : 0] message_aux = 0;
	reg [KEY_WIDTH - 1 : 0] n = 0;
	reg [KEY_WIDTH - 1 : 0] index_o = 0;

	always @(posedge clk) begin
		if (rst_n) begin
			if (valid_i) begin
				if (data_i != START_DECRYPTION_TOKEN) begin
					message[D_WIDTH * n +: D_WIDTH] <= data_i;
					n <= n + 1;
				end else begin
					index_o <= 0;
					busy <= 1;
				end
			end

			if (busy) begin
				if (index_o < n) begin
					valid_o <= 1;
					data_o <= message[D_WIDTH * index_o +: D_WIDTH];
					index_o <= index_o + 1;
				end else begin
					valid_o <= 0;
					data_o <= 0;
					busy <= 0;
					index_o <= 0;
					n <= 0;
					message <= 0;
				end
			end
		end else begin
			valid_o <= 0;
			data_o <= 0;
			busy <= 0;
			index_o <= 0;
			n <= 0;
			message <= 0;
		end
	end

	always @(busy) begin
		if (busy) begin
			case (key)
				// todo handle all different keys here
				default:
					message_aux = message;
			endcase
		end
	end
endmodule
