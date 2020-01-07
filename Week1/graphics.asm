;; \1 sprites W/ offsets \2 offset \3 sprites count
LoadSprites .macro
  ldx #$00
LoadSpritesLoop\@:
  lda \1, x
  sta OAM_RAM+\2, x
  inx
  cpx \3
  bne LoadSpritesLoop\@
  .endm