//===================
// N64 FILE TEMPLATE
//===================
arch n64.cpu
endian msb
output "N64_FILE.N64", create // name of the output ROM

fill $00101000 // set ROM size

origin $00000000
base $80000000 // entry point of code

include "../LIB/N64.INC" // include files
include "../LIB/N64_GFX.INC"
include "N64_HEADER.ASM"
insert "../LIB/N64_BOOTCODE.BIN" // always comes last in the include block

constant PIF_BASE = $BFC0
constant PIF_CTRL = $07FC

Start:

    // code


Data:

    // data
        