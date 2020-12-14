`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     A.C.S
// Engineer     Anton Mircea-Pavel
// 
// Create Date:     23:12:00 11/23/2020 
// Design Name:
// Module Name:     mux
// Project Name     Tema2_Decryption
// Target Devices   N/A
// Tool versions    14.5
// Description:     Mux block that routes the decrypted message from a decryptor 
//                  block to the output of the system
//
// Dependencies:    N/A
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Doc Comments Added
// Revision 0.03 - General Logic Explained in Comments
// Revision 0.04 - First attempt at an implementation
// Revision 0.05 - Bug fix: remove intermediary signals and work directly with data_o and valid_o
// Revision 0.06 - Bug fixes:
//                  - the condition for the reset if should be !rst_n, as rst_n is negated.
//                  - remove redundant ternary operators and leave just the boolean condition itself
//                  - code cleanup
// Revision 0.07 - Change all tab indents to space indents
//////////////////////////////////////////////////////////////////////////////////

module mux #(
        parameter D_WIDTH = 8
    )(
        // Clock and reset interface
        input clk,      // system clock
        input rst_n,    // negated reset signal
        
        //Select interface
        input[1:0] select,
        
        // Output interface
        output reg[D_WIDTH - 1 : 0] data_o,     // System Output Data
        output reg                  valid_o,    // System Output Enable

        //output interfaces
        input [D_WIDTH - 1 : 0]     data0_i,    // Caesar Dec. Output Data
        input                       valid0_i,   // Caesar Dec. Output Enable

        input [D_WIDTH - 1 : 0]     data1_i,     // Scytale Dec. Output Data
        input                       valid1_i,    // Scytale Dec. Output Enable

        input [D_WIDTH - 1 : 0]     data2_i,    // ZigZag Dec. Output Data
        input                       valid2_i    // ZigZag Dec. Output Enable
    );
    /////////////////////////// LOGIC OVERVIEW ///////////////////////////
    //  Everythin happens on the positive edge of the [clk] signal      //
    //                                                                  //
    //  if [validX_i] is HIGH, where X is given by the [select] signal: //
    //      store the [dataX_i] in a variable                           //
    //  if [validX_i] is HIGH and [valid_o] is LOW                      //
    //      set [valid_o] to HIGH                                       //
    //  if [validX_i] is LOW and [valid_o] is HIGH                      //
    //      set [valid_o] to LOW                                        //
    //////////////////////////////////////////////////////////////////////

    always @(posedge clk) begin
        // If the reset signal is HIGH, disable all outs
        if (!rst_n) begin
            data_o <= 0;
            valid_o <= 0;
        end else begin // if reset is LOW
            case (select)
                2'b00: begin
                    // This statement handles the 'first' clock cycle, starting
                    // the count when the [validX_i] gets HIGH.
                    // What happens here is that the ternary operator assigns
                    // the value of [dataX_i] to [data_o] when [validX_i]
                    // is HIGH, and 0 otherwise
                    data_o <= (valid0_i) ? data0_i : 0;

                    // This statement handles the 'second' and 'third' 
                    // clock cycles, starting the count when the [validX_i]
                    // gets HIGH.
                    // What happens here is that the ternary operator assigns
                    // the boolean value of evaluating the expression
                    // (valid0_i == 1 && valid_o == 0) to valid_o
                    // What this basically does is that when [validX_i] gets
                    // HIGH and [valid_o] is LOW, it toggles it from
                    // LOW to HIGH and then back from HIGH to LOW in
                    // 2 clock cycles
                    valid_o <= (valid0_i && !valid_o);
                end
                
                2'b01: begin // see comments above
                    data_o <= (valid1_i) ? data1_i : 0;
                    valid_o <= (valid1_i && !valid_o);
                end
                
                2'b10: begin // see comments above
                    data_o <= (valid2_i) ? data2_i : 0;
                    valid_o <= (valid2_i && !valid_o);
                end
                
                // The [select] signal should never reach this case, but we're
                // implementing it just to be safe.
                // If [select] has an invalid value, then disable all outs
                2'b11: begin
                    data_o <= 0;
                    valid_o <= 0;
                end
            endcase
        end
    end
endmodule
