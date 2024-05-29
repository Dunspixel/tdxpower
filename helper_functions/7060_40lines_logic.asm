label7060:
ld   a,d
ld   (DB61),a
ld   a,e
ld   (DB60),a
ld   hl,DB64
xor  a
ldi  (hl),a
ld   (hl),a
ld   a,(DB61)
and  a,F0
jr   z,label7088
swap a
ld   c,a
label7078:
push bc
ld   hl,70D2
ld   de,DB64
ld   c,02
call 7055
pop  bc
dec  c
jr   nz,label7078
label7088:
ld   a,(DB61)
and  a,0F
jr   z,label70A0
ld   c,a
label7090:
push bc
ld   hl,70D4
ld   de,DB64
ld   c,02
call 7055
pop  bc
dec  c
jr   nz,label7090
label70A0:
ld   a,(DB60)
and  a,F0
jr   z,label70BA
swap a
ld   c,a
label70AA:
push bc
ld   hl,70D6
ld   de,DB64
ld   c,02
call 7055
pop  bc
dec  c
jr   nz,label70AA
label70BA:
ld   a,(DB60)
and  a,0F
ret  z
ld   c,a
label70C1:
push bc
ld   hl,70D8
ld   de,DB64
ld   c,02
call 7055
pop  bc
dec  c
jr   nz,label70C1
ret  
