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
             call  initBlib

             call  PSGInit

             ld     a, DSPON       ; get display constant
             call   toglDSP        ; turn display on using bluelib

             ei                    ; enable interrupts

             jp     main_loop      ; jump to main game loop

.ends

.section "Main loop" free
main_loop:
             nop

.ends