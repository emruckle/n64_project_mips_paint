//--------------------------------------------------------------
// Fraser Mips's font code slightly modified
//--------------------------------------------------------------

arch n64.cpu
endian msb
output "Video009.N64", create
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

constant fb1 = $A0100000 // framebuffer
constant pink_white = $A0201000 // pink text, white background, this is where the expanded font will be stored in memory
constant blue_white = $A0301000 // blue text, white background

Start:	         

	N64_INIT()

	ScreenNTSC(320, 240, BPP16, fb1) // init a 16 bpp screen

	// macros called are in PIXEL8_UTIL.INC
	// then those macros call asm functions in PIXEL8_UTIL.S
	// this is fraser mips's structure/organization
	
	pixel8_init16(pink_white, HOT_PINK16, WHITE16) // create expanded font, store in mem, (8x8 pixel font, 16bpp)
	pixel8_init16(blue_white, LIGHT_BLUE16, WHITE16)

	// font_name, framebuffer, top, left, string_label, length
	pixel8_static16(pink_white, fb1, 32, 16, hello_world_text, 12) // display message
	pixel8_static16(blue_white, fb1, 70, 16, hello_world_text, 12)

Loop:  // while(true);
	j Loop
	nop

align(8)
hello_world_text: // message to display
db "Hello World!"
	
align(8)
include "PIXEL8_UTIL.S" // font asm helper file