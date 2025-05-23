// N64 Lesson 02 Simple Initialize
arch n64.cpu
endian msb
output "Video009.N64", create
// 1024 KB + 4 KB = 1028 KB
fill $00101000 // Set ROM Size

origin $00000000
base $80000000

include "../LIB/N64.INC"
include "../LIB/N64_GFX.INC"
include "../LIB/PIXEL8_UTIL.INC"
include "../LIB/COLORS16.INC"
include "N64_Header.asm"
insert "../LIB/N64_BOOTCODE.BIN"

constant yellow_blue = $A0201000 // white text, black background
constant red_silver = $A0205000 // red text, black background
constant fb1 = $A0100000

Start:	                 // NOTE: base $80001000
	N64_INIT()

	ScreenNTSC(320, 240, BPP32, $A0100000) // 153,600 = 0x2'5800

	nop
	nop
	nop
	
	// pixel8_init16(yellow_blue, PAPAYA_WHIP16, LIGHT_STEEL_BLUE16) // 12,160 = 0x2F80 yellow foreground, blue background
	pixel8_init16(red_silver, CRIMSON16, SILVER16) // Red foreground, Silver background

	nop
	nop
	nop
	// 8x8 pixel font, 16bpp
	// pixel8_static16(yellow_blue, fb1, 16, 16, hello_world_text, 12)
	// top, left
	// 10240, 10240 + 16
	// font_name, framebuffer, top, left, string_label, length
	pixel8_static16(red_silver, fb1, 32, 16, hello_world_text, 12)
Loop:  // while(true);
	j Loop
	nop

align(8)
hello_world_text:
db "Hello World!"
	
align(8)
include "../LIB/PIXEL8_UTIL.S"