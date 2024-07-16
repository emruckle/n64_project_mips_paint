// swaps color of framebuffer using RDP (equivalent of InputTest.asm, just with RDP not CPU)
// framebuffer is init to light blue, pressing up swaps it to hot pink, down swaps it to green
arch n64.cpu
endian msb
output "inputTestRDP.N64", create
// 1024 KB + 4 KB = 1028 KB
fill $00101000 // Set ROM Size

origin $00000000
base $80000000

include "../LIB/N64.INC"
include "../LIB/N64_GFX.INC"
include "../LIB/COLORS32.INC"
include "N64_Header.asm"
include "../LIB/N64_INPUT.INC"
include "../LIB/N64_DRAW.INC"
insert "../LIB/N64_BOOTCODE.BIN"

Start:

    N64_INIT() // Run N64 Initialisation Routine

    ScreenNTSC(320, 240, BPP32, $A0100000) // Screen NTSC: 320x240, 32BPP, DRAM Origin $A0100000

    // only need this line on console, not on emulator
    // on console, if you don't have this line, the screen starts blue, but pressing up/down won't change the color
    // why...??
    // does not matter what you init framebuffer to, just needs to be initialized
    initFramebuffer(0, $A0100000) // YOU NEED THIS LINE, WHY DO YOU NEED THIS LINE?

    DPC(RDPBuffer3, RDPBufferEnd3) // send RDP commands, this is a peter lemon macro- it is in N64_GFX.INC

    InitController(PIF1) // Initialize Controller

Loop: 
    WaitScanline($1E0)
   	ReadController(PIF2) // T0 = Controller Buttons, T1 = Analog X, T2 = Analog Y

  Up:
   	andi t3,t0,JOY_UP // Test JOY UP
  	beqz t3, Down
 	  nop // Delay Slot
    DPC(RDPBuffer, RDPBufferEnd) // send RDP commands 
    j Loop
	  nop


  Down:
  	andi t3,t0,JOY_DOWN // Test JOY DOWN
 	  beqz t3,Loop
	  nop // Delay Slot
    DPC(RDPBuffer2, RDPBufferEnd2) // send RDP commands
	  j Loop
	  nop

align(8) // Align 64-Bi (align data)

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

align(8) // Align 64-Bit
RDPBuffer:
arch n64.rdp
  // draw a pink rectangle covering whole screen
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
  // draw a green rectangle covering the whole screen
  Set_Scissor 0<<2,0<<2, 0,0, 320<<2,240<<2 // Set Scissor: XH 0.0,YH 0.0, Scissor Field Enable Off,Field Off, XL 320.0,YL 240.0
  Set_Other_Modes CYCLE_TYPE_FILL // Set Other Modes
  Set_Color_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_32B,320-1, $00100000 // Set Color Image: FORMAT RGBA,SIZE 32B,WIDTH 320, DRAM ADDRESS $00100000
  
  Set_Fill_Color LIME32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  Fill_Rectangle 319<<2,239<<2, 0<<2,0<<2 // Fill Rectangle: XL 319.0,YL 239.0, XH 0.0,YH 0.0

  Sync_Full // Ensure Entire Scene Is Fully Drawn
RDPBufferEnd2: 

align(8) // Align 64-Bit
RDPBuffer3:
arch n64.rdp
  // draw a blue rect covering the whole screen
  Set_Scissor 0<<2,0<<2, 0,0, 320<<2,240<<2 // Set Scissor: XH 0.0,YH 0.0, Scissor Field Enable Off,Field Off, XL 320.0,YL 240.0
  Set_Other_Modes CYCLE_TYPE_FILL // Set Other Modes
  Set_Color_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_32B,320-1, $00100000 // Set Color Image: FORMAT RGBA,SIZE 32B,WIDTH 320, DRAM ADDRESS $00100000
  
  Set_Fill_Color LIGHT_SKY_BLUE32 // Set Fill Color: PACKED COLOR 32B R8G8B8A8 Pixel
  Fill_Rectangle 319<<2,239<<2, 0<<2,0<<2 // Fill Rectangle: XL 319.0,YL 239.0, XH 0.0,YH 0.0

  Sync_Full // Ensure Entire Scene Is Fully Drawn
RDPBufferEnd3: 
