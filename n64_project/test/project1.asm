// check in to see if i've properly understood videos 1-6

arch n64.cpu
endian msb
output "project1.N64", create
// 1024 KB + 4 KB = 1028 KB
fill $00101000 // Set ROM Size

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


	// Video Initialization (320 x 240 x 16bit)

	lui t0, VI_BASE

	li t1, BPP16
	sw t1, VI_STATUS(t0)

	li t1, $A0100000
	sw t1, VI_ORIGIN(t0)

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

	
	
	// Draw an "E"

	setupFrameBufferBackground:
 	// Buffer Start
	lui t1, $A010
	// Buffer End
	lui t2, $A014
	ori t2, t2, $B000

	 // Red
 	lui t0, PALE_GREEN16
	ori t0, PALE_GREEN16

	loopFrameBuffer:
 	sw t0, 0(t1)
	bne t1,t2,loopFrameBuffer
	addi t1,t1,4
	nop // Marker NOP
	
	// vertical line!!!

	// 20 rows from the top, 122 columns in, 200 pixels tall

	lui t0, HOT_PINK16 // load HOT_PINK16 into the upper half of the t0 register
	ori t0, PALE_GREEN16
	la t1, $A0100000
	
	addi t1, t1, (320 * 20 + 122) * 2 // set t1 to be 320 rows down, and 122 columns in (this is the lines starting point)
	addi t2, r0, 200 // initialize t2 to 200, the height of the line
LoopVertical:
	sw t0, 0x0(t1)
	addi t2, t2, -1 // decrease t2 by 1
	addi t1, t1, 320 * 2 // increase t1 by 320 * 2, moving t1 down one row
	bne t2, r0, LoopVertical // if t2 is not 0, loop
	nop // delay slot

	// first horizontal line!!!
	
	// 20 rows from the top, 122 columns in, 100 pixels long
	
	lui t0, HOT_PINK16 // load HOT_PINK16 into upper half of t0
	ori t0, HOT_PINK16 // load HOT_PINK16 into lower half of t0
	la t1, $A0100000

	addi t1, t1, (320 * 20 + 122) * 2 // set t1 to 20 rows from the top, 122 columns in
	addi t2, t1, 200 // set t2 to the starting point, t1, plus the length of the line (200) * 2, it has to be divisible by 4 because of the nature of the loop
LoopH1:
	sw t0, 0x0(t1)
	addi t1, t1, 4 // increment t1 by 4
	bne t1, t2, LoopH1 // if t1 does not equal t2, loop
	nop // delay slot
	
	// second horizontal line!!!
	
	// 20 + 100 rows from the top, 122 columns in, 75 ish pixels long

	lui t0, HOT_PINK16
	ori t0, HOT_PINK16
	la t1, $A0100000

	// let's try it with loading registers, li is load immediate
	li t3, (320 * 120 + 122) * 2
	add t1, t1, t3
	addi t2, t1, 152
LoopH2:
	sw t0, 0x0(t1)
	addi t1, t1, 4 // increment t1 by 4
	bne t1, t2, LoopH2 // if t1 does not equal t2, loop
	nop // delay slot

	// third horizontal line!!!
	
	// 20 + 200 rows from the top, 122 columns in, 100 pixels long
	
	lui t0, HOT_PINK16
	ori t0, HOT_PINK16
	la t1, $A0100000
	
	// loading register
	li t3, (320 * 220 + 122) * 2
	add t1, t1, t3
	addi t2, t1, 200
LoopH3:
	sw t0, 0x0(t1)
	addi t1, t1, 4 
	bne t1, t2, LoopH3
	nop
	
	
Loop:
	j Loop
	nop

	

	









