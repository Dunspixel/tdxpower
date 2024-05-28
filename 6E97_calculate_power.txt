; This function calculates power both for the current game and for the selected user profile
; The calculation considers score, soft-drop points, lines, previous power, and number of games played previously.
; ROM5 6E97 to 6FDE
label6E97:
ld   a,(C119)       ; TODO: Analysis of 6E97 to 6EB9
and  a
ret  z
ld   hl,BFF0
ld   de,AC24
ld   a,(AC09)
and  a,0F
add  a
add  a
add  l
ld   l,a
ld   a,(de)
add  (hl)
ld   (hl),a
inc  e
ld   a,(de)
adc  (hl)
ldi  (hl),a
ld   b,00
ld   a,(hl)
adc  b
ldi  (hl),a
ld   a,(hl)
adc  b
ld   (hl),a
ld   hl,AC26        ; Load score (S) pointer into HL
ld   de,AFB2        ; Load soft-drop points (SD) pointer into DE
ld   b,00           ; This section subtracts SD (excluding the lowest nybble) from S, resulting in a value of S - SD + (SD % 16)
ld   a,(de)         ; Load lower byte of SD into A
and  a,F0           ; Discard lower nybble of SD
ld   c,a            ; Load A into C
ld   a,(hl)         ; Load lowest byte of S into A
sub  c              ; Subtract C from A
ldi  (hl),a         ; Replace S in SRAM with A, then increment HL to AC27 (next byte of S)
inc  e              ; Increment E, so DE now contains AFB3 (upper byte of SD)
ld   a,(de)         ; Load upper byte of SD into A
ld   c,a
ld   a,(hl)         ; Load second byte of S into A
sbc  c              ; If subtracting the first byte overflowed A and set the carry flag, subtract 1 when subtracting C from A here
ldi  (hl),a         ; Replace second byte of S in SRAM with A, then increment HL to AC28
inc  e              ; AFB4 is not used here
ld   a,(hl)         ; Load third byte of S into A
sbc  b              ; Since B was initialised to 00 earlier, this just subtracts the carry flag from A if it is set
ldi  (hl),a         ; Replace third byte of S in SRAM with A, then increment HL to AC29
ld   a,(hl)         ; Load highest byte of S into A
sbc  b
ld   (hl),a         ; Replace highest byte of S in SRAM with A
ld   hl,AC24        ; Load lines (L) pointer into HL
ld   a,(AC26)       ; Load all bytes of S into registers BCDE
ld   e,a
ld   a,(AC27)
ld   d,a
ld   a,(AC28)
ld   c,a
ld   a,(AC29)
ld   b,a
call 0637           ; See helper_functions/0637_divide - This divides the score by the number of lines and puts the result in DE
ld   hl,AC25        ; The rest of the analysis is currently in the infodump
ldd  a,(hl)         ; TODO: Tidy up the infodump and put it in here
and  a
jr   nz,label6F25
ld   a,(hl)
and  a
jr   z,label6F22
cp   a,0B
jr   c,label6F18
cp   a,10
jr   c,label6F1C
cp   a,15
jr   nc,label6F25
ld   h,d
ld   l,e
srl  h
rr   l
srl  h
rr   l
ld   a,e
sub  l
ld   e,a
jr   nc,label6F13
dec  d
label6F13:
ld   a,d
sub  h
ld   d,a
jr   label6F25
label6F18:
srl  d
rr   e
label6F1C:
srl  d
rr   e
jr   label6F25
label6F22:
ld   de,0000
label6F25:
ld   a,d
ld   (DB61),a
ld   a,e
ld   (DB60),a
xor  a
ld   (DB68),a
ld   (DB69),a
ld   a,(AC09)
and  a,0F
call label7029
xor  a
ldi  (hl),a
ld   a,(hl)
ld   (DB68),a
cp   a,05
jr   nc,label6F47
inc  a
label6F47:
ldi  (hl),a
push hl
ld   a,l
and  a,80
add  a,58
ld   l,a
add  a,14
ld   d,h
ld   e,a
ld   c,50
label6F55:
ldd  a,(hl)
ld   (de),a
dec  e
dec  c
jr   nz,label6F55
ld   a,(AC0A)
cp   a,02
jr   nz,label6F83
ld   a,(DB61)       ; This section will only run if the current mode is Sprint
ld   d,a            ; TODO: Analyse 6F62-6F80
ld   a,(DB60)
ld   e,a
push de
ld   hl,AC24
ldi  a,(hl)
ld   e,a
ld   d,(hl)
call label7060      ; TODO: Analyse 7060 helper function
ld   a,(DB64)
ld   (AF8D),a
pop  de
ld   a,d
ld   (DB61),a
ld   a,e
ld   (DB60),a
label6F83:
pop  hl
push hl
ld   d,h
ld   e,l
ld   hl,AF8D
ld   c,03
call label7055
pop  hl
inc  l
inc  l
inc  l
inc  l
push hl
ldi  a,(hl)
ld   d,(hl)
ld   e,a
ld   hl,0000
ld   a,(DB68)
and  a
jr   z,label6FA5
label6FA1:
add  hl,de
dec  a
jr   nz,label6FA1
label6FA5:
ld   a,(DB61)
ld   d,a
ld   a,(DB60)
ld   e,a
add  hl,de
ld   bc,0000
ld   d,h
ld   e,l
ld   hl,DB68
inc  (hl)
call 0637
pop  hl             ; TODO: Analyse 6FBA to end of function
ld   (hl),e
inc  l
ld   (hl),d
inc  l
ld   de,AC10
ld   c,14
label6FC4:
ld   a,(de)
ldi  (hl),a
inc  e
dec  c
jr   nz,label6FC4
ld   a,l
and  a,80
add  a,7F
ld   l,a
xor  a
ld   c,7E
label6FD3:
add  (hl)
dec  l
dec  c
jr   nz,label6FD3
ld   b,a
ld   a,CB
ldd  (hl),a
add  b
ld   (hl),a
ret  
