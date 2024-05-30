# tdxpower
This is a Python script which calculates Power in Tetris DX (both for single games and overall profile) and an analysis of the assembly code used in the game. It currently only works for Marathon and Ultra modes, as the additional 40Lines logic has not yet been analysed/implemented.

It's my first time trying to analyse and reverse-engineer assembly code, so I'm not very good at it.

If you'd like to read the analysis, please start with 6E97_calculate_power.asm, then refer to the helper functions and the infodump when you get to them. For the time being, most of the analysis is in the infodump which I intend to tidy up and add to the assembly code comments later.

I hope this makes sense to people who know GB assembly better than me!

## Calculations
These calculations are run after you press A on the Game Over screen. If there is a celebratory cutscene, the calculations will run after the cutscene ends.

<ul>
    <li>Pc = ((S - D + (D % 16)) / L) * M</li>
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

## Maximum Power
In Ultra mode, the maximum power is 3,000. This can be achieved by playing on level 9, clearing at least 24 lines, and finishing the game with a 100% Tetris rate.

In Marathon mode, the maximum power by developer-intended means is 6,001. This can be achieved by starting on level 9, clearing 417 consecutive Tetrises to score a maxout (technically 10,010,400 points excluding soft-drop), then topping out with a final line count of 1,668.

Since the internal 4-byte score increases after the counter maxes out, the highest power achievable without overflows is 6,292. This is achieved by scoring a further 15,966 consecutive Tetrises and topping out with a final line count of 65,532 and an internal score of 412,353,600 (excluding soft-drop).

The influence of soft-drop points are too small to impact these maximum power values in any meaningful way.

By overflowing the line counter and finishing with very specific score/line values, a theoretical maximum power of 65,535 can be achieved. Due to the effective line counts being much lower, the influence of soft-drop points actually does affect the power value in this case.
