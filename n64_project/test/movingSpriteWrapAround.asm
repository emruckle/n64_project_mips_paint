// attempting to create a moving "sprite"
// moves with user controller input

// NOTES FOR NEXT ITERATION:
// - more optimal register use
//	- look into what registers can be used for what tasks in MIPS- heavily relying on the t registers right now
//	- also minimizing the number of registers in general
// - functions! look into mips functions, streamline code
//	- functions to streamline code! repetitive and long, this could help with register use as well
//	- could look into macros as a possibility, google them and look at peter lemon's more closely in terms of their structure and how he calls them
// - what is up with the left, right and down bound numbers?
//	- is my math slightly off, or is the console/monitor not behaiving as expected?
//	- try placing points at the bounds I originally thought I needed? see how those look on the emulator vs the monitor
//	- if they are present on the emulator and not visible on the monitor that points towards console/monitor issue, if they aren't present on the emulator then it's a math issue
//	- if it is the console/monitor, run tests to figure out the exact bounds of the console/monitor combo, rather than close estimates
// - sprites!
//	- look into a function for drawing the sprite - just manually redrawing the two pixels is working this time, but it won't work as well with an actual sprite 

// !!!!!!!! fraser mips video series !!!!!!!!!!!
arch n64.cpu
endian msb
output "movingSpriteWrapAround.N64", create
// 1024 KB + 4 KB = 1028 KB
//fill $00101000 // Set ROM Size
fill 1052672

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

// !!!!!! end fraser mips video series !!!!!!!


// !!!!!!!! emma !!!!!!!!!!!

	// clear frame buffer

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
	nop
	
	//sprite

	//init t0, t1
	lui t0, HOT_PINK16
	ori t0, HOT_PINK16
	la t1, $A0100000

	//get starting pos (2 pixels)
	li t3, (320 * 120 + 122) * 2
	add t6, t1, t3
	addi t7, t6, 4

	// get max -- t4 is max
	li t4, 144620 // mapped monitor bounds, this in monitor lower right bound
	add t4, t1, t4
	
	// init t5 to 0, then add the x starting coord of the sprite
	// t5 is the left x coord of the sprite
	li t5, 0
	addi t5, t5, 244

	// draw the "sprite"

Sprite:
	sw t0, 0x0(t6)
	sw t0, 0x0(t7)


// !!!!!!!! end emma !!!!!!!!!!


// !!!!!!!!!! emma using peter lemon's macros (InitController, ReadController) and his constants from N64_INPUT.INC (JOY_UP, JOY_DOWN, JOY_LEFT, JOY_RIGHT) !!!!!!!!!!

	// move the sprite
	InitController(PIF1) // Initialize Controller

Loop: 

   	ReadController(PIF2) // T0 = Controller Buttons, T1 = Analog X, T2 = Analog Y
	
	// copy current pixel positions into registers
	move t8, t6
	move t9, t7

Up:
	// test if they pressed up (this is all dpad, not joystick)
   	andi t3,t0,JOY_UP // Test JOY UP

	// if they didn't press up, check down
  	beqz t3, Down
 	nop // Delay Slot

	// move higher pixel up 1 row
	subi t6, t6, 320 * 2 // sudo instruction

	// make sure new value is in bounds of screen
	li t1, $A0100000
	// 1936 is upper left bound of monitor
	addi t1, t1, 1936
	blt t6, t1, FixSub // if not in bounds, go fix it...
	nop

	// if in bounds, update second pixel
	subi t7, t7, 320 * 2 // sudo instruction

	j Draw
	nop	


Down:
	// test if they pressed down
  	andi t3,t0,JOY_DOWN // Test JOY DOWN

	// if they didn't press down, check left
 	beqz t3,Left
	nop

	// move lower pixel down 1 row
	addi t7, t7, 320 * 2
	// make sure it is in bounds
	bgt t7, t4, FixAdd
	nop

	// update second pixel
	addi t6, t6, 320 * 2
	
	j Draw
	nop

Left:
	// test if they pressed left
	andi t3,t0,JOY_LEFT // Test JOY LEFT

	// if they didn't press left, check right
  	beqz t3, Right
 	nop // Delay Slot
	
	// update x coordinate
	subi t5, t5, 4
	
	// the monitor begins 16 in from where the emulator begins in terms of x coords
	//li t1, 16
	//blt t5, t1, FixLeft
	li t9, 16
	blt t1, t9, FixLeft
	nop
	
	// update first pixel
	subi t6, t6, 4 // sudo instruction
	// update second pixel
	subi t7, t7, 4 // sudo instruction

	j Draw
	nop

Right:
	// test if they pressed right
	andi t3,t0,JOY_RIGHT // Test JOY RIGHT

	// if they didn't press right, they didn't press anything, loop to top 
 	beqz t3,Loop
	nop
	
	// update x coordinate
	addi t5, t5, 4

	// 616 because 604 (the horz size of screen) + 16 (the offset when working with console) and then t5 is the left pixel, so you have to subtract 4 to check the left pixel rather than the right pixel
	li t1, 616
	bgt t5, t1, FixRight
	nop

	// move pixel 1 to the right
	addi t7, t7, 4

	// update second pixel
	addi t6, t6, 4

	j Draw
	nop

Draw:
	// color old positions white (t8, t9)
	lui t0, WHITE16
	ori t0, WHITE16
	sw t0, 0x0(t8)
	sw t0, 0x0(t9)

	// color new positions pink (t6, t7)
	lui t0, HOT_PINK16
	ori t0, HOT_PINK16
	sw t0, 0x0(t6)
	sw t0, 0x0(t7)

	j Loop
	nop

FixSub:
	// for up movement
	// fixes sub if we are out of bounds
	addi t6, t6, 320 * 2

	j Loop
	nop


FixAdd:
	// for down movement
	// fixes add if we are out of bounds
	subi t7, t7, 320 * 2 // sudo instruction

	j Loop
	nop

FixLeft:
	// fixes left if we are out of bounds
	addi t5, t5, 4

	j Loop
	nop


FixRight:
	// fixes right if we are out of bounds
	subi t5, t5, 4 // sudo instruction

	j Loop
	nop

// !!!!!!!!!! end emma with peter lemon's macros/constants) !!!!!!!!!!!!!!	

// !!!!!!!!! peter lemon input demo files !!!!!!!!!!!!!!

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

// !!!!!!!!!!!!! end peter lemon input demo files !!!!!!!!!!!!!!!!!!
