//--------------------------------------------------------------
// Fraser Mips's font code slightly modified
// - macros call functions written in PIXEL8_UTIL.S
//--------------------------------------------------------------

macro pixel8_init16(destination, forecolor, backcolor) { // init the font in memory, does the "expansion"
	// passes arguments to and calls pixel8_init16 function, no isses having a function with the same name as a macro
	li a0, {destination}
	ori a1, r0, {forecolor}
	jal pixel8_init16	
	ori a2, r0, {backcolor}		
}

macro pixel8_static16(font_name, framebuffer, top, left, string_label, length) { // writes a string to the screen using expanded font
	// passes arguments to and calls pixel8_static16 function
	la a0, {font_name}
	la a1, {framebuffer}
	li a2, 320 * 2 * {top}
	li v0, 2 * {left}
	la a3, {string_label}
	jal pixel8_static16
	ori v1, r0, {length} // 64 KB Max Length
}