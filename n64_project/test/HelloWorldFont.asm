// N64 'Bare Metal' 32BPP 320x240 Hello World Demo by krom (Peter Lemon):
arch n64.cpu
endian msb
output "HelloWorldFont.N64", create
fill 1052672 // Set ROM Size

origin $00000000
base $80000000 // Entry Point Of Code
include "../LIB/N64.INC" // Include N64 Definitions
include "N64_HEADER.ASM" // Include 64 Byte Header & Vector Table
include "../MIPSPaint/N64_GAMEPLAY.INC"
include "../LIB/COLORS32.INC"
include "../LIB/N64_FONT.INC"
insert "../LIB/N64_BOOTCODE.BIN" // Include 4032 Byte Boot Code

Start:
  include "../LIB/N64_GFX.INC" // Include Graphics Macros
  N64_INIT() // Run N64 Initialisation Routine

  ScreenNTSC(320, 240, BPP32, $A0100000) // Screen NTSC: 320x240, 32BPP, DRAM Origin = $A0100000

  initFramebuffer(BLACK32, $A0100000)

  PrintString(32, 120, FontBlack, Title, 9) // Print Text String To VRAM Using Font At X,Y Position
  PrintString(50, 20, FontBlack, ToPlay, 7) // Print Text String To VRAM Using Font At X,Y Position
  PrintString(70, 20, FontBlack, Inst1, 33) // Print Text String To VRAM Using Font At X,Y Position
  PrintString(90, 20, FontBlack, Inst2, 21) // Print Text String To VRAM Using Font At X,Y Position
  PrintString(110, 20, FontBlack, Inst3, 22) // Print Text String To VRAM Using Font At X,Y Position
  PrintString(130, 20, FontBlack, Inst4, 23) // Print Text String To VRAM Using Font At X,Y Position
  PrintString(150, 20, FontBlack, Inst5, 32) // Print Text String To VRAM Using Font At X,Y Position
  PrintString(160, 20, FontBlack, Inst5.2, 14) // Print Text String To VRAM Using Font At X,Y Position
  PrintString(180, 20, FontBlack, Inst6, 20) // Print Text String To VRAM Using Font At X,Y Position
  PrintString(200, 118, FontBlack, Press, 4) // Print Text String To VRAM Using Font At X,Y Position
  PrintString(200, 168, FontRed, Press2, 4)

  li t0, HOT_PINK32
  la t2, $A0100000 + (320 * 4 * 45)
  addi t4, r0, 320
			TitleRow:
				sw t0, 0(t2)
				addi t4, t4, -1
				bnez t4, TitleRow
				addi t2, t2, 4

  StartingPos: 
  li t0, HOT_PINK32
	la t4, $A0100000 + (320 * 4 * 45) + (220 * 4)
	sw t0, 0(t4)



Brush:
	li t0, WHITE32
  addi t4, t4, -1280
  addi t5, r0, 4
  BrushWhite1:
    addi t4, t4, 4
    sw t0, 0(t4)
    addi t5, t5, -1
    bnez t5, BrushWhite1
    nop
	addi t4, t4, -1292
	sw t0, 0(t4)
  li t0, BROWN32
  addi t5, r0, 3
  BrushBrown1:
    addi t4, t4, 4
    sw t0, 0(t4)
    addi t5, t5, -1
    bnez t5, BrushBrown1
    nop
	li t0, WHITE32
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, -1296
	sw t0, 0(t4)
	li t0, BROWN32
  addi t5, r0, 4
  BrushBrown2:
    addi t4, t4, 4
    sw t0, 0(t4)
    addi t5, t5, -1
    bnez t5, BrushBrown2
    nop
	li t0, WHITE32
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, -1300
	sw t0, 0(t4)
	li t0, BROWN32
  addi t5, r0, 5
  BrushBrown3:
    addi t4, t4, 4
    sw t0, 0(t4)
    addi t5, t5, -1
    bnez t5, BrushBrown3
    nop
	li t0, WHITE32
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, -1304
	sw t0, 0(t4)
	li t0, BROWN32
  addi t5, r0, 5
  BrushBrown4:
    addi t4, t4, 4
    sw t0, 0(t4)
    addi t5, t5, -1
    bnez t5, BrushBrown4
    nop
	li t0, WHITE32
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, -1304
	sw t0, 0(t4)
	li t0, BROWN32
  addi t5, r0, 4
  BrushBrown5:
    addi t4, t4, 4
    sw t0, 0(t4)
    addi t5, t5, -1
    bnez t5, BrushBrown5
    nop
	li t0, WHITE32
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, -1300
	sw t0, 0(t4)
	li t0, BROWN32
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, 4
	sw t0, 0(t4)
	li t0, WHITE32
	addi t4, t4, 4
	sw t0, 0(t4)
	li t0, ORANGE32
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, 4
	sw t0, 0(t4)
	li t0, WHITE32
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, -1300
	sw t0, 0(t4)
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, 4
	sw t0, 0(t4)
	li t0, ORANGE32
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, 4
	sw t0, 0(t4)
	li t0, WHITE32
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, -1292
	sw t0, 0(t4)
	li t0, ORANGE32
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, 4
	sw t0, 0(t4)
	li t0, WHITE32
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, -1292
	sw t0, 0(t4)
	addi t4, t4, 4
	sw t0, 0(t4)
	li t0, PURPLE32
	addi t4, t4, 4
	sw t0, 0(t4)
	addi t4, t4, 4
	sw t0, 0(t4)
	li t0, WHITE32
	addi t4, t4, 4
	sw t0, 0(t4)
 addi t3, r0, 9
 THandle:
		addi t4, t4, -1292
		sw t0, 0(t4)
    li t0, PURPLE32
    addi t5, r0, 3
    THandlePurple:
      addi t4, t4, 4
      sw t0, 0(t4)
      addi t5, t5, -1
      bnez t5, THandlePurple
      nop
    li t0, WHITE32
    addi t4, t4, 4
    sw t0, 0(t4)
    bnez t3, THandle
    addi t3, t3, -1
  addi t4, t4, -1296 
  addi t5, r0, 3
  THandleWhite:
    addi t4, t4, 4
    sw t0, 0(t4)
    addi t5, t5, -1
    bnez t5, THandleWhite
    nop


Loop:
  j Loop
  nop // Delay Slot

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
  db "6. press B to restart"

Press:
  db "PRESS"

Press2:
  db "START"

align(4) // Align 32-Bit
insert FontBlack, "../test/FontBlack8x8.bin"
insert FontRed, "../test/FontRed8x8.bin"
include "../LIB/N64_FONT.S"

