// drawButBetter.asm -> drawButBetter.N64
// user can draw on screen using dpad
// user's lines cannot leave the bounds of what is visible on the monitor
// user can toggle between draw and erase using c-up and c-down
	// when draw mode is on, there is a paintbrush sprite that acts as a cursor (draw area is 2x2)
	// when erase mode is on, there is an eraser sprite that acts as a cursor (eraser area is 3x3)
	// with both sprites, the screen behind the sprite is restored as it moves

// next steps..
// add move mode/move sprite
// look into where the arrays are in memory, is there a more secure location I can pick? relook into what ranges I can write and read to
// whats up with still having to color the old loc pinkin draw mode? in my old code that made sense, but with the way im drawing the sprite, im not sure why I need that?
// add a way to select colors?
// add a title screen that gives game instructions
// add a way to exit the game? or is exit just resetting the console? 


//		start fraser mips		//

arch n64.cpu
endian msb
output "drawButBetter.N64", create
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
	li t0, WHITE32 // because 32 bit, li is needed for correct color loading

	la t1, $A0100000 // Buffer start

	li t2, (320 * 240) * 4 // it's * 4 because we are working in 32 bit rather than 16 bit
	add t2, t2, t1 // Buffer end

	LoopFrameBuffer:
 		sw t0, 0x0(t1)
		addi t1,t1,4
		bne t1,t2,LoopFrameBuffer
		nop

StartingPos:
	li t0, HOT_PINK32

	la t1, $A0100000

    li t2, 73280 * 2 // center of the screen, * 2 because 73280 is the center of a 16 bit screen
    add t4, t1, t2
    sw t0, 0(t4)

	li t5, 608 // init an x pos counter to prevent "wrap around"

    li t6, 0 // init mode, user is in draw mode to start

InitBrushArray: // init the behind brush array as all white because the user will always start on draw mode
	//la s0, $BFC00F90 // possible alt address
	//la s0, $800018D4 // base pointer (not being used right now)
	la s1, $80003000 // incrementing pointer
	li t0, WHITE32
	li t1, 38 // the brush is 38 pixels, so I need to keep track of 38 pixels of screen content
	BrushArray:
		sw t0, 0(s1) // store white at s1
		addi s1, s1, 4 // increment s1
		subi t1, t1, 1 // subtract 1 from counter
		bnez t1, BrushArray // loop 38 times

DrawLine:
        InitController(PIF1) // Initialize Controller
    ReadLoop:
		li a1, 300 // wait for 300 scanlines, playing with this value changes the speed, but it doesn't seem linear, investigate this more and select a speed i like
		WaitScanline:
        	WaitScanline($1E0)
			subi a1, a1, 1 // subtract 1 from a1
			bnez a1, WaitScanline // loop
			nop
		 
		ReadController(PIF2) // T0 = Controller Buttons, T1 = Analog X, T2 = Analog Y

		move t8, t4 // store old location

        EraseMode: // if the user pressed JOY_CUP and the game is not in erase mode, put in erase mode by incrementing t6
			andi t3, t0, JOY_CUP
           	beqz t3, DrawMode
            nop
		 	bnez t6, DrawMode
			nop
			li t6, 1 // t6 = 1 means erase mode, t6 = 0 means draw mode
			move a0, t8
			jal RestoreBrush // if we are switching from draw to erase, restore what is behind the brush
			nop
			move a0, t4
			jal SaveEraser // save what is behind the eraser
			nop
			j Render
			nop
		DrawMode: // if the user pressed JOY_CDOWN and the game is not in draw model put in draw mode by subtracting 1 from t6
			andi t3, t0, JOY_CDOWN
           	beqz t3, Up
            nop
			beqz t6, Up
			nop
			li t6, 0
			move a0, t8
			jal RestoreEraser // restore the eraser
			nop
			move a0, t4 
			jal SaveBrush // save the brush
			nop 
		    j Render
		    nop

		Up: // if user pressed up on dpad, move pixel up one row
			andi t3 , t0, JOY_UP
			beqz t3, Down
			nop  
			subi t4, t4, 320 * 4 // update pos
			move a0, t4 // a0 is an argument register used to pass things to functions
			jal UpFunc // call bound checking function
			nop
			move t4, v0 // function returns in v0, move the return into t4

		Down: // if user pressed down on dpad, move pixel down one row
			andi t3, t0, JOY_DOWN
			beqz t3,Left
			nop
			addi t4, t4, 320 * 4 // update pos
			move a0, t4
			jal DownFunc // call bounds checking func
			nop
			move t4, v0

		Left: // if user pressed left on dpad, move pixel left
			andi t3,t0,JOY_LEFT
			beqz t3, Right
 			nop
			subi t4, t4, 4 // update pos
			subi t5, t5, 4 // update x counter 
			move a0, t4 // pass pos and x counter to bound check
			move a1, t5
			jal CheckL // call bound check
			nop
			move t4, v0 // move returns to t4, t5
			move t5, v1

		Right: // if user pressed right on dpad, move pixel right
			andi t3,t0,JOY_RIGHT
			beqz t3, Render
 			nop
			addi t4, t4, 4 // update pos
			addi t5, t5, 4 // update x counter
			move a0, t4
			move a1, t5
			jal CheckR // call bounds check func
			nop
			move t4, v0 // get return
			move t5, v1

	Render: // draws the updated pixels on the screen
        beqz t6, Draw
        nop
        Erase: // if on erase mode, color 3x3 white

			li t0, WHITE32 // color old loc white
			sw t0, 0(t8)

			addi t7, t4, 320 * 4
			sw t0, 0(t7)

			subi t7, t7, 4
			sw t0, 0(t7)

			addi t7, t7, 8
			sw t0, 0(t7)

			subi t7, t7, 320 * 4
			sw t0, 0(t7)

			subi t7, t7, 8
			sw t0, 0(t7)

			subi t7, t7, 320 * 4
			sw t0, 0(t7)

			addi t7, t7, 4
			sw t0, 0(t7)

			addi t7, t7, 4
			sw t0, 0(t7)

			li t0, BLACK32 // color current loc black
		    sw t0, 0(t4) 

			move a0, t8
			jal RestoreEraser // restore eraser
			nop

			move a0, t4
			jal SaveEraser // save eraser
			nop

			move a0, t4
			jal EraserSprite // draw eraser
			nop

		    j ReadLoop
		    nop

        Draw: // if on draw mode, color 2x2 pink
			li 	t0, HOT_PINK32 // color old loc pink
		    sw t0, 0(t8)

			subi t7, t4, 4 
			sw t0, 0(t4)

			addi t7, t7, 320 * 4
			sw t0, 0(t4)
			
			addi t7, t7, 4
			sw t0, 0(t4)

			move a0, t8
			jal RestoreBrush // restore brush
			nop
			
			// save new array
			move a0, t4 
			jal SaveBrush // save brush
			nop

			// draw brush
			move a0, t4
			jal BrushSprite
			nop
		    j ReadLoop
		    nop

	UpFunc: // checks upper left hand screen bound
		la t1, $A0100000 // beginning of screen in theory
		li t2, (320 * 3 + 8) * 4
		add t1, t1, t2 // upper left bound of the console/monitor combo
		blt a0, t1, FixUp // if the pixel pos is less than the upper left bound, fix it
		nop
		j UpEnd
		nop
		FixUp:
			addi a0, a0, 320 * 4 // add 1 row back to the pixel pos
		UpEnd:
			move v0, a0 // move a0 into a return register
			jr ra // return
			nop

	DownFunc: // checks lower right hand bound of the screen
		la t1, $A0100000 // beginning of screen in theory
		li t2, (320 * 225 + 8) * 4  + 604 * 2
		add t1, t1, t2 // lower right bound of the console/monitor combo
		bgt a0, t1, FixDown // if you are past the bound, fix it
		nop
		j DEnd
		nop
		FixDown:
			subi a0, a0, 320 * 4 // subtract 1 row from the pixel pos
		DEnd:
			move v0, a0
			jr ra // return
			nop

	CheckL: // checks for left wrap around
		bltz a1, FixL // if a1 (counter) is less than 0, fix it
		nop
		j LEnd
		nop
		FixL:
			addi a1, a1, 4 // add four back to counter and pixel pos
			addi a0, a0, 4
			j LEnd
		LEnd:
			move v0, a0
			move v1, a1
			jr ra // return
			nop

	CheckR: // checks the right wrap around
		li t1, 604 * 2 // width of screen in monitor/console combo
		bgt a1, t1, FixR // if a1 > t1, fix it
		nop
		j REnd
		nop
		FixR:
			subi a1, a1, 4 // subtract 4 from counter and pixel pos
			subi a0, a0, 4
			j REnd
		REnd:
			move v0, a0
			move v1, a1
			jr ra // return
			nop

	RestoreBrush:
		// restore array 
		// a0 = t8
		subi a0, a0, 320 * 4
		addi a0, a0, 4
		la a1, $80003000
		li t1, 4
		// since brush is an irregular shape, each loop is a row
		// saving of the brush starts from the bottom left of the sprite
		RBR1:
			lw t0, 0(a1) // load what is at a1 into t0
			sw t0, 0(a0) // store what is at t0 at a0 (bitmap)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, RBR1
			nop

		subi a0, a0, 320 * 4
		subi a0, a0, 16
		li t1, 5
		RBR2:
			lw t0, 0(a1)
			sw t0, 0(a0)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, RBR2
			nop

		subi a0, a0, 320 * 4
		subi a0, a0, 16
		li t1, 5
		RBR3:
			lw t0, 0(a1)
			sw t0, 0(a0)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, RBR3
			nop

		subi a0, a0, 320 * 4
		subi a0, a0, 20
		li t1, 5
		RBR4:
			lw t0, 0(a1)
			sw t0, 0(a0)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, RBR4
			nop
		
		subi a0, a0, 320 * 4
		subi a0, a0, 16
		li t1, 5
		RBR5:
			lw t0, 0(a1)
			sw t0, 0(a0)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, RBR5
			nop

		subi a0, a0, 320 * 4
		subi a0, a0, 8
		li t1, 3
		RBR6:
			lw t0, 0(a1)
			sw t0, 0(a0)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, RBR6
			nop
			
		subi a0, a0, 320 * 4
		subi a0, a0, 8
		li t1, 3
		RBR7:
			lw t0, 0(a1)
			sw t0, 0(a0)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, RBR7
			nop
		
		subi a0, a0, 320 * 4
		subi a0, a0, 8
		li t1, 3
		RBR8:
			lw t0, 0(a1)
			sw t0, 0(a0)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, RBR8
			nop

		subi a0, a0, 320 * 4
		subi a0, a0, 8
		li t1, 3
		RBR9:
			lw t0, 0(a1)
			sw t0, 0(a0)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, RBR9
			nop

		subi a0, a0, 320 * 4
		subi a0, a0, 8
		li t1, 2
		RBR10:
			lw t0, 0(a1)
			sw t0, 0(a0)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, RBR10
			nop

		jr ra // return
		nop

	SaveBrush:
		//saves brush array
		//same as restore brush, the addresses are just flipped
		// a0 = t4
		subi a0, a0, 320 * 4
		addi a0, a0, 4
		la a1, $80003000
		li t1, 4
		SBR1:
			lw t0, 0(a0) // load what is at a0 (bitmap) into t0
			sw t0, 0(a1) // store t0 at a1
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, SBR1
			nop

		subi a0, a0, 320 * 4
		subi a0, a0, 16
		li t1, 5
		SBR2:
			lw t0, 0(a0)
			sw t0, 0(a1)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, SBR2
			nop

		subi a0, a0, 320 * 4
		subi a0, a0, 16
		li t1, 5
		SBR3:
			lw t0, 0(a0)
			sw t0, 0(a1)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, SBR3
			nop

		subi a0, a0, 320 * 4
		subi a0, a0, 20
		li t1, 5
		SBR4:
			lw t0, 0(a0)
			sw t0, 0(a1)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, SBR4
			nop
		
		subi a0, a0, 320 * 4
		subi a0, a0, 16
		li t1, 5
		SBR5:
			lw t0, 0(a0)
			sw t0, 0(a1)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, SBR5
			nop

		subi a0, a0, 320 * 4
		subi a0, a0, 8
		li t1, 3
		SBR6:
			lw t0, 0(a0)
			sw t0, 0(a1)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, SBR6
			nop
			
		subi a0, a0, 320 * 4
		subi a0, a0, 8
		li t1, 3
		SBR7:
			lw t0, 0(a0)
			sw t0, 0(a1)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, SBR7
			nop

		
		subi a0, a0, 320 * 4
		subi a0, a0, 8
		li t1, 3
		SBR8:
			lw t0, 0(a0)
			sw t0, 0(a1)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, SBR8
			nop

		subi a0, a0, 320 * 4
		subi a0, a0, 8
		li t1, 3
		SBR9:
			lw t0, 0(a0)
			sw t0, 0(a1)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, SBR9
			nop

		subi a0, a0, 320 * 4
		subi a0, a0, 8
		li t1, 2
		SBR10:
			lw t0, 0(a0)
			sw t0, 0(a1)
			addi a1, a1, 4
			addi a0, a0, 4
			subi t1, t1, 1
			bnez t1, SBR10
			nop

		jr ra // return
		nop

	BrushSprite: // draws the brush sprite
		// save registers, this feature of this function is not being used as of right now
		subi sp, sp, 8
		sw t0, 4(sp)
		sw a0, 0(sp)

		// start drawing
		li t0, BLACK32
		subi a0, a0, 320 * 4
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		subi a0, a0, 320 * 4
		subi a0, a0, 12
		sw t0, 0(a0)
		li t0, BROWN32
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		li t0, BLACK32
		addi a0, a0, 4
		sw t0, 0(a0)
		subi a0, a0, 320 * 4
		subi a0, a0, 12
		sw t0, 0(a0)
		li t0, BROWN32
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		li t0, BLACK32
		addi a0, a0, 4
		sw t0, 0(a0)
		subi a0, a0, 320 * 4
		subi a0, a0, 16
		sw t0, 0(a0)
		li t0, BROWN32
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		li t0, BLACK32
		addi a0, a0, 4
		sw t0, 0(a0)
		subi a0, a0, 320 * 4
		subi a0, a0, 12
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		li t0, ORANGE32
		addi a0, a0, 4
		sw t0, 0(a0)
		li t0, BLACK32
		addi a0, a0, 4
		sw t0, 0(a0)
		subi a0, a0, 320 * 4
		subi a0, a0, 4
		sw t0, 0(a0)
		li t0, PURPLE32
		addi a0, a0, 4
		sw t0, 0(a0)
		li t0, BLACK32
		addi a0, a0, 4
		sw t0, 0(a0)
		subi a0, a0, 320 * 4
		subi a0, a0, 4
		sw t0, 0(a0)
		li t0, PURPLE32
		addi a0, a0, 4
		sw t0, 0(a0)
		li t0, BLACK32
		addi a0, a0, 4
		sw t0, 0(a0)
		subi a0, a0, 320 * 4
		subi a0, a0, 4
		sw t0, 0(a0)
		li t0, PURPLE32
		addi a0, a0, 4
		sw t0, 0(a0)
		li t0, BLACK32
		addi a0, a0, 4
		sw t0, 0(a0)
		subi a0, a0, 320 * 4
		subi a0, a0, 4
		sw t0, 0(a0)
		li t0, PURPLE32
		addi a0, a0, 4
		sw t0, 0(a0)
		li t0, BLACK32
		addi a0, a0, 4
		sw t0, 0(a0)
		subi a0, a0, 320 * 4
		subi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)

		lw t0, 4(sp)
		lw a0, 0(sp)
		addi sp, sp, 8
		
		jr ra // return
		nop
	
	EraserSprite: // draw eraser sprite
		li t0, PALE_VIOLET_RED32
		subi a0, a0, 320 * 4
		addi a0, a0, 4
		// eraser is uniform shape, so nested loop to draw
		li t1, 10
		ERows:
			li t2, 9
			ENest:
				sw t0, 0(a0)
				addi a0, a0, 4
				subi t2, t2, 1
				bnez t2, ENest
				nop
			ENestEnd:
				subi t1, t1, 1
				beqz t1, End
				nop
				subi a0, a0, 320 * 4
				subi a0, a0, 36
				j ERows
				nop
		End:
			jr ra
			nop

	SaveEraser:
		//saves eraser array
		// a0 = t4
		subi a0, a0, 320 * 4
		addi a0, a0, 4
		la a1, $80004000

		li t1, 10
		ESRows:
			li t2, 9
			ESNest:
				lw t0, 0(a0) // load what is at a0 (bitmap) into t0
				sw t0, 0(a1) // store t0 at a1
				addi a0, a0, 4
				addi a1, a1, 4
				subi t2, t2, 1
				bnez t2, ESNest
				nop
			ESNestEnd:
				subi t1, t1, 1
				beqz t1, ESEnd
				nop
				subi a0, a0, 320 * 4
				subi a0, a0, 36
				j ESRows
				nop
		ESEnd:
			jr ra // return
			nop

	RestoreEraser:
		//saves eraser array
		// a0 = t8 (old loc)
		subi a0, a0, 320 * 4
		addi a0, a0, 4
		la a1, $80004000

		li t1, 10
		ERRows:
			li t2, 9
			ERNest:
				lw t0, 0(a1) // load what is at a1 into t0
				sw t0, 0(a0) // store t0 at a0 (bitmap)
				addi a0, a0, 4
				addi a1, a1, 4
				subi t2, t2, 1
				bnez t2, ERNest
				nop
			ERNestEnd:
				subi t1, t1, 1
				beqz t1, EREnd
				nop
				subi a0, a0, 320 * 4
				subi a0, a0, 36
				j ERRows
				nop
		EREnd:
			jr ra // return
			nop

// 			end emma 		//

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
