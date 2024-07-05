// attempting to create a moving "sprite"
// moves with user controller input
// in this iteration, I will attempt to..
// 1. optimize my use of registers
// 2. implement a check so it cannot go off screen
// 3. make the sprite bigger?
// 4. implement side to side as well?

// header and vid intit is from fraser mips video tutorial series

arch n64.cpu
endian msb
output "movingSpriteButBetter.N64", create
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

	// clear frame buffer

	setupFrameBufferBackground:
 	// Buffer Start
	lui t1, $A010
	// Buffer End
	lui t2, $A014
	ori t2, t2, $B000

 	lui t0, WHITE16
	ori t0, WHITE16

	loopFrameBuffer:
 	sw t0, 0(t1)
	bne t1,t2,loopFrameBuffer
	addi t1,t1,4
	nop // Marker NOP
	
	// sprite

	// init t0, t1
	lui t0, HOT_PINK16
	ori t0, HOT_PINK16
	la t1, $A0100000

	// get starting pos
	li t2, (320 * 120 + 122) * 2
	add t3, t1, t2
	addi t4, t1, 4

	// init max and min
	// rn I'm using, t0, t1, t2, t3, t4, t5, t6, t7
	// so i still have t8, t9 and maybe the s registers?
	// get me max -- t8 is max
	li t8, 153600
	add t8, t8, t1
	// gets me min -- t9 is min
	move t9, t1	

Sprite:
	sw t0, 0x0(t3)
	sw t0, 0x0(t4)

	// move the sprite
	InitController(PIF1) // Initialize Controller

Loop: 
	// T0, T1, T2 are overridden with this call!! 
   	ReadController(PIF2) // T0 = Controller Buttons, T1 = Analog X, T2 = Analog Y

	move t5, t3
	move t6, t4

Up:
   	andi t7,t0,JOY_UP // Test JOY UP
  	beqz t7, Down
 	nop // Delay Slot
	subi t3, t3, 320 * 2 // sudo instruction
	blt t3, t9, FixSub
	nop
	subi t4, t4, 320 * 2 // sudo instruction

	j Draw
	nop	


Down:
  	andi t7,t0,JOY_DOWN // Test JOY DOWN
 	beqz t7,Loop
	nop
	addi t3, t3, 320 * 2
	addi t4, t4, 320 * 2
	bgt t4, t8, FixAdd
	nop

	j Draw
	nop

Draw:
	lui t0, WHITE16
	ori t0, WHITE16
	sw t0, 0x0(t5)
	sw t0, 0x0(t6)
	lui t0, HOT_PINK16
	ori t0, HOT_PINK16
	sw t0, 0x0(t6)
	sw t0, 0x0(t7)

	j Loop
	nop

FixSub:
	addi t3, t3, 320 * 2

	j Loop
	nop


FixAdd:
	subi t4, t4, 320 * 2 // sudo instruction

	j Loop
	nop
	

// comes from peter lemon input demo files

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
