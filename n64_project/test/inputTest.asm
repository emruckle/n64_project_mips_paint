// testing input, changes color of screen with up and down arrows

arch n64.cpu
endian msb
output "inputTest.N64", create
// 1024 KB + 4 KB = 1028 KB
fill $00101000 // Set ROM Size

origin $00000000
base $80000000

include "../LIB/N64.INC"
include "../LIB/N64_GFX.INC"
include "../LIB/COLORS16.INC"
include "N64_Header.asm"
include "../LIB/N64_INPUT.INC"
insert "../LIB/N64_BOOTCODE.BIN"

Start:

	lui t0, PIF_BASE
	addi t1, 0, 8
	sw t1, PIF_CTRL(t0)

VideoInit:

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
 	lui t0, WHITE16
	ori t0, WHITE16
 	// Buffer Start
	la t1, $A0100000
	// Buffer End
	li t2, (320 * 240) * 2
	add t2, t2, t1

loopFrameBuffer:
 	sw t0, 0x0(t1)
	addi t1,t1,4
	bne t1,t2,loopFrameBuffer
	nop // Marker NOP

	InitController(PIF1) // Initialize Controller

Loop: 

   	ReadController(PIF2) // T0 = Controller Buttons, T1 = Analog X, T2 = Analog Y

Up:
   	andi t3,t0,JOY_UP // Test JOY UP
  	beqz t3, Down
 	nop // Delay Slot
    	// HOT_PINK16
 	lui t0, HOT_PINK16
	ori t0, HOT_PINK16
	j setupFrameBufferBackground2
	nop


Down:
  	andi t3,t0,JOY_DOWN // Test JOY DOWN
 	beqz t3,Loop
	nop // Delay Slot
  	// MEDIUM_AQUAMARINE16
 	lui t0, MEDIUM_AQUAMARINE16
	ori t0, MEDIUM_AQUAMARINE16
	j setupFrameBufferBackground2
	nop

setupFrameBufferBackground2:
 	// Buffer Start
	li t1, $A0100000
	// Buffer End
	li t2, (320 * 240) * 2
	add t2, t2, t1

loopFrameBuffer2:
 	sw t0, 0x0(t1)
	addi t1,t1,4
	bne t1,t2,loopFrameBuffer
	nop // Marker NOP

	j Loop
	nop

align(8) // Align 64-Bit

PIF1:
  dw $FF010401,0
  dw 0,0
  dw 0,0
  dw 0,0
  dw $FE000000,0
  dw 0,0
  dw 0,0
  dw 0,1

PIF2:
  fill 64 // Generate 64 Bytes Containing $00
