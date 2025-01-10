// N64 'Bare Metal' RSP Transform 3D Rectangle Test by krom (Peter Lemon) edited by me
// mixture of my comments and peter lemon's original comments
// currents ideas: 
  // is there a way to fix the "lag" with testing the RSP?
    // when I change the RSP section, and remake the ROM, the visual I see does not always update when I run the ROM
    // sometimes it does though? incredibly inconstent
    // so I run a new ROM that should have changes but don't see any changes on the screen, gets confusing when I don't have a predicted outcome for my tests
    // is this better console vs emulator? most of this work has been on emulators
    // could another emulator be better? is it a MAME problem? try testing with ARES even though there is no debug mode
    // could I create a "palette cleanser" program? that I could run in between running my ROMs 
      // what would this program entail?
  // these are also down by the point arrays:
    // if i add an extra point, it doesn't crash, but the screen is black, all of my points disappear
    // if i remove a point, Fatal error: RDP: load_tile: size = 0
    // changing the amount of times LoopPoint runs does not affect the error
    // removing all commands in the RDP section does not affect the error
      // only way to avoid the error is do never interact with the RDP, comment out the call to start the mem transfer
    // so the error is originating somewhere where i am processing points
    // i think it might have to do with lqv, which process 16 bytes at a times
    // also might need to edit the matrices?
    // edit the amount of times we do matrix 3d -> 2d transformations
    // does it not fail because the registers are just full of junk? in that case shouldn't I not get that tile size error?
    // does a tile need four corners? is that why I am getting the error?
    // should I try to go from 8 points to 4 points rather than from 8 to 7?
      // assembly tends to like mulitples of 4, it might be easier to try to figure it out that way
arch n64.cpu
endian msb
output "Emma3DTriangle.N64", create
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

  // intialization
  N64_INIT() // Run N64 Initialisation Routine

  ScreenNTSC(320, 240, BPP16, $A0100000) // Screen NTSC: 320x240, 16BPP, DRAM Origin $A0100000

  SetXBUS() // RDP Status: Set XBUS (Switch To RSP DMEM For RDP Commands)

  // Load RSP Code To IMEM, loading commands into IMEM
  DMASPRD(RSPCode, RSPCodeEnd, SP_IMEM) // DMA Data Read DRAM->RSP MEM: Start Address, End Address, Destination RSP MEM Address
  DMASPWait() // Wait For RSP DMA To Finish, pipeline synchronization

  // Load RSP Data To DMEM, loading data into DMEM
  DMASPRD(RSPData, RSPDataEnd, SP_DMEM) // DMA Data Read DRAM->RSP MEM: Start Address, End Address, Destination RSP MEM Address
  DMASPWait() // Wait For RSP DMA To Finish, pipeline synchronization

  // set start address of RSP, start execution
  SetSPPC(RSPStart) // Set RSP Program Counter: Start Address
  StartSP() // Start RSP Execution: RSP Status = Clear Halt, Broke, Interrupt, Single Step, Interrupt On Break

  // assuming this makes sure we aren't using old data
  // Flush Data Cache: Index Writeback Invalidate
  la a1,$80000000    // A1 = Cache Start
  la a2,$80002000-16 // A2 = Cache End
  LoopCache:
    cache $0|1,0(a1) // Data Cache: Index Writeback Invalidate
    bne a1,a2,LoopCache
    addiu a1,16 // Address += Data Line Size (Delay Slot)

align(8) // Align 64-Bit
// begin RSP code
RSPCode:
arch n64.rsp
base $0000 // Set Base Of RSP Code Object To Zero

RSPStart:
// Load Point X,Y,Z, loads all the x points, all the y points, all the z points into vector registers
// i think this is part of the removing or adding points problem
// lqv moves 16 bytes
// so dh is 2 bytes, so this moves 8 points
  lqv v0[e0],PointX(r0) // V0 = Point X ($000)
  lqv v1[e0],PointY(r0) // V1 = Point Y ($010)
  lqv v2[e0],PointZ(r0) // V2 = Point Z ($020)

// Load Camera, loads starting position of camera (centered)
  lqv v3[e0],HALF_SCREEN_XY_FOV(r0) // V3 = Screen X / 2, Screen Y / 2, FOV ($030)

// Load Matrix, load values from matrices into vector register
  lqv v4[e0],MatrixRow01XYZT(r0) // V4 = Row 0,1 XYZT ($040)
  lqv v5[e0],MatrixRow23XYZT(r0) // V5 = Row 2,3 XYZT ($050)

// Calculate X,Y,Z 3D, muiltiplying matrix vectors by points vectors to get new points in the 3D space (I'm pretty sure)
// i don't think the number of operations here will change unless I change the matrices themselves
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
// 3D -> 2D conversion?
// i think the number of these operations should change with the number of points
  vmulf v8,v3[e10] // V8 = Z / FOV

  vrcp v3[e3],v8[e0] // Result Fraction (Zero), Source Integer (Z0)
  vrcph v9[e0],v3[e3] // Result Integer, Source Fraction (Zero)

  vrcp v3[e3],v8[e1] // Result Fraction (Zero), Source Integer (Z1)
  vrcph v9[e1],v3[e3] // Result Integer, Source Fraction (Zero)

  vrcp v3[e3],v8[e2] // Result Fraction (Zero), Source Integer (Z2)
  vrcph v9[e2],v3[e3] // Result Integer, Source Fraction (Zero)

  vrcp v3[e3],v8[e3] // Result Fraction (Zero), Source Integer (Z3)
  vrcph v9[e3],v3[e3] // Result Integer, Source Fraction (Zero)

  vrcp v3[e3],v8[e4] // Result Fraction (Zero), Source Integer (Z4)
  vrcph v9[e4],v3[e3] // Result Integer, Source Fraction (Zero)

  vrcp v3[e3],v8[e5] // Result Fraction (Zero), Source Integer (Z5)
  vrcph v9[e5],v3[e3] // Result Integer, Source Fraction (Zero)

  // assuming this have to do with the camera?
  vmulf v6,v9[e0] // X = X / Z + (ScreenX / 2)
  vadd v6,v3[e8]

  vmulf v7,v9[e0] // Y = Y / Z + (ScreenY / 2)
  vadd v7,v3[e9]

// Store Rectangle X,Y Coords To DMEM
  sqv v6[e0],PointX(r0) // DMEM $000 = Point X
  sqv v7[e0],PointY(r0) // DMEM $010 = Point Y

  ori a0,r0,PointX // A0 = X Vector DMEM Offset
  ori a1,r0,RectangleZ // A1 = RDP Rectangle XY DMEM Offset
  // if i manipulate this constant, I do not get any errors and can show less than 8 points, but if I remove a point from the point arrays, then I get an error
  ori t4,r0,5 // T4 = Point Count, constant is 1 less than the number of points you want to draw
  // only want to loop 6 times

LoopPoint:
  // what is fixed 10.2 format?
  // some kind of image format used in Graphics?
  // finding conflicting definitions, maybe peter lemon's includes have something to point me towards the right one?
  lhu t0,PointX(a0) // T0 = Point X
  sll t0,2 // Convert To Rectangle Fixed Point 10.2 Format
  lhu t1,PointY(a0) // T1 = Point Y
  sll t1,2 // Convert To Rectangle Fixed Point 10.2 Format
  lhu t2,PointZ(a0) // T2 = Point Z

  sh t2,$0004(a1) // Store Primitive Z Depth

  sll t2,t0,12
  add t2,t1 // T2 = XL,YL
  lui t3,$3600
  add t2,t3 // T2 = Rectangle 1st Word
  sw t2,$0008(a1) // Store 1st Word
  
  subi t0,2<<2 // T0 = XH
  subi t1,2<<2 // T0 = YH
  sll t2,t0,12
  add t2,t1 // T2 = XH,YH (Rectangle 2nd Word)
  sw t2,$000C(a1) // Store 2nd Word

  addi a0,2 // X Vector DMEM Offset += 2
  addi a1,24 // RDP Rectangle0XY DMEM Offset += 24
  bnez t4,LoopPoint // IF (Point Count != 0) LoopPoint
  subi t4,1 // Decrement Point Count (Delay Slot)

  // something in here is breaking!!
  // when I change the number of points, this is where the error occurs. I am missing a tile when I get to RDP.
  // it doesn't matter what commands I am sending the RDP pipeline, I always get this error
  // this makes me thing I am not properly updating something before getting to the RDP
  RSPDPC(RDPBuffer, RDPBufferEnd) // Run DPC Command Buffer: Start, End

  break // Set SP Status Halt, Broke & Check For Interrupt
align(8) // Align 64-Bit
base RSPCode+pc() // Set End Of RSP Code Object
RSPCodeEnd:

align(8) // Align 64-Bit
RSPData:
base $0000 // Set Base Of RSP Data Object To Zero

// this is all of the X coords for the corners of the objects
// then all the Ys and Zs
// the pos of the num corresponds to the point
// first point is (-2000, 2000, -2000)
// changed points 7, 8 to (0,0,0)
// birds eye view of these points
// triangular prism from desmos multiple by 1000
PointX:
  dh 0,  1000, -1000,  -2000, -1000, -3000, 0, 0 // 8 * Point X (S15) (Signed Integer)
PointY:
  dh  1000,  0, 2000, -1000,  -2000, 0, 0, 0 // 8 * Point Y (S15) (Signed Integer)
PointZ:
  dh 1000, 0, 0, 1,  0, 0,  0, 0 // 8 * Point Z (S15) (Signed Integer)

// there must be a reason that there are 8 values here and 8 points, would assume this changes when num of points changes too
HALF_SCREEN_XY_FOV: // half screen xy fov
  // changing FOV changes size of field of view screen.. this makes sense!
  // changing the 0s here changes NOTHING
  dh 160, 120, 400, 0, 0, 0, 0, 0 // Screen X / 2 (S15) (Signed Integer), Screen Y / 2 (S15) (Signed Integer), FOV (Signed Fraction), Zero Const

// i think this might scale the points?
MatrixRow01XYZT:
  dh 1,0,0,0 // Row 0 X,Y,Z,T (S15) (Signed Integer) (X)
  dh 0,1,0,0 // Row 1 X,Y,Z,T (S15) (Signed Integer) (Y)
MatrixRow23XYZT:
  dh 0,0,1,4000 // Row 2 X,Y,Z,T (S15) (Signed Integer) (Z) // 4000 is scaling my z, the higher the number, the closer together my points appear? is it because they are actually just further away from the camera? or is it making the distance between values (the z val of the shape) bigger
  dh 0,0,0,1 // Row 3 X,Y,Z,T (S15) (Signed Integer) (T)

align(8) // Align 64-Bit
RDPBuffer:
// RDP commands
// this is where the error is showing up, but I don't think it is where it is originating from
// i've tried deleting most if not all of the content in here, and the error still occurs
// think its a computation error above, and it is just slipping through the cracks till i get here
arch n64.rdp
  Set_Scissor 0<<2,0<<2, 0,0, 320<<2,240<<2 // Set Scissor: XH 0.0,YH 0.0, Scissor Field Enable Off,Field Off, XL 320.0,YL 240.0
  Set_Other_Modes CYCLE_TYPE_FILL // Set Other Modes
  Set_Z_Image $00200000 // Set Z Image: DRAM ADDRESS $00200000
  Set_Color_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_16B,320-1, $00200000 // Set Color Image: FORMAT RGBA,SIZE 16B,WIDTH 320, DRAM ADDRESS $00200000
  Set_Fill_Color $FFFFFFFF // Set Fill Color: PACKED COLOR 16B R5G5B5A1 Pixels (Clear ZBuffer)
  Fill_Rectangle 319<<2,239<<2, 0<<2,0<<2 // Fill Rectangle: XL 319.0,YL 239.0, XH 0.0,YH 0.0

  Sync_Pipe // Stall Pipeline, Until Preceeding Primitives Completely Finish
  Set_Color_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_16B,320-1, $00100000 // Set Color Image: FORMAT RGBA,SIZE 16B,WIDTH 320, DRAM ADDRESS $00100000
  Set_Fill_Color $00010001 // Set Fill Color: PACKED COLOR 16B R5G5B5A1 Pixels
  Fill_Rectangle 319<<2,239<<2, 0<<2,0<<2 // Fill Rectangle: XL 319.0,YL 239.0, XH 0.0,YH 0.0

  Set_Other_Modes SAMPLE_TYPE|BI_LERP_0|ALPHA_DITHER_SEL_NO_DITHER|B_M1A_0_2|IMAGE_READ_EN|Z_SOURCE_SEL|Z_COMPARE_EN|Z_UPDATE_EN // Set Other Modes
  Set_Combine_Mode $0,$00, 0,0, $1,$01, $0,$F, 1,0, 0,0,0, 7,7,7 // Set Combine Mode: SubA RGB0,MulRGB0, SubA Alpha0,MulAlpha0, SubA RGB1,MulRGB1, SubB RGB0,SubB RGB1, SubA Alpha1,MulAlpha1, AddRGB0,SubB Alpha0,AddAlpha0, AddRGB1,SubB Alpha1,AddAlpha1

    // the order of these colors is the order of the points
  Set_Blend_Color HOT_PINK32 // Set Blend Color: R 255,G 0,B 0,A 255
RectangleZ:
  Set_Prim_Depth 0,0 // Set Primitive Depth: PRIMITIVE Z,PRIMITIVE DELTA Z
RectangleXY:
  Fill_Rectangle 0,0, 0,0 // Fill Rectangle: XL,YL, XH,YH

  Set_Blend_Color SKY_BLUE32 // Set Blend Color: R 0,G 255,B 0,A 255
  Set_Prim_Depth 0,0 // Set Primitive Depth: PRIMITIVE Z,PRIMITIVE DELTA Z
  Fill_Rectangle 0,0, 0,0 // Fill Rectangle: XL,YL, XH,YH

  Set_Blend_Color LIME_GREEN32 // Set Blend Color: R 0,G 0,B 255,A 255
  Set_Prim_Depth 0,0 // Set Primitive Depth: PRIMITIVE Z,PRIMITIVE DELTA Z
  Fill_Rectangle 0,0, 0,0 // Fill Rectangle: XL,YL, XH,YH

  Set_Blend_Color RED32 // Set Blend Color: R 255,G 255,B 255,A 255
  Set_Prim_Depth 0,0 // Set Primitive Depth: PRIMITIVE Z,PRIMITIVE DELTA Z
  Fill_Rectangle 0,0, 0,0 // Fill Rectangle: XL,YL, XH,YH

  Set_Blend_Color WHITE32 // Set Blend Color: R 128,G 0,B 0,A 255
  Set_Prim_Depth 0,0 // Set Primitive Depth: PRIMITIVE Z,PRIMITIVE DELTA Z
  Fill_Rectangle 0,0, 0,0 // Fill Rectangle: XL,YL, XH,YH

  Set_Blend_Color PURPLE32 // Set Blend Color: R 0,G 128,B 0,A 255
  Set_Prim_Depth 0,0 // Set Primitive Depth: PRIMITIVE Z,PRIMITIVE DELTA Z
  Fill_Rectangle 0,0, 0,0 // Fill Rectangle: XL,YL, XH,YH

  Sync_Full // Ensure�Entire�Scene�Is�Fully�Drawn
RDPBufferEnd:

align(8) // Align 64-Bit
base RSPData+pc() // Set End Of RSP Data Object
RSPDataEnd:

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