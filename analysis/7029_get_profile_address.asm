; This function gets the SRAM address of the selected profile, plus an offset of 01, and loads it into HL
; The addresses are stored in the ROM after the end of the function
; ROM5 7029 to 7034
label7029:
ld   hl,7035        ; Load constant value 7035 into HL
add  a              ; Double A, which currently contains the index of the selected profile
ld   d,00           ; Clear D and load A into E
ld   e,a
add  hl,de          ; As each pointer is two bytes, DE now contains an offset to add to HL
ldi  a,(hl)         ; Load SRAM address into HL
ld   h,(hl)
ld   l,a
ret  

; The opcodes for these instructions correspond to SRAM addresses - they are not actually executed
; ROM5 7035 to 703C
label7035:
add  c              ; 81
cp   h              ; BC       Profile 1: BC81
ld   bc,81BD        ; 01 BD 81 Profile 2: BD01
cp   l              ; BD       Profile 3: BD81
ld   bc,21BE        ; 01 BE 21 Guest:     BE01
