`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     A.C.S
// Engineer:    Anton Mircea-Pavel
// 
// Create Date:     23:12:00 11/23/2020 
// Design Name:
// Module Name:     demux
// Project Name:    Tema2_Decryption
// Target Devices:  N/A
// Tool versions:   14.5
// Description:     Demux block that handles routing the encrypted input
//                  message to the correct decryptor block.
//
// Dependencies:    N/A
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Doc Comments Added
// Revision 0.03 - General Logic Explained in Comments
// Revision 0.04 - First attempt at an implementation
// Revision 0.05 - Bug fixes: binary syntax was wrong: 2b'00 instead of 2'b00
// Revision 0.06 - Bug fix: fix reset condition to !rst_n instead of rst_n
// Revision 0.07 - Refactor:
//                  - Switch to ternary operators instead of case statement
//                  - Refactor if statements for better readability
// Revision 0.08 - Complete rework, but data_o is 1cc late...
// Revision 0.09 - Migrate to a 4 state FSM structure
//               - ( i tried to reverse engineer the signals from the ref modul
//                 e by looking at the waves)
//////////////////////////////////////////////////////////////////////////////////

module demux #(
        parameter MST_DWIDTH = 32,
        parameter SYS_DWIDTH = 8
    )(
        // Clock and reset interface
        input clk_sys,      // system clock
        input clk_mst,      // master clock (4x system clock speed)
        input rst_n,        // negated reset signal
        
        //Select interface
        input[1:0] select,
        
        // Input interface
        input [MST_DWIDTH - 1 : 0]          data_i,     // Encrypted Message
        input                               valid_i,    // Enable Signal
        
        //output interfaces
        output reg [SYS_DWIDTH - 1 : 0]     data0_o,    // Caesar Dec. Input
        output reg                          valid0_o,   // Caesar Dec. Enable
        
        output reg [SYS_DWIDTH - 1 : 0]     data1_o,    // Scytale Dec. Output
        output reg                          valid1_o,   // Scytale Dec. Enable
        
        output reg [SYS_DWIDTH - 1 : 0]     data2_o,    // ZigZag Dec. Output
        output reg                          valid2_o    // ZigZag Dec. Enable
    );
	/////////////////////////// LOGIC OVERVIEW ///////////////////////////
	//    On the positive edge of [master_clock]:                       //
	//        if the input is enabled ([valid_i] is HIGH):              //
	//            store [data_i] into a variable (32 bits)              //
	//                                                                  //
	//    On the positive edge of [system_clock]:                       //
	//        if the input is disabled AND the stored data is not null: //
	//            send an 8bit packet to the apropriate output          //
	//            set the apropriate output-enable signal to HIGH       //
	//            set the other output-enable signals to LOW            //
	//            make sure to only do this for 4 clock cycles          //
	//////////////////////////////////////////////////////////////////////

    reg [MST_DWIDTH - 1 : 0] stored_data = 0;
    reg [1:0] state = 2'b00;

    always @(posedge clk_sys) begin
        if (rst_n) begin // if(!reset)
            case (state) // fsm start
                2'b00: begin // State 1: print 3rd character
                    data0_o  = (select == 2'b00) ? stored_data[23:16] : 0;
                    valid0_o = (select == 2'b00) ? 1 : 0;

                    data1_o  = (select == 2'b01) ? stored_data[23:16] : 0;
                    valid1_o = (select == 2'b01) ? 1 : 0;

                    data2_o  = (select == 2'b10) ? stored_data[23:16] : 0;
                    valid2_o = (select == 2'b10) ? 1 : 0;

                    // if we are receiveing an input or if we haven't finished
                    // outputting the previous one
                    if (valid_i || stored_data != 0)
                        state <= state + 2'b01; // go to next state
                end

                2'b01: begin // State 2: print 2nd character
                    data0_o  = (select == 2'b00) ? stored_data[15:8] : 0;
                    valid0_o = (select == 2'b00) ? 1 : 0;

                    data1_o  = (select == 2'b01) ? stored_data[15:8] : 0;
                    valid1_o = (select == 2'b01) ? 1 : 0;

                    data2_o  = (select == 2'b10) ? stored_data[15:8] : 0;
                    valid2_o = (select == 2'b10) ? 1 : 0;

                    state <= state + 2'b01; // go to next state
                end
                
                2'b10: begin // State 3: print 1st character & read input
                    data0_o  = (select == 2'b00) ? stored_data[7:0] : 0;
                    valid0_o = (select == 2'b00) ? 1 : 0;

                    data1_o  = (select == 2'b01) ? stored_data[7:0] : 0;
                    valid1_o = (select == 2'b01) ? 1 : 0;

                    data2_o  = (select == 2'b10) ? stored_data[7:0] : 0;
                    valid2_o = (select == 2'b10) ? 1 : 0;

                    stored_data <= (valid_i) ? data_i : 0; // store input in reg
                    
                    state <= state + 2'b01; // go to next state
                end
                
                2'b11: begin // State 4: print 4th character
                    data0_o  = (select == 2'b00) ? stored_data[31:24] : 0;
                    valid0_o = (select == 2'b00) ? 1 : 0;

                    data1_o  = (select == 2'b01) ? stored_data[31:24] : 0;
                    valid1_o = (select == 2'b01) ? 1 : 0;

                    data2_o  = (select == 2'b10) ? stored_data[31:24] : 0;
                    valid2_o = (select == 2'b10) ? 1 : 0;
                    
                    state <= state + 2'b01; // go to first state (overflow 2bit reg)
                end
            endcase
        end else begin // if (reset)
            data0_o  = 0; valid0_o = 0;
            data1_o  = 0; valid1_o = 0;
            data2_o  = 0; valid2_o = 0;
            state <= 0; stored_data <= 0;
        end
    end
endmodule
