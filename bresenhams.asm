    org $BFF0

    db "NES", $1A
    db $1
    db $1
    db %00000000
    db %00000000
    db 0
    db 0,0,0,0,0,0,0


numerator equ $01
denominator equ $02
player_buttons equ $03

nmihandler:



    ; Read controller input
    read_ctrl_loop

    ; Update Sprites
    lda #$02
    sta $4014

    rti

irqhandler:
    rti


programstart:
    sei
    cld

    ldx #$ff    
    txs         ; Set-up stack
    inx         ; x is now 0
    
    stx $2000       ; Disable/reset graphic options 
    stx $2001       ; Make sure screen is off
    stx $4015       ; Disable sound
    stx $4010       ; Disable DMC (sound samples)
    lda #$40
    sta $4017       ; Disable sound IRQ
    lda #0  
waitvblank:
    bit $2002       ; check PPU Status to see if
    bpl waitvblank      ; vblank has occurred.
    lda #0
clearmemory:            ; Clear all memory info
    sta $0000,x
    sta $0100,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    lda #$FF
    sta $0200,x     ; Load $FF into $0200 to 
    lda #$00        ; hide sprites 
    inx         ; x goes to 1, 2... 255
    cpx #$00        ; Loop ends after 256 times,
    bne clearmemory     ; clearing all memory
    

waitvblank2:
    bit $2002       ; Check PPU Status one more time
    bpl waitvblank2     ; before we start loading in graphics   
    lda $2002
    ldx #$3F
    stx $2006
    ldx #$00
    stx $2006
copypalloop:
    lda initial_palette,x
    sta $2007
    inx
    cpx #$20
    bne copypalloop
    

 
    ; reset stuff

;need qa/b > .5
;-> 2qa/b > 1
;-> 2qa > b
;-> 2q > b/a
;-> q > (b/a)/2



; USER INPUTS NUMBER FOR NUMERATOR (HOW3)
; press up to change that tile (cycle through 0-9)
; press A to confirm
; press B to go back?!?!?


; should we bother with y-intercepts? I guess there's no reason not to?


;draw a graph (background)
;draw a line (sprites)


    lda $2002
    lda #$20
    sta $2006
    lda #$00
    sta $2006

    
    ldy #1
outer_graphloop:
    ldx #0
inner_graphloop:
    lda graph_layout,x
    sta $2007
    inx
    cpx #32
    bne inner_graphloop
    ldx #0
    iny
    cpy #16
    bne outer_graphloop

mid_graphloop:
    lda graph_layout_mid,x
    sta $2007
    inx
    cpx #32
    bne mid_graphloop

    ldy #1
outer_graphloop2:
    ldx #0
inner_graphloop2:
    lda graph_layout,x
    sta $2007
    inx
    cpx #32
    bne inner_graphloop2
    ldx #0
    iny
    cpy #16
    bne outer_graphloop2



    lda $2002
    lda #$20
    sta $2006
    lda #$22
    sta $2006
    
    ldx #0
    ldy #0
query_user_tiles:
    lda slope_input,x
    sta $2007
    inx
    cpx #7
    bne query_user_tiles

    lda $2002
    lda #$20
    sta $2006
    lda #$42
    sta $2006
query_user_tiles2:
    lda slope_input,x
    sta $2007
    inx
    cpx #14
    bne query_user_tiles2
    
    lda $2002
    lda #$20
    sta $2006
    lda #$62
    sta $2006
query_user_tiles3:
    lda slope_input,x
    sta $2007
    inx
    cpx #21
    bne query_user_tiles3



    ;Input slope of line
    ; 1/1
    ;PUT SOMEWHERE? FIND COORDS TO $2006


    lda #0
    sta $2005
    sta $2005

sprite_pls:
    lda #0
    sta $0201  
    lda #$07
    sta $0200
    lda #$02
    sta $0202
    lda #$40
    sta $0203


    lda #%00011110
    sta $2001
    lda #$88
    sta $2000
    


forever:
    jmp forever



read_controller:
    
    ; Left and right change values in fraction
    ; Up and down change which value to modify (numerator/denominator/plot line)

; Controller Input Reading
    lda #1      ; Begin logging controller input
    sta $4016   ; Controller 1
    lda #0      ; Finish logging
    sta $4016   ; Controller 1

    ldx #8
read_ctrl_loop:
    lda #1      ; Begin logging controller input
    sta $4016   ; Controller 1
    lda #0      ; Finish logging
    sta $4016   ; Controller 1

    ldx #8

    pha     ; Put accumulator on stack
    lda $4016   ; Read next bit from controller

    and #%00000011  ; If button is active on 1st controller,
    cmp #%00000001  ; this will set the carry
    pla     ; Retrieve current button list from stack

    ror     ; Rotate carry onto bit 7, push other
            ; bits one to the right

    dex     
    bne read_ctrl_loop
    
    sta player_buttons   

check_right:
    lda player_buttons   ; Load buttons
    and #%10000000      ; Bit 7 is "right"
    beq checkleft       ; Skip move if zero/not pressed
    increase_num:
        ; Number goes higher
        lda #1
        jsr change_num
check_left:
    lda player_buttons
    and #%01000000      ; Bit 6 is "left"
    beq check_down       ; Skip move if zero/not pressed
    decrease_num:       ; (Sim. to code above but for moving left)
        ; Number goes lower
        lda #255
        jsr change_num
check_down:
    ; Move from numerator to denominator
    ; (or vice versa)

check_up:
    ; Move from denominator to numerator
    ; (or vice versa)


    rts 

change_num:
    ; do something here
    rts


initial_palette:
    db $2A,$27,$0F,$1A  ; Background palettes
    db $2A,$23,$33,$1A
    db $2A,$22,$33,$1A
    db $2A,$27,$31,$1A
    db $0F,$0F,$27,$16  ;  palette
    db $0F,$27,$16,$11  ;  palette
    db $0F,$07,$27,$25  ;  palette
    db $0F,$2d,$16,$2d  ;  palette



; This graph layout assumes $00 is blank, $01 is vertical line tile, $02 is horizontal line tile

graph_layout:
    db $00, $00, $00, $00, $00, $00, $00, $00   ; These 4 lines are the width of the screen
    db $00, $00, $00, $00, $00, $00, $00, $01
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00

    ; do the above 14 times to hit the middle of the screen?

graph_layout_mid:

    db $02, $02, $02, $02, $02, $02, $02, $02
    db $02, $02, $02, $02, $02, $02, $02, $02
    db $02, $02, $02, $02, $02, $02, $02, $02
    db $02, $02, $02, $02, $02, $02, $02, $02


slope_input:
    db $0B, $10, $12, $17, $16, $00, $1E   ; 13 is q!!!!!!
    db $00, $00, $00, $00, $00, $00, $02
    db $15, $0E, $11, $12, $07, $00, $1F




        ;_ (NUMBAH)
        ;_ (NUMBAH)

        ;START


    org $FFFA

    dw nmihandler
    dw programstart
    dw irqhandler

chr_rom_start:
    
background_tile_start:


    ; (Numbers in brackets denote tile #s)

    ; BG#0: Blank Tile
    db %00000000
    db %00000000
    db %00000000
    db %00000000
    db %00000000
    db %00000000
    db %00000000
    db %00000000
    db $00, $00, $00, $00, $00, $00, $00, $00 ; BP2


    ; BG#1: Y Intercept Tile
    db %00011000
    db %00011000
    db %00011000
    db %00011000
    db %00011000
    db %00011000
    db %00011000
    db %00011000
    db $00, $00, $00, $00, $00, $00, $00, $00 ; BP2


    ; BG#2: X Intercept Tile
    db %00000000
    db %00000000
    db %00000000
    db %11111111
    db %11111111
    db %00000000
    db %00000000
    db %00000000
    db $00, $00, $00, $00, $00, $00, $00, $00 ; BP2

    ; BG#3: "A"
    db %00000000    
    db %00011000    ; "A"
    db %00100100
    db %01000010
    db %01000010
    db %01111110
    db %01000010
    db %01000010
    db $00, $00, $00, $00, $00, $00, $00, $00   ; bitplane 2

    db %00000000
    db %11111000    ; "B"
    db %10000100
    db %10000100
    db %11111000
    db %10001000
    db %10000100
    db %11111100
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %00111100    ; "C"
    db %01000010
    db %10000000
    db %10000000
    db %10000000
    db %10000010
    db %01111100

    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %11100000    ; "D"
    db %10010000
    db %10001100
    db %10000110
    db %10000110
    db %10011000
    db %11100000

    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000    ; "E"
    db %11111110
    db %10000000
    db %10000000
    db %11111100
    db %10000000
    db %10000000
    db %11111110
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000    ; "F"
    db %11111110
    db %10000000
    db %10000000
    db %11111100
    db %10000000
    db %10000000
    db %10000000
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %00111000    ; "G"
    db %01000100
    db %10000000
    db %10000000
    db %10011100
    db %10000110
    db %01111100

    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000    ; "H"
    db %10000010
    db %10000010
    db %10000010
    db %11111110
    db %10000010
    db %10000010
    db %10000010
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %11111110    ; "I"
    db %00010000
    db %00010000
    db %00010000
    db %00010000
    db %00010000
    db %11111110
    db $00, $00, $00, $00, $00, $00, $00, $00


    db %00000000
    db %11111110    ; "J"
    db %00010000
    db %00010000
    db %00010000
    db %00010000
    db %10010000
    db %01110000
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %10000010    ; "K"
    db %10000100
    db %10011000
    db %11100000
    db %10100000
    db %10011000
    db %10000100

    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000    ; "L"
    db %10000000
    db %10000000
    db %10000000
    db %10000000
    db %10000000
    db %10000000
    db %11111110
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %10000010    ; "M"
    db %11000110
    db %10101010
    db %10010010
    db %10000010
    db %10000010
    db %10000010
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %10000010    ; "N"
    db %11000010
    db %10100010
    db %10010010
    db %10001010
    db %10000110
    db %10000010

    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %01111100    ; "O"
    db %10000010
    db %10000010
    db %10000010
    db %10000010
    db %10000010
    db %01111100
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %01111100    ; "P"
    db %10000010
    db %10000010
    db %11111100
    db %10000000
    db %10000000
    db %10000000
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %01111000    ; "Q"
    db %10000100
    db %10000010
    db %10000010
    db %10001010
    db %10000100
    db %01111010
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %00111000    ; "R"
    db %11000100
    db %10000100
    db %11111100
    db %10001000
    db %10000100
    db %10000110
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %01111100    ; "S"
    db %11000010
    db %10000000
    db %01110000
    db %00001100
    db %10000110
    db %11111100
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %11111110    ; "T"
    db %00010000
    db %00010000
    db %00010000
    db %00010000
    db %00010000
    db %00010000
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %10000010    ; "U"
    db %10000010
    db %10000010
    db %10000010
    db %10000010
    db %10000010
    db %11111110
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %10000010    ; "V"
    db %10000010
    db %10000010
    db %10000010
    db %01000100
    db %00101000
    db %00010000
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %10000010    ; "W"
    db %10000010
    db %10000010
    db %10000010
    db %10010010
    db %10101010
    db %01000100
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000    ; "X"
    db %10000010    
    db %01000100
    db %00101000
    db %00010000
    db %00101000
    db %01000100
    db %10000010
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000    ; "Y"
    db %10000010    
    db %01000100
    db %00101000
    db %00010000
    db %00010000
    db %00010000
    db %00010000
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %11111110    ; "Z"
    db %00001100    
    db %00011000
    db %00110000
    db %01100000
    db %11000000
    db %11111110
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %00010000    ; "!"
    db %00010000
    db %00010000
    db %00010000
    db %00000000
    db %00010000
    db %00010000
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %00010000    ; "1"
    db %00010000
    db %00010000
    db %00010000
    db %00010000
    db %00010000
    db %00010000
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %01111100    ; "2"
    db %10000010
    db %00000100
    db %00001000
    db %00110000
    db %01000000
    db %11111110
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %01111100    ; "3"
    db %10000010
    db %00000100
    db %00011000
    db %00000100
    db %10000010
    db %01111100
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %00001110    ; "4"
    db %00010010
    db %00100010
    db %01111110
    db %00000010
    db %00000010
    db %00000010
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %11111110    ; "5"
    db %10000000
    db %10000000
    db %11111000
    db %00000100
    db %10000010
    db %01111100
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %00010000    ; "6"
    db %00100000
    db %01000000
    db %01111000
    db %10000100
    db %10000100
    db %01111100
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %11111110    ; "7"
    db %00000100
    db %00001000
    db %00010000
    db %00100000
    db %01000000
    db %10000000
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %00011000    ; "8"
    db %00100100
    db %01000010
    db %00111000
    db %01000100
    db %10000010
    db %01111110
    db $00, $00, $00, $00, $00, $00, $00, $00

    db %00000000
    db %00011000    ; "9"
    db %00100100
    db %01000010
    db %00111110
    db %00000010
    db %00000010
    db %00000010
    db $00, $00, $00, $00, $00, $00, $00, $00



background_tile_end:
    ds 4096-(background_tile_end-background_tile_start)

sprite_tile_start:

    db %11100111
    db %10000001    ; "CURSY (cursor)"
    db %10000001
    db %10000001
    db %10000001
    db %10000001
    db %10000001
    db %11100111
    db $00, $00, $00, $00, $00, $00, $00, $00


sprite_tile_end

    
chr_rom_end:

    ; Pad chr-rom to 8k (to make valid file)
    ds 8192-(chr_rom_end-chr_rom_start)

