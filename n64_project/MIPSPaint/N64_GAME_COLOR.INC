// ----------------------------------------------------------------------------------------------------------
// N64 Include by Emma Ruckle
// Macros for color selection
// ----------------------------------------------------------------------------------------------------------

macro colorSelection(colorAddress) { // checks that JOY_CLEFT button pressed occured within the bounds of the paint palette, t5 = x pos, t9 = current color, colorAddress = base address of color array
	la t0, $A0107D20 // lower bound of the palette
    bgt t4, t0, Render // if you are outside of the color cells, jump to render
	nop
	changeColor({colorAddress})
    nop
	j Render // jump to render
    nop
}

macro changeColor(colorAddress) { // change to the correct color, t5 = x pos, t9 = current color, colorAddress = base address of color array
    addi t0, r0, 20
	blt t5, t0, ChangeColorEnd // if no color was selected (meaning the dividers or sides of the palette were selected), jump to end
	add v0, r0, t9
	addi t0, r0, 156
    addi a2, r0, 8
    la v1, {colorAddress}
    ChangeColorLoop: // find which color was selected
        ble t5, t0, ChangeColorSection
        nop
        addi t0, t0, 8
        blt t5, t0, ChangeColorEnd
        addi v1, v1, 4
        addi t0, t0, 35 * 4
        addi a2, a2, -1
        bnez a2, ChangeColorLoop
        nop
    j ChangeColorEnd
    nop
    ChangeColorSection: // change to selected color
        lw t9, 0(v1)
    ChangeColorEnd:
}