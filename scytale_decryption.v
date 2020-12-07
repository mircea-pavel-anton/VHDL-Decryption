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
// Revision 0.03 - First attempt at an implementation
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
			output reg valid_o					// Output enable
	);	

	reg [D_WIDTH * MAX_NOF_CHARS - 1 : 0] message = 0;
	reg [KEY_WIDTH - 1 : 0] i = 0;
	reg [KEY_WIDTH - 1 : 0] j = 0;
	reg [KEY_WIDTH - 1 : 0] k = 0;

	always @(posedge clk) begin
		if (rst_n) begin
			if (valid_i) begin
				if (data_i != START_DECRYPTION_TOKEN) begin
					message[D_WIDTH * i +: D_WIDTH ] = data_i;
					i = i + 1;
				end else begin
					j <= 0;
					k <= j;
					busy <= 1;
					$display("\n| i\t\t| j\t\t| k\t\t| data_o|");
				end
			end

			if (busy) begin
				if (k < i) begin
					valid_o <= 1;
					data_o <= message[D_WIDTH * k +: D_WIDTH ];
					k <= k + key_N;
					$display("| %d\t| %d\t| %d\t| %s\t\t| message(%d)", i, j, k, data_o, k);
				end else begin
					j <= j + 1;
					k <= j + 1 + key_N;
					
					if (j + 1 < key_N) begin
						data_o <= message[D_WIDTH * (j+1) +: D_WIDTH ];
						$display("| %d\t| %d\t| %d\t| %s\t\t| message(%d)", i, j, k, data_o, j+1);
					end else begin
						i <= 0; j <= 0; k <= 0;
						message <= 0;
						valid_o <= 0;
						data_o <= 0;
						busy <= 0;
					end
				end
			end

		end else begin
			i <= 0; j <= 0; k <= 0;
			message <= 0;
			valid_o <= 0;
			data_o <= 0;
			busy <= 0;
		end
	end
endmodule
