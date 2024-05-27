# This is a recreation of the code used to calculate Power in Tetris DX, based on my analysis of the disassembly.
# The original source code was probably a lot simpler and easy to understand than this.

# Single game power can be calculated from Score, Lines, and Soft-Drop points.
# This is then added to (profile power * max(games played, 5)) and divided by max(games played, 5) + 1.

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
sprint = 2

def get_upper():
    # Get the upper two bytes of power
    return int(power / pow2_16)

def set_upper(val):
    # Set the upper two bytes of power
    global power
    val = val % pow2_16
    power = (power & upper_mask) + (val * pow2_16)

# This bit-shift loop divides score by divisor to get power
# I had no idea division was this complex
# Divisor is lines when calculating single game power, and games played when calculating profile power
def bitshift_loop(divisor):
    global power

    i = 16      # Loop counter
    a = 0       # A register (note: functionality is consolidated to work with two bytes together)
    cf = False  # Carry flag

    while i > 0:
        # Double power and add carry flag
        # HACK: The actual game does not do the zero check which I added here (it's probably somewhere else)
        power <<= 1
        if cf & (power > 0):
            power += 1

        # Subtract divisor from upper bytes of power
        # Set carry flag if divisor is greater than this value
        a = get_upper()
        a -= divisor
        cf = cf | a < 0
        set_upper(a)

        if cf:
            # Add divisor to upper bytes of power
            a = get_upper()
            a += divisor
            set_upper(a)

            # Set carry flag
            cf = True

        # Invert carry flag
        cf = not cf
        i -= 1
    
    # Double power and take lower two bytes
    power <<= 1
    power = power % pow2_16

# Applies a penalty if 20 lines or fewer
# 1-10: x0.25
# 11-15: x0.5
# 16-20: x0.75
def low_line_penalty():
    global power

    if lines >= 16 and lines <= 20:
        temp_power = power >> 2

        # Is this some sort of signed/unsigned conversion?
        if temp_power % pow2_8 > power & pow2_8:
            power -= pow2_8

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

if games > 5:
    games = 5

# Subtract soft-drop points from score, applying bitmask
# This effectively adds soft-drop % 16 to score before running calculation
power = score - (softdrop & sd_mask)
bitshift_loop(lines)
low_line_penalty()

# Current Game Power has been calculated
cur_game_power = power

# TODO: 40Lines specific logic

# Calculate new profile power - (G + P * N) / N+1
# G is Current Game Power, P is previous Profile Power, and N is Games Played
mult_recent_power = profile_power * games
power = cur_game_power + mult_recent_power
bitshift_loop(games + 1)

# New Profile Power has been calculated
new_profile_power = power

print("Your Single Game Power is " + str(cur_game_power))
print("Your new Profile Power is " + str(new_profile_power))
input("Press any key to close.")
