// ----------------------------------------------------------------------------------------------------------------------------------------------
// N64 Include by Emma Ruckle
// Macros for sprites including intializing the color array, drawing the palette, drawing the sprites, saving and restoring the sprites
// ----------------------------------------------------------------------------------------------------------------------------------------------

macro drawPalette(framebuffer, colorAddress) {
	li t0, GREY32 // upper and lower edges of palette
	la t1, {framebuffer}
	addi t2, r0, 3872
	addi t5, r0, 2
	UpperAndLower:
		add t2, t1, t2
		addi t3, r0, 2
		UpperBoundary:
			addi t4, r0, 304
			UBRow:
				sw t0, 0(t2)
				addi t4, t4, -1
				bnez t4, UBRow
				addi t2, t2, 4
			addi t2, t2, -1216
			addi t3, t3, -1
			bnez t3, UpperBoundary
			addi t2, t2, 1280
		addi t5, t5, -1
		bnez t5, UpperAndLower
		addi t2, r0, 32032

	addi t2, r0, 5152 // left and right edges of the palette
	addi t5, r0, 2
	LeftAndRight:
		add t2, t1, t2
		addi t3, r0, 22
		LeftVertical:
			addi t4, r0, 5
			LVRow:
				sw t0, 0(t2)
				addi t4, t4, -1
				bnez t4, LVRow
				addi t2, t2, 4
			addi t2, t2, -20
			addi t3, t3, -1
			bnez t3, LeftVertical
			addi t2, t2, 1280
		addi t5, t5, -1
		bnez t5, LeftAndRight
		addi t2, r0, 6348

	addi t2, r0, 5312 // vertical dividers between colors in the palette
	add t2, t1, t2
	addi t3, r0, 7
	VerticalDividers:
		addi t4, r0, 22
		SetOfDividers:
			addi t5, r0, 2
			DVRow:
				sw t0, 0(t2)
				addi t5, t5, -1
				bnez t5, DVRow
				addi t2, t2, 4
			addi t2, t2, -8
			addi t4, t4, -1
			bnez t4, SetOfDividers
			addi t2, t2, 1280
		li t6, -28160
		add t2, t2, t6
		addi t3, t3, -1
		bnez t3, VerticalDividers
		addi t2, 148

	la a1, {colorAddress} // base address of color array
	addi a2, r0, 6452 // color cells in the palette
	addi t5, r0, 8
	ColorLoop:
		lw t0, 0(a1)
		add t2, t1, a2
		addi t3, r0, 20
		RedLoop:
			addi t4, r0, 35
			RLRow:
				sw t0, 0(t2)
				addi t4, t4, -1
				bnez t4, RLRow
				addi t2, t2, 4
			addi t3, t3, -1
			bnez t3, RedLoop
			addi t2, t2, 1140
		addi a1, a1, 4 // iterate through color array
		addi t5, t5, -1
		bnez t5, ColorLoop
		addi a2, a2, 148
}

macro drawBrushSprite() { // draw brush sprite (bottom to top beginning each row on the left), a0 = t4 = current loc
		li t0, BLACK32 // most rows drawn individually because of irregular shape, identical rows grouped/drawn in loops
		addi a0, a0, -1276
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
        addi t1, r0, 1
        Bristles1:
            addi a0, a0, -1292
            sw t0, 0(a0)
            li t0, BROWN32
            addi a0, a0, 4
            sw t0, 0(a0)
            addi a0, a0, 4
            sw t0, 0(a0)
            addi a0, a0, 4
            sw t0, 0(a0)
            li t0, BLACK32
            addi a0, a0, 4
            sw t0, 0(a0)
            bnez t1, Bristles1
            addi t1, t1, -1
		addi a0, a0, -1296
		sw t0, 0(a0)
		li t0, BROWN32
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		li t0, BLACK32
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, -1292
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		addi a0, a0, 4
		sw t0, 0(a0)
		li t0, ORANGE32
		addi a0, a0, 4
		sw t0, 0(a0)
		li t0, BLACK32
		addi a0, a0, 4
		sw t0, 0(a0)
        addi t1, t1, 3 
        Handle:
		    addi a0, a0, -1284
		    sw t0, 0(a0)
		    li t0, PURPLE32
		    addi a0, a0, 4
		    sw t0, 0(a0)
		    li t0, BLACK32
		    addi a0, a0, 4
		    sw t0, 0(a0)
            bnez t1, Handle
            addi t1, t1, -1
		addi a0, a0, -1284
		sw t0, 0(a0)
		addi a0, a0, 4

		jr ra // return
		sw t0, 0(a0)
}

macro drawEraserSprite() { // draw eraser sprite (drawn bottom to top beginning each row on the left), a0 = t4 = current loc
	li t0, PALE_VIOLET_RED32 // drawn with a nested loop because all rows are identical
	addi a0, a0, -1276
	addi t1, r0, 9
	ERows:
		addi t2, r0, 9
		ENest:
			sw t0, 0(a0)
			addi t2, t2, -1
			bnez t2, ENest
			addi a0, a0, 4
		ENestEnd:
				beqz t1, End
				addi t1, t1, -1
				j ERows
				addi a0, a0, -1316
	End:
		jr ra // return
		nop
}

macro saveOrRestoreBrush() { // save or restore brush, a0 = t8 = old current loc or t4 = current loc depending on mode (t8 for restore, t4 for save)
		addi a0, a0, -1276 // a2 = 1 or -1 to indicate save or restore (save = 1, restore = -1)
		la a1, BrushArrayLoc // base address of brush array
		addi t1, r0, 4
		RBR1: // brush is saved bottom to top beginning on the left each row, rows that are the same length are grouped in nested loops
			bltzl a2, Continue1
			lw t0, 0(a1) // load what is at a1 into t0
			lw t0, 0(a0)
			j Continue11
			sw t0, 0(a1)
			Continue1:
			sw t0, 0(a0) // store what is at t0 at a0
			Continue11:
			addi a1, a1, 4
			addi t1, t1, -1
			bnez t1, RBR1
			addi a0, a0, 4
		addi t2, r0, 1
		Rows2And3:
			addi a0, a0, -1296
			addi t1, r0, 5
			RBR2:
				bltzl a2, Continue2
				lw t0, 0(a1) 
				lw t0, 0(a0)
				j Continue21
				sw t0, 0(a1)
				Continue2:
				sw t0, 0(a0)
				Continue21:
				addi a1, a1, 4
				addi t1, t1, -1
				bnez t1, RBR2
				addi a0, a0, 4
			bnezl t2, Rows2And3
			addi t2, t2, -1
		addi a0, a0, -1300
		addi t1, r0, 5
		RBR4:
			bltzl a2, Continue4
			lw t0, 0(a1) 
			lw t0, 0(a0)
			j Continue41
			sw t0, 0(a1)
			Continue4:
			sw t0, 0(a0)
			Continue41:
			addi a1, a1, 4
			addi t1, t1, -1
			bnez t1, RBR4
			addi a0, a0, 4
		addi a0, a0, -1296
		addi t1, r0, 5
		RBR5:
			bltzl a2, Continue5
			lw t0, 0(a1) 
			lw t0, 0(a0)
			j Continue51
			sw t0, 0(a1)
			Continue5:
			sw t0, 0(a0)
			Continue51:
			addi a1, a1, 4
			addi t1, t1, -1
			bnez t1, RBR5
			addi a0, a0, 4
		addi t2, r0, 3
		Rows6789:
			addi a0, a0, -1288
			addi t1, r0, 3
			RBR6:
				bltzl a2, Continue6
				lw t0, 0(a1) 
				lw t0, 0(a0)
				j Continue61
				sw t0, 0(a1)
				Continue6:
				sw t0, 0(a0)
				Continue61:
				addi a1, a1, 4
				addi t1, t1, -1
				bnez t1, RBR6
				addi a0, a0, 4
			bnezl t2, Rows6789
			addi t2, t2, -1

		addi a0, a0, -1288
		addi t1, r0, 2
		RBR10:
			bltzl a2, Continue10
			lw t0, 0(a1) 
			lw t0, 0(a0)
			j Continue101
			sw t0, 0(a1)
			Continue10:
			sw t0, 0(a0)
			Continue101:
			addi a1, a1, 4
			addi t1, t1, -1
			bnez t1, RBR10
			addi a0, a0, 4

		jr ra // return
		nop
}

macro saveOrRestoreEraser() { // save or restore eraser, a0 = t8 = old current loc or t4 = current loc depending on mode (t8 for restore, t4 for save)
		addi a0, a0, -1276 // a2 = 1 or -1 to indicate save or restore (save = 1, restore = -1)
		la a1, EraserArrayLoc // base address of eraser array
		addi t1, r0, 9
		ESRows: // rows are saved/restored bottom to top beginning on the left
			addi t2, r0, 9
			ESNest:
				bltzl a2, RestoreEMode
				lw t0, 0(a1) // load what is at a1 into t0
				lw t0, 0(a0) 
				sw t0, 0(a1)
				Continue:
				addi a0, a0, 4
				addi t2, t2, -1
				bnez t2, ESNest
				addi a1, a1, 4
			ESNestEnd:
				beqz t1, ESEnd
				addi t1, t1, -1
				j ESRows
				addi a0, a0, -1316
		ESEnd:
			jr ra // return
			nop
		RestoreEMode:
			j Continue
			sw t0, 0(a0) // store t0 at a0
}

macro drawTitleBrush(startingPosition) { // draws larger brush on title screen
	la t4, {startingPosition}
	li t0, WHITE32
	addi t4, t4, -1280
	addi t5, r0, 4
	BrushWhite1:
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t5, t5, -1
		bnez t5, BrushWhite1
		nop
		addi t4, t4, -1292
		sw t0, 0(t4)
	li t0, BROWN32
	addi t5, r0, 3
	BrushBrown1:
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t5, t5, -1
		bnez t5, BrushBrown1
		nop
		li t0, WHITE32
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, -1296
		sw t0, 0(t4)
		li t0, BROWN32
	addi t5, r0, 4
	BrushBrown2:
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t5, t5, -1
		bnez t5, BrushBrown2
		nop
		li t0, WHITE32
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, -1300
		sw t0, 0(t4)
		li t0, BROWN32
	addi t5, r0, 5
	BrushBrown3:
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t5, t5, -1
		bnez t5, BrushBrown3
		nop
		li t0, WHITE32
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, -1304
		sw t0, 0(t4)
		li t0, BROWN32
	addi t5, r0, 5
	BrushBrown4:
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t5, t5, -1
		bnez t5, BrushBrown4
		nop
		li t0, WHITE32
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, -1304
		sw t0, 0(t4)
		li t0, BROWN32
	addi t5, r0, 4
	BrushBrown5:
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t5, t5, -1
		bnez t5, BrushBrown5
		nop
		li t0, WHITE32
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, -1300
		sw t0, 0(t4)
		li t0, BROWN32
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, 4
		sw t0, 0(t4)
		li t0, WHITE32
		addi t4, t4, 4
		sw t0, 0(t4)
		li t0, ORANGE32
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, 4
		sw t0, 0(t4)
		li t0, WHITE32
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, -1300
		sw t0, 0(t4)
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, 4
		sw t0, 0(t4)
		li t0, ORANGE32
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, 4
		sw t0, 0(t4)
		li t0, WHITE32
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, -1292
		sw t0, 0(t4)
		li t0, ORANGE32
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, 4
		sw t0, 0(t4)
		li t0, WHITE32
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, -1292
		sw t0, 0(t4)
		addi t4, t4, 4
		sw t0, 0(t4)
		li t0, PURPLE32
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t4, t4, 4
		sw t0, 0(t4)
		li t0, WHITE32
		addi t4, t4, 4
		sw t0, 0(t4)
	addi t3, r0, 9
	THandle:
			addi t4, t4, -1292
			sw t0, 0(t4)
		li t0, PURPLE32
		addi t5, r0, 3
		THandlePurple:
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t5, t5, -1
		bnez t5, THandlePurple
		nop
		li t0, WHITE32
		addi t4, t4, 4
		sw t0, 0(t4)
		bnez t3, THandle
		addi t3, t3, -1
	addi t4, t4, -1296 
	addi t5, r0, 3
	THandleWhite:
		addi t4, t4, 4
		sw t0, 0(t4)
		addi t5, t5, -1
		bnez t5, THandleWhite
		nop
}