`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     A.C.S.
// Engineer:    Anton Mircea-Pavel
// 
// Create Date:    23:12:00 11/23/2020 
// Design Name: 
// Module Name:     decryption_top
// Project Name:    Tema2_Decryption
// Target Devices:  N/A
// Tool versions:   14.5
// Description:     
//
// Dependencies:    N/A
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - Doc Comments Added
//////////////////////////////////////////////////////////////////////////////////

module decryption_top#(
            parameter addr_witdth   = 8,
            parameter reg_width     = 16,
            parameter MST_DWIDTH    = 32,
            parameter SYS_DWIDTH    = 8
        )(
        // Clock and reset interface
        input clk_sys,      // system clock
        input clk_mst,      // master clock (4x system clock speed)
        input rst_n,        // negated reset
        
        // Input interface
        input [MST_DWIDTH -1 : 0]   data_i,     // data input
        input                       valid_i,    // input enable
        output                      busy,       // 'bool' value to indicate
                                                // processing is happening

        //output interface
        output [SYS_DWIDTH - 1 : 0] data_o,     // data output
        output                      valid_o,    // output enable
        
        // Register access interface
        input[addr_witdth - 1:0]    addr,   // register address
        input                       read,   // action indicator
        input                       write,  // action indicator
        input [reg_width - 1 : 0]   wdata,  // writted data
        output[reg_width - 1 : 0]   rdata,  // read data
        output                      done,   // 'bool' value to indicate status
        output                      error   // 'bool' value to indicate errors
        
    );
    
    
    // TODO: Add and connect all Decryption blocks
    

endmodule
