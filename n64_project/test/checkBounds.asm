// checking bounds on console/emulator in 16bpp
arch n64.cpu
endian msb
output "checkBounds.N64", create
// 1024 KB + 4 KB = 1028 KB
fill $00101000 // Set ROM Size

origin $00000000
base $80000000

include "../LIB/N64.INC"
include "../LIB/N64_GFX.INC"
include "../LIB/COLORS16.INC"
include "../LIB/COLORS32.INC"
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

	
	
	InitializeFrameBuffer:
    	// white
 	//lui t0, WHITE16
	//ori t0, WHITE16
	li t0, WHITE32

 	// Buffer Start
	la t1, $A0100000

	// Buffer End
	li t2, (320 * 240) * 2
	add t2, t2, t1

loopFrameBuffer:
 	sw t0, 0x0(t1)
	addi t1,t1,4
	bne t1,t2,loopFrameBuffer
	nop
	
	//lui t0, HOT_PINK16
	//ori t0, HOT_PINK16
	li t0, HOT_PINK32

	// upper left bound on console

	la t1, $A0100000

	li t3, (320 * 3 + 8) * 2
	add t6, t1, t3

	sw t0, 0x0(t6)

	// upper right bound on console
	
	addi t6, 604
	sw t0, 0x0(t6)

	// lower left bound

	la t1, $A0100000

	//get starting pos (2 pixels)
	li t3, (320 * 225 + 8) * 2
	add t6, t1, t3

	sw t0, 0x0(t6)

	// lower right bound on console
	
	addi t6, 604
	sw t0, 0x0(t6)

	
	la t1, $A0100000
	
	li t3, (320 * 40 + 122) * 2
	add t6, t1, t3

	sw t0, 0x0(t6)

	la t1, $A0100000

	//lui t0, LIME16
	//ori t0, LIME16
	li t0, LIME32

	sw t0, 0(t1)
	li t2, 319 * 2
	add t2, t2, t1
	sw t0, 0(t2)
	li t2, 320 * 236 * 2
	add t2, t2, t1
	sw t0, 0(t2)
	li t2, (320 * 237 - 1) * 2
	add t2, t2, t1
	sw t0, 0(t2)


	//addi t1, 960 + 40
	//sw t0, 0x0(t1)

	//addi t2, t1, 639
	//sw t0, 0x0(t2)

	//la t1, $A0100000

	//addi t1, t1, (320 * 2 + 1) * 2 + 16
	//sw t0, 0x0(t1)

	//la t1, $A0100000
	//li t3, (320 * 236 + 1) * 2 + 16
	//add t1, t1, t3
	//sw t0, 0x0(t1)

	//li t3, (320 * 240 - 1) * 2 
	//addi t1, t1, 635
	//sw t0, 0x0(t1)

	
	
Loop:
	j Loop
	nop

	

	









