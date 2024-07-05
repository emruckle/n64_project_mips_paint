// emma'a include file

constant framebuffer = $A0100000
constant framebufferEnd = $A014B000
constant brushAddress = $80003000
constant startingPos = $A0123C80
constant moveBoundary = $A0108C20


macro initFramebuffer(color, framebuffer, framebufferEnd) {
    li t0, {color}
    la t1, {framebuffer}
    la t2, {framebufferEnd}

    clearLoop:
 		sw t0, 0x0(t1)
		addi t1, t1, 4
		bne t1, t2, clearLoop
		nop
}

macro initPalette() {
    pass
}

macro gameSetup(framebuffer) { // t4 = pos, t5 = x pos, t6 = mode, t9 = color
	la t4, {startingPos}
	li t5, 608
    li t6, 2
	li t9, HOT_PINK32
}

macro initBrushArray(color, brushAddress) {
	li t0, {color}
    la t1, {brushAddress}
	li t2, 38
	BrushArray:
		sw t0, 0(t1)
		addi t1, t1, 4
		subi t2, t2, 1
		bnez t2, BrushArray
		nop
}

macro ChangeModeErase(moveBoundary) {
	li t0, 1
	beq t0, t6, EraseModeEnd // if game is already in erase mode, jump to end
	nop

	DrawOrMoveToErase:
		li t0, {moveBoundary}
		blt t4, t0, EraseModeEnd
		nop
		li t6, 1
		move a0, t8
		jal RestoreBrush
		nop
		move a0, t4
		jal SaveEraser
		nop

		EraseModeEnd:
			j Render
			nop
}