# Tema 2 - Decryption

## Decryption Regfile

This block acts like both a memory and a memory controller.

It plays the role of memory, like RAM to a PC, as in, it stores a few values, more specifically the keys needed to decrypt the incoming messages, in registers and they can later on be retrieved, and the role of the controller as it handles both reading and writing to multiple registers.

Two signals, more specifically `read` and `write` describe the nature of the action that is about to be performed and, based on that, either `wdata` is dumped into the appropriate register, or `rdata` is extracted from it. The register is specified via `addr`.
There are 4 registers which store data:

- `select_register` -> holds the `select` signal for the MUX and DEMUX blocks
- `caesar_key_register`, `scytale_key_register`, `zigzag_key_register` -> hold the keys needed to decypher the respectively encrypted messages

There are 2 more signals of interest:

- `done`, which basically acts like an enable signal for all outs
- `error` which indicates an unavailable address in `addr`

### Inputs

``` verilog
input clk       // system clock
input rst_n     // reset signal

// Register access interface
input [addr_witdth - 1 : 0]  addr  // the address of the desired register
input                        read  // basically a read_enable signal
input                        write // basically a write_enable signal
input [reg_width - 1 : 0]    wdata // the written data
```

### Outputs

``` verilog
output reg [reg_width - 1 : 0]  rdata   // the read data
output reg                      done    // 'bool' value to indicate status
output reg                      error   // 'bool' value to indicate errors

// Output wires
output reg [reg_width - 1 : 0] select       // The signal that will be 
                                            // sent to the MUX & DEMUX blocks
output reg [reg_width - 1 : 0] caesar_key   // The key needed to decrypt the
                                            // caesar message
output reg [reg_width - 1 : 0] scytale_key  // The key needed to decrypt the
                                            // scytale message
output reg [reg_width - 1 : 0] zigzag_key   // The key needed to decrypt the
                                            // zigzag message
```

## Caesar Decryption

This algorithm basically shifts all characters to the right, and that's it.

In order to decrypt it, we just subtract `key` from each character received:

``` verilog
// if !reset is high -> reset is low
if (rst_n) begin
    // set [valid_o] to high if [valid_i] was high last clock
    valid_o <= valid_i;

    // if [valid_i] was high last clock, decrypt input message and
    // send it to [data_o]
    data_o <= (valid_i) ? data_i - key : 0;
end 
```

## Scytale Decryption

This algorithm involves writing the given string into a `M`x`N` matrix, row by row and then reading line by line.

By performing a simple example, pen-on-paper style, for a word of length `16`, with the matrix size of 4x4, we get the following:

``` fenced-code-language
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 ->

1  5  9 13
2  6 10 14
3  7 11 15
4  8 12 16

-> 1 5 9 13 2 6 10 14 3 7 11 15 4 8 12 16
```

So what we can observe the rule:

1. Starting from character 1, we increment by the number of columns
2. Once the increment overflows the number of total characters, we move to start from the second element
3. We keep doing this for x iterations, where x is the number of rows

We can model this behaviour with a nested for loop:

``` C
for (int i = 0; i < key_N; i++) {
    for (int j = i; j < n; j += key_N) {
        print( message[j] );
    }
}
```

However, in verilog, we want to model this loop in such a way that each iteration is executed in a clock cycle:

``` verilog
always @(posedge clk)
    if (busy) begin 
        // This prints the i'th line of the matrix
        if (j < n) begin // we can observe the stop condition for the 2nd loop
            valid_o <= 1;
            data_o <= message[D_WIDTH * j +: D_WIDTH ];
            j <= j + key_N; // the increment condition for the second loop
        end else begin
            valid_o <= 1;
            i <= i + 1; // the increment condition for the first loop
            j <= i + 1 + key_N;
            
            if (i + 1 < key_N) begin // the stop condition for the first loop
                data_o <= message[D_WIDTH * (i+1) +: D_WIDTH ];
            end
        end
    end
end
// see the code for a more in depth explanation
```
