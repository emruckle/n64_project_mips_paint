macro pixel8_init16(destination, forecolor, backcolor) {
    li a0, {destination}
    li a1, {forecolor}
    li a2, {backcolor}
    jal pixel8_init16
    nop // could optimize here with ori a2, r0, {backcolor}
}

macro pixel8_static16(font_name, framebuffer, top, left, string_label, length) {
    la a0, {font_name}
    la a1, {framebuffer}
    lui a2, {top} // 16 bit value
    ori a2, {left} // 16 bit value
    la a3, {string_label}
    jal pixel8_static16
    ori v1, r0, {length} //64 KB max length
}