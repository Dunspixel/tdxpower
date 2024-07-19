# tdxpower
This is a Python script which calculates Power in Tetris DX (both for single games and overall profile) and a currently incomplete analysis of the assembly code used in the game. It currently only works for Marathon and Ultra modes, as the additional 40Lines logic has not yet been analysed/implemented.

If you'd like to read the analysis, please start with 6E97_calculate_power.asm, then refer to the helper functions, val_sram, and val_wram as necessary.

This is my first time trying to analyse and reverse-engineer assembly code, so I'm not very good at it. I hope it makes sense to people who know GB assembly better than me!

## Calculations
These calculations are run after you press A on the Game Over screen. If there is a celebratory cutscene, the calculations will run after the cutscene ends.

<ul>
    <li>P<sub>c</sub> = ((S - D<sub>1</sub> + D<sub>2</sub>) / L) * M</li>
    <li>P<sub>n</sub> = (P<sub>c</sub> + P<sub>p</sub> * N) / (N + 1)</li>
</ul>

<ul>
    <li>P<sub>c</sub> = Current Game Power</li>
    <li>P<sub>p</sub> = Previous Profile Power</li>
    <li>P<sub>n</sub> = New Profile Power</li>
    <li>S = Score</li>
    <li>D<sub>1</sub> = Soft-drop points % 65536</li>
    <li>D<sub>2</sub> = Soft-drop points % 16</li>
    <li>L = Lines % 65536</li>
    <li>M = Line Multiplier</li>
    <li>N = min(number of games played previously, 5)</li>
</ul>

Line Multiplier values:
<table>
    <tr>
        <th>L</th>
        <th>M</th>
    </tr>
    <tr>
        <td>0</td>
        <td>0</td>
    </tr>
    <tr>
        <td>1-10</td>
        <td>0.25</td>
    </tr>
    <tr>
        <td>11-15</td>
        <td>0.5</td>
    </tr>
    <tr>
        <td>16-20</td>
        <td>0.75</td>
    </tr>
    <tr>
        <td>21+</td>
        <td>1</td>
    </tr>
</table>

Note that the score and lines values are internal and slightly different from the values actually displayed. Score will continue increasing after the displayed counter maxes out, and both values will overflow (4 bytes for score, 2 bytes for lines) without this overflow being reflected in the displayed counters.

## Maximum Power
In Ultra mode, the maximum power is 3,000. This can be achieved by playing on level 9, clearing at least 24 lines, and finishing the game with a 100% Tetris rate.

In Marathon mode, the maximum power by developer-intended means is 6,001. This can be achieved by starting on level 9, clearing 417 consecutive Tetrises to score a maxout (technically 10,010,400 points excluding soft-drop), then topping out with a final line count of 1,668.

Since the internal 4-byte score increases after the counter maxes out, the highest power achievable without overflows is 6,292. This is achieved by scoring a further 15,966 consecutive Tetrises and topping out with a final line count of 65,532 and an internal score of 412,353,600 (excluding soft-drop).

The influence of soft-drop points is usually too small to impact these maximum power values in any meaningful way. However, the latter two of the above values can be increased further by overflowing your soft-drop points, as each overflow will add 65,536 to what the game thinks your score will be after the soft-drop points are subtracted.

By overflowing the line counter and increasing it to at least 65,557 (overflow + 21 lines), a power value of 65,535 can be achieved. Due to how the divide function works, using it to divide something where the result is greater than 65,535 will just return 65,535. If the effective line count is less than 21, power values of 16,383, 32,767, or 49,151 will be achieved instead due to the line multiplier.

Also, for reasons I'm not entirely sure of, huge line values just under the point of overflow (around 60-65k) break the divide function, resulting in values of 0.

## Fun Trivia
The power value on your profile only displays the last four digits. If you overflow your line count and achieve a power of 65,535, this will be displayed as 5535. This is the only way to achieve a five-digit power value.

The line counter has a similar bug. While it doesn't overflow with the internal value, it only displays the last five digits if you increase it above 100,000. Despite the display bug, this counter is capped at 999,999.
