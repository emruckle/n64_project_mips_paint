// playing around here, go look at InputTestRDP.asm, that is where I got this idea working
arch n64.cpu
endian msb
output "RDPInputTest.N64", create
fill 1052672 // Set ROM Size

origin $00000000
base $80000000 // Entry Point Of Code
include "../LIB/N64.INC" // Include N64 Definitions
include "../LIB/N64_GFX.INC" // Include Graphics Macros
include "../MIPSPaint/N64_GAME_SPRITES.INC" // Include Graphics Macros
include "../LIB/COLORS32.INC"
include "../LIB/N64_INPUT.INC"
include "../LIB/N64_DRAW.INC"
include "N64_HEADER.ASM" // Include 64 Byte Header & Vector Table
insert "../LIB/N64_BOOTCODE.BIN" // Include 4032 Byte Boot Code

Start:
    N64_INIT() // Run N64 Initialisation Routine

    ScreenNTSC(320, 240, BPP32, $A0100000) // Screen NTSC: 320x240, 32BPP, DRAM Origin $A0100000

top:

  nop
  nop
  nop
InitController(PIF1)


    DPC(RDPBuffer, RDPBufferEnd) // Run DPC Command Buffer: Start, End

      WaitLoop2:
		WaitScanline($1E0)
		ReadController(PIF2) // read controller, t0 = controller buttons
		andi t3, t0, JOY_B
		beqz t3, WaitLoop2
		nop
    //j top
    //nop

    li t0, CADMIUM_YELLOW32
    la t1, $A0100000
   la t2, $A014B000

 clearrLoop:
 sw t0, 0x0(t1)
bne t1, t2, clearrLoop
	addi t1, t1, 4

        WaitLoop3:
		WaitScanline($1E0)
		ReadController(PIF2) // read controller, t0 = controller buttons
		andi t3, t0, JOY_A
		beqz t3, WaitLoop3
		nop
    j top
    nop


    




Loop:
  j Loop
  nop // Delay Slot

align(8) // Align 64-Bit
RDPBuffer:
arch n64.rdp

  Set_Scissor 0<<2,0<<2, 0,0, 320<<2,240<<2 // Set Scissor: XH 0.0,YH 0.0, Scissor Field Enable Off,Field Off, XL 320.0,YL 240.0
  Set_Other_Modes CYCLE_TYPE_FILL // Set Other Modes
  Set_Color_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_32B,320-1, $00100000 // Set Color Image: FORMAT RGBA,SIZE 32B,WIDTH 320, DRAM ADDRESS $00100000
  
  Set_Fill_Color HOT_PINK32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  Fill_Rectangle 319<<2,239<<2, 0<<2,0<<2 // Fill Rectangle: XL 319.0,YL 239.0, XH 0.0,YH 0.0

  Sync_Full // Ensure Entire Scene Is Fully Drawn
RDPBufferEnd: 

align(8) // Align 64-Bit
RDPBuffer2:
arch n64.rdp

  Set_Scissor 0<<2,0<<2, 0,0, 320<<2,240<<2 // Set Scissor: XH 0.0,YH 0.0, Scissor Field Enable Off,Field Off, XL 320.0,YL 240.0
  Set_Other_Modes CYCLE_TYPE_FILL // Set Other Modes
  Set_Color_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_32B,320-1, $00100000 // Set Color Image: FORMAT RGBA,SIZE 32B,WIDTH 320, DRAM ADDRESS $00100000
  
  Set_Fill_Color LIME32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  Fill_Rectangle 319<<2,239<<2, 0<<2,0<<2 // Fill Rectangle: XL 319.0,YL 239.0, XH 0.0,YH 0.0

  Sync_Full // Ensure Entire Scene Is Fully Drawn
RDPBufferEnd2: 


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