`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:		A.C.S
// Engineer:	Anton Mircea-Pavel
// 
// Create Date:		23:12:00 11/23/2020 
// Design Name:
// Module Name:		Register Bank
// Project Name:	Tema2_Decryption
// Target Devices:	N/A
// Tool versions:	14.5
// Description:		This block is responsible for handling the input data from the outside.
//					It stores the keys for the cyphers and sends the select signals to the
//					*MUX blocks
//
// Dependencies:	N/A
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Doc Comments Added
// Revision 0.03 - General Logic Explained in Comments
// Revision 0.04 - First attempt at an implementation
// Revision 0.05 - Bug fix: Wrong values for *key signals when rst is HIGH
// Revision 0.06 - A few hours of debugging later... it works :)
// Revision 0.07 - Update Logic Overview
//////////////////////////////////////////////////////////////////////////////////

module decryption_regfile #(
			parameter addr_witdth	= 8,
			parameter reg_width		= 16
		)(
			// Clock and reset interface
			input clk,		// system clock
			input rst_n,	// reset signal
			
			// Register access interface
			input [addr_witdth - 1 : 0]		addr, // the address of the desired register
			input							read, // basically a read_enable signal
			input							write, // basically a write_enable signal
			input [reg_width - 1 : 0]		wdata, // the written data
			output reg [reg_width - 1 : 0]	rdata, // the read data
			output reg						done, // 'bool' value to indicate status
			output reg						error, // 'bool' value to indicate errors
			
			// Output wires
			output reg [reg_width - 1 : 0] select,	// The signal that will be 
													//sent to the MUX & DEMUX blocks
			output reg [reg_width - 1 : 0] caesar_key,
			output reg [reg_width - 1 : 0] scytale_key,
			output reg [reg_width - 1 : 0] zigzag_key
	);
	/////////////////////////// LOGIC OVERVIEW ///////////////////////////
	//	Everything happens on the positive edge of the [clk] signal		//
	//																	//
	//	set [done_temp] to HIGH id [read] OR [write] are HIGH 			//
	//	set [error_temp] to HIGH if [addr] is invalid					//
	//																	//
	//	based on [addr]:												//
	//		set [reg_temp] = [wdata] if write is HIGH					//
	//		set [rdata_temp] = reg_temp if [read] is HIGH				//
	//	assign all temp values to their corespondents					//
	//////////////////////////////////////////////////////////////////////

	reg [reg_width - 1 : 0]	rdata_temp = 0;
	reg						done_temp = 1;
	reg						error_temp = 0;
	reg [reg_width - 1 : 0] select_temp = 0;
	reg [reg_width - 1 : 0] caesar_key_temp = 0;
	reg [reg_width - 1 : 0] scytale_key_temp = 16'hFFFF;
	reg [reg_width - 1 : 0] zigzag_key_temp = 16'h2;

	always @(posedge clk) begin
		$display("| addr\t| write\t| wdata\t| read\t| rdata\t| done\t| error\t| select\t| caesar\t| scytale\t| zigzag\t|");
		$display("| 0x%0h\t| 0x%0h\t| 0x%0h\t| 0x%0h\t| 0x%0h\t| 0x%0h\t| 0x%0h\t| 0x%0h\t\t| 0x%0h\t\t| 0x%0h\t| 0x%0h\t\t| ", addr, write, wdata, read, rdata_temp, done_temp, error_temp, select_temp, caesar_key_temp, scytale_key_temp, zigzag_key_temp);
		$display("");

		done_temp = (read || write);
		error_temp = (addr == 8'd0 || addr == 8'd16 || addr == 8'd18 || addr == 8'd20) ? 0 : 1;
		case (addr)
			8'd0: begin// select_register
				$display("Select Register address detected");
				rdata_temp  = (read)  ? select_temp : 0;
				select_temp = (write) ? {14'b0, wdata[1:0]} : select_temp;
			end

			8'd16: begin // Caesar key register
				$display("Caesar Register address detected");
				rdata_temp = (read) ? caesar_key_temp : 0;
				caesar_key_temp = (write) ? wdata : caesar_key_temp;
			end

			8'd18: begin // Scytale key register
				$display("Scytale Register address detected");
				rdata_temp = (read) ? scytale_key_temp : 0;
				scytale_key_temp = (write) ? wdata : scytale_key_temp;
			end

			8'd20: begin // ZigZag key register
				$display("ZigZag Register address detected");
				rdata_temp = (read) ? zigzag_key_temp : 0;
				zigzag_key_temp = (write) ? wdata : zigzag_key_temp;
			end

			default: begin
				$display("Invalid address!");
			end
		endcase
		
		error		<= error_temp;
		rdata		<= rdata_temp;
		select		<= select_temp;
		caesar_key	<= caesar_key_temp;
		scytale_key	<= scytale_key_temp;
		zigzag_key	<= zigzag_key_temp;
		done		<= done_temp;
	end
endmodule
