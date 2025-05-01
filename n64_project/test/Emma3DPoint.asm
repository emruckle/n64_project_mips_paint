arch n64.cpu
endian msb
output "Emma3DPoint.N64", create
fill 1052672 // Set ROM Size

origin $00000000
base $80000000 // Entry Point Of Code
include "../LIB/N64.INC" // Include N64 Definitions
include "../LIB/COLORS32.INC" // include 32 bit colors for ease of testing 
include "N64_HEADER.ASM" // Include 64 Byte Header & Vector Table
insert "../LIB/N64_BOOTCODE.BIN" // Include 4032 Byte Boot Code

Start:
  include "../LIB/N64_GFX.INC" // Include Graphics Macros
  include "../LIB/N64_RSP.INC" // Include RSP Macros
  include "../LIB/N64_INPUT.INC" // Include Input Macros

  N64_INIT() // Run N64 Initialisation Routine

  ScreenNTSC(320, 240, BPP16, $A0100000) // Screen NTSC: 320x240, 16BPP, DRAM Origin $A0100000

  SetXBUS() // RDP Status: Set XBUS (Switch To RSP DMEM For RDP Commands)

  // Load RSP Code To IMEM
  DMASPRD(RSPCode, RSPCodeEnd, SP_IMEM) // DMA Data Read DRAM->RSP MEM: Start Address, End Address, Destination RSP MEM Address
  DMASPWait() // Wait For RSP DMA To Finish, pipeline synchronization

  // Load RSP Data To DMEM
  DMASPRD(RSPData, RSPDataEnd, SP_DMEM) // DMA Data Read DRAM->RSP MEM: Start Address, End Address, Destination RSP MEM Address
  DMASPWait() // Wait For RSP DMA To Finish, pipeline synchronization

  SetSPPC(RSPStart) // Set RSP Program Counter: Start Address
  StartSP() // Start RSP Execution: RSP Status = Clear Halt, Broke, Interrupt, Single Step, Interrupt On Break

  // Flush Data Cache: Index Writeback Invalidate
  la a1,$80000000    // A1 = Cache Start
  la a2,$80002000-16 // A2 = Cache End
  LoopCache:
    cache $0|1,0(a1) // Data Cache: Index Writeback Invalidate
    bne a1,a2,LoopCache
    addiu a1,16 // Address += Data Line Size (Delay Slot)

align(8) // Align 64-Bit
RSPCode:
arch n64.rsp
base $0000 // Set Base Of RSP Code Object To Zero

RSPStart:
  lqv v0[e0],PointX(r0) // V0 = Point X ($000)
  lqv v1[e0],PointY(r0) // V1 = Point Y ($010)
  lqv v2[e0],PointZ(r0) // V2 = Point Z ($020)

// Load Camera, loads starting position of camera (centered)
  lqv v3[e0],HALF_SCREEN_XY_FOV(r0) // V3 = Screen X / 2, Screen Y / 2, FOV ($030)

// Load Matrix, load values from matrices into vector register
  lqv v4[e0],MatrixRow01XYZT(r0) // V4 = Row 0,1 XYZT ($040)
  lqv v5[e0],MatrixRow23XYZT(r0) // V5 = Row 2,3 XYZT ($050)

  vmudh v6,v0,v4[e8] // X = (Matrix[0] * X) + (Matrix[1] * Y) + (Matrix[2] * Z) + Matrix[3]
  vmadh v6,v1,v4[e9]
  vmadh v6,v2,v4[e10]
  vadd v6,v4[e11]

  vmudh v7,v0,v4[e12] // Y = (Matrix[4] * X) + (Matrix[5] * Y) + (Matrix[6] * Z) + Matrix[7]
  vmadh v7,v1,v4[e13]
  vmadh v7,v2,v4[e14]
  vadd v7,v4[e15]

  vmudh v8,v0,v5[e8] // Z = (Matrix[8] * X) + (Matrix[9] * Y) + (Matrix[10] * Z) + Matrix[11]
  vmadh v8,v1,v5[e9]
  vmadh v8,v2,v5[e10]
  vadd v8,v5[e11]

// Store Rectangle Z Coords To DMEM
  sqv v8[e0],PointZ(r0) // DMEM $020 = Point Z

// Calculate X,Y 2D
  vmulf v8,v3[e10] // V8 = Z / FOV

  vrcp v3[e3],v8[e0] // Result Fraction (Zero), Source Integer (Z0)
  vrcph v9[e0],v3[e3] // Result Integer, Source Fraction (Zero)

  // assuming this have to do with the camera?
  vmulf v6,v9[e0] // X = X / Z + (ScreenX / 2)
  vadd v6,v3[e8]

  vmulf v7,v9[e0] // Y = Y / Z + (ScreenY / 2)
  vadd v7,v3[e9]

// Store Rectangle X,Y Coords To DMEM
  sqv v6[e0],PointX(r0) // DMEM $000 = Point X
  sqv v7[e0],PointY(r0) // DMEM $010 = Point Y

// here....?
// increment a0 and a1 at the end of looppoint
  ori a0,r0,PointX // A0 = X Vector DMEM Offset
  ori a1,r0,RectangleZ // A1 = RDP Rectangle XY DMEM Offset
  ori t4,r0,0 // T4 = Point Count, constant is 1 less than the number of points you want to draw

LoopPoint:
  // microcode or classic mips?
  // seems very similar to mips, but sometimes instructions are missing on value
  // lhu: zero extended load halfword (2 bytes)
  // - start mem address is a0 + offset PointX
  // - offset is 16-bit 2s complement
  lhu t0,PointX(a0) // T0 = Point X
  // sll: shift left logical
  // - move bits to left (lower to higher)
  // - shift by 2, assuming that since there is no destination register it is staying in t0
  sll t0,2 // Convert To Rectangle Fixed Point 10.2 Format
  
  lhu t1,PointY(a0) // T1 = Point Y
  sll t1,2 // Convert To Rectangle Fixed Point 10.2 Format
  lhu t2,PointZ(a0) // T2 = Point Z

  // sh: stores low 16 bits of reg into mem as 2 bytes starting at address
  // primitive z depth vs point z?
  sh t2,$0004(a1) // Store Primitive Z Depth 

  sll t2,t0,12
  // classic mips add has a destination register
  // does this mean t2 is automatically dest register?
  add t2,t1 // T2 = XL,YL
  // load upper immiediate (load constant into upper 16 bits, lower 16 = 0)
  lui t3,$3600
  add t2,t3 // T2 = Rectangle 1st Word
  // store first word, 8 a1 offset, 1 byte offset
  sw t2,$0008(a1) // Store 1st Word
  
  // again missing a dest register, automatically T0?, assuming << is shifting bits?
  // confirm that
  subi t0,2<<2 // T0 = XH
  subi t1,2<<2 // T0 = YH
  sll t2,t0,12
  add t2,t1 // T2 = XH,YH (Rectangle 2nd Word)
  sw t2,$000C(a1) // Store 2nd Word

  addi a0,2 // X Vector DMEM Offset += 2
  addi a1,24 // RDP Rectangle0XY DMEM Offset += 24
  bnez t4,LoopPoint // IF (Point Count != 0) LoopPoint
  subi t4,1 // Decrement Point Count (Delay Slot)

  // after 
  RSPDPC(RDPBuffer, RDPBufferEnd) // Run DPC Command Buffer: Start, End

  break // Set SP Status Halt, Broke & Check For Interrupt
align(8) // Align 64-Bit
base RSPCode+pc() // Set End Of RSP Code Object
RSPCodeEnd:

align(8) // Align 64-Bit
RSPData:
base $0000 // Set Base Of RSP Data Object To Zero

PointX:
  dh -2000,  0, 0,  0, 0, 0, 0, 0 // 8 * Point X (S15) (Signed Integer)
PointY:
  dh  0,  0, 0, 0,  0, 0, 0, 0 // 8 * Point Y (S15) (Signed Integer)
PointZ:
  dh -1000, 0, 0, 0,  0, 0,  0, 0 // 8 * Point Z (S15) (Signed Integer)

HALF_SCREEN_XY_FOV: // half screen xy fov
  dh 160, 120, 400, 0, 0, 0, 0, 0 // Screen X / 2 (S15) (Signed Integer), Screen Y / 2 (S15) (Signed Integer), FOV (Signed Fraction), Zero Const

MatrixRow01XYZT:
  dh 1,0,0,0 // Row 0 X,Y,Z,T (S15) (Signed Integer) (X)
  dh 0,1,0,0 // Row 1 X,Y,Z,T (S15) (Signed Integer) (Y)
MatrixRow23XYZT:
  dh 0,0,1,4000 // Row 2 X,Y,Z,T (S15) (Signed Integer) (Z) // 4000 is scaling my z, the higher the number, the closer together my points appear? is it because they are actually just further away from the camera? or is it making the distance between values (the z val of the shape) bigger
  dh 0,0,0,1 // Row 3 X,Y,Z,T (S15) (Signed Integer) (T)

align(8) // Align 64-Bit
RDPBuffer:
arch n64.rdp
  Set_Scissor 0<<2,0<<2, 0,0, 320<<2,240<<2 // Set Scissor: XH 0.0,YH 0.0, Scissor Field Enable Off,Field Off, XL 320.0,YL 240.0
  Set_Other_Modes CYCLE_TYPE_FILL // Set Other Modes
  Set_Z_Image $00200000 // Set Z Image: DRAM ADDRESS $00200000
  Set_Color_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_16B,320-1, $00200000 // Set Color Image: FORMAT RGBA,SIZE 16B,WIDTH 320, DRAM ADDRESS $00200000
  Set_Fill_Color $FFFFFFFF // Set Fill Color: PACKED COLOR 16B R5G5B5A1 Pixels (Clear ZBuffer)
  Fill_Rectangle 319<<2,239<<2, 0<<2,0<<2 // Fill Rectangle: XL 319.0,YL 239.0, XH 0.0,YH 0.0

  // why do we do this fill rectangle twice?
  Sync_Pipe // Stall Pipeline, Until Preceeding Primitives Completely Finish
  Set_Color_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_16B,320-1, $00100000 // Set Color Image: FORMAT RGBA,SIZE 16B,WIDTH 320, DRAM ADDRESS $00100000
  Set_Fill_Color $00010001 // Set Fill Color: PACKED COLOR 16B R5G5B5A1 Pixels
  Fill_Rectangle 319<<2,239<<2, 0<<2,0<<2 // Fill Rectangle: XL 319.0,YL 239.0, XH 0.0,YH 0.0

  Set_Other_Modes SAMPLE_TYPE|BI_LERP_0|ALPHA_DITHER_SEL_NO_DITHER|B_M1A_0_2|IMAGE_READ_EN|Z_SOURCE_SEL|Z_COMPARE_EN|Z_UPDATE_EN // Set Other Modes
  Set_Combine_Mode $0,$00, 0,0, $1,$01, $0,$F, 1,0, 0,0,0, 7,7,7 // Set Combine Mode: SubA RGB0,MulRGB0, SubA Alpha0,MulAlpha0, SubA RGB1,MulRGB1, SubB RGB0,SubB RGB1, SubA Alpha1,MulAlpha1, AddRGB0,SubB Alpha0,AddAlpha0, AddRGB1,SubB Alpha1,AddAlpha1

  Set_Blend_Color HOT_PINK32 // Set Blend Color: R 255,G 0,B 0,A 255
  // Set_Blend_Color vs Set_Fill_Color?
  
  // only need one of these lines, but works w either one
RectangleZ:
  Set_Prim_Depth 10000,10000 // Set Primitive Depth: PRIMITIVE Z,PRIMITIVE DELTA Z
RectangleXY:
  Fill_Rectangle 0,0, 0,0 // Fill Rectangle: XL,YL, XH,YH

  Sync_Full // Ensure Entire Scene Is Fully Drawn
RDPBufferEnd:

align(8) // Align 64-Bit
base RSPData+pc() // Set End Of RSP Data Object
RSPDataEnd: