// ---------------------------------------------------------------------------------------------------------------------------------
// Double Buffer Test by Emma Ruckle
// - used Fraser Mips's DoubleBuffer640x480 as a reference
// - Swaps between buffers
// - Has not been tested on console
// Notes:
// - to change the buffer being displayed, change the VI_ORIGIN
// - can be implemented with VI interupts, right now I am just using WaitScanline to get the same effect
// ---------------------------------------------------------------------------------------------------------------------------------

arch n64.cpu
endian msb
output "DoubleBuffer.N64", create
// 1024 KB + 4 KB = 1028 KB
fill $00101000 // Set ROM Size

origin $00000000
base $80000000

include "../LIB/N64.INC"
include "../LIB/N64_GFX.INC"
include "../LIB/COLORS32.INC"
include "N64_Header.asm"
insert "../LIB/N64_BOOTCODE.BIN"

constant fb1 = $A0100000
constant fb2 = $A0200000

macro initFramebuffer(color, framebuffer) { // initialize framebuffer
    li t0, {color}
    la t1, {framebuffer}
    la t2, $A014B000
    clearLoop:
 		sw t0, 0x0(t1)
		bne t1, t2, clearLoop
		addi t1, t1, 4
}

macro initFramebuffer2(color, framebuffer) { // initialize framebuffer2
    li t0, {color}
    la t1, {framebuffer}
    la t2, $A024B000
    clearLoop2:
 		sw t0, 0x0(t1)
		bne t1, t2, clearLoop2
		addi t1, t1, 4
}

Start:
	N64_INIT()
	ScreenNTSC(320, 240, BPP32, fb1)
	nop
	nop
	nop
	initFramebuffer(HOT_PINK32, fb1)
	initFramebuffer2(LIME32, fb2)
	nop
	nop
	nop
	lui t4,VI_BASE

SwapBuffer:

	jal WaitLoop
	nop

	li t1, fb2
	sw t1, VI_ORIGIN(t4) // this!! change VI_ORIGIN to base address of buffer you want to display - no copying a whole buffer

	jal WaitLoop
	nop

	li t1, fb1
	sw t1, VI_ORIGIN(t4)

	j SwapBuffer
	nop

WaitLoop:
	addi a1, r0, 6000 // it's very hard to see this working on console, the more WaitScanlines, the slower the swap, the easier to see
	WaitScanline:
		// peter lemon macro --------------------------------------
        WaitScanline($1E0)
		// --------------------------------------------------------
		bnez a1, WaitScanline
		addi a1, a1, -1
	jr ra
	nop