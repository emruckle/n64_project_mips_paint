// drawing sprites with cpu
arch n64.cpu
endian msb
output "paintbrush.N64", create
// 1024 KB + 4 KB = 1028 KB
fill $00101000 // Set ROM Size

origin $00000000
base $80000000

include "../LIB/N64.INC"
include "../LIB/N64_GFX.INC"
include "../LIB/COLORS32.INC"
include "N64_Header.asm"
insert "../LIB/N64_BOOTCODE.BIN"

Start:
	lui t0, PIF_BASE
	addi t1, 0, 8
	sw t1, PIF_CTRL(t0)

	ScreenNTSC(320, 240, BPP32, $A0100000)
	
InitializeFrameBuffer:
	li t0, $FFFFFF00
	
 	// Buffer Start
	la t1, $A0100000

	// Buffer End
	li t2, (320 * 240) * 4
	add t2, t2, t1

loopFrameBuffer:
 	sw t0, 0x0(t1)
	addi t1,t1,4
	bne t1,t2,loopFrameBuffer
	nop

StartingPos: 
	lui t0, HOT_PINK32
	ori t0, HOT_PINK32 
	la t1, $A0100000
    li t2, 73280 * 2
    add t4, t1, t2
	sw t0, 0(t4)

Brush:
	//li t0, BLACK32

	//subi t4, t4, 320 * 4

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4
	//subi t4, t4, 12
	//sw t0, 0(t4)

	//li t0, BROWN32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 16
	//sw t0, 0(t4)

	//li t0, BROWN32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4
	
	//subi t4, t4, 20
	//sw t0, 0(t4)

	//li t0, BROWN32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 24
	//sw t0, 0(t4)

	//li t0, BROWN32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 24
	//sw t0, 0(t4)

	//li t0, BROWN32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 20
	//sw t0, 0(t4)

	//li t0, BROWN32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, ORANGE32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 20
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, ORANGE32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 12
	//sw t0, 0(t4)
	
	//li t0, ORANGE32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4
	
	//subi t4, t4, 12
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, PURPLE32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//////

	//subi t4, t4, 320 * 4

	//subi t4, t4, 12
	//sw t0, 0(t4)

	//li t0, PURPLE32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 12
	//sw t0, 0(t4)

	//li t0, PURPLE32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 12
	//sw t0, 0(t4)

	//li t0, PURPLE32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 12
	//sw t0, 0(t4)

	//li t0, PURPLE32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 12
	//sw t0, 0(t4)

	//li t0, PURPLE32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 12
	//sw t0, 0(t4)

	//li t0, PURPLE32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	///li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 12
	//sw t0, 0(t4)

	//li t0, PURPLE32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 12
	//sw t0, 0(t4)

	//li t0, PURPLE32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 12
	//sw t0, 0(t4)

	//li t0, PURPLE32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4

	//subi t4, t4, 12
	//sw t0, 0(t4)

	//li t0, PURPLE32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//li t0, BLACK32

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//subi t4, t4, 320 * 4
	
	//subi t4, t4, 8
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

	//addi t4, t4, 4
	//sw t0, 0(t4)

Brush2:

	li t0, BLACK32

	subi t4, t4, 320 * 4

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4

	subi t4, t4, 12
	sw t0, 0(t4)

	li t0, BROWN32

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4

	subi t4, t4, 12
	sw t0, 0(t4)

	li t0, BROWN32

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4

	subi t4, t4, 16
	sw t0, 0(t4)

	li t0, BROWN32

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4

	subi t4, t4, 12
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, ORANGE32

	addi t4, t4, 4
	sw t0, 0(t4)
	
	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4

	subi t4, t4, 4
	sw t0, 0(t4)

	li t0, PURPLE32

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)


	subi t4, t4, 320 * 4

	subi t4, t4, 4
	sw t0, 0(t4)

	li t0, PURPLE32

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)


	subi t4, t4, 320 * 4

	subi t4, t4, 4
	sw t0, 0(t4)

	li t0, PURPLE32

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)


	subi t4, t4, 320 * 4

	subi t4, t4, 4
	sw t0, 0(t4)

	li t0, PURPLE32

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4
	subi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

UpBrush:
	StartingPos3: 
	lui t0, HOT_PINK32
	ori t0, HOT_PINK32 
	la t1, $A0100000
    li t2, 73280 * 2 - 300 

    add t4, t1, t2
	sw t0, 0(t4)

	subi t4, t4, 320 * 4
	addi t4, t4, 4

	li t0, BLACK32
	
	sw t0, 0(t4)
	
	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4
	subi t4, t4, 4

	sw t0, 0(t4)

	li t0, PURPLE32

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4
	subi t4, t4, 4

	sw t0, 0(t4)

	li t0, PURPLE32

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4
	subi t4, t4, 4

	sw t0, 0(t4)

	li t0, PURPLE32

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4
	subi t4, t4, 4

	sw t0, 0(t4)

	li t0, PURPLE32

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4
	subi t4, t4, 4

	sw t0, 0(t4)

	li t0, ORANGE32

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4
	subi t4, t4, 12

	sw t0, 0(t4)

	li t0, BROWN32

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4
	subi t4, t4, 16

	sw t0, 0(t4)

	li t0, BROWN32

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4
	subi t4, t4, 12

	sw t0, 0(t4)

	li t0, BROWN32

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	li t0, BLACK32

	addi t4, t4, 4
	sw t0, 0(t4)

	subi t4, t4, 320 * 4
	subi t4, t4, 12

	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)

	addi t4, t4, 4
	sw t0, 0(t4)





Eraser:
	StartingPos2: 
	lui t0, HOT_PINK32
	ori t0, HOT_PINK32 
	la t1, $A0100000
    li t2, 73280 * 2 + 300
    add t4, t1, t2
	sw t0, 0(t4)

	li t0, PALE_VIOLET_RED32

	subi t4, t4, 320 * 4
	addi t4, t4, 4
	li t1, 10
	ERows:
		li t2, 9
		ENest:
			sw t0, 0(t4)
			addi t4, t4, 4
			subi t2, t2, 1
			bnez t2, ENest
			nop
		ENestEnd:
			subi t1, t1, 1
			beqz t1, End
			subi t4, t4, 320 * 4
			subi t4, t4, 36
			j ERows
			nop
	End:








	
Loop:
	j Loop
	nop