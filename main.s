FNAME "msx-samurai.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-BFFFh (ASCII 16k Mapper)

DEBUG:          equ 255             ; defines debug mode, value is irrelevant (comment it out for production version)

; Compilation address
    org 0x4000, 0x7fff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"
    INCLUDE "Include/V9990.s"

Execute:
    IFDEF DEBUG
        ld      hl, PROGRAM_START
        call    PrintString
    ENDIF


    call    EnableRomPage2


    IFDEF DEBUG
        ld      hl, SET_MODE_P1
        call    PrintString
    ENDIF
    call    V9.Mode_P1


    IFDEF DEBUG
        ld      hl, DISABLE_SCREEN
        call    PrintString
    ENDIF
    call    V9.DisableScreen



    ; ; WARNING: NOT FINISHED
    ; ld      hl, 0   ; X scroll value (11 bits)
    ; ld      de, 0   ; Y scroll value (13 bits)
    ; call    V9.SetScroll_Layer_A

    ; ; WARNING: NOT FINISHED
    ; ld      hl, 0   ; X scroll value (9 bits)
    ; ld      de, 0   ; Y scroll value (9 bits)
    ; call    V9.SetScroll_Layer_B



    IFDEF DEBUG
        ld      hl, CLEAR_VRAM
        call    PrintString
    ENDIF
    call    V9.ClearVRAM



    IFDEF DEBUG
        ld      hl, SET_PALETTE_CONTROL_REGISTER
        call    PrintString
    ENDIF
    ; ------- set palettes
    ld      a, 1    ; palette number for layer A (0-3)
    ld      b, 0    ; palette number for layer B (0-3)
    call    V9.SetPaletteControlRegister



    IFDEF DEBUG
        ld      hl, SET_NAMTBL_LAYER_B
        call    PrintString
    ENDIF
    ; ------- set names table layer B
    ld		hl, NAM_TBL_seq 				        ; RAM address (source)
    ld		a, V9.P1_NAMTBL_LAYER_B >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_NAMTBL_LAYER_B AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, NAM_TBL_seq.size    		        ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory



    ;call    Load_BG_Earthquake
    call    Load_BG_Haohmaru


    
    ; ; set R#25 SPRITE GENERATOR BASE ADDRESS (READ/WRITE)
    ; ; Sprite pattern: Selected from among 256 patterns
    ; ; The pattern data is shared with the pattern layer (the base address should be set in register R#25.)
    ; ; SGBA17-15: bits 3-1
    ; ld      a, 25           ; register number
    ; ;ld     b, 0000 sss0 b  ; value
    ; ld      b, 0000 0000 b  ; value
    ; call    V9.SetRegister

    IFDEF DEBUG
        ld      hl, SET_SPR_GEN_BASE_ADDR_REGISTER
        call    PrintString
    ENDIF
    ld      a, 0
    call    V9.SetSpriteGeneratorBaseAddrRegister



    IFDEF DEBUG
        ld      hl, LOADING_SPR_EARTHQUAKE
        call    PrintString
    ENDIF



    ; ------- load sprite patterns

	; switch MegaROM page
    ld	    a, EARTHQUAKE_SPR_MEGAROM_PAGE
	ld	    (Seg_P8000_SW), a

    ld		hl, Earthquake_1			            ; RAM address (source)
    ld		a, V9.P1_PATTBL_LAYER_A >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_PATTBL_LAYER_A AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Earthquake_1.size	                ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

; 128 bytes per line x 256 lines
EARTHQUAKE_2_VRAM_ADDR: equ (V9.P1_PATTBL_LAYER_A + (128*256))

	; switch MegaROM page
    ld	    a, EARTHQUAKE_SPR_MEGAROM_PAGE + 1
	ld	    (Seg_P8000_SW), a

    ld		hl, Earthquake_2			            ; RAM address (source)
    ld		a, EARTHQUAKE_2_VRAM_ADDR >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, EARTHQUAKE_2_VRAM_ADDR AND 0xffff   ; VRAM address bits 15-0 (destiny)
    ld		bc, Earthquake_2.size	                ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

; 128 bytes per line x 256 lines
EARTHQUAKE_3_VRAM_ADDR: equ (V9.P1_PATTBL_LAYER_A + ((128*256)*2))

	; switch MegaROM page
    ld	    a, EARTHQUAKE_SPR_MEGAROM_PAGE + 2
	ld	    (Seg_P8000_SW), a

    ld		hl, Earthquake_3			            ; RAM address (source)
    ld		a, EARTHQUAKE_3_VRAM_ADDR >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, EARTHQUAKE_3_VRAM_ADDR AND 0xffff   ; VRAM address bits 15-0 (destiny)
    ld		bc, Earthquake_3.size	                ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

; 128 bytes per line x 256 lines
EARTHQUAKE_4_VRAM_ADDR: equ (V9.P1_PATTBL_LAYER_A + ((128*256)*3))

	; switch MegaROM page
    ld	    a, EARTHQUAKE_SPR_MEGAROM_PAGE + 3
	ld	    (Seg_P8000_SW), a

    ld		hl, Earthquake_4			            ; RAM address (source)
    ld		a, EARTHQUAKE_4_VRAM_ADDR >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, EARTHQUAKE_4_VRAM_ADDR AND 0xffff   ; VRAM address bits 15-0 (destiny)
    ld		bc, Earthquake_4.size	                ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory



    ; load SPRATR table
    ld		hl, SPRATR_Earthquake_1				    ; RAM address (source)
    ld		a, V9.P1_SPRATR >> 16	                ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_SPRATR AND 0xffff             ; VRAM address bits 15-0 (destiny)
    ld		bc, SPRATR_Earthquake_1.size		    ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory



    ; set palette for sprites
    ld      a, 1
    ld      hl, Earthquake_1_palette
    call    V9.LoadPalette

; ------------------------------------------

    call    Load_Haohmaru_Sprites
    ;call    Load_Nakoruru_Sprites

; ------------------------------------------------------

    IFDEF DEBUG
        ;ld      hl, ENABLE_LAYER_B
        ld      hl, ENABLE_SCREEN
        call    PrintString
    ENDIF
    call    V9.EnableScreen
    ;call    V9.Enable_Layer_B


    ; --------
    ;jp      $   ; eternal loop
MainLoop:
    call    Wait_Vblank



    ld      a, (BIOS_JIFFY)
    and     0000 0111 b     ; animation at each 8 frames
    or      a
    jp      nz, .skipAnimation

    ld      a, (BIOS_JIFFY)
    and     0001 1000 b
    srl     a   ; shift right register
    srl     a
    srl     a
    call    V9.SetSpriteGeneratorBaseAddrRegister
.skipAnimation:


    ld      hl, (Counter)
    inc     hl
    ld      (Counter), hl


    ld      de, 300
    call    BIOS_DCOMPR         ; Compare Contents Of HL & DE, Set Z-Flag IF (HL == DE), Set CY-Flag IF (HL < DE)
    call    z, Load_Nakoruru_Sprites

    ld      de, 600
    call    BIOS_DCOMPR         ; Compare Contents Of HL & DE, Set Z-Flag IF (HL == DE), Set CY-Flag IF (HL < DE)
    call    z, Load_BG_Earthquake

    ld      de, 900
    call    BIOS_DCOMPR         ; Compare Contents Of HL & DE, Set Z-Flag IF (HL == DE), Set CY-Flag IF (HL < DE)
    call    z, Load_Haohmaru_Sprites

    ld      de, 1200
    call    BIOS_DCOMPR         ; Compare Contents Of HL & DE, Set Z-Flag IF (HL == DE), Set CY-Flag IF (HL < DE)
    call    z, .Load_BG_Haohmaru_ResetCounter


    jp      MainLoop

.Load_BG_Haohmaru_ResetCounter:
    ld      hl, 0
    ld      (Counter), hl

    call    Load_BG_Haohmaru

    ret
; -------------------------------------------------------------

Load_BG_Earthquake:
    IFDEF DEBUG
        ld      hl, LOADING_BG_EARTHQUAKE
        call    PrintString
    ENDIF



    ; ------- set palette for layer B
	; switch MegaROM page
    ld	    a, EARTHQUAKE_BG_MEGAROM_PAGE
	ld	    (Seg_P8000_SW), a

    ld      a, 0
    ld      hl, Earthquake_BG_palette
    call    V9.LoadPalette



    ; ------- set tile patterns layer B

    ld		hl, Earthquake_bg_0			            ; RAM address (source)
    ld		a, V9.P1_PATTBL_LAYER_B >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_PATTBL_LAYER_B AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Earthquake_bg_0.size	                ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

	; switch MegaROM page
    ld	    a, EARTHQUAKE_BG_MEGAROM_PAGE + 1
	ld	    (Seg_P8000_SW), a

    ld		hl, Earthquake_bg_1			            ; RAM address (source)
    ld		a, 0 + (V9.P1_PATTBL_LAYER_B + Haohmaru_bg_0.size) >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, 0 + (V9.P1_PATTBL_LAYER_B + Haohmaru_bg_0.size) AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Earthquake_bg_1.size	                ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

    ret

Load_BG_Haohmaru:
    IFDEF DEBUG
        ld      hl, LOADING_BG_HAOHMARU
        call    PrintString
    ENDIF



    ; ------- set palette for layer B
	; switch MegaROM page
    ld	    a, HAOHMARU_BG_MEGAROM_PAGE
	ld	    (Seg_P8000_SW), a

    ld      a, 0
    ld      hl, Haohmaru_bg_palette
    call    V9.LoadPalette



    ; ------- set tile patterns layer B

    ld		hl, Haohmaru_bg_0			            ; RAM address (source)
    ld		a, V9.P1_PATTBL_LAYER_B >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_PATTBL_LAYER_B AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Haohmaru_bg_0.size	                ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

	; switch MegaROM page
    ld	    a, HAOHMARU_BG_MEGAROM_PAGE + 1
	ld	    (Seg_P8000_SW), a

    ld		hl, Haohmaru_bg_1			            ; RAM address (source)
    ld		a, 0 + (V9.P1_PATTBL_LAYER_B + Haohmaru_bg_0.size) >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, 0 + (V9.P1_PATTBL_LAYER_B + Haohmaru_bg_0.size) AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Haohmaru_bg_1.size	                ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

    ret

; -------------------------------------------------------------

Load_Haohmaru_Sprites:

    IFDEF DEBUG
        ld      hl, LOADING_SPR_HAOHMARU
        call    PrintString
    ENDIF


; 128 bytes per line x 128 lines
HAOHMARU_1_VRAM_ADDR: equ (V9.P1_PATTBL_LAYER_A + ((128*128)*1))

	; switch MegaROM page
    ld	    a, HAOHMARU_SPR_MEGAROM_PAGE
	ld	    (Seg_P8000_SW), a

    ld		hl, Haohmaru_1			                ; RAM address (source)
    ld		a, HAOHMARU_1_VRAM_ADDR >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, HAOHMARU_1_VRAM_ADDR AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Haohmaru_1.size	                    ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

; 128 bytes per line x 128 lines
HAOHMARU_2_VRAM_ADDR: equ (V9.P1_PATTBL_LAYER_A + ((128*128)*3))

	; switch MegaROM page
    ld	    a, HAOHMARU_SPR_MEGAROM_PAGE + 1
	ld	    (Seg_P8000_SW), a

    ld		hl, Haohmaru_2			                ; RAM address (source)
    ld		a, HAOHMARU_2_VRAM_ADDR >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, HAOHMARU_2_VRAM_ADDR AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Haohmaru_2.size	                    ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

; 128 bytes per line x 128 lines
HAOHMARU_3_VRAM_ADDR: equ (V9.P1_PATTBL_LAYER_A + ((128*128)*5))

	; switch MegaROM page
    ld	    a, HAOHMARU_SPR_MEGAROM_PAGE + 2
	ld	    (Seg_P8000_SW), a

    ld		hl, Haohmaru_3			                ; RAM address (source)
    ld		a, HAOHMARU_3_VRAM_ADDR >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, HAOHMARU_3_VRAM_ADDR AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Haohmaru_3.size	                    ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

; 128 bytes per line x 128 lines
HAOHMARU_4_VRAM_ADDR: equ (V9.P1_PATTBL_LAYER_A + ((128*128)*7))

	; switch MegaROM page
    ld	    a, HAOHMARU_SPR_MEGAROM_PAGE + 3
	ld	    (Seg_P8000_SW), a

    ld		hl, Haohmaru_4			                ; RAM address (source)
    ld		a, HAOHMARU_4_VRAM_ADDR >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, HAOHMARU_4_VRAM_ADDR AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Haohmaru_4.size	                    ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

; ---------------------------

    ; load SPRATR table
HAOHMARU_SPRATR_ADDR:   equ V9.P1_SPRATR + SPRATR_Earthquake_1.size
    ld		hl, SPRATR_Haohmaru_1				    ; RAM address (source)
    ld		a, HAOHMARU_SPRATR_ADDR >> 16           ; VRAM address bits 18-16 (destiny)
    ld		de, HAOHMARU_SPRATR_ADDR AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, SPRATR_Haohmaru_1.size		        ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory



    ; set palette for sprites
    ld      a, 2
    ld      hl, Haohmaru_1_palette
    call    V9.LoadPalette

    ret

; -------------------------------------------------------------

Load_Nakoruru_Sprites:

    IFDEF DEBUG
        ld      hl, LOADING_SPR_NAKORURU
        call    PrintString
    ENDIF

; 128 bytes per line x 128 lines
;HAOHMARU_1_VRAM_ADDR: equ (V9.P1_PATTBL_LAYER_A + ((128*128)*1))

	; switch MegaROM page
    ld	    a, NAKORURU_SPR_MEGAROM_PAGE
	ld	    (Seg_P8000_SW), a

    ld		hl, Nakoruru_1			                ; RAM address (source)
    ld		a, HAOHMARU_1_VRAM_ADDR >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, HAOHMARU_1_VRAM_ADDR AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Nakoruru_1.size	                    ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

; 128 bytes per line x 128 lines
;HAOHMARU_2_VRAM_ADDR: equ (V9.P1_PATTBL_LAYER_A + ((128*128)*3))

	; switch MegaROM page
    ld	    a, NAKORURU_SPR_MEGAROM_PAGE + 1
	ld	    (Seg_P8000_SW), a

    ld		hl, Nakoruru_2			                ; RAM address (source)
    ld		a, HAOHMARU_2_VRAM_ADDR >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, HAOHMARU_2_VRAM_ADDR AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Nakoruru_2.size	                    ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

; 128 bytes per line x 128 lines
; HAOHMARU_3_VRAM_ADDR: equ (V9.P1_PATTBL_LAYER_A + ((128*128)*5))

	; switch MegaROM page
    ld	    a, NAKORURU_SPR_MEGAROM_PAGE + 2
	ld	    (Seg_P8000_SW), a

    ld		hl, Nakoruru_3			                ; RAM address (source)
    ld		a, HAOHMARU_3_VRAM_ADDR >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, HAOHMARU_3_VRAM_ADDR AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Nakoruru_3.size	                    ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

; 128 bytes per line x 128 lines
; HAOHMARU_4_VRAM_ADDR: equ (V9.P1_PATTBL_LAYER_A + ((128*128)*7))

	; switch MegaROM page
    ld	    a, NAKORURU_SPR_MEGAROM_PAGE + 3
	ld	    (Seg_P8000_SW), a

    ld		hl, Nakoruru_4			                ; RAM address (source)
    ld		a, HAOHMARU_4_VRAM_ADDR >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, HAOHMARU_4_VRAM_ADDR AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Nakoruru_4.size	                    ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

; ---------------------------

    ; SPRATR table is the same for Haohmaru and Nakoruru sprites

    ; load SPRATR table
;HAOHMARU_SPRATR_ADDR:   equ V9.P1_SPRATR + SPRATR_Earthquake_1.size
    ld		hl, SPRATR_Haohmaru_1				    ; RAM address (source)
    ld		a, HAOHMARU_SPRATR_ADDR >> 16           ; VRAM address bits 18-16 (destiny)
    ld		de, HAOHMARU_SPRATR_ADDR AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, SPRATR_Haohmaru_1.size		        ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory



    ; set palette for sprites
    ld      a, 2
    ld      hl, Nakoruru_1_palette
    call    V9.LoadPalette

    ret


PrintString:
    ld      a, (hl)
    or      a
    ret     z
    call    BIOS_CHPUT
    inc     hl
    jp      PrintString


; To write a value in VRAM, set the target address to VRAM Write Base Address registers (R#0-R#2) 
; and have the data output at VRAM DATA port (P#0). As the bit 7 (MSB) of R#2 functions as
; AII (Address Increment Inhibit), if it is "1", automatic address increment by writing the data is inhibited.

; To read the data of VRAM, set the target address to VRAM Read Base Address registers (R#3-R#5) and read 
; in the data of VRAM DATA port (P#0). As the bit 7 (MSB) of R#5 functions as AII (Address Increment Inhibit), 
; if it is "1", automatic address increment by reading in the data is inhibited.

; The address can be specified up to 19 bits (512K bytes), with lower 8 bits set to R#0 (or R#3), center 8 
; bits to R#1 (or R#4) and upper 3 bits to R#2 (or R#5).

; Note: Always the full address must be written. Specifying partial addresses will not work correctly.

; ----- Write to VRAM:
; set P#4 to 0000 0000 b
; set P#3 to VRAM lower addr (bits 0-7)
; set P#3 to VRAM center addr (bits 8-15)
; set P#3 to VRAM upper addr (bits 16-18) --> warning: higher bit here is AII (explained above)
; set P#0 to value to be written
; if AII is 0, write next bytes to sequentially P#0


NAM_TBL_seq:
    dw 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,280,281,282,283,284,285,286,287,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,318,319,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 320,321,322,323,324,325,326,327,328,329,330,331,332,333,334,335,336,337,338,339,340,341,342,343,344,345,346,347,348,349,350,351,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 352,353,354,355,356,357,358,359,360,361,362,363,364,365,366,367,368,369,370,371,372,373,374,375,376,377,378,379,380,381,382,383,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,399,400,401,402,403,404,405,406,407,408,409,410,411,412,413,414,415,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 416,417,418,419,420,421,422,423,424,425,426,427,428,429,430,431,432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,447,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 448,449,450,451,452,453,454,455,456,457,458,459,460,461,462,463,464,465,466,467,468,469,470,471,472,473,474,475,476,477,478,479,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 480,481,482,483,484,485,486,487,488,489,490,491,492,493,494,495,496,497,498,499,500,501,502,503,504,505,506,507,508,509,510,511,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 512,513,514,515,516,517,518,519,520,521,522,523,524,525,526,527,528,529,530,531,532,533,534,535,536,537,538,539,540,541,542,543,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 544,545,546,547,548,549,550,551,552,553,554,555,556,557,558,559,560,561,562,563,564,565,566,567,568,569,570,571,572,573,574,575,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 576,577,578,579,580,581,582,583,584,585,586,587,588,589,590,591,592,593,594,595,596,597,598,599,600,601,602,603,604,605,606,607,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,636,637,638,639,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 640,641,642,643,644,645,646,647,648,649,650,651,652,653,654,655,656,657,658,659,660,661,662,663,664,665,666,667,668,669,670,671,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 672,673,674,675,676,677,678,679,680,681,682,683,684,685,686,687,688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,703,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 704,705,706,707,708,709,710,711,712,713,714,715,716,717,718,719,720,721,722,723,724,725,726,727,728,729,730,731,732,733,734,735,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 736,737,738,739,740,741,742,743,744,745,746,747,748,749,750,751,752,753,754,755,756,757,758,759,760,761,762,763,764,765,766,767,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 768,769,770,771,772,773,774,775,776,777,778,779,780,781,782,783,784,785,786,787,788,789,790,791,792,793,794,795,796,797,798,799,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 800,801,802,803,804,805,806,807,808,809,810,811,812,813,814,815,816,817,818,819,820,821,822,823,824,825,826,827,828,829,830,831,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 832,833,834,835,836,837,838,839,840,841,842,843,844,845,846,847,848,849,850,851,852,853,854,855,856,857,858,859,860,861,862,863,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.size:  equ $ - NAM_TBL_seq

; ------------------------- SPRATR

    INCLUDE "Graphics/Characters/Earthquake/Earthquake_SPRATR.s"
    INCLUDE "Graphics/Characters/Haohmaru/Haohmaru_SPRATR.s"


; ------------------------- Palettes
    INCLUDE "Graphics/Characters/Earthquake/Earthquake_palette.s"
    INCLUDE "Graphics/Characters/Haohmaru/Haohmaru_palette.s"
    INCLUDE "Graphics/Characters/Nakoruru/Nakoruru_palette.s"


; ------------------------- Strings for debug

PROGRAM_START:                  db      "Program start", 13, 10, 0
SET_MODE_P1:                    db      "Set mode P1", 13, 10, 0
DISABLE_SCREEN:                 db      "Disable screen", 13, 10, 0
ENABLE_SCREEN:                  db      "Enable screen", 13, 10, 0
CLEAR_VRAM:                     db      "Clear VRAM", 13, 10, 0
SET_PALETTE_CONTROL_REGISTER:   db      "Set palette control reg", 13, 10, 0
SET_NAMTBL_LAYER_B:             db      "Set NAMTBL layer B", 13, 10, 0
SET_SPR_GEN_BASE_ADDR_REGISTER: db      "Set SPR gen base addr reg", 13, 10, 0
ENABLE_LAYER_B:                 db      "Enable layer B", 13, 10, 0

LOADING_BG_HAOHMARU:
    db      "Loading BG Haohmaru", 13, 10, 0

LOADING_BG_EARTHQUAKE:
    db      "Loading BG Earthquake", 13, 10, 0

LOADING_SPR_HAOHMARU:
    db      "Loading SPR Haohmaru", 13, 10, 0

LOADING_SPR_NAKORURU:
    db      "Loading SPR Nakoruru", 13, 10, 0

LOADING_SPR_EARTHQUAKE:
    db      "Loading SPR Earthquake", 13, 10, 0

; -------------------
    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; ----------------------------------------------------
; MegaROM pages at 0x8000

HAOHMARU_BG_MEGAROM_PAGE: equ 1
EARTHQUAKE_BG_MEGAROM_PAGE: equ 3

EARTHQUAKE_SPR_MEGAROM_PAGE: equ 5
HAOHMARU_SPR_MEGAROM_PAGE: equ 9
NAKORURU_SPR_MEGAROM_PAGE: equ 13

; ------------------------
; Backgrounds

; ------- Page 1
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Background/Haohmaru_0.s"

	ds PageSize - ($ - 0x8000), 255

; ------- Page 2
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Background/Haohmaru_1.s"
	ds PageSize - ($ - 0x8000), 255

; ------- Page 3
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Background/Earthquake_0.s"
	ds PageSize - ($ - 0x8000), 255

; ------- Page 4
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Background/Earthquake_1.s"
	ds PageSize - ($ - 0x8000), 255

; ------------------------
; Sprites

; Earthquake

; ------- Page 5
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Characters/Earthquake/Earthquake_1.s"
	ds PageSize - ($ - 0x8000), 255

; ------- Page 6
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Characters/Earthquake/Earthquake_2.s"
	ds PageSize - ($ - 0x8000), 255

; ------- Page 7
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Characters/Earthquake/Earthquake_3.s"
	ds PageSize - ($ - 0x8000), 255

; ------- Page 8
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Characters/Earthquake/Earthquake_4.s"
	ds PageSize - ($ - 0x8000), 255

; Haohmaru

; ------- Page 9
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Characters/Haohmaru/Haohmaru_1.s"
	ds PageSize - ($ - 0x8000), 255

; ------- Page 10
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Characters/Haohmaru/Haohmaru_2.s"
	ds PageSize - ($ - 0x8000), 255

; ------- Page 11
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Characters/Haohmaru/Haohmaru_3.s"
	ds PageSize - ($ - 0x8000), 255

; ------- Page 12
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Characters/Haohmaru/Haohmaru_4.s"
	ds PageSize - ($ - 0x8000), 255

; Nakoruru

; ------- Page 13
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Characters/Nakoruru/Nakoruru_1.s"
	ds PageSize - ($ - 0x8000), 255

; ------- Page 14
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Characters/Nakoruru/Nakoruru_2.s"
	ds PageSize - ($ - 0x8000), 255

; ------- Page 15
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Characters/Nakoruru/Nakoruru_3.s"
	ds PageSize - ($ - 0x8000), 255

; ------- Page 16
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Characters/Nakoruru/Nakoruru_4.s"
	ds PageSize - ($ - 0x8000), 255

; ----------------------------------------------------
; RAM
	org     0xc000, 0xe5ff


Counter:     rw 1
