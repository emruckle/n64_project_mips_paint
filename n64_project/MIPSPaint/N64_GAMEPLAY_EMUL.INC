// ----------------------------------------------------------------------------------------------------------
// N64 Include by Emma Ruckle
// Macros essential to gameplay including intialization, changing modes, boundary checks, rendering
// ----------------------------------------------------------------------------------------------------------

constant framebuffer = $A0100000 // base address of the framebuffer

macro initFramebuffer(color, framebuffer, framebufferEnd) { // initialize framebuffer
    li t0, {color}
    la t1, {framebuffer}
    la t2, {framebufferEnd}
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

macro initBrushArray(color, brushAddress) { // initialize brush array to WHTIE32
    li t0, {color}
	la t1, {brushAddress}
	li t2, 37
	BrushArray:
		sw t0, 0(t1)
		addi t1, t1, 4
		bnez t2, BrushArray
		addi t2, t2, -1
}

macro changeModeErase() { // change mode to erase, t4 = pos, t6 = mode
    la t0, $A0108C20 // boundary check
    blt t4, t0, Render
	nop

    addi t0, r0, 1
    beq t6, t0, Render // eraser check
	nop

    addi t6, r0, 1
	addi a2, r0, -1 // draw and move have the same sprite, so no need to differentiate
	jal SaveOrRestoreBrush // restore brush
    add a0, r0, t8
	addi a2, r0, 1
	jal SaveOrRestoreEraser // save eraser
	add a0, r0, t4
}

macro changeModeDraw() { // change mode to draw, t4 = pos, t6 = mode
    la t0, $A0108720 // boundary check
    blt t4, t0, Render
    nop

    beq t6, r0, Render // draw check
	nop

    addi t0, r0, 2
    beq t6, t0, Render // move check
    addi t6, r0, 0

	addi a2, r0, -1 // restore eraser
	jal SaveOrRestoreEraser
	add a0, r0, t8
	addi a2, r0, 1 // save brush
	jal SaveOrRestoreBrush
	add a0, r0, t4
}

macro changeModeMove() { // change to move, t6 = mode, no boundary check because move mode's boundary is higher than draw's and erase's
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

macro upCheck(framebuffer) { // check upper bound (dependent on mode), t4 = pos, t6 = mode
    addi a0, r0, 2
	beql t6, a0, upStart
	addi t2, r0, 10272 // move upper bound
	addi a0, r0, 1
	beq t6, a0, upErase
	nop
    upDraw:
		li t2, 34592 // draw upper bound
        j upStart
        nop
    upErase:
		li t2, 35872 // erase upper bound
	upStart:
		la t1, {framebuffer}
		add t2, t1, t2 
		bltl t4, t2, upEnd // if pos less than bound, add 320 * 4 to pos
		addi t4, t4, 1280
	upEnd:  
}

macro downCheck() { // check lower bound (all modes have same lower bound), t4 = pos
    la t1, $A01469D8 - 320 * 4
	bgtl t4, t1, downEnd // if greater than lower bound, subtract 320 * 4
	addi t4, t4, -1280
    downEnd:
}

macro checkLeft() { // check left bound, t4 = pos, t5 = x pos
    //bltzl t5, FixL // if less than left bound, add 4
	addi t1, r0, 4
	bltl t5, t1, FixL
	addi t5, t5, 4 // x counter
	j LEnd
	nop
	FixL:
        addi t4, t4, 4 // current pos
	LEnd:
}

macro checkRight() { // check right bound, t4 = pos, t5 = x pos
    addi t1, r0, 1212
	bgtl t5, t1, FixR // if greater than right bound, subtract 4
	addi t5, t5, -4 // x counter
	j REnd
	nop
	FixR:
		addi t4, t4, -4 // current pos
	REnd:
}

macro eraseRender() { // if on erase mode, render screen with a 3x3 area erased, t4 = pos, t8 = old pos
    li t0, WHITE32
    sw t0, 0(t8) // color old current loc pixel white
	addi t7, t4, -1284
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
	li t0, BLACK32 // mark center of eraser with a black pixel
	sw t0, 0(t4) 
	addi a2, r0, -1 // restore eraser
	jal SaveOrRestoreEraser
	add a0, r0, t8
	addi a2, r0, 1 // save eraser
	jal SaveOrRestoreEraser
	add a0, r0, t4
	jal EraserSprite // draw sprite
	add a0, r0, t4
}

macro drawRender() { // if on draw mode, render screen with a 2x2 colored area, t4 = pos, t8 = old pos
	sw t9, 0(t8) // color old current loc
	addi t7, t4, -4 
	sw t9, 0(t7)
	addi t7, t7, 320 * 4
	sw t9, 0(t7)
	addi t7, t7, 4
	sw t9, 0(t7)
	addi a2, r0, -1 // restore brush
	jal SaveOrRestoreBrush
	add a0, r0, t8
	addi a2, r0, 1
	jal SaveOrRestoreBrush // save brush
	add a0, r0, t4
	jal BrushSprite // draw sprite
	add a0, r0, t4
}

macro moveRender() { // if on move mode, render the screen, t4 = pos, t8 = old pos
	addi a2, r0, -1
	jal SaveOrRestoreBrush // restore brush
	add a0, r0, t8
	addi a2, r0, 1
	jal SaveOrRestoreBrush // save brush
	add a0, r0, t4
	jal BrushSprite // draw sprite
	add a0, r0, t4
}

