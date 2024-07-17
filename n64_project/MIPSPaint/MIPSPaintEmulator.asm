// ---------------------------------------------------------------------------------------------------------------------------------
// N64 Game MIPS Paint by Emma Ruckle
// Emulator edition
// User can draw on the screen using the DPAD, toggle between erase (JOY_CUP), draw (JOY_CDOWN), and move modes (JOY_CRIGHT)
// User can select colors in the color palette (JOY_CLEFT)
// User enters game by pressing JOY_START while on title screen
// User can reread instructions (JOY_B) or restart (JOY_Z)
// ---------------------------------------------------------------------------------------------------------------------------------
arch n64.cpu
endian msb
output "MIPSPaintEmulator.N64", create
// 1024 KB + 4 KB = 1028 KB
fill $00101000 // Set ROM Size

origin $00000000
base $80000000

include "../LIB/N64.INC"
include "../LIB/N64_GFX.INC"
include "../LIB/COLORS32.INC"
include "N64_Header.asm"
include "../LIB/N64_INPUT.INC"
include "N64_GAMEPLAY_EMUL.INC"
include "N64_GAME_COLOR.INC"
include "N64_GAME_SPRITES.INC"
include "N64_FONT.INC"
include "N64_AUDIO.INC"
insert "../LIB/N64_BOOTCODE.BIN"

constant fb1 = $A0100000 // game buffer
constant fb2 = $A0200000// start screen buffer

Start:
	// peter lemon macros --------------------------------------------
	N64_INIT()
	ScreenNTSC(320, 240, BPP32, fb2)
		TitleScreen()
		InitController(PIF1) // initialize controller
	// ---------------------------------------------------------------
	Restart:
	//Audio()
	initFramebuffer(WHITE32, framebuffer, $A014B000) // initialize framebuffer
	drawPalette(framebuffer, ColorArray) // draw palette
	gameSetup() // initialize game setup
	initBrushArray(WHITE32, BrushArrayLoc) // intitialize brush array
	//j Swap
	//nop
	SeeInstructions:
	WaitLoop:
		WaitScanline($1E0)
		ReadController(PIF2) // read controller, t0 = controller buttons
		andi t3, t0, JOY_START
		beqz t3, WaitLoop
		nop
	Swap:
	lui t0, VI_BASE
	li t1, fb1
	sw t1, VI_ORIGIN(t0)// swap buffer

DrawLine:
		// peter lemon macro ------------------------------------------
        //InitController(PIF1) // initialize controller
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
			j Render
			nop

		DrawMode:
			andi t3, t0, JOY_CDOWN
           	beqz t3, MoveMode
            nop
			changeModeDraw() // if JOY_CDOWN was pressed, put game in draw mode
			j Render
			nop

		MoveMode:
			andi t3, t0, JOY_CRIGHT
			beqz t3, ColorSelect
			nop
			changeModeMove() // if JOY_CRIGHT was pressed, put game in move mode
			j Render
			nop
		
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
			beqz t3, SoftReset
 			nop
			addi t4, t4, 4
			addi t5, t5, 4 // update x coord
			checkRight() // bound check
		
		SoftReset:
			andi t3, t0, JOY_B
			beqz t3, HardReset
 			nop
			beqz t6, FixBrushBug
			addi t0, r0, 2
			beq t6, t0, FixBrushBug
			nop
			FixEraserBug:
				add a0, r0, t8
				jal SaveOrRestoreEraser
				addi a2, r0, -1
				j Swap2
				nop
			FixBrushBug:
				add a0, r0, t8
				jal SaveOrRestoreBrush
				addi a2, r0, -1
			Swap2:
			addi t6, r0, 2
			lui t0, VI_BASE
			li t1, fb2
			sw t1, VI_ORIGIN(t0) // swap buffer back to title screen buffer
			j SeeInstructions // jump to top
			nop
		HardReset:
			andi t3, t0, JOY_Z
			beqz t3, Render
 			nop
			lui t0, VI_BASE
			li t1, fb2
			sw t1, VI_ORIGIN(t0) // swap buffer back to title screen buffer
			j Restart // jump to top
			nop

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

align(8)
	EraserArrayLoc:
	fill 360

align(8)
	BrushArrayLoc:
	fill 152

align(8)
	ColorArray:
	dw RED32
    dw ORANGE32
    dw CADMIUM_YELLOW32
    dw LIME_GREEN32
    dw DEEP_SKY_BLUE32
    dw DARK_VIOLET32
    dw HOT_PINK32
    dw BLACK32

align(4)
Title:
  db "MIPS PAINT"

ToPlay:
  db "TO PLAY:"

Inst1:
  db "1. use the D-PAD to move the brush"

Inst2:
  db "2. press C-UP to erase"

Inst3:
  db "3. press C-DOWN to draw"

Inst4:
  db "4. press C-RIGHT to move"

Inst5:
  db "5. press C-LEFT in the palette to"

Inst5.2:
  db "   change color"

Inst6:
  db "6. press B to see instructions"

Inst7:
  db "7. press Z to restart"

Press:
  db "PRESS"

Press2:
  db "START"

align(4) // Align 32-Bit
insert FontBlack, "FontBlack8x8.bin"
insert FontRed, "FontRed8x8.bin"
include "N64_FONT.S"

// peter lemon -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
align(8) // Align 64-Bit
RDPBuffer:
arch n64.rdp
	Set_Scissor 0<<2,0<<2, 0,0, 256<<2,8<<2 // Set Scissor: XH 0.0,YH 0.0, Scissor Field Enable Off,Field Off, XL 256.0,YL 8.0
	Set_Color_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_16B,256-1, $00100000 // Set Color Image: FORMAT RGBA,SIZE 16B,WIDTH 256, DRAM ADDRESS $00100000
	Set_Other_Modes CYCLE_TYPE_COPY|EN_TLUT // Set Other Modes

	Set_Texture_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_16B,1-1, ALawLUT // Set Texture Image: FORMAT RGBA,SIZE 16B,WIDTH 1, Tlut DRAM ADDRESS
	Set_Tile 0,0,0, $100, 0,0, 0,0,0,0, 0,0,0,0 // Set Tile: TMEM Address $100, Tile 0
	Load_Tlut 0<<2,0<<2, 0, 255<<2,0<<2 // Load Tlut: SL 0.0,TL 0.0, Tile 0, SH 255.0,TH 0.0

	Sync_Tile // Sync Tile
	Set_Tile IMAGE_DATA_FORMAT_COLOR_INDX,SIZE_OF_PIXEL_8B,32, $000, 0,0, 0,0,0,0, 0,0,0,0 // Set Tile: FORMAT COLOR INDEX,SIZE 8B,Tile Line Size 32 (64bit Words), TMEM Address $000, Tile 0
	Set_Texture_Image IMAGE_DATA_FORMAT_COLOR_INDX,SIZE_OF_PIXEL_8B,256-1, Sample // Set Texture Image: FORMAT COLOR INDEX,SIZE 8B,WIDTH 256, Sample DRAM ADDRESS
	Load_Tile 0<<2,0<<2, 0, 255<<2,7<<2 // Load_Tile: SL 0.0,TL 0.0, Tile 0, SH 255.0,TH 7.0
	Texture_Rectangle 255<<2,7<<2, 0, 0<<2,0<<2, 0<<5,0<<5, 4<<10,1<<10 // Texture Rectangle: XL 255.0,YL 7.0, Tile 0, XH 0.0,YH 0.0, S 0.0,T 0.0, DSDX 4.0,DTDY 1.0

	Sync_Full 
RDPBufferEnd:

ALawLUT:
 dh -5504, -5248, -6016, -5760, -4480, -4224, -4992, -4736
 dh -7552, -7296, -8064, -7808, -6528, -6272, -7040, -6784
 dh -2752, -2624, -3008, -2880, -2240, -2112, -2496, -2368
 dh -3776, -3648, -4032, -3904, -3264, -3136, -3520, -3392
 dh -22016,-20992,-24064,-23040,-17920,-16896,-19968,-18944
 dh -30208,-29184,-32256,-31232,-26112,-25088,-28160,-27136
 dh -11008,-10496,-12032,-11520,-8960, -8448, -9984, -9472
 dh -15104,-14592,-16128,-15616,-13056,-12544,-14080,-13568
 dh -344,  -328,  -376,  -360,  -280,  -264,  -312,  -296
 dh -472,  -456,  -504,  -488,  -408,  -392,  -440,  -424
 dh -88,   -72,   -120,  -104,  -24,   -8,    -56,   -40
 dh -216,  -200,  -248,  -232,  -152,  -136,  -184,  -168
 dh -1376, -1312, -1504, -1440, -1120, -1056, -1248, -1184
 dh -1888, -1824, -2016, -1952, -1632, -1568, -1760, -1696
 dh -688,  -656,  -752,  -720,  -560,  -528,  -624,  -592
 dh -944,  -912,  -1008, -976,  -816,  -784,  -880,  -848
 dh 5504,  5248,  6016,  5760,  4480,  4224,  4992,  4736
 dh 7552,  7296,  8064,  7808,  6528,  6272,  7040,  6784
 dh 2752,  2624,  3008,  2880,  2240,  2112,  2496,  2368
 dh 3776,  3648,  4032,  3904,  3264,  3136,  3520,  3392
 dh 22016, 20992, 24064, 23040, 17920, 16896, 19968, 18944
 dh 30208, 29184, 32256, 31232, 26112, 25088, 28160, 27136
 dh 11008, 10496, 12032, 11520, 8960,  8448,  9984,  9472
 dh 15104, 14592, 16128, 15616, 13056, 12544, 14080, 13568
 dh 344,   328,   376,   360,   280,   264,   312,   296
 dh 472,   456,   504,   488,   408,   392,   440,   424
 dh 88,    72,    120,   104,   24,    8,     56,    40
 dh 216,   200,   248,   232,   152,   136,   184,   168
 dh 1376,  1312,  1504,  1440,  1120,  1056,  1248,  1184
 dh 1888,  1824,  2016,  1952,  1632,  1568,  1760,  1696
 dh 688,   656,   752,   720,   560,   528,   624,   592
 dh 944,   912,   1008,  976,   816,   784,   880,   848

insert Sample, "Sample3.alaw"
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

