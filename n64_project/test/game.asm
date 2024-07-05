// N64 'Game' First draft of a drawing game by Emma Ruckle, based on Input Demo files by krom (Peter Lemon):
arch n64.cpu
endian msb
output "game.N64", create
fill $00101000 // Set ROM Size (this is FMs fill num, not PL)

origin $00000000
base $80000000

include "../LIB/N64.INC"
include "../LIB/N64_GFX.INC"
include "../LIB/COLORS16.INC"
include "N64_Header.asm"
insert "../LIB/N64_BOOTCODE.BIN"

Start:
	lui t0, PIF_BASE
	addi t1, 0, 8
	sw t1, PIF_CTRL(t0)

videoInitialization: // macro function, included in GFX LIB file by PL
    ScreenNTSC(320, 240, BPP32, $A0100000) // Screen NTSC: 320x240, 32BPP, DRAM Origin $A0100000

setupFrameBufferBackground:
 	// Buffer Start
	lui t1, $A010
	// Buffer End
	lui t2, $A014
	ori t2, t2, $B000
    // fill t0 with black
 	lui t0, BLACK32
	ori t0, BLACK32
loopFrameBuffer: //initialize the screen as black
 	sw t0, 0(t1)
	bne t1,t2,loopFrameBuffer
	addi t1,t1,4
	nop

//initialize start pixel
//initialize Controller
//now in a loop...
    //WaitScanline
    //read the Controller
    //