; This function divides the 4-byte value in registers BCDE (numerator) by the 2-byte value pointed to by registers HL (denominator)
; The resulting value will be stored in registers DE
; If the effective result of division is greater than 65,535, then this value will be 65,535 (hex FFFF)
; ROM0 0637 to 0663
label0637:
xor  a              ; XOR A with itself, clearing it
ld   a,10           ; Initialse loop counter to hex 10 (dec 16), then store in FF88
ld   (ff00+88),a

; Loop start
label063C:
rl   e              ; Bit-shift BCDE to the left
rl   d
rl   c
rl   b

; This section subtracts the denominator from the upper two bytes of the numerator
ld   a,c
sub  (hl)           ; Subtract lower byte of denominator from C
ld   c,a
inc  hl             ; Increment HL to point to upper byte of denominator
ld   a,b            
sbc  (hl)           ; Subtract upper byte of denominator from B - if C now has a "negative" value, subtract 1 from B
ld   b,a
dec  hl             ; Decrement HL to point to lower byte
jr   nc,label0657   ; If B is still "positive", jump to 0657

; This section adds the denominator to the upper two bytes of the numerator
ld   a,c
add  (hl)           ; Add lower byte of denominator to C
ld   c,a
inc  hl             ; Increment HL to point to upper byte of denominator
ld   a,b
adc  (hl)           ; Subtract upper byte of denominator from B - if adding to C caused an overflow, add 1 to B
ld   b,a
dec  hl             ; Decrement HL to point to lower byte, ready for next iteration
scf                 ; Set carry flag to 1, clear negative/half-carry flags

label0657:
ccf                 ; Invert carry flag
ld   a,(ff00+88)    ; Decrement loop counter
dec  a
ld   (ff00+88),a
jr   nz,label063C   ; If loop counter is not zero, jump to 063C (start of loop)
rl   e              ; Bit-shift DE to the left
rl   d
ret  
