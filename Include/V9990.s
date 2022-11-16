; --------------- V9990 constants

V9:

; ------ MSX V9990 ports:
; 60h~6Fh*	Graphics9000 / V9990.

; V9900 I/O PORT SPECIFICATIONS
; P#0	VRAM DATA	(R/W)
; P#1	PALETTE DATA	(R/W)
; P#2	COMMAND DATA	(R/W)
; P#3	REGISTER DATA	(R/W)
; P#4	REGISTER SELECT	(W)
; P#5	STATUS	(R)
; P#6	INTERRUPT FLAG	(R/W)
; P#7	SYSTEM CONTROL	(W)
; P#8-B	Kanji ROM
; P#C-F	Reserved

.PORT_0:    equ 0x60
.PORT_1:    equ 0x61
.PORT_2:    equ 0x62
.PORT_3:    equ 0x63
.PORT_4:    equ 0x64
.PORT_5:    equ 0x65
.PORT_6:    equ 0x66
.PORT_7:    equ 0x67
; ... TODO: include more ports



; P1 VRAM mapping
; 00000-3FDFF	(Sprite) Pattern Data (Layer A)
; 3FE00-3FFFF	Sprite Attribute Table
; 40000-7BFFF	Pattern Data (Layer B)
; 7C000-7DFFF	PNT(A) - Pattern Name Table (Layer A)
; 7E000-7FFFF	PNT(B) - Pattern Name Table (Layer B)

; P1 mode:
.P1_PATTBL_LAYER_A:     equ 0x00000     ; 00000-3FDFF	(Sprite) Pattern Data (Layer A)
.P1_PATTBL_LAYER_B:     equ 0X40000     ; 40000-7BFFF	Pattern Data (Layer B)
.P1_SPRATR:             equ 0X3fe00     ; 3FE00-3FFFF	Sprite Attribute Table
.P1_NAMTBL_LAYER_A:     equ 0X7c000     ; 7C000-7DFFF	PNT(A) - Pattern Name Table (Layer A)
.P1_NAMTBL_LAYER_B:     equ 0X7e000     ; 7E000-7FFFF	PNT(B) - Pattern Name Table (Layer B)

; -------------------------------------------------------------

; To set a value in the register, have the register No. output at REGISTER SELECT port (P#4) and then the data at REGISTER DATA port (P#3).

; Set register number A with value in B
.SetRegister:
    di
        out     (V9.PORT_4), a  ; register number
        ld      a, b
    ei
    out     (V9.PORT_3), a  ; value
    ret


; -------------------------------------------------------------

; To obtain the value from the register, have the register No. output at P#4 and then read P#3.

; Read register A, value is returned in A
.ReadRegister:
    di
        out     (V9.PORT_4), a  ; register number
    ei
    in      a, (V9.PORT_3)  ; value
    ret


; -------------------------------------------------------------

; Set V9990 to write at address pointed by ADE (19 bits)
.SetVdp_Write:
    ld      b, a    ; save A register

    ; set P#4 to 0000 0000 b
    xor     a ; ld a, 0000 0000 b
    di
        out     (V9.PORT_4), a

        ld      c, V9.PORT_3

        ; set P#3 to VRAM lower addr (bits 0-7)
        out     (c), e

        ; set P#3 to VRAM center addr (bits 8-15)
        out     (c), d

        ; set P#3 to VRAM upper addr (bits 16-18) --> warning: higher bit here is AII (explained above)
        and     0111 1111 b     ; force AII bit to 0
    ei
    out     (c), b

    ret

; -------------------------------------------------------------


; Write VRAM from RAM
; Inputs:
; 	HL: source addr in RAM
; 	ADE: 19 bits destiny addr in VRAM
; 	BC: number of bytes
.LDIRVM:
    ; TODO: use SetVdp_Write
    ; push    bc
    ;     push    af
    ;         ; set P#4 to 0000 0000 b
    ;         ld      a, 0000 0000 B
    ;         out     (V9.PORT_4), a

    ;         ld      c, V9.PORT_3

    ;         ; set P#3 to VRAM lower addr (bits 0-7)
    ;         out     (c), e

    ;         ; set P#3 to VRAM center addr (bits 8-15)
    ;         out     (c), d
    ;     pop     af

    ;     ; set P#3 to VRAM upper addr (bits 16-18) --> warning: higher bit here is AII (explained above)
    ;     and     0111 1111 b     ; force AII bit to 0
    ;     out     (c), a
    ; pop     de

    push    bc
        call    .SetVdp_Write
    pop     de

    ld      c, V9.PORT_0
.LDIRVM_loop:
    ; set P#0 to value to be written
    outi
    
    dec     de
    ld      a, e
    or      d
    jp      nz, .LDIRVM_loop

    ret


; Set tile pattern in V9990 VRAM
; 	HL: source addr in RAM
; 	ADE: 19 bits destiny addr in VRAM
.SetTilePattern:
    ld      b, 8
.SetTilePattern_loop:
    push    af, bc
        call    V9.SetVdp_Write

        ld      c, (V9.PORT_0)

        outi outi outi outi     ; one line = 8 pixels = 4 bytes

        ex      de, hl
            ld      bc, 0x80    ; tile pattern lines are spaced by 128 bytes (0x80)
            add     hl, bc
        ex      de, hl

    pop     bc, af
    djnz    .SetTilePattern_loop

    ret

; -------------------------------------------------------------

.ClearVRAM:
    xor     a
    ld      de, 0
    call    V9.SetVdp_Write

    ; TODO: use VDP command (faster)
    ld      bc, 0 ; = 65536 (64 kb)
.ClearVRAM_loop:
    xor     a
    ; 64 kb x 8 = 512 kb
    out     (v9.PORT_0), a
    out     (v9.PORT_0), a
    out     (v9.PORT_0), a
    out     (v9.PORT_0), a
    out     (v9.PORT_0), a
    out     (v9.PORT_0), a
    out     (v9.PORT_0), a
    out     (v9.PORT_0), a

    dec     bc
    ld      a, b
    or      c
    jp      nz, .ClearVRAM_loop

    ret

; -------------------------------------------------------------

.Mode_P1:
    ; ------- set P1 mode

    ; set MCS = 0 on P#7
    xor     a
    out     (V9.PORT_7), a

    ; set DSPM = 0 (bits 7-6) of R#6
    ; set DKCM = 0 (bits 5-4) of R#6
    ; set XIMM = 1 (bits 3-2) of R#6
    ; set CLRM = 1 (bits 1-0) of R#6
    ld      a, 6            ; register number
    ld      b, 0000 0101 b  ; value
    call    V9.SetRegister

    ; bit 7 of R#7 is fixed at 0
    ; set C25M = 0 (bit 6) of R#7
    ; set SM1 = 0 (bit 5) of R#7
    ; set SM = 0 (bit 4) of R#7
    ; set PAL = 0 (bit 3) of R#7
    ; set EO = 0 (bit 2) of R#7
    ; set IL = 0 (bit 1) of R#7
    ; set HSCN = 0 (bit 0) of R#7
    ld      a, 7            ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister


    ; set control register (R#8)
    ; set DISP = 1 (bit 7) of R#8
    ld      a, 8            ; register number
    ld      b, 1000 0010 b  ; value
    call    V9.SetRegister


    ; set priority control register (R#27)
    ld      a, 27           ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ret


; ; convert tile number to tile pattern base addr:
;     ld      hl, tile_number

;     push    hl
;         ld      a, l
;         and     1110 0000 b
    
;     pop     hl
;     and     0001 1111 b

; -----------------------------------------------------------


    ; WARNING: NOT FINISHED
; Set scroll control registers for layer B (R#17 to R#20)
; Inputs:
;   HL: X scroll value (11 bits)
;   DE: Y scroll value (13 bits)
.SetScroll_Layer_A:

    ; R#17: scroll Y layer A (bits 7-0)
    ld      a, 17           ; register number
    ld      b, e            ; value
    call    V9.SetRegister

    ; TODO: read R#18 and save bits 7-6 before (R512/R256)

    ; R#18: scroll Y layer A (bits 12-8)
    ld      a, 18           ; register number
    ld      b, d            ; value
    call    V9.SetRegister


    ; TODO: adjust H and L before set registers

    ; R#19: scroll X layer A (bits 2-0)
    ld      a, 19           ; register number
    ld      b, 0 ;l            ; value
    call    V9.SetRegister

    ; R#20: scroll X layer A (bits 10-3)
    ld      a, 20           ; register number
    ld      b, 0 ;h            ; value
    call    V9.SetRegister

    ret

    ; WARNING: NOT FINISHED
; Set scroll control registers for layer B (R#21 to R#24)
; Inputs:
;   HL: X scroll value (9 bits)
;   DE: Y scroll value (9 bits)
.SetScroll_Layer_B:

    ; TODO: implement

    ld      a, 21           ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ld      a, 22           ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ld      a, 23           ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ld      a, 24           ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ret

; -----------------------------------------------------------

; Input:
;   A: palette number for layer A (0-3)
;   B: palette number for layer B (0-3)
.SetPaletteControlRegister:

    sla     b   ; shift left register
    sla     b

    or      b
    ld      b, a

    ; ------- set palette control register (R#13)
    
    ; R#13 is WRITE ONLY

    ; Background colors are specified by Pattern data plus a palette offset in R#13.
    ; P1 layer "A" and P2 pattern pixels 0,1,4,5 use offset specified in R#13 PLTO3-2.
    ; P1 layer "B" and P2 pattern pixels 2,3,6,7 use offset specified in R#13 PLTO5-4.

    ; set PLTM to 00 on R#13 (bits 7-6)
    ; set YAE to 0 on R#13 (bit 5)
    ; set PLTAIH to 0 on R#13 (bit 4)
    ; set PLTO2-5 to 0 on R#13 (bits 0-3), to RESET scroll for both layers
    
    ;                +------- palette number for layer B
    ;                |  +---- palette number for layer A
    ;                |  |
    ;ld      b, 0000 bb aa b  ; value


    ld      a, 13           ; register number
    call    V9.SetRegister

    ret


; -----------------------------------------------------------


; Input:
;   A: palette number (0-3)
;   HL: pointer to palette data (48 bytes)
.LoadPalette:

    ld      c, a
    
    ; set 0000 1110 b to P#4
    ld      a, 0000 1110 b
    out     (V9.PORT_4), a

    ld      a, c

    sla     a   ; shift left register
    sla     a
    sla     a
    sla     a
    sla     a
    sla     a

    ; set palette number (6 higher bits) to P#3; 2 lower bits to 00
    
    ;           +---- palette number (0-3)
    ;           |
    ;ld      a, nn00 0000 b
    out     (V9.PORT_3), a

    ; set RED value (5 bits, 0-31 value) to P#1
    ; set GREEN value (5 bits, 0-31 value) to P#1
    ; set BLUE value (5 bits, 0-31 value) to P#1
    ;ld      hl, Palette_test_0
    ld      c, V9.PORT_1
    ;ld      b, 16 * 3   ; number of colors * 3
    ;otir
    ; 48x OUTI
    outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi 

    ret

; -----------------------------------------------------------

; Inputs:
; 	ADE: 19 bits addr in VRAM
.Fill_NAM_TBL_Sequentially:
    call    .SetVdp_Write

    ld      bc, 64 * 64     ; loop counter (size of names table)
    ld      de, 0           ; value to be written
.Fill_NAM_TBL_Sequentially_loop:

    ; write word value (little endian)
    ld      a, e
    out     (V9.PORT_0), a
    ld      a, d
    out     (V9.PORT_0), a

    inc     de
    
    dec     bc
    ld      a, b
    or      c
    jp      nz, .Fill_NAM_TBL_Sequentially_loop

    ; TODO: faster
    ; dec     c
    ; jp      nz, .Fill_NAM_TBL_Sequentially_loop
    ; djnz    .Fill_NAM_TBL_Sequentially_loop

    ret

; -----------------------------------------------------------

; Inputs:
; 	ADE: 19 bits addr in VRAM
.Fill_NAM_TBL_Sequentially_32_cols:
    call    .SetVdp_Write
    push    de
    pop     hl              ; VRAM addr

    ld      bc, 32 * 64     ; loop counter (size of names table)
    ld      de, 0           ; value to be written
    ld      ixl, 0            ; col number counter
.Fill_NAM_TBL_Sequentially_32_cols_loop:

    ; write word value (little endian)
    ld      a, e
    out     (V9.PORT_0), a
    ld      a, d
    out     (V9.PORT_0), a

    inc     de
    
    inc     ixl
    cp      32          ; number of cols
    call    z, .Fill_NAM_TBL_Sequentially_32_cols_next_line

    dec     bc
    ld      a, b
    or      c
    jp      nz, .Fill_NAM_TBL_Sequentially_32_cols_loop

    ret

.Fill_NAM_TBL_Sequentially_32_cols_next_line:
    ; HL += 64 (32 cols)
    push    bc
        ld      bc, 256
        add     hl, bc
    pop     bc

    ; both names tables of P1 mode have the same addr on bits 18-16
    ld		a, V9.P1_NAMTBL_LAYER_A >> 16	        ; VRAM address bits 18-16 (destiny)
    push    de
        push    hl
        pop     de
        call    .SetVdp_Write
    pop     de
    
    ld      ixl, 0    ; reset col counter

    ret

; -----------------------------------------------------------

.DisableScreen:
    call    .Disable_Layer_A
    call    .Disable_Layer_B
    ret

.EnableScreen:
    call    .Enable_Layer_A
    call    .Enable_Layer_B
    ret

; Disable layer "A" and sprites
.Disable_Layer_A:
    ;           +---- SDA: Set to "1" to disable layer "A" and sprites.
    ;           |+--- SDB: Set to "1" to disable layer "B" and sprites.
    ;           ||
    ;ld      b, ab00 0000 b  ; value
    ld      a, 22           ; register number
    call    V9.ReadRegister

    or      1000 0000 b     ; disable layer A
    ld      b, a

    ld      a, 22           ; register number
    ;ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ret



; Disable layer "B" and sprites
.Disable_Layer_B:
    ld      a, 22           ; register number
    call    V9.ReadRegister

    or      0100 0000 b     ; disable layer B
    ld      b, a

    ld      a, 22           ; register number
    call    V9.SetRegister

    ret



; Enable layer "A" and sprites
.Enable_Layer_A:
    ld      a, 22           ; register number
    call    V9.ReadRegister

    and     0111 1111 b     ; enable layer A
    ld      b, a

    ld      a, 22           ; register number
    call    V9.SetRegister

    ret



; Enable layer "B" and sprites
.Enable_Layer_B:
    ld      a, 22           ; register number
    call    V9.ReadRegister

    and     1011 1111 b     ; enable layer B
    ld      b, a

    ld      a, 22           ; register number
    call    V9.SetRegister

    ret



; -----------------------------------------------------------

; Input:
;   A: value of bits 17-15 of Sprite Generator Base Addr (0-7)
; Warning: only works on P1 mode
.SetSpriteGeneratorBaseAddrRegister:

    sla     a   ; shift left register
    ld      b, a

    ld      a, 25            ; register number
    call    V9.SetRegister

    ret