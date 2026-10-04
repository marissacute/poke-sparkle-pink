# Type Chart

Effectiveness of an attacking type (rows) against a defending type (columns),
generated from `TypeEffects` in [data/types/type_matchups.asm](data/types/type_matchups.asm).

`2` = 2×  ·  `½` = ½×  ·  `0` = 0× (immune)  ·  blank = 1×  ·  `*` = differs from official Gen 9

| Att \ Def | Nor | Fig | Fly | Poi | Gro | Roc | Bug | Gho | Ste | Fir | Wat | Gra | Ele | Psy | Ice | Dra | Dar | Fai |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **Normal** |  |  |  |  |  | ½ |  | 0 | ½ |  |  |  |  |  |  |  |  |  |
| **Fighting** | 2 |  | ½ | ½ |  | 2 | ½ | 0 | 2 |  |  |  |  | ½ | 2 |  | 2 | ½ |
| **Flying** |  | 2 |  |  |  | ½ | 2 |  | ½ |  |  | 2 | ½ |  |  |  |  |  |
| **Poison** |  |  |  | ½ | ½ | ½ |  | ½ | 0 |  |  | 2 |  |  |  |  |  | 2 |
| **Ground** |  |  | 0 | 2 |  | 2 | ½ |  | 2 | 2 |  | ½ | 2 |  |  |  |  |  |
| **Rock** |  | ½ | 2 |  | ½ |  | 2 |  | ½ | 2 |  |  |  |  | 2 |  |  |  |
| **Bug** |  | ½ | ½ | ½ |  |  |  | ½ | ½ | ½ |  | 2 |  | 2 |  |  | 2 | ½ |
| **Ghost** | 0 |  |  |  |  |  |  | 2 |  |  |  |  |  | 2 |  |  | ½ |  |
| **Steel** |  |  |  |  |  | 2 |  |  | ½ | ½ | ½ |  | ½ |  | 2 |  |  | 2 |
| **Fire** |  |  |  |  |  | ½ | 2 |  | 2 | ½ | ½ | 2 |  |  | 2 | ½ |  |  |
| **Water** |  |  |  |  | 2 | 2 |  |  |  | 2 | ½ | ½ |  |  | ½\* | ½ |  |  |
| **Grass** |  |  | ½ | ½ | 2 | 2 | ½ |  | ½ | ½ | 2 | ½ |  |  | ½\* | ½ |  |  |
| **Electric** |  |  | 2 |  | 0 |  |  |  |  |  | 2 | ½ | ½ |  |  | ½ |  |  |
| **Psychic** |  | 2 |  | 2 |  |  |  |  | ½ |  |  |  |  | ½ |  |  | 0 |  |
| **Ice** |  |  | 2 |  | 2 |  |  |  | ½ | ½ | ½ | 2 |  |  | ½ | 2 |  |  |
| **Dragon** |  |  |  |  |  |  |  |  | ½ |  |  |  |  |  |  | 2 |  | 0 |
| **Dark** |  | ½ |  |  |  |  |  | 2 |  |  |  |  |  | 2 |  |  | ½ | ½ |
| **Fairy** |  | 2 |  | ½ |  |  |  |  | ½ | ½ |  |  |  |  |  | 2 | 2 |  |

## Differences from official Gen 9

Only 2 cells differ:

| Matchup | Official Gen 9 | This game | Location |
|---|---|---|---|
| Water → Ice | 1× | ½× | [type_matchups.asm:132](data/types/type_matchups.asm#L132) |
| Grass → Ice | 1× | ½× | [type_matchups.asm:133](data/types/type_matchups.asm#L133) |

Both are deliberate Ice-type defensive buffs (the "New matchups for ice" block).
Side effect: Ice/Water and Ice/Grass duals take ¼× from those types, and since
[core.asm:5261](engine/battle/core.asm#L5261) turns 0 damage into a miss, very low-power
moves can visibly "miss" against them.

Bug → Poison was formerly 2× (a Gen 1 leftover); it is now ½×, matching Gen 9.
