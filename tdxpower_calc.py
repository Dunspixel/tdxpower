# Tetris DX Power Calculator 1.0 by Dunspixel

# This is a recreation of the code used to calculate Power in Tetris DX, based on my analysis of the disassembly.
# The original source code was probably a lot simpler and easy to understand than this.

# Single game power can be calculated from Score, Lines, and Soft-Drop points.
# This is then added to (profile power * min(games played, 5)) and divided by min(games played, 5) + 1.

# Currently, this only works for Marathon and Ultra modes.
# There's some extra logic which is applied for 40Lines mode, but I haven't analysed that yet.

global power
global lines

sd_mask = 0xFFFFFFF0    # Soft-drop bitmask
upper_mask = 0x0000FFFF # Bitmask for reading/writing upper two bytes
pow2_16 = 65536         # Coefficient for writing upper two bytes
pow2_8 = 256            # Coefficient for byte operations
marathon = 0
ultra = 1
fortylines = 2

def get_upper():
    # Get the upper two bytes of power
    return int(power / pow2_16)

def set_upper(val):
    # Set the upper two bytes of power
    global power
    val = val % pow2_16
    power = (power & upper_mask) + (val * pow2_16)

# This bit-shift loop divides score/power by denominator to get a new power value
# I had no idea division was this complex
# denominator is lines when calculating single game power, and games played when calculating profile power
def divide_power_by(denominator):
    global power

    i = 16      # Loop counter
    a = 0       # A register (note: functionality is consolidated to work with two bytes together)
    cf = False  # Carry flag

    while i > 0:
        # Double power and add carry flag
        power <<= 1
        if cf:
            power += 1

        # Subtract divisor from upper bytes of power
        # Set carry flag if divisor is greater than this value
        a = get_upper()
        a -= denominator
        cf = cf | a < 0
        set_upper(a)

        if cf:
            # Add divisor to upper bytes of power
            a = get_upper()
            a += denominator
            set_upper(a)

            # Set carry flag
            cf = True

        # Invert carry flag
        cf = not cf
        i -= 1
    
    # Double power and take lower two bytes
    power <<= 1
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
#print("Marathon = 0, Ultra = 1, 40Lines = 2")
#mode = int(input("Game Mode: "))

cur_game_power = 0
new_profile_power = 0

# Lines is a 2-byte value, so it will overflow if it is greater than 65,535
lines = lines % pow2_16

# Games played stops incrementing once it reaches 5
if games > 5:
    games = 5

# Subtract soft-drop points from score, applying bitmask
# This effectively adds soft-drop % 16 to score before running calculation
power = score - (softdrop & sd_mask)
divide_power_by(lines)
apply_line_multiplier()

# Current Game Power has been calculated
cur_game_power = power

#if mode == fortylines:
    # TODO: 40Lines specific logic

# Calculate new profile power - (G + P * N) / N+1
# G is Current Game Power, P is previous Profile Power, and N is Games Played
mult_recent_power = profile_power * games
power = cur_game_power + mult_recent_power
divide_power_by(games + 1)

# New Profile Power has been calculated
new_profile_power = power

print("Your Single Game Power is " + str(cur_game_power))
print("Your new Profile Power is " + str(new_profile_power))
input("Press any key to close.")
