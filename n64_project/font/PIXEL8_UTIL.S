pixel8_init16:
    // a0 = {destination}
    // a1 = {forecolor}
    // a2 = {backcolor}

    li t0, PIXEL8_START
    addi t3, r0, 94
_pixel8_init16_newChar: 
    ld t1, 0x0(t0) // load 8 bytes into the t1 register, loaded font char
    addi t2, r0, 63
_pixel8_init16_do_pixel:
    bltzl t1, _pixel8_init16_continue
    sh a1, 0(a0)// 16 bit color
    sh a2, 0(a0)
_pixel8_init16_continue:
    sll t1, t1, 1
    addi a0, a0, 2
    bne t2, r0, _pixel8_init16_do_pixel
    addi t2, t2, -1
    
    addi t0, t0, 8
    bne t3, r0, _pixel8_init16_newChar
    addi t3, t3, -1

    jr ra
    nop

pixel8_static16:
    // a0 = {font_name}
    // a1 = {framebuffer}
    // a2 = {top} // 16 bit value
    // a2 = {left} // 16 bit value
    // a3 = {string_label}
    // v1 = {length} //64 KB max length
    beq a0, r0, _pixel8_static16_exit
    nop
    beq a1, r0, _pixel8_static16_exit
    nop
    beq a3, r0, _pixel8_static16_exit
    nop
    blez v1, _pixel8_static16_exit
    nop

_pixel8_static16_next_char:
    lb t0, 0(a3)
    addi t0, t0, -32
    addi t1, r0, 128
    mult t0, t1
    srl t2, a2, 16
    andi a2, a2, 0xFFFF
    mflo t1
    add t1, t1, a0
    andi t3, r0, 640
    mult t2, t3
    sll a2, a2, 1
    add t4, a1, a2
    mflo t3
    add t4, t4, t3
    addi t7, r0, 8
_pixel8_static16_next_char_line:
    ld t5, 0(t1)
    ld t6, 8(t1)
    sd t5, 0(t4)
    sd t6, 8(t4)
    addi t1, t1, 16
    addi t4, t4, 640
    bne t7, r0, _pixel8_static16_next_char_line
    addi t7, t7 -1

_pixel8_static16_exit:
    jr ra
    nop


PIXEL8_START:
insert "PIXEL8.FNT"
PIXEL8_END: