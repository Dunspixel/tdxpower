; This function calculates power both for the current game and for the selected user profile
; The calculation considers score, soft-drop points, lines, previous power, and number of games played previously.
; In this analysis, I will refer to the variables as follows:
; Score: S, Soft-Drop Points: sD, Lines: Lc, Previous Games: N, Previous Power: Pp, Current Game Power: Pc, New Power: Pn
; sD is to prevent confusion with register D, and Lc is to prevent confusion with register L
; ROM5 6E97 to 6FDE
label6E97:
ld   a,(C119)       ; TODO: Analyse 6E97-6EB9
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

; Subtract sD from S, add sD % 16, then divide new S by Lc
ld   hl,AC26        ; Load S pointer into HL
ld   de,AFB2        ; Load sD pointer into DE
ld   b,00
ld   a,(de)         ; Load lower byte of sD into A
and  a,F0           ; Discard lower nybble of sD
ld   c,a            ; Load A into C
ld   a,(hl)         ; Load lowest byte of S into A
sub  c              ; Subtract C from A
ldi  (hl),a         ; Replace S in SRAM with A, then increment HL to AC27 (next byte of S)
inc  e              ; Increment E, so DE now contains AFB3 (upper byte of SD)
ld   a,(de)         ; Load upper byte of sD into A
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
ld   hl,AC24        ; Load Lc pointer into HL
ld   a,(AC26)       ; Load all bytes of S into registers BCDE
ld   e,a
ld   a,(AC27)
ld   d,a
ld   a,(AC28)
ld   c,a
ld   a,(AC29)
ld   b,a
call 0637           ; 0637_divide - This divides S by Lc and puts the newly calculated Pc in DE

; Multiply Pc by a line multiplier - x0 if Lc is 0, x0.25 if Lc is 1-10, x0.5 if Lc is 11-15, x0.75 if Lc is 16-20, else do nothing (x1)
ld   hl,AC25        ; Pointer to upper byte of Lc
ldd  a,(hl)         ; Load upper byte of Lc into A and decrement HL
and  a              ; This AND sets the zero flag if upper byte of Lc is zero
jr   nz,label6F25   ; Jump to 6F25 and skip line multiplier if non-zero (i.e. more than 255 lines)
ld   a,(hl)         ; Load lower byte of Lc into A
and  a
jr   z,label6F22    ; Jump to 6F22 if A is 0
cp   a,0B           ; This sets the carry flag if A is less than hex 0B
jr   c,label6F18    ; Jump to 6F18 if A is between 1 and 10
cp   a,10
jr   c,label6F1C    ; Jump to 6F1C if A is between 11 and 15
cp   a,15
jr   nc,label6F25   ; Jump to 6F25 if A is between 16 and 20 (technically, not 21 or higher)

; This section will only run if Lc is between 16 and 20 - multiply DE by x0.75
ld   h,d            ; Copy P from DE to HL
ld   l,e
srl  h              ; Bit-shift HL to the right twice
rr   l
srl  h
rr   l
ld   a,e            ; Load E into A
sub  l              ; Subtract Lc from A - This effectively reduces power by a quarter
ld   e,a            ; Load A back into E
jr   nc,label6F13
dec  d              ; If subtraction caused an overflow, subtract carry flag from D
label6F13:
ld   a,d            ; Load D into A
sub  h              ; Subtract H from A
ld   d,a            ; Load A back into E
jr   label6F25

; This section will only run if Lc is between 1 and 10 - multiply DE by x0.5
label6F18:
srl  d              ; Bit-shift DE to the right
rr   e

; This section will only run if Lc is between 1 and 15 - multiply DE by x0.5
; If previous section run due to Lc being between 1 and 10, effective multiplier is x0.25
label6F1C:
srl  d
rr   e
jr   label6F25      ; Jump to 6F25

; This section is only executed if Lc is 0
label6F22:
ld   de,0000        ; Set power to zero

; Store Pc in WRAM DB60 and DB61, then initialise DB68 and DB69
label6F25:
ld   a,d            ; Load D into A
ld   (DB61),a       ; Load A into DB61
ld   a,e            ; Load E into A
ld   (DB60),a       ; Load A into DB60
xor  a              ; XOR A with itself, clearing it
ld   (DB68),a       ; Use A to clear DB68 and DB69
ld   (DB69),a

; Get SRAM address for selected user profile
ld   a,(AC09)       ; Load value of AC09 into A - This is the selected user profile
and  a,0F           ; And A with hex 0F - only the lower nybble is needed
call 7029           ; 7029_get_profile_address - Loads SRAM address for current profile (+01) into HL

; Note that I will be using Profile 1 SRAM addresses for descriptions here - HL contains BC81 at this point
; Increment N, if it is less than 5
xor  a              ; XOR A with itself, clearing it
ldi  (hl),a         ; Use A to clear BC81, increment HL to BC82
ld   a,(hl)         ; Load value of BC82 (N) into A
ld   (DB68),a       ; Load A into DB68
cp   a,05           ; Set carry flag if A is less than 5
jr   nc,label6F47   ; Jump to 6F47 if A is 5 or greater (i.e. cap N at 5)
inc  a              ; Else, increment A
label6F47:
ldi  (hl),a         ; Load A (new N) into BC82, increment HL to BC83
push hl             ; Push HL onto stack

; This basically sets L to either 00 or 80, making HL the beginning of the current profile section in SRAM (BC80 in this case)
ld   a,l            ; Load value of L into A
and  a,80           ; AND A with constant value 80

; Set HL to BCD8 and DE to BCEC
add  a,58           ; Add 58 to A
ld   l,a            ; Load A into L
add  a,14           ; Add 14 to A
ld   d,h            ; Load H into D
ld   e,a            ; Load A into E

; This is a loop which runs 80 (hex 50) times
; It copies SRAM addresses BC88-BCD8 into BC9C-BCEC, shifting this section forward by 20 (hex 14) and duplicating BC88-BC9B with BC9C-BCB0
; I'm not entirely sure what these addresses store - they may not be relevant to power calculation
ld   c,50           ; Load constant value 50 into C - for use as loop counter
label6F55:
ldd  a,(hl)         ; Load value of value pointed by HL into A, decrement HL
ld   (de),a         ; Load value of A into address pointed by DE
dec  e              ; Decrement E
dec  c              ; Decrement C
jr   nz,label6F55   ; Jump to 6F55 if loop counter is not zero

; Determine if current game mode is 40Lines
ld   a,(AC0A)       ; Load value of AC0A (Current Mode) into A
cp   a,02           ; Set zero flag if A is 02
jr   nz,label6F83   ; Jump to 6F83 (i.e. skip 40Lines logic) if zero flag is false

; This section will only run if the current mode is 40Lines
; TODO: Analyse 6F62-6F80
ld   a,(DB61)       
ld   d,a
ld   a,(DB60)
ld   e,a
push de
ld   hl,AC24
ldi  a,(hl)
ld   e,a
ld   d,(hl)
call label7060      ; TODO: Analyse 7060_40lines_logic
ld   a,(DB64)
ld   (AF8D),a
pop  de
ld   a,d
ld   (DB61),a
ld   a,e
ld   (DB60),a

; Set DE to BC83 (total profile lines) and HL to AF8D (lines for current game), then add current game lines to profile total
label6F83:
pop  hl             ; Pop stack into HL (address BC83)
push hl             ; Push HL into stack
ld   d,h            ; Load HL into DE
ld   e,l
ld   hl,AF8D        ; Load constant value AF8D into HL
ld   c,03           ; Load constant value 03 (loop counter) into C
call 7055           ; 7055_add_bcd - Add AF8D-AF8F to BC83-BC85 as decimal values

; Calculate Pn from Pc, Pp, and N
pop  hl             ; Pop stack into HL (address BC83)
inc  l              ; Increment HL to BC87 (Profile Power)
inc  l
inc  l
inc  l
push hl             ; Push HL into stack
ldi  a,(hl)         ; Load value of BC87 (via HL) into A, increment HL to BC88
ld   d,(hl)         ; Load value of BC88 (via HL) into D
ld   e,a            ; Load A into E
ld   hl,0000        ; Load constant value 0000 into HL
ld   a,(DB68)       ; Load value of DB68 (N) into A
and  a              ; This AND sets the zero flag if A is 00
jr   z,label6FA5    ; Jump to 6FA5 if A is zero (i.e. this is the first game for this profile)

; This section will only run if number of games played is non-zero
; This is a loop which multiplies Pp by N and assigns it to HL
label6FA1:
add  hl,de          ; Add DE to HL
dec  a              ; Decrement A
jr   nz,label6FA1   ; Jump to 6FA1 if zero flag is false

; Set DE to Pc, then add to HL (Pp)
label6FA5:
ld   a,(DB61)       ; Load DB60-DB61 (Pc) into DE
ld   d,a
ld   a,(DB60)
ld   e,a
add  hl,de          ; Add DE to HL
ld   bc,0000        ; Load constant value 0000 into BC
ld   d,h            ; Load HL (Pc + Pp * N) into DE
ld   e,l
ld   hl,DB68        ; Load DB68 (pointer to N) into HL
inc  (hl)           ; Increment value pointed by HL - DB68 now contains N + 1
call 0637           ; 0637_divide - Divides (Pc + Pp * N) by (N + 1), storing Pn in DE

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
