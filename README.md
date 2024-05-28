# tdxpower
This is my (currently incomplete) analysis of the assembly code used to calculate Power in Tetris DX, plus a calculator which recreates it.

It's my first time trying to analyse and reverse-engineer assembly code, so I'm not very good at it.

If you'd like to read the analysis, please start with 6E97_calculate_power.asm, then refer to the helper functions and the infodump when you get to them. For the time being, most of the analysis is in the infodump which I intend to tidy up and add to the assembly code comments later.

I hope this makes sense to people who know GB assembly better than me!

Note: There's some extra logic for 40Lines mode which I haven't looked into yet. I will implement this later.

## Calculations
These calculations are run after you press A on the Game Over screen. If there is a celebratory cutscene, the calculations will run after the cutscene ends.

<ul>
    <li>Pc = (((S - D + (D % 16)) / L) * M</li>
    <li>Pn = (Pc + Pp * N) / (N + 1)</li>
</ul>

<ul>
    <li>Pc = Current Game Power</li>
    <li>Pp = Previous Profile Power</li>
    <li>Pn = New Profile Power</li>
    <li>S = Score</li>
    <li>D = Soft-drop points</li>
    <li>L = Lines</li>
    <li>M = Line Multiplier</li>
    <ul>
        <li>If L is between 1 and 10, M is 0.25</li>
        <li>If L is between 11 and 15, M is 0.5</li>
        <li>If L is between 16 and 20, M is 0.75</li>
        <li>Else M is 1</li>
    </ul>
    <li>N = Number of games played previously (Max 5)</li>
</ul>
