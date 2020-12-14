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
// Revision 0.03 - Rough outline of what the code should look like
// Revision 0.04 - Instantiate regfile
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
    // Caesar decryption wires
    wire                        caesar_busy;
    wire [KEY_WIDTH - 1 : 0]    caesar_key;
    wire                        caesar_valid;
    wire [MST_DWIDTH - 1 : 0]   caesar_message;

    // Scytale decryption wires
    wire                        scytale_busy;
    wire [KEY_WIDTH - 1 : 0]    scytale_key;
    wire                        scytale_valid;
    wire [MST_DWIDTH - 1 : 0]   scytale_message;
    
    // Zigzag decryption wires
    wire                        zigzag_busy;
    wire [KEY_WIDTH - 1 : 0]    zigzag_key;
    wire                        zigzag_valid;
    wire [MST_DWIDTH - 1 : 0]   zigzag_message;

    // Additional wires
    wire [1:0] mux_select;

    decryption_regfile reg(
        .clk(clk_sys),
        .rst_n(rst_n),
        .addr(addr),
        .read(read),
        .write(write),
        .rdata(rdata),
        .wdata(wdata),
        .done(done),
        .error(error),
        .select(mux_select),
        .caesar_key(caesar_key),
        .scytale_key(scytale_key),
        .zigzag_key(zigzag_key)
    );

    demux dmx(
        .clk_sys(clk_sys),
        .clk_mst(clk_mst),
        .rst_n(rst_n),
        .select(),
        .data_i(),
        .valid_i(),
        .data0_o(),
        .valid0_o(),
        .data1_o(),
        .valid1_o(),
        .data2_o(),
        .valid2_o()
    );

    mux mx(
        .clk(clk),
        .rst_n(rst_n),
        .select(),
        .data_o(),
        .valid_o(),
        .data0_i(),
        .valid0_i(),
        .data1_i(),
        .valid1_i(),
        .data2_i(),
        .valid2_i()
    );

    caesar_decryption cd(
        .clk(clk),
        .rst_n(rst_n),
        .data_i(),
        .valid_i(),
        .key(caesar_key),
        .busy(caesar_busy),
        .data_o(caesar_message),
        .valid_o(caesar_valid)
    );

    scytale_decryption sd(
        .clk(clk),
        .rst_n(rst_n),
        .data_i(),
        .valid_i(),
        .key_M(scytale_key[7:0]),
        .key_N(scytale_key[15:8]),
        .busy(scytale_busy),
        .data_o(scytale_message),
        .valid_o(scytale_valid)
    );

    zigzag_decryption zd(
        .clk(clk),
        .rst_n(rst_n),
        .data_i(),
        .valid_i(),
        .key(zigzag_key[7:0]),
        .busy(zigzag_busy),
        .data_o(zigzag_message),
        .valid_o(zigzag_valid)
    );

    // Output assigns
    assign busy = (caesar_busy || scytale_busy || zigzag_busy);
endmodule
