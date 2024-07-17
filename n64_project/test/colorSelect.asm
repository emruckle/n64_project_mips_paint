// drawing color select palette with cpu

arch n64.cpu
endian msb
output "colorSelect.N64", create
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

// bounds

    li t0, HOT_PINK32

	// upper left bound on console

	la t1, $A0100000

	li t3, (320 * 3 + 8) * 4
	add t6, t1, t3

	sw t0, 0x0(t6)

	// upper right bound on console
	
	addi t6, 604 * 2
	sw t0, 0x0(t6)

	// lower left bound

	la t1, $A0100000

	//get starting pos (2 pixels)
	li t3, (320 * 225 + 8) * 4
	add t6, t1, t3

	sw t0, 0x0(t6)

	// lower right bound on console
	
	addi t6, 604 * 2
	sw t0, 0x0(t6)

// end bounds


// start palette

	// init info
	li t0, GREY32
	la t1, $A0100000

	// upper boundary nested loop
	li t2, (320 * 3 + 8) * 4
	add t2, t1, t2
	li t3, 2
	UpperBoundary:
		li t4, 304
		UBRow:
			sw t0, 0(t2)
			addi t2, t2, 4
			subi t4, t4, 1
			bnez t4, UBRow
			nop
		subi t2, t2, 304 * 4
		addi t2, t2, 320 * 4
		subi t3, t3, 1
		bnez t3, UpperBoundary
		nop

	// lower boundary nested loop
    li t2, 320 * 25 * 4 + 32
    add t2, t1, t2
	li t3, 2
	LowerBoundary:
		li t4, 304
		LBR:
			sw t0, 0(t2)
			addi t2, t2, 4
			subi t4, t4, 1
			bnez t4, LBR
			nop
		subi t2, t2, 304 * 4
		addi t2, t2, 320 * 4
		subi t3, t3, 1
		bnez t3, LowerBoundary
		nop

	// left vertical nested loop
	li t2, 3872 + 320 * 4
	add t2, t1, t2
	li t3, 22
	LeftVertical:
		li t4, 5
		LVRow:
			sw t0, 0(t2)
			addi t2, t2, 4
			subi t4, t4, 1
			bnez t4, LVRow
			nop
		subi t2, t2, 5 * 4
		addi t2, t2, 320 * 4
		subi t3, t3, 1
		bnez t3, LeftVertical
		nop

	// right vertical nested loop
	li t2, 3872 + 320 * 4 + 604 * 2 + 4 - 16
	add t2, t1, t2
	li t3, 22
	RightVertical:
		li t4, 5
		RVRow:
			sw t0, 0(t2)
			addi t2, t2, 4
			subi t4, t4, 1
			bnez t4, RVRow
			nop
		subi t2, t2, 5 * 4
		addi t2, t2, 320 * 4
		subi t3, t3, 1
		bnez t3, RightVertical
		nop

	// vertical dividers nested loop
	li t2, 3872 + 320 * 4 + 16 + 35 * 4
	add t2, t1, t2
	li t3, 7
	VerticalDividers:
		li t4, 22
		SetOfDividers:
			li t5, 2
			DVRow:
				sw t0, 0(t2)
				addi t2, t2, 4
				subi t5, t5, 1
				bnez t5, DVRow
				nop
			subi t2, t2, 8
			addi t2, t2, 320 * 4
			subi t4, t4, 1
			bnez t4, SetOfDividers
			nop
		li t6, 320 * 22 * 4
		sub t2, t2, t6
		addi t2, 37 * 4
		subi t3, t3, 1
		bnez t3, VerticalDividers
		nop

	li t2, 3872 + 320 * 4 * 2 +20
	li t0, RED32
	add t2, t1, t2
	li t3, 20
	RedLoop:
		li t4, 34
		RLRow:
			sw t0, 0(t2)
			addi t2, t2, 4
			subi t4, t4, 1
			bnez t4, RLRow
			nop
		subi t2, t2, 34 * 4
		addi t2, t2, 320 * 4
		subi t3, t3, 1
		bnez t3, RedLoop
		nop

	li t2, 3872 + 320 * 4 * 2 +20 + 8 + 34 * 4
	li t0, ORANGE32
	add t2, t1, t2
	li t3, 20
	OrangeLoop:
		li t4, 35
		OLRow:
			sw t0, 0(t2)
			addi t2, t2, 4
			subi t4, t4, 1
			bnez t4, OLRow
			nop
		subi t2, t2, 35 * 4
		addi t2, t2, 320 * 4
		subi t3, t3, 1
		bnez t3, OrangeLoop
		nop

	li t2, 3872 + 320 * 4 * 2 +20 + 8 + 34 * 4 * 2 + 12
	li t0, YELLOW32
	add t2, t1, t2
	li t3, 20
	YellowLoop:
		li t4, 35
		YLRow:
			sw t0, 0(t2)
			addi t2, t2, 4
			subi t4, t4, 1
			bnez t4, YLRow
			nop
		subi t2, t2, 35 * 4
		addi t2, t2, 320 * 4
		subi t3, t3, 1
		bnez t3, YellowLoop
		nop

	li t2, 3872 + 320 * 4 * 2 +20 + 8 + 34 * 4 * 2 + 12 + 35 * 4 + 8
	li t0, LIME_GREEN32
	add t2, t1, t2
	li t3, 20
	GreenLoop:
		li t4, 35
		GLRow:
			sw t0, 0(t2)
			addi t2, t2, 4
			subi t4, t4, 1
			bnez t4, GLRow
			nop
		subi t2, t2, 35 * 4
		addi t2, t2, 320 * 4
		subi t3, t3, 1
		bnez t3, GreenLoop
		nop

	li t2, 3872 + 320 * 4 * 2 +20 + 8 + 34 * 4 * 2 + 12 + 35 * 4 * 2 + 8 + 8
	li t0, DEEP_SKY_BLUE32
	add t2, t1, t2
	li t3, 20
	BlueLoop:
		li t4, 35
		BLRow:
			sw t0, 0(t2)
			addi t2, t2, 4
			subi t4, t4, 1
			bnez t4, BLRow
			nop
		subi t2, t2, 35 * 4
		addi t2, t2, 320 * 4
		subi t3, t3, 1
		bnez t3, BlueLoop
		nop

	li t2, 3872 + 320 * 4 * 2 +20 + 8 + 34 * 4 * 2 + 12 + 35 * 4 * 3 + 8 + 8 + 8
	li t0, DARK_VIOLET32
	add t2, t1, t2
	li t3, 20
	PurpleLoop:
		li t4, 35
		PuLRow:
			sw t0, 0(t2)
			addi t2, t2, 4
			subi t4, t4, 1
			bnez t4, PuLRow
			nop
		subi t2, t2, 35 * 4
		addi t2, t2, 320 * 4
		subi t3, t3, 1
		bnez t3, PurpleLoop
		nop

	li t2, 3872 + 320 * 4 * 2 +20 + 8 + 34 * 4 * 2 + 12 + 35 * 4 * 4 + 8 + 8 + 8 + 8
	li t0, HOT_PINK32
	add t2, t1, t2
	li t3, 20
	PinkLoop:
		li t4, 35
		PLRow:
			sw t0, 0(t2)
			addi t2, t2, 4
			subi t4, t4, 1
			bnez t4, PLRow
			nop
		subi t2, t2, 35 * 4
		addi t2, t2, 320 * 4
		subi t3, t3, 1
		bnez t3, PinkLoop
		nop

	li t2, 3872 + 320 * 4 * 2 +20 + 8 + 34 * 4 * 2 + 12 + 35 * 4 * 5 + 8 + 8 + 8 + 8 + 8
	li t0, BLACK32
	add t2, t1, t2
	li t3, 20
	BlackLoop:
		li t4, 36
		BlLRow:
			sw t0, 0(t2)
			addi t2, t2, 4
			subi t4, t4, 1
			bnez t4, BlLRow
			nop
		subi t2, t2, 36 * 4
		addi t2, t2, 320 * 4
		subi t3, t3, 1
		bnez t3, BlackLoop
		nop

// color cell bounds

li t0, LIME32
la t1, $A0100000

// upper right (lower cell bound)
li t2, (320 * 3 + 8) * 4 + 320 * 4 + 304 * 4 -4
add t2, t1, t2
sw t0, 0(t2)

// lower left (upper cell bound)
li t2, 32032
add t2, t1, t2
sw t0, 0(t2)

// red left
//li t2, (320 * 3 + 8) * 4 + (320 * 4) * 10 + 20
li t2, 16692
add t2, t1, t2
sw t0, 0(t2)

// red right
//li t2, (320 * 3 + 8) * 4 + (320 * 4) * 10 + 20 + 34 * 4 - 4
li t2, 16824
add t2, t1, t2
sw t0, 0(t2)

// orange left
//li t2, (320 * 3 + 8) * 4 + (320 * 4) * 10 + 20 + 34 * 4 - 4 + 12
li t2, 16836
add t2, t1, t2
sw t0, 0(t2)

li t2, (320 * 3 + 8) * 4 + (320 * 4) * 10 + 20 + 34 * 4 - 4 + 12 + 35 * 4 - 4
add t2, t1, t2
sw t0, 0(t2)




Loop:
	j Loop
	nop