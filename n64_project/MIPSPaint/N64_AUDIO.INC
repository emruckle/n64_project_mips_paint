// ----------------------------------------------------------------------------------------------------------
// N64 Include using code by Peter Lemon
// Slightly modified Peter Lemon assembly code
// Macro to initialize audio, start audio sample, and loop through audio
// ----------------------------------------------------------------------------------------------------------
// to do:
// 1. understand this code
// 2. change the bitrate?
// 3. change the sample frequency?
// ----------------------------------------------------------------------------------------------------------

macro Audio() {
    // init general audio registers
    lui s2, AI_BASE // s2 = AI base register ($A4500000)
    ori s3, r0, 1 // s3 = AI control DMA enable bit (1)
    sw s3, AI_CONTROL(s2) // store AI control DMA enable bit To AI control register ($A4500008), enabling DMA

    // init sample based audio registers
    LoopSample:
        la s4, Sample // s4 = sound sample address (sample DRAM Offset)
        la s5, $10000000|(Sample&$3FFFFFF) // s5 = sample aligned cart physical ROM offset ($10000000..$13FFFFFF 64MB)
        ori s3, r0, 15  // s3 = sample bit rate (bitrate-1) 
        sw s3, AI_BITRATE(s2) // store sample bit rate to AI bit rate register ($A4500014)
        li s3, (VI_NTSC_CLOCK/44100)-1 // s3 = sample frequency: (VI_NTSC_CLOCK(48681812) / FREQ(44100)) - 1
        sw s3, AI_DACRATE(s2) // store sample frequency to AI DAC rate register ($A4500010)

    // play sample (decode a-law sound sample using RDP)
    LoopBuffer:
        // DPC = RDP interface regs
        lui s0, DPC_BASE // s0 = reality display processer control interface base register ($A4100000)
        la s1, RDPBuffer // s1 = DPC Command start address
        sw s1, DPC_START(s0) // store DPC command start address to DP start register ($A4100000)
        la s1, RDPBufferEnd // s1 = DPC command end address
        sw s1, DPC_END(s0) // store DPC command end address to DP end register ($A4100004)

        AIBusy:
            lb s3, AI_STATUS(s2) // s3 = AI status register byte ($A450000C)
            andi s3, $40 // AND AI status with AI status DMA busy bit ($40XXXXXX)
            bnez s3, AIBusy // IF TRUE AI DMA is busy
            nop

        lui a3, $A010 // a3 = sample DRAM offset
        sw a3, AI_DRAM_ADDR(s2) // store sample DRAM offset to AI DRAM address register ($A4500000)
        ori s3, r0,$1000-1 // s3 = length of sample buffer in bytes - 1
        sw s3, AI_LEN(s2) // store length of sample buffer to AI length register ($A4500004)

        addiu s5, $0800 // sample ROM offset += $800
        la a3, $10000000|((Sample+Sample.size)&$3FFFFFF) // a3 = sample END aligned cart physical ROM offset ($10000000..$13FFFFFF 64MB)
        bge s5, a3, LoopSample // IF (sample ROM offset >= sample END offset) LoopSample
        nop

        lui a3, PI_BASE // a3 = PI base register ($A4600000)
        sw s4, PI_DRAM_ADDR(a3) // store RAM offset to PI DRAM address register ($A4600000)
        sw s5, PI_CART_ADDR(a3) // store ROM offset to PI cart address register ($A4600004)
        ori s3, r0,$0800-1 // s3 = length of DMA transfer in bytes - 1
        sw s3, PI_WR_LEN(a3) // store DMA length to PI write length register ($A460000C)

        ReadController(PIF2) // read controller, t0 = controller buttons
        andi t3, t0, JOY_START
        beqz t3, LoopBuffer // if they haven't pressed start, contiune playiing sample
        nop
}