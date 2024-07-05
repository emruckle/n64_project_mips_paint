// emma'a include file

//constant framebufferEnd = $A014B000
//constant brushAddress = $80003000
//constant startingPos = $A0123C80
//constant eraseBoundary = $A0108C20
//constant drawBoundary = $A0108720
//constant paletteBoundary = $A0107D20
constant framebuffer = $A0100000

macro initFramebuffer(color, framebuffer) {
    li t0, {color}
    la t1, {framebuffer}
    la t2, $A014B000

    clearLoop:
 		sw t0, 0x0(t1)
		bne t1, t2, clearLoop
		addi t1, t1, 4
}

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
    blt t4, t0, Render
    addi t0, r0, 1

    beq t6, t0, Render // eraser check
    addi t6, r0, 1

	addi a2, r0, -1
	jal SaveOrRestoreBrush
    add a0, r0, t8
	addi a2, r0, 1
	jal SaveOrRestoreEraser
	add a0, r0, t4
}

macro changeModeDraw() { // t4 = pos, t6 = mode
    la t0, $A0108720 // boundary check
    blt t4, t0, Render
    nop // can you get rid of this nop?

    beq t6, r0, Render // draw check
    addi t0, r0, 2

    beq t6, t0, Render // move check
    addi t6, r0, 0

	addi a2, r0, -1
	jal SaveOrRestoreEraser
	add a0, r0, t8
	addi a2, r0, 1
	jal SaveOrRestoreBrush
	add a0, r0, t4
}

macro changeModeMove() { // t6 = mode
    beql t6, r0, Render // draw check
    addi t6, r0, 2

    addi t0, r0, 1
    bne t6, t0, Render // erase check
    addi t6, r0, 2
    
    li t0, WHITE32
    sw t0, 0(t8)
	addi a2, r0, -1
	jal SaveOrRestoreEraser
	add a0, r0, t8
	addi a2, r0, 1
	jal SaveOrRestoreBrush
	add a0, r0, t4
}

macro upCheck(framebuffer) { // a0 = t4 = pos, a1 = t6 = mode
    addi a0, r0, 2
	beql t6, a0, upStart
	addi t2, r0, 10272
	addi a0, r0, 1
	beq t6, a0, upErase
	nop
    upDraw:
		li t2, 34592
        j upStart
        nop
    upErase:
		li t2, 35872
	upStart:
		la t1, {framebuffer}
		add t2, t1, t2 
		bltl t4, t2, upEnd
		addi t4, t4, 1280
	upEnd:  
}

macro downCheck() { // a0 = t4 = pos
    la t1, $A01469D8
	bgtl t4, t1, downEnd
	addi t4, t4, -1280
    downEnd:
}

macro checkLeft() { // a0 = t4 = pos, a1 = t5 = x pos
    bltzl t5, FixL
	addi t5, t5, 4
	j LEnd
	nop
	FixL:
        addi t4, t4, 4
	LEnd:
}

macro checkRight() { // a0 = t4 = pos, a1 = t5 = x pos
    addi t1, r0, 1208
	bgtl t5, t1, FixR // if a1 > t1, fix it
	addi t5, t5, -4
	j REnd
	nop
	FixR:
		addi t4, t4, -4
	REnd:
}


macro eraseRender() { // t4 = pos, t8 = old pos
    li t0, WHITE32
    sw t0, 0(t8)
	addi t7, t4, -1280
	addi t1, r0, 3
	eraseLoop:
		addi t2, r0, 3
		eraseLoopRow:
			sw t0, 0(t7)
			addi t2, t2, -1
			bnezl t2, eraseLoopRow
			addi t7, t7, 4
	    addi t1, t1, -1
		bnezl t1, eraseLoop
		addi t7, t7, 1272  
	    addi t7, t4, 320 * 4
	li t0, BLACK32
	sw t0, 0(t4) 
	addi a2, r0, -1
	jal SaveOrRestoreEraser
	add a0, r0, t8
	addi a2, r0, 1
	jal SaveOrRestoreEraser
	add a0, r0, t4
	jal EraserSprite
	add a0, r0, t4
}

macro drawRender() { // t4 = pos, t8 = old pos
	sw t9, 0(t8)
	subi t7, t4, 4 
	sw t9, 0(t4)
	addi t7, t7, 320 * 4
	sw t9, 0(t4)
	addi t7, t7, 4
	sw t9, 0(t4)
	addi a2, r0, -1
	jal SaveOrRestoreBrush
	add a0, r0, t8
	addi a2, r0, 1
	jal SaveOrRestoreBrush
	add a0, r0, t4
	jal BrushSprite
	add a0, r0, t4
}

macro moveRender() { // t4 = pos, t8 = old pos
	addi a2, r0, -1
	jal SaveOrRestoreBrush
	add a0, r0, t8
	addi a2, r0, 1
	jal SaveOrRestoreBrush
	add a0, r0, t4
	jal BrushSprite
	add a0, r0, t4
}

