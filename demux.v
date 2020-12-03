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
// Description:		Demux block that handles routing the encrypted input
//					message to the correct decryptor block.
//
// Dependencies:	N/A
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Doc Comments Added
// Revision 0.03 - General Logic Explained in Comments
// Revision 0.04 - First attempt at an implementation
// Revision 0.05 - Bug fixes: binary syntax was wrong: 2b'00 instead of 2'b00
//////////////////////////////////////////////////////////////////////////////////

module demux #(
		parameter MST_DWIDTH = 32,
		parameter SYS_DWIDTH = 8
	)(
		// Clock and reset interface
		input clk_sys,		// system clock
		input clk_mst,		// master clock (4x system clock speed)
		input rst_n,		// reset signal
		
		//Select interface
		input[1:0] select,
		
		// Input interface
		input [MST_DWIDTH - 1 : 0]			data_i,		// Encrypted Message
		input								valid_i,	// Enable Signal
		
		//output interfaces
		output reg [SYS_DWIDTH - 1 : 0]		data0_o,	// Caesar Dec. Input
		output reg							valid0_o,	// Caesar Dec. Enable
		
		output reg [SYS_DWIDTH - 1 : 0]		data1_o,	// Scytale Dec. Output
		output reg							valid1_o,	// Scytale Dec. Enable
		
		output reg [SYS_DWIDTH - 1 : 0]		data2_o,	// ZigZag Dec. Output
		output reg							valid2_o	// ZigZag Dec. Enable
	);
	/////////////////////////// LOGIC OVERVIEW ///////////////////////////
	//	On the positive edge of [master_clock]:							//
	//		if the input is enabled ([valid_i] is HIGH):				//
	//			store [data_i] into a variable (32 bits)				//
	//																	//
	//	On the positive edge of [system_clock]:							//
	//		if the input is disabled AND the stored data is not null:	//
	//			send an 8bit packet to the apropriate output			//
	//			set the apropriate output-enable signal to HIGH			//
	//			set the other output-enable signals to LOW				//
	//			make sure to only do this for 4 clock cycles			//
	//	?? Reset pin functionality ??									//
	//////////////////////////////////////////////////////////////////////
	
	reg [MST_DWIDTH - 1 : 0] stored_data;
	reg [3 : 0] packet_counter;

	always @(posedge clk_mst) begin
		if (valid_i && !rst_n) begin
			stored_data <= data_i;
			packet_counter <= 0;
		end
		// if an else statement was implemented, stored_data would have been set to 0 
		// if valid_i is LOW, and we don't want that. We want stored_data to be 0 
		// only when the reset signal is HIGH. As such, another if statement is used
		if (rst_n) begin
			stored_data <= 0;
			packet_counter <= 0;
		end
	end

	always @(posedge clk_sys) begin
		if (!valid_i && !rst_n && stored_data != 0 && packet_counter < 3'd4) begin
			case (select)
				2'b00: begin // select = 0
					// Set the correct output data and enable
					data0_o <= stored_data[8*packet_counter +: 8];
					valid0_o <= 1;

					// Disable the other outputs
					data1_o <= 0;
					data2_o <= 0;
					valid1_o <= 0;
					valid2_o <= 0;
				end
				
				2'b01: begin // select = 1
					// Set the correct output data and enable
					data1_o <= stored_data[8*packet_counter +: 8];
					valid1_o <= 1;

					// Disable the other outputs
					data0_o <= 0;
					data2_o <= 0;
					valid0_o <= 0;
					valid2_o <= 0;
				end

				2'b10: begin // select = 2
					// Set the correct output data and enable
					data2_o <= stored_data[8*packet_counter +: 8];
					valid2_o <= 1;

					// Disable the other outputs
					data0_o <= 0;
					data1_o <= 0;
					valid0_o <= 0;
					valid1_o <= 0;
				end
				 
				// It shouldn't reach this case, but for safe measure, we'll implement it
				2'b11: begin
					// Disable all outs
					data0_o <= 0;
					data1_o <= 0;
					data2_o <= 0;
					valid0_o <= 0;
					valid1_o <= 0;
					valid2_o <= 0;
				end
			endcase

			packet_counter <= packet_counter + 3'b001;
		end

		if (packet_counter > 3'd3) begin
			// The 4 packets have been sent. Disable all outs
			data0_o <= 0;
			data1_o <= 0;
			data2_o <= 0;
			valid0_o <= 0;
			valid1_o <= 0;
			valid2_o <= 0;
		end

		if (rst_n) begin
			// Disable all outs
			data0_o <= 0;
			data1_o <= 0;
			data2_o <= 0;
			valid0_o <= 0;
			valid1_o <= 0;
			valid2_o <= 0;
		end
	end
endmodule
