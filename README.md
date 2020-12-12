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
### Behaviour Example
Reading address: `0x00` -> Select register
| reset	| addr	| write	| wdata	| read	| rdata	| done	| error	| select	| caesar	| scytale	| zigzag	|
| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:		| :-:		| :-:		| :-:		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x1	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x1	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|

Reading address: `0x01` -> Invalid address
| reset	| addr	| write	| wdata	| read	| rdata	| done	| error	| select	| caesar	| scytale	| zigzag	|
| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:		| :-:		| :-:		| :-:		|
| 0x1	| 0x1	| 0x0	| 0x0	| 0x1	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x1	| 0x1	| 0x0		| 0x10		| 0x12		| 0x14		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|

Reading address: `0x10` -> Caesar register
| reset	| addr	| write	| wdata	| read	| rdata	| done	| error	| select	| caesar	| scytale	| zigzag	|
| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:		| :-:		| :-:		| :-:		|
| 0x1	| 0x10	| 0x0	| 0x0	| 0x1	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x10	| 0x1	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|

Reading address: `0x12` -> Scytale register
| reset	| addr	| write	| wdata	| read	| rdata	| done	| error	| select	| caesar	| scytale	| zigzag	|
| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:		| :-:		| :-:		| :-:		|
| 0x1	| 0x12	| 0x0	| 0x0	| 0x1	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x12	| 0x1	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|

Reading address: `0x14` -> Zigzag register
| reset	| addr	| write	| wdata	| read	| rdata	| done	| error	| select	| caesar	| scytale	| zigzag	|
| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:		| :-:		| :-:		| :-:		|
| 0x1	| 0x14	| 0x0	| 0x0	| 0x1	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x14	| 0x1	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|

Writting address: `0x00` with value `0x0000` -> Select register
| reset	| addr	| write	| wdata	| read	| rdata	| done	| error	| select	| caesar	| scytale	| zigzag	|
| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:		| :-:		| :-:		| :-:		|
| 0x1	| 0x0	| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x0		| 0xffff	| 0x2		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x1	| 0x0	| 0x0		| 0x0		| 0xffff	| 0x2		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x0		| 0xffff	| 0x2		|

Writting address: `0x01` with value `0x0001` -> Invalid address
| reset	| addr	| write	| wdata	| read	| rdata	| done	| error	| select	| caesar	| scytale	| zigzag	|
| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:		| :-:		| :-:		| :-:		|
| 0x1	| 0x1	| 0x1	| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x0		| 0xffff	| 0x2		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x1	| 0x1	| 0x0		| 0x0		| 0xffff	| 0x2		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x0		| 0xffff	| 0x2		|

Writting address: `0x10` with value `0x0010` -> Caesar register
| reset	| addr	| write	| wdata	| read	| rdata	| done	| error	| select	| caesar	| scytale	| zigzag	|
| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:		| :-:		| :-:		| :-:		|
| 0x1	| 0x10	| 0x1	| 0x10	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x0		| 0xffff	| 0x2		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x1	| 0x0	| 0x0		| 0x10		| 0xffff	| 0x2		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0xffff	| 0x2		|

Writting address: `0x12` with value `0x0012` -> Scytale register
| reset	| addr	| write	| wdata	| read	| rdata	| done	| error	| select	| caesar	| scytale	| zigzag	|
| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:		| :-:		| :-:		| :-:		|
| 0x1	| 0x12	| 0x1	| 0x12	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0xffff	| 0x2		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x1	| 0x0	| 0x0		| 0x10		| 0x12		| 0x2		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0x12		| 0x2		|

Writting address: `0x14` with value `0x0014` -> Zigzag register
| reset	| addr	| write	| wdata	| read	| rdata	| done	| error	| select	| caesar	| scytale	| zigzag	|
| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:	| :-:		| :-:		| :-:		| :-:		|
| 0x1	| 0x14	| 0x1	| 0x14	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0x12		| 0x2		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x1	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|
| 0x1	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0	| 0x0		| 0x10		| 0x12		| 0x14		|

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
