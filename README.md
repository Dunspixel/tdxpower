# tdxpower
This is my (currently incomplete) analysis of the assembly code used to calculate Power in Tetris DX, plus a calculator which recreates it.

It's my first time trying to analyse and reverse-engineer assembly code, so I'm not very good at it.

If you'd like to read the analysis, please start with tdxpower_analysis.txt, then refer to the helper functions when you get to them.

I hope this makes sense to people who know GB assembly better than me! At the moment, most of the analysis is just one massive infodump, 
but I plan on tidying it up later so it's easier to follow.

Note: There's some extra logic for 40Lines mode which I haven't looked into yet. I will implement this later.

## Calculations
These calculations are run after you press A on the Game Over screen to calculate your power.

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
