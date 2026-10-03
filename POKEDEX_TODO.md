# Pokédex TODO

Outstanding work for the full dex. **202 dex species.** Every list below was derived by
parsing the source tables, not by hand — re-derive before trusting a count (see
[Verifying](#verifying)).

Scope notes:

- **Mew and Hoopa are excluded throughout** — they are deliberately unobtainable.
- The three internal `MISSINGNO.` slots (`FOSSIL_KABUTOPS` `$B6`, `FOSSIL_AERODACTYL` `$B7`,
  `MON_GHOST` `$B8`) have no dex entry and are not audited.

---

## 1. Placeholder graphics

11 species, front **and** back. Each pair is the same blank image — the fronts are
byte-identical to one another (77 B) and so are the backs (75 B). None of these PNGs are
tracked by git yet.

- [ ] Annihilape — `gfx/pokemon/gsfront/annihilape.png`, `gsback/annihilapeb.png`
- [ ] Flygon — `gfx/pokemon/gsfront/flygon.png`, `gsback/flygonb.png`
- [ ] Glaceon — `gfx/pokemon/gsfront/glaceon.png`, `gsback/glaceonb.png`
- [ ] Leafeon — `gfx/pokemon/gsfront/leafeon.png`, `gsback/leafeonb.png`
- [ ] Mime Jr. — `gfx/pokemon/gsfront/mimejr.png`, `gsback/mimejrb.png`
- [ ] Mismagius — `gfx/pokemon/gsfront/mismagius.png`, `gsback/mismagiusb.png`
- [x] Munchlax — `gfx/pokemon/gsfront/munchlax.png`, `gsback/munchlaxb.png`
- [ ] Sneasel — `gfx/pokemon/gsfront/sneasel.png`, `gsback/sneaselb.png`
- [ ] Trapinch — `gfx/pokemon/gsfront/trapinch.png`, `gsback/trapinchb.png`
- [ ] Vibrava — `gfx/pokemon/gsfront/vibrava.png`, `gsback/vibravab.png`
- [ ] Weavile — `gfx/pokemon/gsfront/weavile.png`, `gsback/weavileb.png`

### Also

- [ ] **Hoopa's back sprite** is a blank too — `gsback/hoopab.png` (72 B, uniform). Its front
  is real art. This one *is* tracked, so it will not show up in `git status`.
- [x] All 202 species now use their animated Gen 2 party-menu icon. The 11 above deliberately
  borrow a relative's icon, e.g. `trapinch`/`vibrava`/`flygon` are all `ICON_BUG`
  ([menu_icons.asm](data/pokemon/menu_icons.asm)).
- [ ] Three unreferenced art files sit in `gfx/pokemon/gsfront/`: `magnezone_colour.png`,
  `fossilkabutops.png`, `fossilaerodactyl.png`. Keep or delete.

---

## 2. Can't be obtained

**26 species.** Split by whether a player can end up owning them at all.

### Never ownable — 20

**Whole lines absent:**

- [ ] Mareep line — Mareep, Flaaffy, Ampharos
- [ ] Trapinch line — Trapinch, Vibrava, Flygon
- [ ] Houndour line — Houndour, Houndoom
- [ ] Sneasel line — Sneasel, Weavile

**Pre-evolutions whose evolution is already obtainable** (add the missing base form to a wild
table, a gift, or a trade):

- [ ] Elekid → Electabuzz
- [ ] Happiny → Chansey
- [ ] Mime Jr. → Mr. Mime
- [ ] Munchlax → Snorlax
- [ ] Smoochum → Jynx
- [ ] Tyrogue → Hitmonlee / Hitmonchan (both Dojo gifts)
- [ ] Magby → Magmar (Magmar is trainer-only — see below)

**Reachable only through an unobtainable pre-evolution:**

- [ ] Hitmontop — requires Tyrogue, which appears nowhere

**Standalone:**

- [ ] Skarmory

### Trainer-only — 6

Appear on an enemy team but can never be owned. Needs a wild/gift/trade source:

- [ ] Clodsire
- [ ] Magmar
- [ ] Miltank
- [ ] Paldean Wooper
- [ ] Quagsire
- [ ] Wooper

---

## 3. Never appears on a trainer's team

**43 species**, excluding the legendaries/mythicals (Articuno, Zapdos, Moltres, Mewtwo, Mew,
Hoopa). The other 153 of 202 species appear on at least one trainer's team.

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
- [ ] Omanyte
- [ ] Pineco
- [ ] Politoed
- [ ] Porygon
- [ ] Porygon2
- [ ] Psyduck
- [ ] Scizor
- [ ] Scyther
- [ ] Skarmory
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

### Empty learnsets (11) — confirm these are intentional

No level-up moves at all. These are functional, because the four level-1 moves in
`base_stats/*.asm` are copied into the move slots before the learnset is written — so this is
a "confirm" item, not a defect:

- [ ] Abra
- [ ] Arcanine
- [ ] Caterpie
- [ ] Clefable
- [ ] Ditto
- [ ] Kakuna
- [ ] Metapod
- [ ] Ninetales
- [ ] Raichu
- [ ] Starmie
- [ ] Weedle

### Thin learnsets — 3 moves or fewer (16)

Several are vanilla-correct. Tyrogue and Magnezone are this fork's own additions and worth a
look:

- [ ] Tyrogue (2)
- [ ] Magnezone (3)
- [ ] Cloyster (1)
- [ ] Crobat (1)
- [ ] Exeggutor (1)
- [ ] Magikarp (2)
- [ ] Poliwrath (2)
- [ ] Bellossom (3)
- [ ] Gastly (3)
- [ ] Gengar (3)
- [ ] Haunter (3)
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
- [ ] **`PrizeMonLevelDictionary` is stale.**
  [data/events/prize_mon_levels.asm](data/events/prize_mon_levels.asm) still has `NIDORINA` and
  `PINSIR` level entries, but neither appears in either prize menu any more (the menus hold
  ABRA/CLEFAIRY/DRATINI and EEVEE/SCYTHER/PORYGON).

---

## Verifying

Re-derive the lists and diff against this file:

| Category | How to check |
|---|---|
| Placeholder graphics | `md5sum gfx/pokemon/gsfront/*.png \| sort \| uniq -d -w32`, same for `gsback/`; `git status gfx/pokemon/` |
| Obtainable | union of `db <lvl>, <SPECIES>` in `data/wild/` (plus the hardcoded Old Rod MAGIKARP at [item_effects.asm:1772](engine/items/item_effects.asm#L1772)), `lb bc, <SPECIES>, <LVL>` gifts, `DisplayPokedex` gifts, `OW_POKEMON` map objects, `npctrade` column 2, `data/events/prizes.asm`, and `data/trainers/parties.asm`; then close forwards under `db EVOLVE_*` |
| Trainers | `db` team rows in `data/trainers/parties.asm` — both `db <lvl>, SPECS…, 0` and `db $FF, <lvl>, SPEC, …` forms |
| Cries | `mon_cry` rows carrying a `same as` marker in `data/pokemon/cries.asm` — every placeholder now has one, so a plain grep is exact |
| Learnsets | Count `db 0` rows per `*EvosMoves:` struct — every well-formed one has exactly two; the moves are the rows *between* them |

Two things to watch when parsing — the learnset rows sit between the two terminators, not after
the last one, and `PAL_WOOPER` must not be counted as a species.
