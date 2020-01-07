;; \1 posYHi \2 posXHi \3 offset
UpdatePos  .macro
  ldx #$03
  ldy #$00
  UpdatePosLoop\@:
    lda \1
    clc
    adc MiddlePadle, y ; add high byte of y position to y offset (first byte of paddle's OAM ROM)
    sta OAM_RAM+\3, y ; store it in OAM RAM with offset
    lda \2 ; x position is constant for paddle
    sta OAM_RAM+\3, x

    inx
    inx
    inx
    inx

    iny
    iny
    iny
    iny

  cpy #$10 ; you can live it as constant or make it fourth argument
  bne UpdatePosLoop\@
  .endm