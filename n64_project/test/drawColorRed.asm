// ---------------------------------------------------------------------------------------------------------------------------------
// N64 Game MIPS Paint by Emma Ruckle
// Best played on console, does not have full functionalty on an emulator
// User can draw on the screen using the DPAD, toggle between erase (JOY_CUP), draw (JOY_CDOWN), and move modes (JOY_CRIGHT)
// User can select colors in the color palette (JOY_CLEFT)
// ---------------------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------
// Remaining ToDos:
// - find an example of double buffering that includes switching the buffers
// - finish watching fraser mips's font video series
// - create a title screen with gameplay instructions
// - should there be a way to exit the game? 
// - try to get the color array intialization to work without needing a looping macro (using dd)
// - look over use of delay slots in change mode functions, make sure instructions there make sense
// ---------------------------------------------------------------------------------------------------------------------------------

arch n64.cpu
endian msb
output "MIPSPaint.N64", create
// 1024 KB + 4 KB = 1028 KB
fill $00101000 // Set ROM Size

origin $00000000
base $80000000

include "../LIB/N64.INC"
include "../LIB/N64_GFX.INC"
include "../LIB/COLORS32.INC"
include "N64_Header.asm"
include "../LIB/N64_INPUT.INC"
include "../LIB/N64_GAMEPLAY.INC"
include "../LIB/N64_GAME_COLOR.INC"
include "../LIB/N64_GAME_SPRITES.INC"
insert "../LIB/N64_BOOTCODE.BIN"

Start:
	// peter lemon macros --------------------------------------------
	N64_INIT()
	ScreenNTSC(320, 240, BPP32, framebuffer)
	// ---------------------------------------------------------------
	initFramebuffer(WHITE32, framebuffer) // initialize framebuffer
	createColorArray(ColorArray) // intitialize color array
	drawPalette(framebuffer, ColorArray) // draw palette
	gameSetup() // initialize game setup
	initBrushArray(WHITE32, BrushArrayLoc) // intitialize brush array

DrawLine:
		// peter lemon macro ------------------------------------------
        InitController(PIF1) // initialize controller
		// -----------------------------------------------------------
    ReadLoop:
		addi a1, r0, 300 // can be adjusted to change controller sensitivity
		WaitScanline:
			// peter lemon macro --------------------------------------
        	WaitScanline($1E0)
			// --------------------------------------------------------
			bnez a1, WaitScanline
			addi a1, a1, -1
		// peter lemon macro ------------------------------------------
		ReadController(PIF2) // read controller, t0 = controller buttons
		// ------------------------------------------------------------
		add t8, r0, t4 // store old current loc
        EraseMode:
			andi t3, t0, JOY_CUP
           	beqz t3, DrawMode
            nop
			changeModeErase() // if JOY_CUP was pressed, put game in erase mode

		DrawMode:
			andi t3, t0, JOY_CDOWN
           	beqz t3, MoveMode
            nop
			changeModeDraw() // if JOY_CDOWN was pressed, put game in draw mode

		MoveMode:
			andi t3, t0, JOY_CRIGHT
			beqz t3, ColorSelect
			nop
			changeModeMove() // if JOY_CRIGHT was pressed, put game in move mode
		
		ColorSelect:
			andi t3, t0, JOY_CLEFT
        	beqz t3, Up
           	nop
			colorSelection(ColorArray) // if JOY_CLEFT was pressed, change the drawing color

		Up: // if user pressed up on dpad, move pixel up one row
			andi t3 , t0, JOY_UP
			beqz t3, Down
			nop  
			addi t4, t4, -1280
			upCheck(framebuffer) // bound check

		Down: // if user pressed down on dpad, move pixel down one row
			andi t3, t0, JOY_DOWN
			beqz t3,Left
			nop
			addi t4, t4, 1280
			downCheck() // bound check

		Left: // if user pressed left on dpad, move pixel left
			andi t3,t0,JOY_LEFT
			beqz t3, Right
 			nop
			addi t4, t4, -4
			addi t5, t5, -4 // update x coord
			checkLeft() // bound check

		Right: // if user pressed right on dpad, move pixel right
			andi t3,t0,JOY_RIGHT
			beqz t3, Render
 			nop
			addi t4, t4, 4
			addi t5, t5, 4 // update x coord
			checkRight() // bound check

	Render: // draws screen
        beqz t6, Draw
        nop
		addi t0, r0, 2
		beq t6, t0, Move
		nop
        Erase: // erase mode
			eraseRender()
		    j ReadLoop
		    nop

        Draw: // draw mode
			drawRender()
			j ReadLoop
	 		nop

		Move: // move mode
			moveRender()
		    j ReadLoop
		    nop

	BrushSprite: // draw brush sprite
		drawBrushSprite()

	SaveOrRestoreBrush: // save or restore brush
		saveOrRestoreBrush()
	
	EraserSprite: // draw eraser sprite
		drawEraserSprite()

	SaveOrRestoreEraser: // save or restore eraser
		saveOrRestoreEraser()
	
	// peter lemon ----------------------------------------
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
	// ----------------------------------------------------

	EraserArrayLoc:
	fill 360

	BrushArrayLoc:
	fill 152

	ColorArray:
	fill 32