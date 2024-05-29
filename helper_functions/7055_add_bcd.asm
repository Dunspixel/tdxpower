; This function adds the BCD value pointed to by registers HL to the BCD value pointed to by registers DE
; The number of bytes to add is determined by the loop counter in register C
label7055:
xor  a              ; XOR A with itself, clearing it
label7056:
ld   a,(de)         ; Load value pointed by DE into A
adc  (hl)           ; Add value pointed by HL to A, plus carry flag if set
daa                 ; Decimal Adjust Accumulator - this treats the addition as BCD
ld   (de),a         ; Load new value back into address pointed by DE
inc  e              ; Increment pointers
inc  l
dec  c              ; Decrement loop counter
jr   nz,label7056   ; Loop if loop counter is not zero
ret  
