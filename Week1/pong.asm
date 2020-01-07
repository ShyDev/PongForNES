  .include "nesdefs.asm"
  
  ;; iNes header
  
  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring

;;;;;;;;;;;;;;;

;;;;;; VARIABLES
  .rsset $0000

paddle1PosLo .rs 1
paddle1PosHi .rs 1
;;;;

;;;;; START OF CODE
  .bank 0
  .org $8000
Reset:	
	NES_INIT	; set up stack pointer, turn off PPU
  jsr WaitSync	; wait for VSYNC
  jsr ClearRAM	; clear RAM
  jsr WaitSync	; wait for VSYNC (and PPU warmup)

	lda #$3f	; $3F -> A register
  ldy #$00	; $00 -> Y register
  sta PPU_ADDR	; write #HIGH byte first
  sty PPU_ADDR    ; $3F00 -> PPU address

  lda #CTRL_NMI
  sta PPU_CTRL	; enable NMI
  lda #MASK_COLOR
  sta PPU_MASK	; enable rendering

LoadPalettes:
  lda PPU_STATUS             ; read PPU status to reset the #HIGH/#LOW latch
  lda #$3F
  sta PPU_ADDR             ; write the #HIGH byte of $3F00 address
  lda #$00
  sta PPU_ADDR             ; write the #LOW byte of $3F00 address
  ldx #$00              ; start out at 0
LoadPalettesLoop:
  lda Palette, x        ; load data from address (palette + the value in x)
                          ; 1st time through loop it will load palette+0
                          ; 2nd time through loop it will load palette+1
                          ; 3rd time through loop it will load palette+2
                          ; etc
  sta PPU_DATA             ; write to PPU
  inx                   ; X = X + 1
  cpx #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  bne LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down

  .include "transforms.asm"
  .include "graphics.asm"

  lda #$00
  sta OAM_ADDR       ; set the #LOW byte (00) of the RAM address
  lda #$02
  sta OAM_DMA       ; set the #HIGH byte (02) of the RAM address, start the transfer

  LoadSprites MiddlePadle, #$00, #$10

  ;initilize variables
  lda #$80
  sta paddle1PosHi
  lda #$00
  sta paddle1PosLo

  lda #%10000000   ; enable NMI
  sta PPU_CTRL
  lda #%00010000   ; enable sprites
  sta PPU_MASK

.endless
	jmp .endless	; endless loop
;;

  .include "nesppu.asm"

;;v-blank
NMIHandler:
  SAVE_REGS

  lda #$00
  sta OAM_ADDR       ; set the #LOW byte (00) of the RAM address
  lda #$02
  sta OAM_DMA       ; set the #HIGH byte (02) of the RAM address, start the transfer

   ;;This is the PPU clean up section, so rendering the next frame starts properly.
  lda #%10000000   ; enable NMI
  sta PPU_CTRL
  lda #%00010000   ; enable sprites
  sta PPU_MASK
  lda #$00        ;;tell the ppu there is no background scrolling
  sta $2005
  sta $2005

  UpdatePos paddle1PosHi, #$0C, #$00

  RESTORE_REGS

  RTI
;;

  .bank 1
  .org $A000
Palette:
  .db $0f,$00,$28,$30,$0f,$01,$21,$31,$0f,$06,$16,$26,$0f,$09,$19,$29 ;;background
  .db $0f,$00,$28,$30,$0f,$01,$21,$31,$0f,$06,$16,$26,$0f,$09,$19,$29 ;;sprites

MiddlePadle:
  .db 0, $03, $00, $00 
  .db 8, $04, $00, $00
  .db 16, $04, $00, $00
  .db 24, $02, $00, $00

  NES_VECTORS
  .bank 2
  .org $0000

  .incbin "pong.chr"