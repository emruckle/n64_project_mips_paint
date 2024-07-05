// check in to see if i've properly understood videos 1-6

arch n64.cpu
endian msb
output "checkBounds32.N64", create
// 1024 KB + 4 KB = 1028 KB
fill $00101000 // Set ROM Size

origin $00000000
base $80000000

include "../LIB/N64.INC"
include "../LIB/N64_GFX.INC"
include "../LIB/COLORS32.INC"
include "../LIB/COLORS16.INC"
include "N64_Header.asm"
insert "../LIB/N64_BOOTCODE.BIN"

Start:
	lui t0, PIF_BASE
	addi t1, 0, 8
	sw t1, PIF_CTRL(t0)

    ScreenNTSC(320, 240, BPP32, $A0100000)
	
	InitializeFrameBuffer:
    	// white
 	lui t0, WHITE16
	ori t0, WHITE16
    //li t0, WHITE32

 	// Buffer Start
	la t1, $A0100000

	// Buffer End
	li t2, (320 * 240) * 4
	add t2, t2, t1

loopFrameBuffer:
 	sw t0, 0x0(t1)
	addi t1,t1,4
	bne t1,t2,loopFrameBuffer
	nop
	
	//lui t0, HOT_PINK32
	//ori t0, HOT_PINK32

    //li t0, HOT_PINK32
	lui t0, HOT_PINK16
	ori t0, HOT_PINK16

	// upper left bound on console

	la t1, $A0100000

	li t3, (320 * 3 + 8) * 4
	add t6, t1, t3

	sw t0, 0x0(t6)

	// upper right bound on console
	
	addi t6, 604 * 2
	sw t0, 0x0(t6)

	// lower left bound

	la t1, $A0100000

	//get starting pos (2 pixels)
	li t3, (320 * 225 + 8) * 4
	add t6, t1, t3

	sw t0, 0x0(t6)

	// lower right bound on console
	
	addi t6, 604 * 2
	sw t0, 0x0(t6)

	
	la t1, $A0100000
	
	li t3, (320 * 40 + 122) * 4
	add t6, t1, t3

	sw t0, 0x0(t6)


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

	

	









