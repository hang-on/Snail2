; Snail2 (c) 2014, [hang-on]

; Create 3 x 16 KB slots for ROM and 1 x 8 KB slot for RAM.

.memorymap
defaultslot 2
slotsize $4000
slot 0 $0000
slot 1 $4000
slot 2 $8000
slotsize $2000
slot 3 $C000
.endme

; Map 32 KB of ROM into 2 x 16 KB banks.

.rombankmap
bankstotal 2
banksize $4000
banks 2
.endro

.include "lib\bluelib.inc"
.include "lib\psglib.inc"

.define DSPOFF     %10100000       ; display off
.define DSPON      %11100000       ; display on


.bank 0 slot 0
.org 0
.section "Startup" force
             di                    ; disable interrupts
             im    1               ; interrupt mode 1
             ld    sp, $dff0       ; stack pointer near end of RAM
             jp    start_demo
.ends

.orga $0038
.section "Maskable interrupt handler" force
             ex    af, af'         ; save AF in their shadow register

             in    a, VDPCOM       ; VDP status / satisfy interrupt

             exx                   ; save the rest of the registers

             call  hdlFrame        ; bluelib frame handler
             call  PSGFrame        ; psglib housekeeping
             call  PSGSFXFrame     ; process next SFX frame

             exx                   ; restore the registers
             ex    af, af'         ; also restore AF

             ei                    ; enable interrupts

             reti                  ; return from interrupt
.ends



.orga $0066
.section "Non-Maskable interrupt handler (pause)" force
             retn                  ; disable pause button
.ends

.section "Start demo" free
start_demo:
             ld    hl, VDP_register_setup
             call  initVDP
             
             call  clearRam

             call  PSGInit

             ld     a, DSPON       ; get display constant
             call   toglDSP        ; turn display on using bluelib

             ei                    ; enable interrupts

             jp     main_loop      ; jump to main game loop
             
; 
VDP_register_setup:
    .db %00000110                  ;
                                   ; b4 = line interrupt (disabled)
                                   ; b5 = blank left column (disabled)
                                   ; b6 = dont scroll top two rows (disabled)

    .db %10100000                  ; b0 = zoomed sprites! (disabled)
                                   ; b5 = frame interrupt (enabled)
                                   ; b6 = turn display off
    .db $FF                        ; name table at $3800
    .db $FF                        ; always $ff
    .db $FF                        ; alwaus $ff
    .db $FF                        ; sprite attrib. table at $3F00
    .db $FB                        ; sprite tiles in first 8K of VRAM
    .db %11110001                  ; border color (color 1 in bank 2)
    .db $00                        ; horiz. scroll = 0
    .db $00                        ; vert. scroll = 0
    .db $FF                        ; disable line counter


.ends

.section "Main loop" free
main_loop:
             nop

.ends