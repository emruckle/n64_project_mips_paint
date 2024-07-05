//asm test file

arch n64.cpu
endian msb
output "test.N64", create

fill $00101000 // set ROM size

origin $00000000
base $80000000 // entry point of code

// I don't think these files paths are right
// include "../LIB/N64.INC"
// include "../LIB/N64_GFX.INC"
include "N64_HEADER.ASM"
insert "../LIB/N64_BOOTCODE.BIN"

constant PIF_BASE = $BFC0
constant PIF_CTRL = $07FC

Start:
    lui 8, PIF_BASE
    addi 9, 0, 8
    sw 9, PIF_CTRL(8)

Loop:
    j Loop
    nop