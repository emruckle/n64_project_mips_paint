// drawButBetter.asm -> drawButBetter.N64
// replaces peter lemon's WaitScanline with interrupt handling
// user can draw on screen using dpad
// user's pictures cannot leave the bounds of what is visible on the monitor
// user can toggle between draw and erase using c-up and c-down

// next steps..
// make the eraser bigger? potentially 2 x 2 square
// add a single pixel moving "sprite"
// expand on single pixel "sprite" and add a moving paintbrush (or pencil/pen?)
// add a way to select colors?
// add a title screen that gives game instructions
// add a way to exit the game? or is exit just resetting the console


//		start fraser mips		//

arch n64.cpu
endian msb
output "drawINTR.N64", create
// 1024 KB + 4 KB = 1028 KB
fill $00101000 // Set ROM Size

origin $00000000
base $80000000

include "../LIB/N64.INC"
include "../LIB/N64_GFX.INC"
include "../LIB/COLORS32.INC"
include "N64_Header.asm"
include "../LIB/N64_INPUT.INC"
insert "../LIB/N64_BOOTCODE.BIN"
//include "../LIB/N64_INTERRUPT.INC"


Start:

	lui t0, PIF_BASE
    addi t1, 0, 8
    sw t1, PIF_CTRL(t0)

// Video Initialization (320 x 240 x 32bit)

	lui t0, VI_BASE

	li t1, BPP32	// this is the only change required to init 32 bit rather than 16 bit
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

//		end fraser mips		//

//		start emma (using peter lemon's controller constants, InitController(), WaitScanline() and ReadController()) 		//

InitializeFrameBuffer:
	li t0, WHITE32 // if two instructions are used, white is spotty looking, need to use li for desired screen clearing

	la t1, $A0100000 // Buffer start

	li t2, (320 * 240) * 4 // it's * 4 because we are working in 32 bit rather than 16 bit
	add t2, t2, t1 // Buffer end

	LoopFrameBuffer:
 		sw t0, 0x0(t1)
		addi t1,t1,4
		bne t1,t2,LoopFrameBuffer
		nop

StartingPos:
    lui t0, HOT_PINK32 // using two instructions makes a more opaque/darker pink
	ori t0, t0, HOT_PINK32  

	la t1, $A0100000

    li t2, 73280 * 2 // center of the screen, * 2 because 73280 is the center of a 16 bit screen
    add t4, t1, t2
    sw t0, 0(t4)

	li t5, 608 // init an x pos counter to prevent "wrap around"

    li t6, 0 // init mode, user is in draw mode to start

DrawLine:
        InitController(PIF1) // Initialize Controller
    ReadLoop:
        //WaitScanline($1E0) // this makes the controller less sensitive/move slower? but why?
		//lui a0, MI_BASE
		//IntLoop:
			//li t1, $1E0
			//sw t1, VI_V_INTR(t0)

			//beqz t0,IntLoop   // IF (VI Interrupt == 0) Wait For VI Interrupt To Fire
    		//nop
		//li t1, 0
		//sw t1, VI_V_CURRENT_LINE(t0)

	WaitForVerticalInterrupt:
  		lui a0,MI_BASE // A0 = MIPS Interface (MI) Base Register ($A4300000)
		li t1, $1E0
		sw t1, VI_V_INTR(t0)
  	WaitVI:
    	lw t0,MI_INTR(a0) // T0 = MI: Interrupt Register ($A4300008)
    	andi t0,$08       // T0 &= VI Interrupt (Bit 3)
   	 	beqz t0,WaitVI    // IF (VI Interrupt == 0) Wait For VI Interrupt To Fire
    	nop               // Delay Slot
	
	////
	li t0, LIME32
	la t1, $A0100000

    li t2, 73280 * 2 // center of the screen, * 2 because 73280 is the center of a 16 bit screen
    add t4, t1, t2
    sw t0, 0(t4)
	/////
	li t0, BLUE32
	sw t0, 0(t4)

 	lui a0,VI_BASE // A0 = Video Interface (VI) Base Register ($A4400000)

	li t0, HOT_PINK32
	la t1, $A0100000

    li t2, 73280 * 2 // center of the screen, * 2 because 73280 is the center of a 16 bit screen
    add t4, t1, t2
    sw t0, 0(t4)
		 
  	sw r0,VI_V_CURRENT_LINE(a0) // Clear VI Interrupt, Store Zero To VI: Current Vertical Line Register ($A4400010)

	li t0, ORANGE32
	la t1, $A0100000

    li t2, 73280 * 2 // center of the screen, * 2 because 73280 is the center of a 16 bit screen
    add t4, t1, t2
    sw t0, 0(t4)
		 
	ReadController(PIF2) // T0 = Controller Buttons, T1 = Analog X, T2 = Analog Y

	li t0, PURPLE32
	la t1, $A0100000

    li t2, 73280 * 2 // center of the screen, * 2 because 73280 is the center of a 16 bit screen
    add t4, t1, t2
    sw t0, 0(t4)


//			start peter lemon		//

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

// 			end peter lemon			//