// ----------------------------------------------------------------------------------------------------------
// N64 Include by Emma Ruckle
// Macros to set up the title screen
// PrintString is by Peter Lemon, slightly modified
// ----------------------------------------------------------------------------------------------------------

macro PrintString(rows, cols, fontfile, string, length) { // passes arugments to printString asm code, and calls printString asm
  la a0, fb2 + (320 * 4 * {rows}) + ({cols} * 4) // starting pos of text
  la a1, {fontfile} // font address
  la a2, {string} // string
  jal printString
  addi t0, r0, {length} // length of string
}

macro titleLine() { // draws pink line on title screen
  li t0, HOT_PINK32
  la t2, fb2 + (320 * 4 * 26)
  addi t4, r0, 320
		TitleRow:
			sw t0, 0(t2)
			addi t4, t4, -1
			bnez t4, TitleRow
			addi t2, t2, 4
}

macro TitleScreen() {
    initFramebuffer(BLACK32, fb2, $A024B000)
    PrintString(17, 120, FontBlack, Title, 9)
    PrintString(30, 20, FontBlack, ToPlay, 7)
    PrintString(50, 20, FontBlack, Inst1, 33)
    PrintString(70, 20, FontBlack, Inst2, 21)
    PrintString(90, 20, FontBlack, Inst3, 22)
    PrintString(110, 20, FontBlack, Inst4, 23)
    PrintString(130, 20, FontBlack, Inst5, 32)
    PrintString(140, 20, FontBlack, Inst5.2, 14)
    PrintString(160, 20, FontBlack, Inst6, 29)
    PrintString(180, 20, FontBlack, Inst7, 20)
    PrintString(200, 118, FontBlack, Press, 4)
    PrintString(200, 168, FontRed, Press2, 4)
    drawTitleBrush(fb2 + (320 * 4 * 26) + (220 * 4))
    titleLine()
}