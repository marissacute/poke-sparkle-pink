# Pokédex TODO

Outstanding work for the full dex. **202 dex species.** Every list below was derived by
parsing the source tables, not by hand — re-derive before trusting a count (see
[Verifying](#verifying)). Last re-derived 2026-10-04.

Scope notes:

- **Mew and Hoopa are excluded throughout** — they are deliberately unobtainable.
- The three internal `MISSINGNO.` slots (`FOSSIL_KABUTOPS` `$B6`, `FOSSIL_AERODACTYL` `$B7`,
  `MON_GHOST` `$B8`) have no dex entry and are not audited.

---

## 1. Placeholder graphics

Every blank is a *uniform* image — one sample value across the whole file — which is a surer
tell than the file size. Done already: Munchlax, Sneasel, Flygon, Mime Jr. and Mismagius
(front **and** back), plus the **fronts** of Annihilape and Weavile. All of these PNGs are
tracked by git.

**No blank front remains.** Glaceon, Leafeon (both 2026-10-06, from `drawings/`) and
Mismagius (2026-10-06) were the last, and each now has real art in `gsfront/`.

**5 species with a real front but a blank back:**

- [ ] Annihilape — `gsback/annihilapeb.png`
- [ ] Glaceon — `gsback/glaceonb.png`
- [ ] Hoopa — `gsback/hoopab.png` (72 B, a different file from the others above)
- [ ] Leafeon — `gsback/leafeonb.png`
- [ ] Weavile — `gsback/weavileb.png`

Four of the five blank backs are byte-identical (75 B, md5 `39796b54…`); Hoopa's is the 72 B
outlier, as before.

### Also

- [x] All 202 species now use their animated Gen 2 party-menu icon. The placeholder species
  deliberately borrow a relative's icon — e.g. `trapinch`/`vibrava`/`flygon` are all `ICON_BUG`
  ([menu_icons.asm](data/pokemon/menu_icons.asm)).

---

## 2. Can't be obtained

**5 species** (excluding Mew and Hoopa). Split by whether a player can end up owning them at
all.

### Never ownable — 4

**Whole lines absent:**

- [ ] Mareep line — Mareep, Flaaffy, Ampharos

**Pre-evolutions whose evolution is already obtainable** (add the missing base form to a wild
table, a gift, or a trade):

- [ ] Munchlax → Snorlax

**Recently closed here** (kept for the record):

- [x] ~~Mime Jr. → Mr. Mime~~ — FIXED 2026-10-04. The Route 2 trade now asks for an ABRA and
  gives a MIME_JR nicknamed MARCEL ([trades.asm](data/events/trades.asm), `TRADE_FOR_MARCEL`),
  where it used to give a Mr. Mime. Mime Jr. evolves into Mr. Mime at level 20, so the trade
  still reaches the same end state. **Its front and back art are still the blank placeholders**
  (see [section 1](#1-placeholder-graphics)), so it renders as an empty square until that is
  drawn.
- [x] ~~Smoochum → Jynx~~ — FIXED 2026-10-04. SMOOCHUM is one of the three mons on Celadon
  prize menu 1 ([prizes.asm](data/events/prizes.asm)), at 1000 coins.
- [x] ~~Paldean Wooper~~ — FIXED 2026-10-04. The Cerulean Trade House now trades a WOOPER for
  a PALDEAN_WOOPER nicknamed CLODDY ([trades.asm](data/events/trades.asm), index
  `TRADE_FOR_CLODDY`). It does not close forwards to Clodsire: `PaldeanWooperEvosMoves` is
  still `db 0`, so the evolution would have to be added first.

---

## 3. Never appears on a trainer's team

**40 species**, excluding the legendaries/mythicals (Articuno, Zapdos, Moltres, Mewtwo, Mew,
Hoopa). The other 162 of 202 species appear on at least one trainer's team.

- [ ] Abra
- [ ] Ampharos
- [ ] Annihilape
- [ ] Blissey
- [ ] Clefable
- [ ] Ditto
- [ ] Eevee
- [ ] Elekid
- [ ] Flaaffy
- [ ] Flygon
- [ ] Forretress
- [ ] Glaceon
- [ ] Happiny
- [ ] Hitmontop
- [ ] Houndoom
- [ ] Houndour
- [ ] Kabuto
- [ ] Kingdra
- [ ] Krabby
- [ ] Leafeon
- [ ] Ledian
- [ ] Ledyba
- [ ] Magby
- [ ] Mareep
- [ ] Mime Jr.
- [ ] Mismagius
- [ ] Munchlax
- [ ] Politoed
- [ ] Porygon
- [ ] Porygon2
- [ ] Psyduck
- [ ] Scizor
- [ ] Scyther
- [ ] Slowking
- [ ] Smoochum
- [ ] Sneasel
- [ ] Trapinch
- [ ] Tyrogue
- [ ] Vibrava
- [ ] Weavile

---

## 4. Placeholder cries

**45 species.** Every one carries a `; <Name>, same as <Other> for now` comment in
[data/pokemon/cries.asm](data/pokemon/cries.asm), so they can be found by grepping for
`same as`. The bracketed name is whose cry is being borrowed:

- [ ] Igglybuff (Jigglypuff)
- [ ] Magnezone (Magnezone — comment is self-referential, presumably means Magneton)
- [ ] Espeon (Flareon)
- [ ] Umbreon (Vaporeon)
- [ ] Bellossom (Vileplume)
- [ ] Wooper (Poliwag)
- [ ] Paldean Wooper (Wooper)
- [ ] Sylveon (Jolteon)
- [ ] Pichu (Pikachu)
- [ ] Clodsire (Quagsire)
- [ ] Hoopa (Mew)
- [ ] Skarmory (Fearow)
- [ ] Miltank (Tauros)
- [ ] Pineco (Pinsir)
- [ ] Forretress (Pinsir)
- [ ] Crobat (Golbat)
- [ ] Ledyba (Caterpie)
- [ ] Ledian (Caterpie)
- [ ] Politoed (Poliwhirl)
- [ ] Slowking (Slowbro)
- [ ] Magby (Magmar)
- [ ] Tyrogue (Hitmonchan)
- [ ] Elekid (Electabuzz)
- [ ] Smoochum (Jynx)
- [ ] Mareep (Pikachu)
- [ ] Flaaffy (Pikachu)
- [ ] Ampharos (Pikachu)
- [ ] Hitmontop (Hitmonlee)
- [ ] Kingdra (Seadra)
- [ ] Blissey (Chansey)
- [ ] Porygon2 (Porygon)
- [ ] Houndour (Growlithe)
- [ ] Houndoom (Arcanine)
- [ ] Happiny (Chansey)
- [ ] Annihilape (Primeape)
- [ ] Mismagius (Misdreavus)
- [ ] Mime Jr. (Mr. Mime)
- [ ] Sneasel (**Persian** — unrelated)
- [ ] Weavile (**Persian** — unrelated)
- [ ] Leafeon (Eevee)
- [ ] Glaceon (Eevee)
- [ ] Munchlax (Snorlax)
- [ ] Trapinch (**Sandshrew** — unrelated)
- [ ] Vibrava (**Sandshrew** — unrelated)
- [ ] Flygon (**Sandshrew** — unrelated)

> Not every repeated cry is a placeholder. Cry reuse is original Gen 1 behaviour — Slowbro
> shares with Charizard, Growlithe with Sandshrew, the whole Eevee family shares one cry, and
> so on. Conversely, the *other* member of each pair above is the original and needs nothing.
> The four bolded entries are the ones borrowing from a species that isn't even a relative;
> they are the clearest stopgaps.

---

## 5. Pokémon that miss moves

### ~~Broken~~ — missing evolutions terminator (7) — FIXED 2026-09-20

Each of these structs in [data/pokemon/evos_moves.asm](data/pokemon/evos_moves.asm) had **one**
`db 0` instead of two. The engine finds a learnset by scanning to the first zero byte
([pokemon_data_constants.asm:85-90](constants/pokemon_data_constants.asm#L85-L90)), so it ran
straight past the end of the evolution block — three learned **nothing**, four read the next
struct's evolution bytes as level/move pairs and learned **garbage moves**. All came from
uncommitted working-tree changes. One `db 0` each, after the `db EVOLVE_*` line; verified by
reading the learnsets back out of the rebuilt ROM.

- [x] Primeape
- [x] Sneasel
- [x] Vibrava
- [x] Misdreavus
- [x] Mime Jr.
- [x] Munchlax
- [x] Trapinch

> Nothing in the toolchain catches this class of bug — `assert_table_length` checks entry
> counts and `-Wtruncation=1` checks byte widths, neither checks struct shape. It is only
> visible by parsing `db 0` counts per struct (see [Verifying](#verifying)).

### Empty learnsets (7) — confirm these are intentional

No level-up moves at all. These are functional, because the four level-1 moves in
`base_stats/*.asm` are copied into the move slots before the learnset is written — so this is
a "confirm" item, not a defect:

- [ ] Abra
- [ ] Clefable
- [ ] Ditto
- [ ] Kakuna
- [ ] Ninetales
- [ ] Raichu
- [ ] Starmie

> Arcanine and Metapod used to be on this list and now each have exactly one move — Arcanine
> `EXTREME_SPEED` at 50, Metapod `EVOLUTION_MOVE, HARDEN`. They moved to the thin list below.

### Thin learnsets — 3 moves or fewer (23)

Several are vanilla-correct. Tyrogue, Magnezone and Magmar are this fork's own additions and
worth a look (Magmar was trimmed to three in the 2026-10 balance pass):

- [ ] Arcanine (1)
- [ ] Caterpie (1)
- [ ] Cloyster (1)
- [ ] Crobat (1)
- [ ] Exeggutor (1)
- [ ] Metapod (1)
- [ ] Weedle (1)
- [ ] Flygon (2)
- [ ] Magikarp (2)
- [ ] Poliwrath (2)
- [ ] Tyrogue (2)
- [ ] Weavile (2)
- [ ] Bellossom (3)
- [ ] Gastly (3)
- [ ] Gengar (3)
- [ ] Haunter (3)
- [ ] Magmar (3)
- [ ] Magnezone (3)
- [ ] Nidoking (3)
- [ ] Nidoqueen (3)
- [ ] Victreebel (3)
- [ ] Vileplume (3)
- [ ] Wigglytuff (3)

---

## Bugs found alongside this audit

Not species gaps, but found while deriving the lists above.

- [x] **`PAL_WOOPER` is a palette constant, not a species. — FIXED 2026-09-20.**
  [data/trainers/parties.asm](data/trainers/parties.asm) lines 234, 271, 275 and 280 used
  `PAL_WOOPER`, which resolved to
  [palette_constants.asm:247](constants/palette_constants.asm#L247) `PAL_WOOPER ; $DA` = 218 —
  outside the species range entirely, so four enemy teams carried a garbage species. Changed to
  `PALDEAN_WOOPER` ($3F); confirmed in the rebuilt ROM.

  > The name collision itself is still live: `constants/palette_constants.asm` is included
  > *after* `constants/pokemon_constants.asm` (`includes.asm:35` vs `:43`), and in rgbasm the
  > last definition of a symbol wins. The palette constant also shadows the species one. Any
  > future species whose name collides with a `PAL_*` constant will silently resolve to a
  > palette id in exactly the same way. Renaming the palette constant is the durable fix.
- [x] ~~**`PrizeMonLevelDictionary` is stale, and `GetPrizeMonLevel` scans unchecked.**~~
  — FIXED 2026-10-04. The dictionary now lists exactly the six species the two mon menus
  offer (GOLDEEN/HAPPINY/SMOOCHUM and EEVEE/SCYTHER/PORYGON); the dead `NIDORINA, 17` is gone
  and EEVEE has an entry. `GetPrizeMonLevel` stops on a `db 0, 0` terminator instead of
  scanning off the end, and falls back to `PRIZE_MON_FALLBACK_LEVEL` rather than returning
  whatever byte it happened to land on.

  The two tables are now linked **at build time** so they cannot drift apart again: the
  `prize_level` macro in
  [prize_mon_levels.asm](data/events/prize_mon_levels.asm) defines `PRIZE_LEVEL_<species>` for
  each entry, and the `prize_mon` macro in [prizes.asm](data/events/prizes.asm) asserts that
  symbol exists for every species its menus list — so removing a menu entry's level now fails
  the build with `no PrizeMonLevelDictionary entry for <SPECIES>` instead of being discovered
  in play. This requires `prize_mon_levels.asm` to be INCLUDEd *before* `prizes.asm`
  ([prize_menu.asm](engine/events/prize_menu.asm)); the reverse order makes every assert
  fail on a forward reference.

  Verified in-game 2026-10-04: buying the 500-coin Goldeen from the Celadon prize vendor
  produced a level 10 Goldeen, matching its dictionary entry.

---

## Verifying

Re-derive the lists and diff against this file:

| Category | How to check |
|---|---|
| Placeholder graphics | `md5sum gfx/pokemon/gsfront/*.png \| sort \| uniq -d -w32`, same for `gsback/` — blanks also show up as ~75–77 B files. Uniformity is the real tell; a duplicate md5 only groups them |
| Obtainable | union of `db <lvl>, <SPECIES>` in `data/wild/` (plus the hardcoded Old Rod MAGIKARP at [item_effects.asm:1772](engine/items/item_effects.asm#L1772)), `lb bc, <SPECIES>, <LVL>` gifts, fossil revives (OMANYTE/KABUTO/AERODACTYL), starter picks, `npctrade` column 2, `data/events/prizes.asm`, scripts that set `wCurOpponent` (SNORLAX, MEWTWO), and `OW_POKEMON` map objects; then close forwards under `db EVOLVE_*` |
| Trainers | `db` team rows in `data/trainers/parties.asm` — both `db <lvl>, SPECS…, 0` and `db $FF, <lvl>, SPEC, …` forms |
| Cries | `mon_cry` rows carrying a `same as` marker in `data/pokemon/cries.asm` — every placeholder now has one, so a plain grep is exact |
| Learnsets | Read the structs out of the **built ROM** via `EvosMovesPointerTable` (`pokered.sym`) rather than regexing the source |

Traps that cost time when parsing the obtainable set — each produced a false positive:

- **`STARTER1`/`STARTER2`/`STARTER3` are not a "player gets a starter" signal.** They are
  defined in `constants/pokemon_constants.asm` as IGGLYBUFF/MAGNEMITE/DRATINI, but
  `CeruleanCity`, `ChampionsRoom`, `PokemonTower*`, `Route22`, `SSAnne2F` and `SilphCo7F` only
  use them to pick the *rival's* team. The player's starter comes solely from
  `scripts/OaksLab.asm`; the Route 15 aide's classic three come from `.StarterList` in
  `scripts/Route15Gate2F.asm`.
- **`wCurOpponent` has one unreachable case:** `scripts/ViridianCity.asm` sets it to `WEEDLE`
  for the Old Man's catching demo, guarded by `BATTLE_TYPE_OLD_MAN`. Skip any such site or
  Weedle is counted as obtainable from a battle you cannot keep.
- **`lb bc` argument order is not consistent.** `GivePokemon` takes species in `b` and level in
  `c` (`lb bc, EEVEE, 25`), but the fishing code is the opposite (`lb bc, 5, MAGIKARP`).
- `PAL_WOOPER` must not be counted as a species (see the palette name collision above).

Also remember scripted `wCurOpponent` battles (Route 12/16 Snorlax) are a real source, so the
plain wild tables alone will undercount what is obtainable. For learnsets, the source-side
tally is tempting but the ROM is ground truth — `EvosMovesPointerTable` is ordered by species
index (entry *n* is species *n+1*, since `NO_MON` occupies slot 0), every pointer is bank
`$0e`, and the evolution methods have fixed payload sizes (`EVOLVE_LEVEL` 3 bytes,
`EVOLVE_ITEM` 4, `EVOLVE_TRADE` 3, `EVOLVE_STAT` 4).
