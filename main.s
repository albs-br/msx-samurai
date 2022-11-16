FNAME "msx-samurai.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-BFFFh (ASCII 16k Mapper)

; Compilation address
    org 0x4000, 0x7fff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"
    INCLUDE "Include/V9990.s"

Execute:
    call    EnableRomPage2

	; enable MegaROM page 1
    ld	    a, 1
	ld	    (Seg_P8000_SW), a



    call    V9.Mode_P1



    call    V9.DisableScreen



    ; ; WARNING: NOT FINISHED
    ; ld      hl, 0   ; X scroll value (11 bits)
    ; ld      de, 0   ; Y scroll value (13 bits)
    ; call    V9.SetScroll_Layer_A

    ; ; WARNING: NOT FINISHED
    ; ld      hl, 0   ; X scroll value (9 bits)
    ; ld      de, 0   ; Y scroll value (9 bits)
    ; call    V9.SetScroll_Layer_B



    call    V9.ClearVRAM



    ; ------- set palettes
    ld      a, 1    ; palette number for layer A (0-3)
    ld      b, 0    ; palette number for layer B (0-3)
    call    V9.SetPaletteControlRegister

    ; ------- set palette for layer B
    ld      a, 0
    ld      hl, Haohmaru_bg_palette
    call    V9.LoadPalette



    ; ------- set names table layer B
    ld		hl, NAM_TBL_seq 				        ; RAM address (source)
    ld		a, V9.P1_NAMTBL_LAYER_B >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_NAMTBL_LAYER_B AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, NAM_TBL_seq.size    		        ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory



    ; ------- set tile patterns layer B

    ld		hl, Haohmaru_bg_0			            ; RAM address (source)
    ld		a, V9.P1_PATTBL_LAYER_B >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_PATTBL_LAYER_B AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Haohmaru_bg_0.size	                ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

	; enable MegaROM page 2
    ld	    a, 2
	ld	    (Seg_P8000_SW), a

    ld		hl, Haohmaru_bg_1			            ; RAM address (source)
    ld		a, 0 + (V9.P1_PATTBL_LAYER_B + Haohmaru_bg_0.size) >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, 0 + (V9.P1_PATTBL_LAYER_B + Haohmaru_bg_0.size) AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Haohmaru_bg_1.size	                ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory


    
    ; set R#25 SPRITE GENERATOR BASE ADDRESS (READ/WRITE)
    ; Sprite pattern: Selected from among 256 patterns
    ; The pattern data is shared with the pattern layer (the base address should be set in register R#25.)
    ; SGBA17-15: bits 3-1
    ld      a, 25           ; register number
    ;ld     b, 0000 sss0 b  ; value
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister



    ; ------- load sprite patterns

	; enable MegaROM page 3
    ld	    a, 3
	ld	    (Seg_P8000_SW), a

    ld		hl, Earthquake_1			            ; RAM address (source)
    ld		a, V9.P1_PATTBL_LAYER_A >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_PATTBL_LAYER_A AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, Earthquake_1.size	                ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

	; enable MegaROM page 4
    ld	    a, 4
	ld	    (Seg_P8000_SW), a

; 128 bytes per line x 128 lines
EARTHQUAKE_CONT_VRAM_ADDR: equ (V9.P1_PATTBL_LAYER_A + (128*128))

    ld		hl, Earthquake_1_cont		            ; RAM address (source)
    ld		a, EARTHQUAKE_CONT_VRAM_ADDR >> 16	    ; VRAM address bits 18-16 (destiny)
    ld		de, EARTHQUAKE_CONT_VRAM_ADDR AND 0xffff; VRAM address bits 15-0 (destiny)
    ld		bc, Earthquake_1_cont.size	            ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory



    ; load SPRATR table
    ld		hl, SPRATR_Earthquake_1				    ; RAM address (source)
    ld		a, V9.P1_SPRATR >> 16	                ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_SPRATR AND 0xffff             ; VRAM address bits 15-0 (destiny)
    ld		bc, SPRATR_Earthquake_1.size		    ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory



    ; ------- set palette for layer A/sprites
    ld      a, 1
    ld      hl, Earthquake_1_palette
    call    V9.LoadPalette



    ;call    V9.EnableScreen
    call    V9.Enable_Layer_B


    ; --------
    jp      $   ; eternal loop


; -------------------------------------------------------------

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

SPRATR_Earthquake_1:
    ;     +--- Sprite Y-coordinate (Actual display position is one line below specified)
    ;     |        +--- Sprite Pattern Number (Pattern Offset is specified in R#25 SGBA)
    ;     |        |       +--- X (bit 7-0)
    ;     |        |       |        +-------------- Palette offset for sprite colors.
    ;     |        |       |        |  +----------- Sprite is in front of the front layer when P=0, sprite is behind the front layer when P=1.
    ;     |        |       |        |  | +--------- Sprite is disabled when D=1
    ;     |        |       |        |  | |     +--- X (bit 9-8)
    ;     |        |       |        |  | |     |
    ;     Y,     PAT,      X,       nn p d - - X
; line 0
    db   56,       0,    128,       01 0 0 0 0 00 b
    db   56,       1,    128+16,    01 0 0 0 0 00 b
    db   56,       2,    128+32,    01 0 0 0 0 00 b
    db   56,       3,    128+48,    01 0 0 0 0 00 b
    db   56,       4,    128+64,    01 0 0 0 0 00 b
    db   56,       5,    128+80,    01 0 0 0 0 00 b
    db   56,       6,    128+96,    01 0 0 0 0 00 b
    db   56,       7,    128+112,   01 0 0 0 0 00 b

; line 1
    db   56+16,   16,    128,       01 0 0 0 0 00 b
    db   56+16,   17,    128+16,    01 0 0 0 0 00 b
    db   56+16,   18,    128+32,    01 0 0 0 0 00 b
    db   56+16,   19,    128+48,    01 0 0 0 0 00 b
    db   56+16,   20,    128+64,    01 0 0 0 0 00 b
    db   56+16,   21,    128+80,    01 0 0 0 0 00 b
    db   56+16,   22,    128+96,    01 0 0 0 0 00 b
    db   56+16,   23,    128+112,   01 0 0 0 0 00 b

; line 2
    db   56+32,   32,    128,       01 0 0 0 0 00 b
    db   56+32,   33,    128+16,    01 0 0 0 0 00 b
    db   56+32,   34,    128+32,    01 0 0 0 0 00 b
    db   56+32,   35,    128+48,    01 0 0 0 0 00 b
    db   56+32,   36,    128+64,    01 0 0 0 0 00 b
    db   56+32,   37,    128+80,    01 0 0 0 0 00 b
    db   56+32,   38,    128+96,    01 0 0 0 0 00 b
    db   56+32,   39,    128+112,   01 0 0 0 0 00 b

; line 3
    db   56+48,   48,    128,       01 0 0 0 0 00 b
    db   56+48,   49,    128+16,    01 0 0 0 0 00 b
    db   56+48,   50,    128+32,    01 0 0 0 0 00 b
    db   56+48,   51,    128+48,    01 0 0 0 0 00 b
    db   56+48,   52,    128+64,    01 0 0 0 0 00 b
    db   56+48,   53,    128+80,    01 0 0 0 0 00 b
    db   56+48,   54,    128+96,    01 0 0 0 0 00 b
    db   56+48,   55,    128+112,   01 0 0 0 0 00 b

; line 4
    db   56+64,   64,    128,       01 0 0 0 0 00 b
    db   56+64,   65,    128+16,    01 0 0 0 0 00 b
    db   56+64,   66,    128+32,    01 0 0 0 0 00 b
    db   56+64,   67,    128+48,    01 0 0 0 0 00 b
    db   56+64,   68,    128+64,    01 0 0 0 0 00 b
    db   56+64,   69,    128+80,    01 0 0 0 0 00 b
    db   56+64,   70,    128+96,    01 0 0 0 0 00 b
    db   56+64,   71,    128+112,   01 0 0 0 0 00 b

; line 5
    db   56+80,   80,    128,       01 0 0 0 0 00 b
    db   56+80,   81,    128+16,    01 0 0 0 0 00 b
    db   56+80,   82,    128+32,    01 0 0 0 0 00 b
    db   56+80,   83,    128+48,    01 0 0 0 0 00 b
    db   56+80,   84,    128+64,    01 0 0 0 0 00 b
    db   56+80,   85,    128+80,    01 0 0 0 0 00 b
    db   56+80,   86,    128+96,    01 0 0 0 0 00 b
    db   56+80,   87,    128+112,   01 0 0 0 0 00 b

; line 6
    db   56+96,   96,    128,       01 0 0 0 0 00 b
    db   56+96,   97,    128+16,    01 0 0 0 0 00 b
    db   56+96,   98,    128+32,    01 0 0 0 0 00 b
    db   56+96,   99,    128+48,    01 0 0 0 0 00 b
    db   56+96,  100,    128+64,    01 0 0 0 0 00 b
    db   56+96,  101,    128+80,    01 0 0 0 0 00 b
    db   56+96,  102,    128+96,    01 0 0 0 0 00 b
    db   56+96,  103,    128+112,   01 0 0 0 0 00 b

; line 7
    db  56+112,  112,    128,       01 0 0 0 0 00 b
    db  56+112,  113,    128+16,    01 0 0 0 0 00 b
    db  56+112,  114,    128+32,    01 0 0 0 0 00 b
    db  56+112,  115,    128+48,    01 0 0 0 0 00 b
    db  56+112,  116,    128+64,    01 0 0 0 0 00 b
    db  56+112,  117,    128+80,    01 0 0 0 0 00 b
    db  56+112,  118,    128+96,    01 0 0 0 0 00 b
    db  56+112,  119,    128+112,   01 0 0 0 0 00 b

; line 8
    db  56+128,  128,    128,       01 0 0 0 0 00 b
    db  56+128,  129,    128+16,    01 0 0 0 0 00 b
    db  56+128,  130,    128+32,    01 0 0 0 0 00 b
    db  56+128,  131,    128+48,    01 0 0 0 0 00 b
    db  56+128,  132,    128+64,    01 0 0 0 0 00 b
    db  56+128,  133,    128+80,    01 0 0 0 0 00 b
    db  56+128,  134,    128+96,    01 0 0 0 0 00 b
    db  56+128,  135,    128+112,   01 0 0 0 0 00 b

.size:  equ $ - SPRATR_Earthquake_1

; ------------------------- Palettes
    INCLUDE "Graphics/Characters/Earthquake_palette.s"

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; ----------------------------------------------------
; MegaROM pages at 0x8000

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
    INCLUDE "Graphics/Characters/Earthquake_1.s"
	ds PageSize - ($ - 0x8000), 255

; ------- Page 4
	org	0x8000, 0xBFFF
    INCLUDE "Graphics/Characters/Earthquake_1_cont.s"
	ds PageSize - ($ - 0x8000), 255



; ----------------------------------------------------
; RAM
	org     0xc000, 0xe5ff


;VerticalScroll:     rb 1
