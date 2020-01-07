
;;	processor 6502

;;;;; CONSTANTS

PPU_CTRL	= $2000
PPU_MASK	= $2001
PPU_STATUS	= $2002
OAM_ADDR	= $2003
OAM_DATA	= $2004
PPU_SCROLL	= $2005
PPU_ADDR	= $2006
PPU_DATA	= $2007

PPU_OAM_DMA	= $4014
DMC_FREQ	= $4010
APU_STATUS	= $4015
APU_NOISE_VOL   = $400C
APU_NOISE_FREQ  = $400E
APU_NOISE_TIMER = $400F
APU_DMC_CTRL    = $4010
APU_CHAN_CTRL   = $4015
APU_FRAME       = $4017

JOYPAD1		= $4016
JOYPAD2		= $4017

; NOTE: I've put this outside of the PPU & APU, because it is a feature
; of the APU that is primarily of use to the PPU.
OAM_DMA         = $4014
; OAM local RAM copy goes from $0200-$02FF:
OAM_RAM         = $0200

; PPU_CTRL flags
CTRL_NMI	= %10000000	; Execute Non-Maskable Interrupt on VBlank
CTRL_8x8	= %00000000 	; Use 8x8 Sprites
CTRL_8x16	= %00100000 	; Use 8x16 Sprites
CTRL_BG_0000	= %00000000 	; Background Pattern Table at $0000 in VRAM
CTRL_BG_1000	= %00010000 	; Background Pattern Table at $1000 in VRAM
CTRL_SPR_0000	= %00000000 	; Sprite Pattern Table at $0000 in VRAM
CTRL_SPR_1000	= %00001000 	; Sprite Pattern Table at $1000 in VRAM
CTRL_INC_1	= %00000000 	; Increment PPU Address by 1 (Horizontal rendering)
CTRL_INC_32	= %00000100 	; Increment PPU Address by 32 (Vertical rendering)
CTRL_NT_2000	= %00000000 	; Name Table Address at $2000
CTRL_NT_2400	= %00000001 	; Name Table Address at $2400
CTRL_NT_2800	= %00000010 	; Name Table Address at $2800
CTRL_NT_2C00	= %00000011 	; Name Table Address at $2C00

; PPU_MASK flags
MASK_TINT_RED	= %00100000	; Red Background
MASK_TINT_BLUE	= %01000000	; Blue Background
MASK_TINT_GREEN	= %10000000	; Green Background
MASK_SPR	= %00010000 	; Sprites Visible
MASK_BG		= %00001000 	; Backgrounds Visible
MASK_SPR_CLIP	= %00000100 	; Sprites clipped on left column
MASK_BG_CLIP	= %00000010 	; Background clipped on left column
MASK_COLOR	= %00000000 	; Display in Color
MASK_MONO	= %00000001 	; Display in Monochrome

; read flags
F_BLANK		= %10000000 	; VBlank Active
F_SPRITE0	= %01000000 	; VBlank hit Sprite 0
F_SCAN8		= %00100000 	; More than 8 sprites on current scanline
F_WIGNORE	= %00010000 	; VRAM Writes currently ignored.

KEY_A      = %10000000
KEY_B      = %01000000
KEY_SELECT = %00100000
KEY_START  = %00010000
KEY_UP     = %00001000
KEY_DOWN   = %00000100
KEY_LEFT   = %00000010
KEY_RIGHT  = %00000001

;;;;; NES_INIT SETUP MACRO (place at start)
        
        .macro NES_INIT
        sei			;disable IRQs
        cld			;decimal mode not supported
        ldx #$ff
        txs			;set up stack pointer
        inx			;increment X to 0
        stx PPU_MASK		;disable rendering
        stx DMC_FREQ		;disable DMC interrupts
        stx PPU_CTRL		;disable NMI interrupts
	bit PPU_STATUS		;clear VBL flag
        bit APU_CHAN_CTRL	;ack DMC IRQ bit 7
	lda #$40
	sta APU_FRAME		;disable APU Frame IRQ
	lda #$0F
	sta APU_CHAN_CTRL	;disable DMC, enable/init other channels.        
        .endm

;;;;; NES_VECTORS - CPU vectors at end of address space

	.macro NES_VECTORS
	;seg Vectors		; segment "Vectors"
	.org $fffa		; start at address $fffa
       	.dw NMIHandler	; $fffa vblank nmi
	.dw Reset		; $fffc reset
	.dw 0	; $fffe irq / brk
	.ENDM

;;;;; SAVE_REGS - save A/X/Y registers

        .macro SAVE_REGS
        pha
        txa
        pha
        tya
        pha
        .ENDM

;;;;; RESTORE_REGS - restore Y/X/A registers

        .macro RESTORE_REGS
        pla
        tay
        pla
        tax
        pla
        .ENDM
