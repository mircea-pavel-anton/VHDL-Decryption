`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     A.C.S
// Engineer:    Anton Mircea-Pavel
// 
// Create Date:    22:33:04 11/23/2020 
// Design Name: 
// Module Name:     zigzag_decryption 
// Project Name:    Tema2_Decryption
// Target Devices:  N/A
// Tool versions:   14.5
// Description:     This block decrypts a zigzag-encrypted message and
//                  sends it out, one character at a time
//
// Dependencies:    N/A
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Implement busy port
// Revision 0.03 - Doc Comments Added
// Revision 0.04 - After a few sleepless nights (2 to be precise) of futile 
//                 attempts to implement this in a combinational always block
//                 and running into countless & confusing errors,
//                 I decided to ditch that and try a seq implementation
//                 This is the first attempt at an implementation for decryption
//                 where key=3
//                 I would like to formally apologise for what you're about to read.
//                 ...but it works
// Revision 0.05 - Implement decryption algo for key = 2. Code optimizations on the way. 
//                 ...Here be dragons
// Revision 0.06 - Remove duplicate code, $write statements and unused signals
// Revision 0.07 - More code dedup & implement small FSM lookalikes in decryption algo
// Revision 0.08 - Merge nested ifs into a single one with cond1 & cond2 & ...
// Revision 0.09 - Add comments along the way to explain wtf is going on
// Revision 0.10 - Change all tabs to spaces since Xilinx uses a 3-spaces-wide
//                 tab (WTF??) and all the code looks messy as a result of that.
// Revision 0.11 - Clip all lines at max 85 characters for better readability
// Revision 0.12 - After a small heart-attack after uploading to the online checker
//                 and failing all tests... change key_width to 8 bits :)
//////////////////////////////////////////////////////////////////////////////////
module zigzag_decryption #(
                parameter D_WIDTH = 8,
                parameter KEY_WIDTH = 8,
                parameter MAX_NOF_CHARS = 50,
                parameter START_DECRYPTION_TOKEN = 8'hFA
            )(
            // Clock and reset interface
            input clk,      // system clock
            input rst_n,    // negated reset
            
            // Input interface
            input[D_WIDTH - 1:0] data_i,    // The encrypted message
            input valid_i,                  // Input enable
            
            // Decryption Key
            input[KEY_WIDTH - 1 : 0] key,
            
            // Output interface
            output reg busy,                  // Indicates processing is going on
            output reg[D_WIDTH - 1:0] data_o, // The decrypted message
            output reg valid_o                // Output enable
    );



    reg [D_WIDTH * MAX_NOF_CHARS - 1 : 0] message = 0; // the encrypted message
    reg [KEY_WIDTH - 1 : 0] n = 0; // the length of the message
    reg [KEY_WIDTH - 1 : 0] index_o = 0; // the index of the output message.

    // Some random variables used as indexes i had no better names for
    // i, j, k were implemented as the indexes for the 3 substrings
    // needed to solve for key=3
    reg [KEY_WIDTH - 1 : 0] i = 0;
    reg [KEY_WIDTH - 1 : 0] j = 0;
    reg [KEY_WIDTH - 1 : 0] k = 0;
    reg [KEY_WIDTH - 1 : 0] state = 0; // used to mimick a FSM for decryption
    reg [KEY_WIDTH - 1 : 0] aux1 = 0;
    reg [KEY_WIDTH - 1 : 0] aux2 = 0;

    always @(posedge clk) begin
        if (rst_n && valid_i) begin // reading the encrypted message
            // if we have not yet reached the end of the message, store each
            // letter into [message]
            // Note that message will have the string stored backwards
            if (data_i != START_DECRYPTION_TOKEN && !busy) begin
                message[D_WIDTH * n +: D_WIDTH] <= data_i;
                n <= n + 1'b1; // increment the character counter
            end else begin // if we have reached the end of the message
                index_o <= 0;   // set the index of the output message to 0
                                // this is used to track how many iterations
                                // have been made so far, so it's basically
                                // [n] for the output message
                                // It is not used as an actual index, like
                                // [message[index_o]], but rather as an iteration
                                // counter
                busy <= 1;  // let the other devices connected to us know
                            // that we are busy

                // Compute some data needed for the decryption
                // These variables are not necesarily needed.
                // The values they compute can be copy pasted instead in their
                // plce, but i feel like they improve code readability
                case (key)
                    2: begin
                        aux1 <= (n>>1) + (n&1); // elements in the first row
                                                // aux1 = n/2 + n%2 
                                                //      = (n div 2 + n mod 2)
                    end
                    3: begin
                        // aux1 = n/4 +  (n%4 > 0) ( n div 4 + 1 if n mod 4 > 0)
                        // What this means is that we have a number of elements
                        // in the first row equal to the number of full cycles
                        // performed, +1 if there is a partial cycle started
                        // For example:
                        // 1       5       9
                        //   2   4   6   8   10
                        //     3       7        11
                        // We consider a cycle to be:
                        // 1    
                        //   2   4
                        //     3
                        // So, we have 2 full cycles.
                        // A partial cycle is:
                        // 9
                        //   10
                        //      11
                        // In this case 11/4 = 2 
                        //              11%4 = 3
                        // So we have 2 + (3>0) ? 1 : 0 = 2 + 1 = 3 elements
                        // on the first row
                        // The second row has 2 * 11/4 + (11%4>1) = 2 * 2 + 1 = 5
                        // elements.
                        // The way this is calculated, is as follows:
                        // Each full cycle has 2 elements on the second row.
                        // A partial cycle only has a single element on the second
                        // row IF the length of the partial cycle is greater than or
                        // equal to 2 characters
                        // => (n/4) * 2 + (n%4 ? 1) ? 1 : 0
                        // Similarly, the third row will have one element per full
                        // cycle, and one more element if the partial cycle has a
                        // length of 3
                        // However, this value is not needed
                        aux1 <= (n>>2) + ( ((n&3) > 0) ? 1 : 0 );
                        aux2 <= (n>>2) * 2 + ( ((n&3) > 1) ? 1 : 0 );
                    end
                endcase
            end
        end

        if (busy && index_o < n) begin // output-ing the decrypted message
            case (key)
                2: begin
                    valid_o <= 1;   // Set output_enable to high, so that
                                    // other devices connected to us know
                                    // we're not spitting bullshit rn
                    
                    // Keep track of the number of iterations.
                    // It should never exceed [n].
                    index_o <= index_o + 1;

                    // A puny attempt of mimicking a FSM for the decryption
                    // algo.
                    // I tried to make the whole shizzle be a FSM, but i failed
                    case (state)
                        0: begin
                            // The input string is basically split in 2
                            // This state prints the element on position i
                            // (the i-th element? english is hard)
                            // from the first sub-string
                            data_o <= message[D_WIDTH * i +: D_WIDTH];
                            state <= 1; // go print from the second substring
                        end
                        1: begin
                            // The input string is basically split in 2
                            // This state prints the element on position i
                            // from the second sub-string
                            data_o <= message[D_WIDTH * ( i + aux1 ) +: D_WIDTH];
                            i <= i + 1; 
                            state <= 0; // go back and print from the first substring
                        end
                    endcase
                end
                3: begin
                    valid_o <= 1;   // Set output_enable to high, so that
                                    // other devices connected to us know
                                    // we're not spitting bullshit rn

                    // Keep track of the number of iterations.
                    // It should never exceed [n].
                    index_o <= index_o + 1;

                    // A puny attempt of mimicking a FSM for the decryption
                    // algo.
                    // I tried to make the whole shizzle be a FSM, but i failed
                    // This is a tad bit more complex than the previous
                    // implementation. Basically, we split the string into 3 
                    // substrings this time instead of 2, and the order we
                    // have to print in is a bit funky.
                    // We have to go from 1 to 2 to 3, then back to 2 and then
                    // repeat
                    // As such, state=0 print from substring 1, then go to state=1
                    //          state=1 print from substring 2, then go to state=2
                    //          state=2 print from substring 3, then go to state=3
                    //          state=3 print from substring 2, then go to state=0
                    // State=3 could have been bundled up together with state=1
                    // but i find that this way it is easier to follow and more 
                    // readable
                    // To each his own, i guess...
                    case (state)
                        0: begin // Prints the i'th element from substring 1
                            data_o <= message[D_WIDTH * i +: D_WIDTH];
                            i <= i + 1;
                            state <= 1;
                        end

                        1: begin // Prints the j'th element from substring 2
                            data_o <= message[D_WIDTH * ( j + aux1 ) +: D_WIDTH];
                            j <= j + 1;
                            state <= 2;
                        end

                        2: begin // Prints the k'th element from substring 1
                            data_o <= message[D_WIDTH * ( k + aux1 + aux2 ) +: D_WIDTH];
                            k <= k + 1;
                            state <= 3;
                        end

                        3: begin// Prints the j'th element from substring 2 again
                            data_o <= message[D_WIDTH * ( j + aux1 ) +: D_WIDTH];
                            j <= j + 1;
                            state <= 0;
                        end
                    endcase
                end

                // if the key we received is neither 2 nor 3, we just spit back the
                // encrypted message. Any other decryption is above our paygrade.
                default: begin
                    valid_o <= 1;
                    data_o <= message[D_WIDTH * index_o +: D_WIDTH];
                    index_o <= index_o + 1;
                end
            endcase
        end

        // If we were to model a FSM, this is the reset state
        // The events that would send us into such a state are:
        // 1. if the reset signal is high (rst_n is LOW)
        // 2. If we were hard working boys (or girls) and we just
        //    finished decrypting a message and outputting it
        // In both of those cases, we would like to reset all values
        // as to not interfere with future decryptions.
        //LTP TPE H ATB H ATTESEES//(3)
        if ( (busy && index_o >= n) || rst_n == 0) begin
            valid_o <= 0;
            data_o <= 0;
            busy <= 0;
            message <= 0;
            n <= 0;
            index_o <= 0;
            i <= 0; j <= 0; k <= 0;
            state <= 0;
            aux1 <= 0;
            aux2 <= 0;
        end
    end
endmodule
