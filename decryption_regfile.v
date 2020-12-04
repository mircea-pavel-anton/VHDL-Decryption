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
// Revision 0.08 - Separate comb and seq logic into separate slways blocks
// Revision 0.09 - Implement reset signal functionality
// Revision 0.10 - Remove initialization values for temp regs
// Revision 0.11 - Remove temp variables and comb logic as it is redundant
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
	//	set [done] to HIGH id [read] OR [write] were HIGH 				//
	//	set [error] to HIGH if [addr] were invalid						//
	//																	//
	//	based on [addr]:												//
	//		set [reg] = [wdata] if write is HIGH						//
	//		set [rdata] = reg if [read] is HIGH							//
	//////////////////////////////////////////////////////////////////////

	always @(posedge clk) begin
		$display("| reset\t| addr\t| write\t| wdata\t| read\t| rdata\t| done\t| error\t| select\t| caesar\t| scytale\t| zigzag\t|");
		$display("| 0x%0h\t| 0x%0h\t| 0x%0h\t| 0x%0h\t| 0x%0h\t| 0x%0h\t| 0x%0h\t| 0x%0h\t| 0x%0h\t\t| 0x%0h\t\t| 0x%0h\t| 0x%0h\t\t| ", rst_n, addr, write, wdata, read, rdata, done, error, select, caesar_key, scytale_key, zigzag_key);
		$display("");

		if (rst_n) begin
			done <= (read || write);
			error <= (addr == 8'd0 || addr == 8'd16 || addr == 8'd18 || addr == 8'd20) ? 0 : 1;
			case (addr)
				8'd0: begin // select_register
					$display("Select Register address detected");
					rdata <= (read)  ? select : 0;
					select <= (write) ? {14'b0, wdata[1:0]} : select;
				end

				8'd16: begin // Caesar key register
					$display("Caesar Register address detected");
					rdata <= (read) ? caesar_key : 0;
					caesar_key <= (write) ? wdata : caesar_key;
				end

				8'd18: begin // Scytale key register
					$display("Scytale Register address detected");
					rdata <= (read) ? scytale_key : 0;
					scytale_key <= (write) ? wdata : scytale_key;
				end

				8'd20: begin // ZigZag key register
					$display("ZigZag Register address detected");
					rdata <= (read) ? zigzag_key : 0;
					zigzag_key <= (write) ? wdata : zigzag_key;
				end
			endcase
		end else begin
			rdata <= 0;
			done <= 1;
			error <= 0;
			select <= 0;
			caesar_key <= 0;
			scytale_key <= 16'hFFFF;
			zigzag_key <= 16'h2;
		end
	end
endmodule
