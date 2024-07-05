// using vid4.asm as a base
// 320 x 240 and 16 bit color
arch n64.cpu
endian msb
output "vid5.N64", create
// 1024 KB + 4 KB = 1028 KB
fill $00101000 // Set ROM Size

origin $00000000
base $80000000

include "../LIB/N64.INC"
// make sure you have this include
include "../LIB/N64_GFX.INC"
include "../LIB/COLORS16.INC"
include "N64_Header.asm"
insert "../LIB/N64_BOOTCODE.BIN"

Start:	                 // NOTE: base $80001000
	lui t0, PIF_BASE     // t0 = $BFC0 << 16	
	addi t1, 0, 8	// t1 = 0 + 8, example of how you can use the zero register
	sw t1, PIF_CTRL(t0)  // 0xBFC007FC = 8, take the value, store it in t1
	
	nop
	nop
	nop
	// new for this video!! video initialization starts here
	// 320 x 240 x 16bit
	// dollar sign means a hex value, rather than an int
	lui t0, VI_BASE

	li t1, BPP16 // psuedo instruction, defines 16 bit per pixel mode
	sw t1, VI_STATUS(t0)

	li t1, $A0100000
	sw t1, VI_ORIGIN(t0)  //starting address for our frame buffer, have it start 1 megabyte in

	li t1, 320
	sw t1, VI_WIDTH(t0)

	li t1, $200
	sw t1, VI_V_INTR(t0)

	li t1, 0
	sw t1, VI_V_CURRENT_LINE(t0)

	li t1, $3E52239
	sw t1, VI_TIMING(t0)

	li t1, $20D
	sw t1, VI_V_SYNC(t0)

	li t1, $C15
	sw t1, VI_H_SYNC(t0)

	li t1, $C150C15
	sw t1, VI_H_SYNC_LEAP(t0)

	li t1, $6C02EC
	sw t1, VI_H_VIDEO(t0)

	li t1, $2501FF
	sw t1, VI_V_VIDEO(t0)

	li t1, $E0204
	sw t1, VI_V_BURST(t0)

	li t1, ($100*((320)/160))
	sw t1, VI_X_SCALE(t0)

	li t1, ($100*((240)/60))
	sw t1, VI_Y_SCALE(t0)

	nop
	nop
	nop

// Draw a Line (Horizontal)
	
	// 15 rows from the top
	// in 110 columns cause 110 + 100 + 110 = 320
	// 100 pixels long

	lui t0, HOT_PINK16
	ori t0, HOT_PINK16 // fills the lower half of the register with HOT_PINK16 as well, now you have two pixels of lawn green
	// what was t0 before ori?
	la t1, $A0100000 // psuedo instruction, bass compiler has some options.. can create your own instructions? 

	// window is 320 pixels wide, to move down 15 rows is 320 * 15, then add 110
	// each pixel is not a single byte, it is actually 2 bytes, because we are in the 16 bit per pixel mode
	// so... (320 * 15 + 110) * 2
	
	addi t1, t1, (320 * 15 + 110) * 2 //asuming 2s complement? is there an add unsiged immediate?
	
	// need to loop 50 times because we have one green pixel right now

	addi t2, t1, 200 //cause 100 pixels * 2
do_Store2Pixels: // like a while loop... 
	sw t0, 0x0(t1) //store, whyt the 0x0??
	addi t1, t1, 4 // destination, num1, num2 (addition), incrementing t1 by 4 bytes
	bne t1, t2, do_Store2Pixels
	nop // always safe, don't hesistate to but them in
	// structure of this loop vs the verticle line loop...
	
// Draw a Line (vertical)

	// 20 rows from the top
	// 100 columns 
	// 200 pixels tall
	
	lui t0, LIGHT_BLUE16
	// want a single pixel line
	// ori t0, LIGHT_BLUE16
	la t1, $A0100000

	addi t1, t1, (320 * 20 + 100) * 2
	addi t2, r0, 200 // a little like a for loop, initializing i or index val
do_Store2Pixels2:
	sw t0, 0x0(t1) // upper of the register
	addi t2, t2, -1 // so we subtract from counter as we go through
	addi t1, t1, 320 * 2
	bne t2, r0, do_Store2Pixels2
	nop // unitl you know what you want to put in the delay slot, stick with nop

Loop:  // while(true); : tells the assembler that Loop is a jump instruction, you've seen this before
	j Loop
	nop