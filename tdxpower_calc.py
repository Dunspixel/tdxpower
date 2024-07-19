# tdxpower v1.0.1
# © 2024 Dunspixel

# This is a recreation of the code used to calculate Power in Tetris DX, based on my analysis of the assembly code.
# The original source code was probably a lot simpler and easy to understand than this.

# Single game power can be calculated from Score, Lines, and Soft-Drop points.
# This is then added to (profile power * min(games played, 5)) and divided by min(games played, 5) + 1.

# Currently, this only works for Marathon and Ultra modes.
# There's some extra logic which is applied for 40Lines mode, but I haven't analysed that yet.

global power
global lines

sd_mask = 0xFFFFFFF0 # Soft-drop bitmask
b_mask = 0x00FFFFFF  # Bitmask for reading/writing register B
c_mask = 0xFF00FFFF  # Bitmask for reading/writing register C
d_mask = 0xFFFF00FF  # Bitmask for reading/writing register D
pow2_24 = 16777216   # Coefficient for register B
pow2_16 = 65536      # Coefficient for register C and two-byte operations
pow2_8 = 256         # Coefficient for register D and byte operations

# Get value of B register
def get_b():
    return int(power / pow2_24)

# Set value of B register
def set_b(val):
    global power
    val = val % pow2_8
    power = (power & b_mask) + (val * pow2_24)

# Get value of C register
def get_c():
    return int(power / pow2_16) % pow2_8

# Set value of C register
def set_c(val):
    global power
    val = val % pow2_8
    power = (power & c_mask) + (val * pow2_16)

# Get value of D register
def get_d():
    return int(power / pow2_8) % pow2_8

# Set value of D register
def set_d(val):
    global power
    val = val % pow2_8
    power = (power & d_mask) + (val * pow2_8)

# This bit-shift loop divides score/power by denominator to get a new power value
# I had no idea division was this complex
# denominator is lines when calculating single game power, and (games played + 1) when calculating profile power
# If the effective result of division is greater than 65,535, then this will return 65,535.
def divide_power_by(denominator):
    global power

    i = 16     # Loop counter
    a = 0      # Accumulator
    cf = False # Carry flag

    while i > 0:
        # Double power and add carry flag
        power <<= 1
        if cf:
            power += 1

        # Subtract divisor from upper bytes of power
        # Set carry flag if divisor is greater than this value
        a = get_c()
        a -= denominator % pow2_8
        cf = cf | a < 0
        set_c(a)

        a = get_b()
        a -= int(denominator / pow2_8)
        if cf:
            a -= 1
            cf = False
        cf = cf | a < 0
        set_b(a)

        if cf:
            # Add divisor to upper bytes of power
            a = get_c()
            a += denominator % pow2_8
            cf = cf | a >= pow2_8
            set_c(a)

            a = get_b()
            a += int(denominator / pow2_8)
            if cf:
                a += 1
                cf = False
            cf = cf | a >= pow2_8
            set_b(a)

            # Set carry flag
            cf = True

        # Invert carry flag
        cf = not cf
        i -= 1
    
    # Double power and take lower two bytes
    power <<= 1
    if cf:
        power += 1
    power = power % pow2_16

# Applies a multiplier if 20 lines or fewer
# 0: x0
# 1-10: x0.25
# 11-15: x0.5
# 16-20: x0.75
# 21+: x1
def apply_line_multiplier():
    global power

    # Set power to zero if no lines cleared
    if lines == 0:
        power = 0

    if lines >= 16 and lines <= 20:
        temp_power = power >> 2
        power -= temp_power

    if lines >= 1 and lines <= 10:
        power >>= 1

    if lines >= 1 and lines <= 15:
        power >>= 1

score = int(input("Score: "))
softdrop = int(input("Soft-Drop Points: "))
lines = int(input("Lines: "))
profile_power = int(input("Profile Power: "))
print("Note: Games Played is capped at 5 in SRAM, so enter 5 if you've played a lot")
games = int(input("Games Played (prior to this one): "))

cur_game_power = 0
new_profile_power = 0

# Soft-Drop Points (D) and Lines (L) are 2-byte values, so they will overflow if greater than 65,535
softdrop = softdrop % pow2_16
lines = lines % pow2_16

# Games played stops incrementing once it reaches 5
if games > 5:
    games = 5

# Subtract soft-drop points from score (S), applying bitmask
# This effectively adds D % 16 to (S - D) before running calculation
power = score - (softdrop & sd_mask)
divide_power_by(lines)

# Multiply by M, whose value is dependent on L
apply_line_multiplier()

# Current Game Power (Pc) has been calculated
cur_game_power = power

# Calculate new profile power - (Pc + Pp * N) / N+1
# Pp is previous Profile Power, and N is Games Played
mult_recent_power = profile_power * games
power = cur_game_power + mult_recent_power
divide_power_by(games + 1)

# New Profile Power (Pn) has been calculated
new_profile_power = power

print("Your Single Game Power is " + str(cur_game_power))
print("Your new Profile Power is " + str(new_profile_power))
input("Press any key to close.")
