// N64 'Bare Metal' 32BPP 320x240 Fill Rectangle RDP Demo by krom (Peter Lemon):
// can you use rdp rectangle to init framebuffer rather than a loop?
// is it worth using the math to reddraw the palette?
arch n64.cpu
endian msb
output "RDPRectangleTest.N64", create
fill 1052672 // Set ROM Size

origin $00000000
base $80000000 // Entry Point Of Code
include "../LIB/N64.INC" // Include N64 Definitions
include "../LIB/N64_GFX.INC" // Include Graphics Macros
include "../MIPSPaint/N64_GAME_SPRITES.INC" // Include Graphics Macros
include "../LIB/COLORS32.INC"
include "N64_HEADER.ASM" // Include 64 Byte Header & Vector Table
insert "../LIB/N64_BOOTCODE.BIN" // Include 4032 Byte Boot Code

Start:
    N64_INIT() // Run N64 Initialisation Routine

    ScreenNTSC(320, 240, BPP32, $A0100000) // Screen NTSC: 320x240, 32BPP, DRAM Origin $A0100000

    WaitScanline($200) // Wait For Scanline To Reach Vertical Blank

    DPC(RDPBuffer, RDPBufferEnd) // Run DPC Command Buffer: Start, End

    //drawPalette($A0100000, ColorArray)

    DPC(RDPBuffer2, RDPBufferEnd2) // Run DPC Command Buffer: Start, End

    //drawPalette($A0100000, ColorArray)

Loop:
  j Loop
  nop // Delay Slot

align(8) // Align 64-Bit
RDPBuffer:
arch n64.rdp
  Set_Scissor 0<<2,0<<2, 0,0, 320<<2,240<<2 // Set Scissor: XH 0.0,YH 0.0, Scissor Field Enable Off,Field Off, XL 320.0,YL 240.0
  Set_Other_Modes CYCLE_TYPE_FILL // Set Other Modes
  Set_Color_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_32B,320-1, $00100000 // Set Color Image: FORMAT RGBA,SIZE 32B,WIDTH 320, DRAM ADDRESS $00100000
  
  Set_Fill_Color WHITE32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  Fill_Rectangle 319<<2,239<<2, 0<<2,0<<2 // Fill Rectangle: XL 319.0,YL 239.0, XH 0.0,YH 0.0

  //Set_Fill_Color HOT_PINK32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  //Fill_Rectangle 179<<2,139<<2, 16<<2,8<<2 // Fill Rectangle: XL 179.0,YL 139.0, XH 16.0,YH 8.0

  Sync_Full // Ensure Entire Scene Is Fully Drawn
RDPBufferEnd:

align(8)
RDPBuffer2:
arch n64.rdp
  //Set_Scissor 0<<2,0<<2, 0,0, 320<<2,240<<2 // Set Scissor: XH 0.0,YH 0.0, Scissor Field Enable Off,Field Off, XL 320.0,YL 240.0
  //Set_Other_Modes CYCLE_TYPE_FILL // Set Other Modes
  //Set_Color_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_32B,320-1, $00100000 // Set Color Image: FORMAT RGBA,SIZE 32B,WIDTH 320, DRAM ADDRESS $00100000

  Set_Fill_Color GREY32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  Fill_Rectangle 311<<2,26<<2, 8<<2,3<<2 // Fill Rectangle: XL 179.0,YL 139.0, XH 16.0,YH 8.0

  Set_Fill_Color RED32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  Fill_Rectangle 47<<2,24<<2, 13<<2,5<<2 // Fill Rectangle: XL 179.0,YL 139.0, XH 16.0,YH 8.0

  Set_Fill_Color ORANGE32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  Fill_Rectangle 84<<2,24<<2, 50<<2,5<<2 // Fill Rectangle: XL 179.0,YL 139.0, XH 16.0,YH 8.0

    Set_Fill_Color CADMIUM_YELLOW32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  Fill_Rectangle 121<<2,24<<2, 87<<2,5<<2 // Fill Rectangle: XL 179.0,YL 139.0, XH 16.0,YH 8.0

        Set_Fill_Color LIME_GREEN32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  Fill_Rectangle 158<<2,24<<2, 124<<2,5<<2 // Fill Rectangle: XL 179.0,YL 139.0, XH 16.0,YH 8.0

        Set_Fill_Color DEEP_SKY_BLUE32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  Fill_Rectangle 195<<2,24<<2, 161<<2,5<<2 // Fill Rectangle: XL 179.0,YL 139.0, XH 16.0,YH 8.0

        Set_Fill_Color DARK_VIOLET32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  Fill_Rectangle 232<<2,24<<2, 198<<2,5<<2 // Fill Rectangle: XL 179.0,YL 139.0, XH 16.0,YH 8.0

        Set_Fill_Color HOT_PINK32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  Fill_Rectangle 269<<2,24<<2, 235<<2,5<<2 // Fill Rectangle: XL 179.0,YL 139.0, XH 16.0,YH 8.0

        Set_Fill_Color BLACK32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  Fill_Rectangle 306<<2,24<<2, 272<<2,5<<2 // Fill Rectangle: XL 179.0,YL 139.0, XH 16.0,YH 8.0

  Sync_Full // Ensure Entire Scene Is Fully Drawn
RDPBufferEnd2:

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