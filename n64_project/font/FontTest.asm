// N64 Lesson 02 Simple Initialize
arch n64.cpu
endian msb
output "FontTest.N64", create
// 1024 KB + 4 KB = 1028 KB
fill $00101000 // Set ROM Size

origin $00000000
base $80000000

include "../LIB/N64.INC"
include "../LIB/N64_GFX.INC"
include "../LIB/COLORS16.INC"
include "PIXEL8_UTIL.INC"
include "N64_Header.asm"
insert "../LIB/N64_BOOTCODE.BIN"

constant fb1 = $A0100000
constant yellow_blue = $A0201000

Start:	                 // NOTE: base $80001000
	N64_INIT()

	ScreenNTSC(320,240, BPP16, $A0100000) // 153,600 = 0x2'5800

	nop
	nop
	nop

	// stored after framebuffer 1 at $A0130000
	pixel8_init16(yellow_blue, PAPAYA_WHIP16, LIGHT_STEEL_BLUE16) // yellow text, blue background

	nop
	nop
	nop

	pixel8_static16(yellow_blue, fb1, 16, 16, hello_world_text, 12)
	
Loop:  // while(true);
	j Loop
	nop

align(8)
hello_world_text:
db "Hello World! "
align(8)
include "PIXEL8_UTIL.S"