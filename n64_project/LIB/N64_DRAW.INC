// emma'a include file (old, used in some tests but not in MIPS Paint)

constant framebuffer = $A0100000
//constant framebufferEnd = $A014B000
constant brushAddress = $80003000
//constant startingPos = $A0123C80
//constant eraseBoundary = $A0108C20
//constant drawBoundary = $A0108720
//constant paletteBoundary = $A0107D20

macro initFramebuffer(color, framebuffer) {
    li t0, {color}
    la t1, {framebuffer}
    la t2, $A014B000

    clearLoop:
 		sw t0, 0x0(t1)
		bne t1, t2, clearLoop
		addi t1, t1, 4
}

//macro initPalette() {
//    pass
//}

macro gameSetup() { // t4 = pos, t5 = x pos, t6 = mode, t9 = color
	la t4, $A0123C80
    addi t5, r0, 608
    addi t6, r0, 2
	li t9, HOT_PINK32
}

macro initBrushArray(color, brushAddress) {
    li t0, {color}
	la t1, {brushAddress}
	li t2, 37

	BrushArray:
		sw t0, 0(t1)
		addi t1, t1, 4
		bnez t2, BrushArray
		addi t2, t2, -1
}

// bitmasks?
// do i want to use the delay slot even if i dont need to? is that more expensive than using a nop everytime
macro changeModeErase() { // t4 = pos, t6 = mode
    la t0, $A0108C20 // boundary check
    blt t4, t0, changeModeEnd
    addi t0, r0, 1

    beq t6, t0, changeModeEnd // eraser check
    addi t6, r0, 1

	jal RestoreBrush
    add a0, r0, t8
	jal SaveEraser
	add a0, r0, t4
}

macro changeModeDraw() { // t4 = pos, t6 = mode
    la t0, $A0108720 // boundary check
    blt t4, t0, changeModeEnd
    nop // can you get rid of this nop?

    beq t6, r0, changeModeEnd // draw check
    addi t0, r0, 2

    beq t6, t0, changeModeEnd // move check
    addi t6, r0, 0

	jal RestoreEraser
	add a0, r0, t8
	jal SaveBrush
	add a0, r0, t4
}

macro changeModeMove() { // t6 = mode
    beql t6, r0, changeModeEnd // draw check
    addi t6, r0, 2

    addi t0, r0, 1
    bne t6, t0, changeModeEnd // erase check
    addi t6, r0, 2

	jal RestoreEraser
	add a0, r0, t8
	jal SaveBrush
	add a0, r0, t4
}

macro colorSelection() {
	la t0, $A0107D20
    bgt t4, t0, Render // if you are outside of the color cells, jump to render
	nop

    add a0, r0, t5
	jal ChangeColor // call ChangeColor
	add a1, r0, t9

	j Render // jump to render
	add t9, r0, v0
}


