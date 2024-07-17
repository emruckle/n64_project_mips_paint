// early iteration of mips paint
arch n64.cpu
endian msb
output "draw.N64", create
// 1024 KB + 4 KB = 1028 KB
fill $00101000 // Set ROM Size

origin $00000000
base $80000000

include "../LIB/N64.INC"
include "../LIB/N64_GFX.INC"
include "../LIB/COLORS32.INC"
include "N64_Header.asm"
include "../LIB/N64_INPUT.INC"
insert "../LIB/N64_BOOTCODE.BIN"

Start:

N64_INIT()

ScreenNTSC(320, 240, BPP32, $A0100000)

InitializeFrameBuffer:
    // white
 	//lui t0, WHITE32
	//ori t0, WHITE32
	li t0, WHITE32

 	// Buffer Start
	la t1, $A0100000

	// Buffer End
	li t2, (320 * 240) * 4
	add t2, t2, t1

loopFrameBuffer:
 	sw t0, 0x0(t1)
	addi t1,t1,4
	bne t1,t2,loopFrameBuffer
	nop

StartingPos:
    lui t0, HOT_PINK32
	ori t0, HOT_PINK32  
	la t1, $A0100000

    li t2, 73280 * 2
    add t4, t1, t2
    sw t0, 0(t4)

	// x value
	//addi t5, 0, 0
	li t5, 608
	//li t5, 0x0000025C

DrawLine:
        InitController(PIF1) // Initialize Controller
    ReadLoop:
        WaitScanline($1E0)
        ReadController(PIF2) // T0 = Controller Buttons, T1 = Analog X, T2 = Analog Y
		//addi	sp, sp, -4		// allocate stack space for ret addr
		//sw		ra, 0(sp)
		Up:
			andi t3 , t0, JOY_UP
			beqz t3, Down
			nop
			// else update pos
			subi t4, t4, 320 * 4
			move a0, t4
			jal UpFunc
			nop
			move t4, v0

		Down:
			andi t3, t0, JOY_DOWN
			beqz t3,Left
			nop
			// else.. down
			addi t4, t4, 320 * 4
			move a0, t4
			jal DownFunc
			nop
			move t4, v0

		Left:
			andi t3,t0,JOY_LEFT
			beqz t3, Right
 			nop
			// else left
			subi t4, t4, 4
			subi t5, t5, 4
			move a0, t4
			move a1, t5
			jal CheckL
			nop
			move t4, v0
			move t5, v1

		Right:
			andi t3,t0,JOY_RIGHT
			beqz t3, Draw
 			nop
			// else right
			addi t4, t4, 4
			addi t5, t5, 4
			move a0, t4
			move a1, t5
			jal CheckR
			nop
			move t4, v0
			move t5, v1

	Draw:
		lui t0, HOT_PINK32
		ori t0, HOT_PINK32
		sw t0, 0(t4)
		j ReadLoop
		nop

	UpFunc:
		//addi	sp, sp, -4		// allocate stack space for ret addr
		//sw		ra, 0(sp)	
		la t1, $A0100000
		li t2, (320 * 3 + 8) * 4
		add t1, t1, t2
		blt a0, t1, FixUp
		nop
		j UpEnd
		nop
		FixUp:
			addi a0, a0, 320 * 4
		UpEnd:
			move v0, a0
			jr ra
			nop

	DownFunc:
		//addi	sp, sp, -4		// allocate stack space for ret addr
		//sw		ra, 0(sp)	
		la t1, $A0100000
		li t2, (320 * 225 + 8) * 4  + 604 * 2
		add t1, t1, t2
		bgt a0, t1, FixDown
		nop
		j DEnd
		nop
		FixDown:
			subi a0, a0, 320 * 4
		DEnd:
			move v0, a0
			jr ra
			nop

	CheckL:
		//addi	sp, sp, -4		// allocate stack space for ret addr
		//sw		ra, 0(sp)
		bltz a1, FixL
		nop
		j LEnd
		nop
		FixL:
			addi a1, a1, 4
			addi a0, a0, 4
			j LEnd
		LEnd:
			move v0, a0
			move v1, a1
			jr ra
			nop

	CheckR:
		//addi	sp, sp, -4		// allocate stack space for ret addr
		//sw		ra, 0(sp)
		li t1, 604 * 2
		bgt a1, t1, FixR
		nop
		j REnd
		nop
		FixR:
			subi a1, a1, 4
			subi a0, a0, 4
			j REnd
		REnd:
			move v0, a0
			move v1, a1
			jr ra
			nop
		
    align(8) // Align 64-Bit

    PIF1:
    dw $FF010401,0
    dw 0,0
    dw 0,0
    dw 0,0
    dw $FE000000,0
    dw 0,0
    dw 0,0
    dw 0,1

    PIF2:
    fill 64 // Generate 64 Bytes Containing $00

Loop:
	j Loop
	nop