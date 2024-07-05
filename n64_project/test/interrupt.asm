// VI interrupt replacement for WaitScanline by peter lemon
// heavily based on code by peter lemon 
// these are all peter lemon's predefined constants from his N64_INTERRUPT.INC file
    
li a0, 2	// wait for 2 VI interrupts- this can be removed later, depends on the speed I want you to be able to draw
lui t0,VI_BASE // A0 = Video Interface (VI) Base Register ($A4400000)
li t1, $1E0 // if not initialized, VI_V_INTR's default value is 0x3FF (haven't played with these values much yet)
sw t1, VI_V_INTR(t0) // init VI_V_INTR to $1E0
WaitFor2Inter: 
    lui t0, MI_BASE // t0 = MIPS Interface (MI) Base Register ($A4300000)
  	WaitFor1Inter:
        // wait for the interrupt
        lw t1, MI_INTR(t0) // t1 = MI: Interrupt Register ($A4300008) // load the value of the interrupt register into t1
    	andi t1, t1, $08       // logical operator with VI bitmask
   	 	beqz t1, WaitFor1Inter    // if we haven't receievd the interrupt, wait for it
    	nop  

    // deal with the interrupt
 	lui t0,VI_BASE // A0 = Video Interface (VI) Base Register ($A4400000)
  	sw r0 ,VI_V_CURRENT_LINE(t0) // Clear VI Interrupt by writing 0 to VI_V_CURRENT_LINE
	subi a0, a0, 1
	bnez a0,WaitFor2Inter
	nop