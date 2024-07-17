//--------------------------------------------------------------
// Fraser Mips's font code slightly modified
// - simplified slightly and corrected so the full string prints
//--------------------------------------------------------------

pixel8_init16: // expanding the font into 16 bpp

	constant font_char_cnt = 94
	constant font_char_bits = 63
	variable font_addr = a0	
	constant forecolor = a1
	constant backcolor = a2
		
	beq font_addr, r0, _pixel8_init16_exit
	nop
	li t0, PIXEL8_FNT_START	// t0 = start of original font
	addi t3, r0, font_char_cnt // t3 = number of chars in font

_newChar:
	ld t1, 0x0(t0) // t1 = current font character
	addi t2, r0, font_char_bits // t2 = single character bit count

_do_pixel:
	bltzl t1, _continue // if bit is a 1, store forecolor at font_addr
	sh forecolor, 0x0(font_addr) // store 16 bit halfword- take the 1 bit and then convert it to 16 bit by storing a 16 bit halfword for every 1 bit in the original font	
	sh backcolor, 0x0(font_addr) // else store backcolor

_continue:
	dsll t1, t1, 1 // slide current font character binary number 1 to the left, getting the next bit
	addi font_addr, font_addr, 2 // increment font address by two, moving to next pixel
	bne t2, r0, _do_pixel // loop until there are no more bits to read in the original font character
	addi t2, t2, -1
	
	addi t0, t0, 8 // move to next char in og font
	bne t3, r0, _newChar // loop until there are no more chars in og font
	addi t3, t3, -1

_pixel8_init16_exit:
	jr ra
	nop

pixel8_static16: // displaying the message

	// variables and constants have different scopes, if they share a name the variable will be used first
	// stuck with fraser's declarations in terms of what is a constant vs a variable
	constant font_addr = a0
	constant fb = a1
	variable top = a2
	variable left = v0
	variable string_length = v1 // 64 KB Max Length
	variable string_label = a3	
	
	// Parameter Validation
	beq font_addr, r0, _exit
	nop
	beq fb, r0, _exit
	nop
	beq string_label, r0, _exit
	nop	
	blez string_length, _exit
	nop

_pixel8_static16_next_char:
	constant first_printable_ascii = 32
	constant bytes_per_char = 128
	variable fb_position = t4
	variable current_char = t0
	variable remaining_bytes_for_char = t1
	
	lb current_char, 0x0(string_label)	// current_char = first char in string
	addi current_char, current_char, -first_printable_ascii // convert current_char from ascii to font index by subtracting 32
	
	// math for total bytes per char
		// 1 pixel = 2 bytes
		// 1 character = 64 pixels
		// 64 * 2 = 128 bytes per character
		// 8x8 = 1 row = 8 pixels aka 16 bytes
	
	addi remaining_bytes_for_char, r0, bytes_per_char // init remaining_bytes_for_char to total bytes per char (128)
	
	// these lines convert remaining_bytes_for_char to the mem location of what needs to be copied to the framebuffer
	mult current_char, remaining_bytes_for_char
	mflo remaining_bytes_for_char // load mult result into remaining_bytes_for_char
	add remaining_bytes_for_char, remaining_bytes_for_char, font_addr // remaining_bytes_for_char = remaining_bytes_for_char + font_addr
	
	add fb_position, fb, left
	add fb_position, fb_position, top // fb_position = fb + left + top
	addi t7, r0, 7 // t7 = 7

_pixel8_static16_next_char_line:
	ld t5, 0x0(remaining_bytes_for_char) // load 64 bit doubleword into t5
	ld t6, 0x8(remaining_bytes_for_char) // load 64 bit doubleword into t6
	sd t5, 0x0(fb_position) // store 64 bit doubleword at fb_position
	sd t6, 0x8(fb_position) // store 64 bit doubleword at 8(fb_position), 8 is offset
	addi remaining_bytes_for_char, remaining_bytes_for_char, 16 // increment remaining_bytes_for_char by 16
	addi fb_position, fb_position, 640 // move fb_position to next row
	bne t7, r0, _pixel8_static16_next_char_line // if t7 != 0, do the next line of the char
	addi t7, t7, -1

	addi string_label, string_label, 1 // increment the char in the string by 1
	addi left, left, 16 // increment left starting pos of letter by 16

 	bnez string_length, _pixel8_static16_next_char // if there are more characters to display, loop
 	addi string_length, string_length, -1
	
_exit:
	jr ra
	nop


PIXEL8_FNT_START: // insert the font file
insert "PIXEL8.FNT"
PIXEL8_FNT_END: