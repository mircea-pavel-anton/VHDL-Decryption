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

	
	output reg [D_WIDTH - 1 : 0]	stored_data;
	output reg						valid_sig;

	always @(posedge clk) begin
		// If the reset signal is HIGH, disable all outs
		if (rst_n) begin
			stored_data <= 0;
			valid_sig <= 0;
		end else begin // if reset is LOW
			case (select)
				2b'00: begin
					// This statement handles the 'first' clock cycle, starting
					// the count when the [validX_i] gets HIGH.
					// What happens here is that the ternary operator assigns
					// the value of [dataX_i] to [stored_data] when [validX_i]
					// is HIGH, and 0 otherwise
					stored_data <= (valid0_i == 1) ? data0_i : 0;

					// This statement handles the 'second' and 'third' 
					// clock cycles, starting the count when the [validX_i]
					// gets HIGH.
					// What happens here is that the ternary operator assigns
					// the boolean value of evaluating the expression
					// (valid0_i == 1 && valid_sig == 0) to valid_sig
					// What this basically does is that when [validX_i] gets
					// HIGH and [valid_sig] is LOW, it toggles it from
					// LOW to HIGH and then back from HIGH to LOW in
					// 2 clock cycles
					valid_sig <= (valid0_i == 1 && valid_sig == 0);
				end
				
				2b'01: begin // see comments above
					stored_data <= (valid1_i == 1) ? data1_i : 0;
					valid_sig <= (valid1_i == 1 && valid_sig == 0);
				end
				
				2b'10: begin // see comments above
					stored_data <= (valid2_i == 1) ? data2_i : 0;
					valid_sig <= (valid2_i == 1 && valid_sig == 0);
				end
				
				// The [select] signal should never reach this case, but we're
				// implementing it just to be safe.
				// If [select] has an invalid value, then disable all outs
				2b'11: begin
					data_o <= 0;
					valid_o <= 0;
				end
			endcase
		end
	end
	
	assign data_o = stored_data;
	assign valid_o = valid_sig;
endmodule
