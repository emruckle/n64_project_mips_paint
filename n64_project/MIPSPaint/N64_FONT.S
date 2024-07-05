// ----------------------------------------------------------------------------------------------------------
// N64 ASSEMBLY by Peter Lemon, slightly modified
// Displays Font
// ----------------------------------------------------------------------------------------------------------
printString:
  DrawChars:
    addi t1, r0, 7 // t1 = character x pixel counter
    addi t2, r0, 7 //  t2 = character y pixel counter
    lbu t3, 0(a2) // t3 = next text character
    addi a2, 1 // increment text address

    sll t3, 8 // t3 *= 256 (shift to sorrect position in font)
    add t3, a1 // t3 += font address

    DrawCharX:
      lw t4, 0(t3) // load font Text character pixel
      addi t3, 4
      sw t4, 0(a0) // store font text character pixel into frame buffer
      addi a0, 4

      bnez t1, DrawCharX // if (character x pixel counter != 0) DrawCharX
      addi t1, -1 // decrement character x pixel counter\

      addi a0, (320 * 4) - 8 * 4 // jump down 1 scanline, jump back 1 char
      addi t1, r0, 7 // reset character x pixel counter
      bnez t2, DrawCharX // if (character y pixel counter != 0) DrawCharX
      addi t2, -1 // decrement character y pixel counter

    addi a0, -(((320 * 4) * 8) - 8 * 4) // jump to start of next char
    bnez t0, DrawChars // continue to print characters
    addi t0, -1 // subtract number of text characters to print

    jr ra
    nop