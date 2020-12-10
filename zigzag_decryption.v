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
// Description:		This block decrypts a zigzag-encrypted message and
//					sends it out, one character at a time
//
// Dependencies:	N/A
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Implement busy port
// Revision 0.03 - Doc Comments Added
// Revision 0.04 - After a few sleepless nights (2 to be precise) of futile attempts to implement this
//					in a comb always block and running into countless & confusing errors,
//					I decided to ditch that and try a seq implementation
//					This is the first attempt at an implementation for decryption where key=3
//					I would like to formally apologise for what you're about to read... but it works
// Revision 0.05 - Implement decryption algo for key = 2. Code optimizations on the way... Here be dragons
// Revision 0.06 - Remove duplicate code, $write statements and unused signals
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
	reg [D_WIDTH * MAX_NOF_CHARS - 1 : 0] message = 0;
	reg [KEY_WIDTH - 1 : 0] n = 0;
	reg [KEY_WIDTH - 1 : 0] index_o = 0;

	reg [KEY_WIDTH - 1 : 0] i = 0;
	reg [KEY_WIDTH - 1 : 0] j = 0;
	reg [KEY_WIDTH - 1 : 0] k = 0;
	reg [KEY_WIDTH - 1 : 0] state = 0;
	reg [KEY_WIDTH - 1 : 0] aux1 = 0;
	reg [KEY_WIDTH - 1 : 0] aux2 = 0;

	always @(posedge clk) begin
		if (rst_n) begin
			if (valid_i) begin
				if (data_i != START_DECRYPTION_TOKEN) begin
					message[D_WIDTH * n +: D_WIDTH] <= data_i;
					n <= n + 1'b1;
				end else begin
					index_o <= 0;
					busy <= 1;

					i <= 0;
					j <= 0;
					k <= 0;
					state <= 0;
					index_o <= 0;
					
					if (key == 2) begin
						aux1 <= (n>>1) + (n&1);
					end
					if (key == 3) begin
						aux1 <= (n>>2) + ( ((n&3) > 0) ? 1 : 0 );  // elements in the first row
						aux2 <= (n>>2) * 2 + ( ((n&3) > 1) ? 1 : 0 ); // elements in the second row
					end
				end
			end

			if (busy) begin
				case (key)
					2: begin
						if (index_o < n) begin
							valid_o <= 1;
							index_o <= index_o + 1;
							if (state == 0) begin
								data_o <= message[D_WIDTH * i +: D_WIDTH];
								state <= 1;
							end 
							if (state == 1) begin
								data_o <= message[D_WIDTH * ( i + aux1 ) +: D_WIDTH];
								i <= i + 1;
								state <= 0;
							end 
						end
					end
					3: begin // a cycle of 4 units
						if (index_o < n) begin
							valid_o <= 1;
							index_o <= index_o + 1;
							if (state == 0) begin
								data_o <= message[D_WIDTH * i +: D_WIDTH];
								i <= i + 1;
								state <= 1;
							end 
							if (state == 1) begin
								data_o <= message[D_WIDTH * ( j + aux1 ) +: D_WIDTH];
								j <= j + 1;
								state <= 2;
							end 
							if (state == 2) begin
								data_o <= message[D_WIDTH * ( k + aux1 + aux2 ) +: D_WIDTH];
								k <= k + 1;
								state <= 3;
							end
							if (state == 3) begin
								data_o <= message[D_WIDTH * ( j + aux1 ) +: D_WIDTH];
								j <= j + 1;
								state <= 0;
							end
						end
					end

					default: begin
						if (index_o < n) begin
							valid_o <= 1;
							data_o <= message[D_WIDTH * index_o +: D_WIDTH];
							index_o <= index_o + 1'b1;
						end
					end
				endcase
				if (index_o >= n) begin
					valid_o <= 0;
					data_o <= 0;
					busy <= 0;
					index_o <= 0;
					n <= 0;
					message <= 0;
					aux1 <= 0;
					aux2 <= 0;
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
endmodule
