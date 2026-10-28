# TODO — Bug fixes

Scan date: 2026-10-28
Baseline: `HEAD` 5757fe7c vs `upstream/master` c1a3b6c5
Method: static audit of `engine/`, `home/`, `scripts/`, `data/`, `text/`, `audio/`, `color/`; no fixes applied; no runtime emulation. Build artifacts were current, so all build-time `ASSERT`s pass.

Severity: **P0** lost content / crash / corruption · **P1** wrong behavior / OOB read · **P2** exploit / UI / wrong text · **P3** latent (not normally reachable).

How to use: work top-down. Each item has the trigger, the root cause, a fix sketch, and a test. Fix sketches are starting points, not patches — re-read the current code before editing. For runtime repros use `PYBOY_TESTING.md`; build first, test in `/tmp`.

Quick links: [P0](#p0--major) · [P1](#p1--medium) · [P2](#p2--minor--cosmetic) · [P3](#p3--latent) · [Known pokered bugs](#known-pokered-bugs-still-present) · [Already fixed](#already-fixed--do-not-chase) · [Verified clean](#verified-clean) · [Runtime checks wanted](#runtime-checks-wanted)

---

## P0 — Major

### BUG-01 — Mewtwo is permanently lost if the player blacks out
- [ ] **Fix Mewtwo persistence on blackout**
  - Where: [scripts/CeruleanCaveB1F.asm:41-60](scripts/CeruleanCaveB1F.asm#L41-L60), [engine/overworld/toggleable_objects.asm:137-143](engine/overworld/toggleable_objects.asm#L137-L143), [engine/movie/oak_speech/init_player_data.asm:44](engine/movie/oak_speech/init_player_data.asm#L44)
  - Trigger: talk to Mewtwo, lose the battle. The map script hides the object before the fight; the `wIsInBattle == $ff` branch resets the script without setting `EVENT_BEAT_MEWTWO` and without showing the object again.
  - Cause: `HideObject` sets a persistent bit in `wToggleableObjectFlags` (only cleared at new-game init and saved in the main save data). `EVENT_FIGHT_MEWTWO` is reset before the battle, so the only way to set it again is to talk to the now-hidden sprite. Saving after the blackout makes the loss permanent.
  - Fix sketch: in the `$ff` branch, before resetting, restore the object:
    ```asm
    ld a, TOGGLE_MEWTWO
    ld [wToggleableObjectIndex], a
    predef ShowObject
    ```
    Better: move the `HideObject` call out of `CeruleanCaveB1FDefaultScript` and into the non-blackout post-battle path, so the object only disappears after a decisive outcome. Decide separately whether running away should keep it (currently it does not).
  - Test: fight, lose, black out, return — Mewtwo visible and fightable; win/catch — object disappears and `EVENT_BEAT_MEWTWO` is set.
  - Confidence: high.

### BUG-02 — Link battle can leak `wIsTrainerBattle = 1` into the next fishing battle
- [ ] **Clear the trainer flag at battle end and at the rod**
  - Where: [engine/link/cable_club.asm:279-284](engine/link/cable_club.asm#L279-L284), [engine/battle/core.asm:1082-1100](engine/battle/core.asm#L1082-L1100), [engine/battle/end_of_battle.asm:48-62](engine/battle/end_of_battle.asm#L48-L62), [engine/battle/init_battle_variables.asm:3-6](engine/battle/init_battle_variables.asm#L3-L6), [engine/items/item_effects.asm:1726-1736](engine/items/item_effects.asm#L1726-L1736), [engine/battle/core.asm:6811-6815](engine/battle/core.asm#L6811-L6815), [home/trainers2.asm:6-13](home/trainers2.asm#L6-L13), [engine/battle/read_trainer_party.asm:17-27](engine/battle/read_trainer_party.asm#L17-L27)
  - Trigger: win a link battle (or the opponent runs), leave the Cable Club, then use Old/Good/Super Rod before a normal walking encounter resets the flag. `RodResponse` stores the fish species in `wCurOpponent`, but `InitBattleCommon` still sees `wIsTrainerBattle = 1` and treats that species as a trainer class. `TrainerDataPointers`/`TrainerPicAndMoneyPointers` only have 58 entries; species IDs up to 205 read far out of bounds → garbage party/pic, glitch mon, or hang.
  - Cause: `TrainerBattleVictory` returns early for `LINK_STATE_BATTLING` before its new `wIsTrainerBattle = 0` clear; `EndOfBattle.resetVariables` and `InitBattleVariables` don't clear it either. The old `wCurOpponent >= OPP_ID_OFFSET` test was self-validating and got removed in the class-ID refactor.
  - Fix sketch: defense in depth.
    1. In `RodResponse` when a bite is stored, `xor a; ld [wIsTrainerBattle], a` (matches the old-man/Mewtwo/`OW_POKEMON` paths).
    2. Clear `wIsTrainerBattle` on every battle end: add it to `EndOfBattle.resetVariables`, or clear it before the link early-return in `TrainerBattleVictory` and in `EnemyRan`.
    3. Consider clearing it in the debug-menu battle path too ([engine/debug/debug_menu.asm:110-116](engine/debug/debug_menu.asm#L110-L116)).
  - Test: link battle win → exit → fish with each rod; battle must be a normal wild fish. Also test after a link loss and after the opponent runs. Verify map scripts that read `wIsTrainerBattle` after a normal trainer battle still work (`wWasTrainerBattle` is the sprite-removal flag).
  - Confidence: high code path; exact crash depends on the garbage tables.

### BUG-03 — Pokedex completion and diploma are unreachable
- [x] **Fix the completion threshold (and the rating table)**
  - Where: [scripts/CeladonMansion3F.asm:33](scripts/CeladonMansion3F.asm#L33), [engine/events/pokedex_rating.asm:60-74](engine/events/pokedex_rating.asm#L60-L74), [text/pokedex_ratings.asm:106-117](text/pokedex_ratings.asm#L106-L117)
  - Trigger: own all obtainable Pokémon (200 of 202), talk to the Game Designer in Celadon Mansion 3F. The check is `cp NUM_POKEMON - 1` = 201 owned; Mew and Hoopa are unobtainable by design, so 201 can never be reached. The diploma and completed-dex text never show.
  - Cause: the dex was expanded from 151 to 202 but the “discount Mew” constant was only decremented once. The rating table still uses `NUM_POKEMON + 1` with the old “150 to 151 / entirely complete” text, so 150 owned already announces a complete dex.
  - Fix sketch: use the number of obtainable dex entries (200), e.g. `NUM_POKEMON - 2` (or a named constant tied to `tools/audit_dex.py`), and rescale the rating thresholds/last text to the new total. Keep the “entirely complete” wording only for the real completion count.
  - Test: debug-set 200 owned bits and talk to the designer → text + diploma; 199 → no. Check Oak's rating at 150/199/200.
  - Confidence: high.

---

## P1 — Medium

### BUG-04 — Eevee evolution-preview buffer is 8 bytes too small
- [ ] **Enlarge or bound `wEvoDataBuffer`**
  - Where: [ram/wram.asm:913-916](ram/wram.asm#L913-L916), [data/pokemon/evos_moves.asm:1498-1508](data/pokemon/evos_moves.asm#L1498-L1508), [engine/menus/party_menu.asm:120-160](engine/menus/party_menu.asm#L120-L160)
  - Trigger: open the party menu with an evolution stone and select Eevee. The buffer is `5*4 + 3 + 1` = 24 bytes; Eevee now has seven stone evolutions + one level evolution + terminator = 32 bytes. The copy takes 24 bytes, the terminator is absent, and the scan walks into following WRAM.
  - Effect: the 7th entry (Ice Stone → Glaceon) is not found, so the preview likely says “NOT ABLE” for the stone that actually evolves it; a garbage match can also show ABLE for the wrong stone. The evolution itself still works (`TryEvolvingMon` reads the ROM table directly).
  - Fix sketch: enlarge the buffer to `7*4 + 3 + 1` = 32. It lives in a `UNION`; check the union branch sizes and WRAM0 free space first (the 56-byte padding was reclaimed earlier; see the comment around `wGameProgressFlags`). Alternatives if WRAM0 is tight: keep the 24-byte copy but stop at the terminator with a hard bound, or parse the needed entries directly from the ROM bank in the party menu instead of copying the whole list. Consider a build-time assert on the longest evolution block.
  - Test: Ice Stone on Eevee shows ABLE; Fire/Thunder/Water/Sun/Moon/Leaf still show ABLE; unrelated stones show NOT ABLE; no long WRAM scan.
  - Confidence: high (mechanics); exact on-screen text needs a runtime check.

### BUG-05 — 99-item stack split reads past the bag at the last slot
- [ ] **Stop the split scan at the terminator**
  - Where: [engine/items/inventory.asm:59-77](engine/items/inventory.asm#L59-L77)
  - Trigger: the item reaching 100 is in the **last occupied bag slot** and there is room for a new slot. `AddItemToInventory_` stores 99 and jumps to `.notAtEndOfInventory` with `hl` pointing at the next item ID, which is the `$ff` terminator. The loop reads it as an item ID (doesn't compare against `$ff` at that point), advances two bytes, and keeps scanning pairs past `wBagItems` until it finds a `$ff` byte.
  - Effect: the leftover can be added correctly if the scan happens to stop, but a byte in adjacent WRAM (money/name/options/etc.) matching `wCurItem` at the right position causes a write to an unrelated quantity byte. This is the known 99-stack bug; the split logic mitigates the direct quantity-100 overflow but not this last-slot path.
  - Fix sketch: after `ld [hli], 99`, test the byte now at `hl`:
    ```asm
    ld a, [hl]
    cp $ff
    jp z, .addNewItem
    jp .notAtEndOfInventory
    ```
    `.addNewItem` expects `hl` at the terminator and pops the saved inventory pointer, so this is a small change. Alternatively restructure the loop to test the terminator at the top.
  - Test: 99 Potions in the last slot, add one → 99 + 1 in a new slot; no reads past `wBagItems`. Also test 99 in a middle slot, two existing stacks, and a full bag.
  - Note: the code is unchanged from upstream, so this is a known bug still present, not a custom regression.

---

## P2 — Minor / cosmetic

### BUG-06 — Fuchsia Gym pre-Champion rematch repeats the badge/TM gift
- [x] **Gate Fuchsia's post-battle gift on prior defeat, not Champion status**
  - Where: [scripts/FuchsiaGym.asm:48-54](scripts/FuchsiaGym.asm#L48-L54), [scripts/FuchsiaGym.asm:147-169](scripts/FuchsiaGym.asm#L147-L169)
  - Trigger: beat Koga, talk again immediately, accept the rematch, win before the Elite Four. The post-battle script checks `EVENT_PLAYER_IS_CHAMPION`; pre-Champion it runs `FuchsiaGymReceiveTM06` again: another TM06, badge text, and the trainer range is set again.
  - Fix sketch: mirror the other gyms and check `EVENT_BEAT_KOGA` (or `EVENT_GOT_TM06`) at the top of `FuchsiaGymKogaPostBattleScript`: first win → award; later wins → rematch text. Decide separately whether the rematch offer itself should be Champion-gated; if so, add that to the `.KogaRematch` text path too.
  - Test: beat Koga, rematch before the E4 → no second TM06/badge text; after becoming Champion → rematch text only.
  - Confidence: high.

### BUG-07 — Fighting Dojo reward skipped and master repeatable if already Champion
- [x] **Choose the Dojo branch by reward state, not Champion status**
  - Where: [scripts/FightingDojo.asm:74-91](scripts/FightingDojo.asm#L74-L91), [scripts/FightingDojo.asm:118-140](scripts/FightingDojo.asm#L118-L140)
  - Trigger: become Champion, then defeat the Karate Master for the first time. The post-battle script takes the `EVENT_PLAYER_IS_CHAMPION` branch: it prints the rematch text and sets `EVENT_BEAT_FIGHTING_DOJO_REMATCH`, but never sets `EVENT_BEAT_KARATE_MASTER..TRAINER_3` and never prints “I will give you a Pokémon”. The default script still sees `EVENT_BEAT_KARATE_MASTER` clear, so the master can be re-battled indefinitely; the balls still work.
  - Fix sketch: branch on `EVENT_BEAT_KARATE_MASTER` (or a dedicated “reward given” event) instead of `EVENT_PLAYER_IS_CHAMPION`. On the first win, always set the trainer range and show the reward text; on later wins, show the rematch text. Confirm the intended Champion gating for the rematch separately.
  - Test: Champion first, beat the master once → reward text and range set, master no longer re-battlable; subsequent rematch if intended.
  - Confidence: high.

### BUG-08 — Elevator floor menus print garbage descriptions
- [x] **Stop the special-list description lookup from indexing item descriptions**
  - Where: [home/list_menu.asm:186-192](home/list_menu.asm#L186-L192), [data/items/descriptions.asm:1-33](data/items/descriptions.asm#L1-L33), [engine/events/elevator.asm:15-20](engine/events/elevator.asm#L15-L20)
  - Trigger: open any elevator floor menu. `DisplayListMenuID` now calls `PrintDescription` for every list, but `PrintItemDescription` only returns early for `PCPOKEMONLISTMENU`. Floor entries are item IDs `FLOOR_B2F..FLOOR_B4F` ($56–$63) while `ItemDescriptions` has 85 entries ($01–$55), so the 4-byte-stride lookup runs into `_MasterBallDescription` text and prints fragments (“Wil”, “l ca”, etc.). Higher floors can start on text-command bytes.
  - The badge house (same `SPECIALLISTMENU`) is fine: badge IDs are real item IDs with descriptions.
  - Fix sketch: pick one:
    - A: add 14 floor description records to the end of `ItemDescriptions` (they line up with IDs $56–$63), e.g. “Goes to B2F.” This keeps the existing index path in bounds.
    - B: skip `PrintDescription` unless `wListMenuID` is `ITEMLISTMENU`/`PRICEDITEMLISTMENU`, and special-case the badge house if badge descriptions are wanted.
    - C: have `PrintItemDescription` bounds-check against `NUM_ITEMS + NUM_FLOORS`.
  - Test: every elevator (Celadon, Silph, Rocket Hideout) shows sane text or no description box; badge house still shows badge descriptions.
  - Confidence: high for the wrong lookup; severity is cosmetic-ish but the read can land on text commands.

### BUG-09 — `BrunoAI` uses a Hyper Potion at full HP
- [ ] **Check the HP-fraction result before using the potion**
  - Where: [engine/battle/trainer_ai.asm:422-427](engine/battle/trainer_ai.asm#L422-L427)
  - Trigger: any Bruno battle; the 50% roll passes. `AICheckIfHPBelowFraction` returns carry if below the fraction, but the code falls through to `jp AIUseHyperPotion` regardless (missing `ret nc`).
  - Fix sketch: add `ret nc` (or `jp nc, .noPotion`) after `call AICheckIfHPBelowFraction`; optionally restore an X Defend fallback if that was the upstream intent.
  - Test: Bruno at full HP after the 50% roll does not waste a potion.
  - Confidence: confirmed.

### BUG-10 — Wrap countdown freezes while the trapped mon has a Substitute
- [ ] **Decide and fix the Substitute/wrap interaction**
  - Where: [engine/battle/core.asm:569-590](engine/battle/core.asm#L569-L590)
  - Trigger: a Pokémon trapped by BIND/WRAP/FIRE_SPIN/CLAMP uses Substitute (allowed while trapped). `HandleWrapDamage` returns at `HAS_SUBSTITUTE_UP` before decrementing the counter, and models no damage to the Substitute. The target stays unable to switch/run until the Substitute breaks.
  - Fix sketch: decrement the count before the Substitute test (and release when it hits 0), or model the 1/16 damage against the Substitute’s HP. Pick the intended Gen 2 behaviour first; the current code does neither.
  - Test: enemy wraps the player, player uses Substitute, count still ticks down and releases; Substitute takes residual damage if that is intended.
  - Confidence: confirmed mechanics; design choice needed.

### BUG-11 — Priority lookup reads past the table for move `$ff`
- [ ] **Handle `CANNOT_MOVE`/`$ff` before the priority scan**
  - Where: [engine/battle/core.asm:446-480](engine/battle/core.asm#L446-L480), [data/battle/priority_moves.asm:10](data/battle/priority_moves.asm#L10)
  - Trigger: link battle where the opponent sent `LINKBATTLE_NO_ACTION`, or any case where Haze set the target's selected move to `$ff`. The scan's `cp b` matches the `db -1` terminator and reads the next ROM byte (the `$21` opcode of `HandlePoisonBurnLeechSeed`) as priority 33. Deterministic, but wrong turn order.
  - Fix sketch: if the selected move is `$ff`, use the default priority 7 and skip the table (or check `cp $ff` before the terminator match).
  - Test: link no-action ordering; Haze then next-turn priority.
  - Confidence: confirmed.

### BUG-12 — TM machine list scroll state is not managed
- [x] **Save/reset/restore `wListScrollOffset` like the mart**
  - Where: [engine/events/tm_machine.asm:1-22](engine/events/tm_machine.asm#L1-L22), [engine/events/tm_machine.asm:104-110](engine/events/tm_machine.asm#L104-L110), compare [engine/events/pokemart.asm:2-9](engine/events/pokemart.asm#L2-L9)
  - Trigger: open the Indigo Plateau Lobby TM machine after any list menu left a nonzero scroll offset. The machine sets `wCurrentMenuItem = 0` but never resets `wListScrollOffset`, so the list opens mid-scroll. On exit it writes the stale `wSavedListScrollOffset` back into `wListScrollOffset`, which the next list menu can inherit.
  - Fix sketch: at entry, copy `wListScrollOffset` to `wSavedListScrollOffset` and zero `wListScrollOffset`; on exit restore. Mirror the mart exactly.
  - Test: scroll the bag, close, open the TM machine, check the initial row; then open the bag again and check its scroll.
  - Confidence: high.

### BUG-13 — Duplicate `(party mon, move slot)` rows in the special-moves table
- [ ] **Fix the overwritten special moves**
  - Where: [data/trainers/special_moves.asm:71-73](data/trainers/special_moves.asm#L71-L73) (Blaine 2), [161-162](data/trainers/special_moves.asm#L161-L162), [175-176](data/trainers/special_moves.asm#L175-L176), [186-187](data/trainers/special_moves.asm#L186-L187) (Rival3 1/2/3)
  - Trigger: Blaine rematch, or the Champion battle with any starter. The writer in [engine/battle/read_trainer_party.asm:87-118](engine/battle/read_trainer_party.asm#L87-L118) applies entries in order, so the second write to the same slot overwrites the first. Ninetales ends up with Confuse Ray instead of Flamethrower.
  - Fix sketch: change the second entry’s move slot from 1 to 2 (verify the intended Ninetales/Blaine-rematch movesets first), or reorder/remove the duplicate. Then re-run a duplicate-slot check on the table.
  - Test: inspect Blaine’s rematch Ninetales and the Champion Ninetales moves in battle; all intended moves present.
  - Confidence: confirmed (script that found all duplicates and party sizes is in the scan notes).

### BUG-14 — Mareep hides on blackout but the shears still trigger an empty-tile battle
- [ ] **Restore the Mareep sprites on blackout (or keep them visible until an outcome)**
  - Where: [scripts/Route12.asm:24-43](scripts/Route12.asm#L24-L43), [scripts/Route16.asm:24-43](scripts/Route16.asm#L24-L43), [engine/items/item_effects.asm:1623-1652](engine/items/item_effects.asm#L1623-L1652)
  - Trigger: shear the Mareep, lose/blackout, return. The object stays hidden (`HideObject` before the battle, `$ff` branch resets without restoring); `EVENT_FIGHT_*` was reset, `EVENT_BEAT_*` is clear. Using the shears at the coordinates sets `EVENT_FIGHT_*` again and starts a wild battle from an empty tile.
  - Fix sketch: in the `wIsInBattle == $ff` branch, `ShowObject` the corresponding `TOGGLE_ROUTE_12_MAREEP` / `TOGGLE_ROUTE_16_MAREEP`, or move the `HideObject` call into the non-blackout outcome. The encounter is not lost today, only the sprite presentation.
  - Test: shear, lose, return → sprite visible and shearable; win/catch → hidden.
  - Confidence: high.

### BUG-15 — Cinnabar Blaine rematch skips the end-of-battle text setup
- [x] **Mirror the other gym rematch setup**
  - Where: [scripts/CinnabarGym.asm:244-262](scripts/CinnabarGym.asm#L244-L262), compare [scripts/PewterGym.asm:136-171](scripts/PewterGym.asm#L136-L171)
  - Trigger: Blaine rematch. The path sets `wCurOpponent`/`wTrainerNo`/`wIsTrainerBattle` but does not set `BIT_TALKED_TO_TRAINER`/`BIT_PRINT_END_BATTLE_TEXT` or call `SaveEndBattleTextPointers`, so Blaine’s rematch defeat line is not printed.
  - Fix sketch: add the same status-flag sets and `SaveEndBattleTextPointers` before starting the rematch (with the rematch win/lose text), and set `wSpriteIndex` the way the other gyms do.
  - Test: win the Blaine rematch → his defeat text prints.
  - Confidence: high.

### BUG-16 — Route 15 starter menu draws Squirtle outside its box
- [ ] **Fix the box height or the row spacing**
  - Where: [scripts/Route15Gate2F.asm:49-63](scripts/Route15Gate2F.asm#L49-L63), [scripts/Route15Gate2F.asm:110-127](scripts/Route15Gate2F.asm#L110-L127)
  - Trigger: talk to the Route 15 gate aide with 50+ owned species. The box is drawn with height 6 (rows 0–5); the three options are printed at rows 2/4/6, so Squirtle and the third cursor row are outside the border.
  - Fix sketch: draw the box with height 7 (rows 0–6), or move the third option to row 5 and adjust `wTopMenuItemY`/spacing so the cursor still lands on each row.
  - Test: open the menu, move the cursor through all three options; everything inside the border.
  - Confidence: high.

### BUG-17 — New text that overflows or overwrites itself
- [x] **Fix the overlong/two-`line` texts**
  - [text/VermilionGym_2.asm:83](text/VermilionGym_2.asm#L83): `"Are you scared, kid?"` = 20 chars; guaranteed overflow. Split into `text` + `line`.
  - [text/CeladonGym.asm:256-257](text/CeladonGym.asm#L256-L257): `line` used twice; the second line overwrites the first. Change the second to `cont`.
  - [data/text/text_4.asm:258](data/text/text_4.asm#L258): `"INSUFFICENT FUNDS."` = 18 chars on the ▼ row; shorten and fix the spelling (“INSUFFICIENT”).
  - [text/SaffronGym.asm:68](text/SaffronGym.asm#L68): `"It is a ghost type"` = 18 chars followed by `cont`; shorten or change the continuation to a `line`/`para` so the arrow does not eat the last char.
  - [data/text/text_2.asm:1062](data/text/text_2.asm#L1062): “hurt by FIRE SPIN!” = 18 chars + prompt; shorten.
  - Test in-game with the text box; remember the ▼ occupies column 18 of the bottom row.

### BUG-18 — Stale Poké Flute text after the flute was removed
- [x] **Rewrite the shears/Fuji/Celadon Pokécenter lines**
  - [data/text/text_6.asm:94-100](data/text/text_6.asm#L94-L100): `_UsedShearsNoEffectText` says “Played the # FLUTE. Now, that’s a catchy tune!” — rewrite for the shears (e.g. “The shears had no effect.”).
  - [text/MrFujisHouse.asm:78](text/MrFujisHouse.asm#L78): “FLUTE helped you?” — update to the shears.
  - [text/CeladonPokecenter.asm:2](text/CeladonPokecenter.asm#L2): NPC still describes the removed Poké Flute.
  - Test: use the shears away from Mareep; talk to Mr. Fuji after the gift; talk to the Celadon Pokécenter NPC.

### BUG-19 — Pokedex rating says “entirely complete” from 150 owned
- [x] **Rescale the rating buckets/text** (fixed with BUG-03)
  - Where: [engine/events/pokedex_rating.asm:60-74](engine/events/pokedex_rating.asm#L60-L74), [text/pokedex_ratings.asm:106-117](text/pokedex_ratings.asm#L106-L117)
  - Trigger: own 150+ of 202. The last bucket is `NUM_POKEMON + 1` (203) but its text is the old “150 to 151 / entirely complete” line, so 150 owned already reads as complete.
  - Fix sketch: add buckets for the new range (or at least change the final threshold/text to the obtainable total) and keep “entirely complete” for real completion. Tie this to BUG-03.
  - Test: check Oak’s rating at 150/199/200 owned.
  - Note: the bucket is not an exact full-dex check; it is cosmetic but misleading.

### BUG-20 — Possible naming-screen palette inheritance (verify first)
- [ ] **Investigate `SET_PAL_NAMING_SCREEN`**
  - Where: [engine/menus/naming_screen.asm:92-94](engine/menus/naming_screen.asm#L92-L94), [color/color.asm:917-928](color/color.asm#L917-L928), compare `SetPal_Generic` at [color/color.asm:581-608](color/color.asm#L581-L608)
  - Trigger: enter the naming screen after the party menu or a map with a different tileset. `SetPal_NameEntry` only sets overworld sprite palettes and clears the sprite palette map; it does not load BG palettes, clear `W2_TilesetPaletteMap`, set `W2_StaticPaletteMapChanged`, or set `W2_ForceBGUpdate`.
  - Fix sketch: only after reproducing — either use `SET_PAL_GENERIC` for the naming screen or make `SetPal_NameEntry` perform the missing BG palette setup.
  - Test: enter naming from several screens/tilesets and compare colors.
  - Confidence: medium; visual only.

---

## P3 — Latent

### BUG-21 — StarterDex wipes the whole owned-dex array
- [ ] **Make the temporary dex flags surgical**
  - Where: [engine/events/starter_dex.asm:5-24](engine/events/starter_dex.asm#L5-L24)
  - It fills all 26 bytes of `wPokedexOwned` with `$FF`, calls `ShowPokedexData`, then clears all 26 bytes. Gated to the pre-starter ball inspection, so it is currently safe, but any later call would erase the player’s owned flags.
  - Fix sketch: set only the bit for the species being shown (`wPokedexNum`) and restore that byte/bit, or save the whole array to a scratch buffer and restore it.

### BUG-22 — Map-trainer lose end-battle pointer is garbage
- [ ] **Restore the register contract in `TalkToTrainer`**
  - Where: [home/trainers.asm:47-60](home/trainers.asm#L47-L60), [home/trainers.asm:104-113](home/trainers.asm#L104-L113)
  - Upstream’s offset-`$a` special case returned the second end-battle pointer in `DE`; the hack removed it so offset `$a` returns in `HL`, but `TalkToTrainer` still does `push de`/`pop de`, so `wEndBattleLoseTextPointer` is stale. Currently dead data because `PrintEndBattleText` only runs on victory (`wBattleResult == 0`), and the macro stores the same text for both end-battle slots.
  - Fix sketch: `push hl`/`pop de` around the second read (or restore the old `DE` return for offset `$a`). Low priority.

### BUG-23 — `GetMonIconID` reads one byte before `MonPartyData` for dex 0
- [ ] **Bounds-check the icon conversion**
  - Where: [engine/gfx/mon_icons.asm:130-141](engine/gfx/mon_icons.asm#L130-L141)
  - Fossil/ghost species have dex number 0; `dec a` becomes `$FF` and reads before the table. It happens to return the ghost icon (`ICON_GHOST`), not a crash, and no normal party/naming/trade path uses those species.
  - Fix sketch: if `IndexToPokedex` returns 0, return a defined fallback icon (e.g. `ICON_GHOST`) before the `dec a`.

### BUG-24 — Malformed MissingNo dex entry
- [ ] **Give the internal slots a valid dex-entry structure**
  - Where: [data/pokemon/dex_entries.asm:1557-1561](data/pokemon/dex_entries.asm#L1557-L1561)
  - `MissingNoDexEntry` has `db "???@"`, height/weight, then a raw Japanese string with no `text_far`/`text_end`. `PokedexEntryPointers` points the three internal species here; if the page were ever shown, `TextCommandProcessor` would interpret raw bytes. Unreachable through the dex menu (dex 1–202 only).
  - Fix sketch: use a proper `text_far _... / text_end` description, or point the internal slots at a safe existing entry.

### BUG-25 — Route 16 shears coordinates may not cover north/south
- [ ] **Verify the map geometry**
  - Where: [engine/items/item_effects.asm:1656-1661](engine/items/item_effects.asm#L1656-L1661)
  - Only `(27,10)` and `(25,10)` (east/west of the Mareep at 26,10) are accepted. If the Cycling Road lets the player stand north or south of it, shears there say “no effect”.
  - Fix sketch: verify on the map; add `(26,9)`/`(26,11)` if reachable and desired.

---

## Known pokered bugs still present

From the archived pokered wiki, verified against this tree. Fix sketches are the standard wiki fixes where known; confirm against the current code. These are not custom regressions unless noted.

### Battle engine

- [ ] **100%-accurate moves miss 1/256** — [engine/battle/core.asm:5478-5482](engine/battle/core.asm#L5478-L5482). `cp b / jr nc, .moveMissed` counts equality as a miss; a 255 accuracy roll can still roll 255.
- [ ] **Guaranteed critical hits fail 1/256** — [engine/battle/core.asm:4678-4683](engine/battle/core.asm#L4678-L4683). Same equality test; `b` is capped at `$FF`.
- [ ] **Substitute can leave the user at 0 HP** — [engine/battle/move_effects/substitute.asm:32-40](engine/battle/move_effects/substitute.asm#L32-L40). Only carry/underflow branches; exactly max/4 HP subtracts to 0 and sets the substitute.
- [ ] **Drain/Dream Eater hit through Substitute** — [engine/battle/core.asm:5407-5414](engine/battle/core.asm#L5407-L5414). `CheckTargetSubstitute` overwrites A with 0/1, so the effect comparisons never match (the Swift fix broke this).
- [ ] **Max Ether/Max Elixir ignore PP-Up bits** — [engine/items/item_effects.asm:1938-1948](engine/items/item_effects.asm#L1938-L1948). `.fullyRestorePP` compares the raw PP byte; the normal Ether path is already masked.
- [ ] **Counter reuses stale/shared damage** — [engine/battle/core.asm:4731-4736](engine/battle/core.asm#L4731-L4736). `wDamage` is shared and can be from another hit/switch/battle.
- [ ] **Bide link battles clear only the high byte** — [engine/battle/core.asm:884-885](engine/battle/core.asm#L884-L885).
- [ ] **Psywave can do 0 damage on one side only (link desync)** — [engine/battle/core.asm:4807-4814](engine/battle/core.asm#L4807-L4814) (player rerolls 0) vs [4923-4930](engine/battle/core.asm#L4923-L4930) (enemy allows 0).
- [ ] **Fly/Dig full paralysis/confusion leaves invulnerability on** — [engine/battle/core.asm:3628-3629](engine/battle/core.asm#L3628-L3629), [5977-5978](engine/battle/core.asm#L5977-L5978). `INVULNERABLE` is only cleared when the charging move executes.
- [ ] **Healing moves fail at 255/511 HP gaps** — [engine/battle/move_effects/heal.asm:13-20](engine/battle/move_effects/heal.asm#L13-L20). High-byte `cp` carry is ignored.
- [ ] **Switch-out text underflows when HP was gained** — [engine/battle/common_text.asm:176-215](engine/battle/common_text.asm#L176-L215).
- [ ] **Haze curing freeze during Hyper Beam recharge can permanently prevent attacking** — [engine/battle/move_effects/haze.asm:24-31](engine/battle/move_effects/haze.asm#L24-L31). `NEEDS_TO_RECHARGE` is not cleared; the `$ff` selected move bails before the Hyper Beam check.
- [ ] **CooltrainerF always switches at 10–20% HP** — [engine/battle/trainer_ai.asm:343-350](engine/battle/trainer_ai.asm#L343-L350). The dead 25% roll was deleted, not fixed; add `cp 25 percent + 1 / ret nc` if the intended behavior is the wiki fix.
- [ ] **Ghost Marowak marked seen without the Silph Scope** — [engine/battle/core.asm:6255-6263](engine/battle/core.asm#L6255-L6263). `LoadEnemyMonData` marks `wEnemyMonSpecies2` seen before the ghost checks.
- [ ] **Move-learning/swap sound uses the loaded audio bank** — [engine/pokemon/learn_move.asm:211-213](engine/pokemon/learn_move.asm#L211-L213), [engine/pokemon/learn_move.asm:188](engine/pokemon/learn_move.asm#L188). Switch to `BANK(SFX_Swap_1)`/the correct jingle for the context.
- [ ] **Status-curing items overwrite battle stats/badge boosts** — [engine/items/item_effects.asm:900-911](engine/items/item_effects.asm#L900-L911). Copies raw party stats over `wBattleMonStats`; the removed `DoubleOrHalveSelectedStats` was a no-op, so this is still live.
- [ ] **AI healing items leave enemy HUD/status stale** — [engine/battle/trainer_ai.asm:546-552](engine/battle/trainer_ai.asm#L546-L552), [622-639](engine/battle/trainer_ai.asm#L622-L639). Only `UpdateHPBar2` is called; the status icon/color is not redrawn.
- [ ] **Select-swap while Transformed swaps the real party moves** — [engine/battle/core.asm:2901-2950](engine/battle/core.asm#L2901-L2950). The menu shows the transformed list but indices are applied to the real party moves.
- [ ] **Minimize/Substitute + party status screen corrupts the enemy battle pic** — [engine/battle/core.asm:2498-2520](engine/battle/core.asm#L2498-L2520). The animation reload uses a stale `hWhoseTurn`; wiki fix is `ld a,1 / ldh [hWhoseTurn],a` before the reload.
- [ ] **Wild victory music plays before the player faint check** — [engine/battle/core.asm:923-938](engine/battle/core.asm#L923-L938). If the last player mon and wild enemy faint together, the win music plays and the loss path follows.
- [ ] **Transformed move swap has no SFX** — same swap code as above; only the party-menu swap plays `SFX_SWAP`.

### Overworld / scripts

- [ ] **Cinnabar left-shore half-blocks load grass encounters** — [engine/battle/wild_encounters.asm:28](engine/battle/wild_encounters.asm#L28), comment [71-72](engine/battle/wild_encounters.asm#L71-L72). The MissingNo. route; the code explicitly acknowledges the left-shore case.
- [ ] **Viridian Forest star grass cannot trigger encounters** — [engine/battle/wild_encounters.asm:28-33](engine/battle/wild_encounters.asm#L28-L33). Only `wGrassTile` is accepted; the star-grass tile is not.
- [ ] **Bicycle clerk leaves instant text on the B exit** — [scripts/BikeShop.asm:52-76](scripts/BikeShop.asm#L52-L76). `BIT_NO_TEXT_DELAY` is cleared only on the non-B path.
- [ ] **Route 16 sign not readable from directly in front (medium confidence)** — [data/maps/objects/Route16.asm:26](data/maps/objects/Route16.asm#L26).
- [ ] **Route 14 cut tree can return and block the player** — [engine/overworld/player_state.asm:257-296](engine/overworld/player_state.asm#L257-L296). The front-tile read can use stale VRAM/map data at the screen edge.
- [ ] **Invisible PCs/bench characters on Celadon Hotel and Safari rest houses** — [data/events/hidden_events.asm](data/events/hidden_events.asm), [data/events/bench_guys.asm:14](data/events/bench_guys.asm#L14).
- [ ] **Ledge jump can land on an NPC** — [engine/overworld/ledges.asm:38-55](engine/overworld/ledges.asm#L38-L55).
- [ ] **Falling through a hole while biking does not restore map music** — [engine/overworld/player_animations.asm:204-224](engine/overworld/player_animations.asm#L204-L224).
- [ ] **Item Finder misses items at coordinate 0** — [engine/items/itemfinder.asm:27-52](engine/items/itemfinder.asm#L27-L52). Latent: no hidden item at x=0/y=0 exists.
- [ ] **NPC bounds checks are broken** — [engine/overworld/movement.asm:657](engine/overworld/movement.asm#L657), [669](engine/overworld/movement.asm#L669).
- [ ] **Bottom row/rightmost column treated as offscreen** — [engine/overworld/movement.asm:625-630](engine/overworld/movement.asm#L625-L630).
- [ ] **NPC movement delay 0 wraps to 256** — [engine/overworld/movement.asm:361-365](engine/overworld/movement.asm#L361-L365).
- [ ] **Route 12 gate binoculars stop NPCs while A is held** — [scripts/Route12Gate2F.asm:68-79](scripts/Route12Gate2F.asm#L68-L79).
- [ ] **Level-up evolution can trigger a stone evolution from a stale `wCurItem`** — [engine/pokemon/evos_moves.asm:97-103](engine/pokemon/evos_moves.asm#L97-L103). Add a real “stone was used” guard instead of comparing `wCurItem`.
- [ ] **Ghost Marowak can be skipped with a Poké Doll** — [engine/items/item_effects.asm:1553-1559](engine/items/item_effects.asm#L1553-L1559), [scripts/PokemonTower6F.asm:63-66](scripts/PokemonTower6F.asm#L63-L66). The post-battle script treats `wBattleResult == 0` as defeat.
- [ ] **Poisoned fainted party: walk with no usable mon** — [engine/events/poison.asm:11-12](engine/events/poison.asm#L11-L12), [97](engine/events/poison.asm#L97). Save/reset before the fourth step.
- [ ] **Surf water-collision branch is wrong** — [home/overworld.asm:1906](home/overworld.asm#L1906). `jr nz, .checkIfNextTileIsPassable ; bug?`.
- [ ] **Dungeon battle-transition map list is incomplete** — [data/maps/dungeon_maps.asm:1-27](data/maps/dungeon_maps.asm#L1-L27).
- [ ] **Tile-pair collision does not advance past the first matched tile** — [home/overworld.asm:1327-1336](home/overworld.asm#L1327-L1336). `.currentTileMatchesFirstInPair` uses `ld a,[hl]` and loops without advancing.
- [ ] **Trainer-Fly: stale `wCurOpponent`/`wIsTrainerBattle` on map load** — [engine/overworld/clear_variables.asm:1-20](engine/overworld/clear_variables.asm#L1-L20). Clear both; note the link-battle leak above is a different path.
- [ ] **Gym/Dojo statues count as shore/water** — [engine/items/item_effects.asm:2689-2705](engine/items/item_effects.asm#L2689-L2705), [data/tilesets/water_tilesets.asm:5-6](data/tilesets/water_tilesets.asm#L5-L6).
- [ ] **Following Oak into the lab can stick the player in a wall** — [scripts/PalletTown.asm:123-131](scripts/PalletTown.asm#L123-L131).
- [ ] **Route 8 gate guard faces left instead of up** — [scripts/Route8Gate.asm:31](scripts/Route8Gate.asm#L31).
- [ ] **Lift Key can be grabbed immediately** — [scripts/RocketHideoutB4F.asm:189-198](scripts/RocketHideoutB4F.asm#L189-L198).
- [ ] **Silph Co. 11F elevator** — [data/tilesets/door_tile_ids.asm](data/tilesets/door_tile_ids.asm). No `INTERIOR` entry with `door_tiles $04, $15`.
- [ ] **Mr. Fuji’s house cannot be left immediately after the warp** — [scripts/PokemonTower7F.asm:67-85](scripts/PokemonTower7F.asm#L67-L85). The extra warp-exit bit is not set.
- [ ] **Pokémon Tower 2F rival coord terminator is `$0F`, not `-1`** — [scripts/PokemonTower2F.asm:64](scripts/PokemonTower2F.asm#L64).
- [ ] **Mt. Moon B2F battle lock via Escape Rope/Teleport/Dig** — [scripts/MtMoonB2F.asm:6-19](scripts/MtMoonB2F.asm#L6-L19). Check `BIT_ESCAPE_WARP` before setting `BIT_NO_BATTLES`.
- [ ] **Holding A keeps dialogue/menus open** — [home/text_script.asm:100-116](home/text_script.asm#L100-L116), [engine/menus/start_sub_menus.asm:641-647](engine/menus/start_sub_menus.asm#L641-L647).
- [ ] **Safari Zone escape (partial)** — gate exit coordinates are fixed, but a blackout does not clear `EVENT_IN_SAFARI_ZONE`: [home/text_script.asm:213-232](home/text_script.asm#L213-L232), [engine/events/black_out.asm](engine/events/black_out.asm).
- [ ] **99-item stack last-slot scan** — see BUG-05; the split exists but the terminator path reads past `wBagItems`.
- [ ] **Lucky slot machine `cp $7` allows index 0** — [scripts/GameCorner.asm:14-23](scripts/GameCorner.asm#L14-L23). Wiki fix: `cp $8`.
- [ ] **Slot-machine early-stop logic** — [engine/slots/slot_machine.asm:301-339](engine/slots/slot_machine.asm#L301-L339); the `jr c` never triggers and the middle/bottom stop-early logic is wrong.
- [x] **Oak’s five Poké Ball speech overwrites a line** — [text/OaksLab.asm:140-142](text/OaksLab.asm#L140-L142). Change the second `line` to `cont`.
- [x] **Raichu trade says the Raichu evolved** — [data/events/trades.asm:25](data/events/trades.asm#L25), [data/text/text_7.asm:140-146](data/text/text_7.asm#L140-L146). Use a non-evolution dialogue set.
- [ ] **Route 8 “chem?” truncation** — [text/Route8.asm:4](text/Route8.asm#L4). Subjective text fix.
- [ ] **18th character eaten by ▼** — by design of the text box; the new offenders are in BUG-17.

### Graphics / audio / menus

- [ ] **Fainted-mon/trainer slide tearing** — [engine/battle/core.asm:1344-1389](engine/battle/core.asm#L1344-L1389), [1398-1432](engine/battle/core.asm#L1398-L1432). Clear `hAutoBGTransferEnabled` during the copy and restore it before the delay.
- [ ] **Backsprite lower-right tile deleted while sliding off** — [engine/battle/animations.asm:1842-1848](engine/battle/animations.asm#L1842-L1848). Bounds `$61`/`$30` should be `$62`/`$31`.
- [ ] **Double Edge opponent animation** — [data/battle_anims/subanimations.asm:549-550](data/battle_anims/subanimations.asm#L549-L550). `SUBANIMTYPE_COORDFLIP` should be `SUBANIMTYPE_HVFLIP`.
- [ ] **15th NPC sprite wrong initial position** — [home/text_script.asm:31-42](home/text_script.asm#L31-L42), [engine/overworld/turn_sprite.asm:1-22](engine/overworld/turn_sprite.asm#L1-L22). Uses `hCurrentSpriteOffset` (stuck at 15) instead of the sprite index.
- [ ] **Pewter Gym youngster sprite misalignment** — [scripts/PewterCity.asm:135](scripts/PewterCity.asm#L135). `$40` should be `$50`.
- [ ] **Pitch-slide engine borrows the wrong high byte** — [audio/engine_1.asm:1189-1201](audio/engine_1.asm#L1189-L1201), plus engine_2/engine_3 equivalents. Load `wChannelPitchSlideTargetFrequencyHighBytes` before the borrow.
- [ ] **Oak’s lab music channel cut off** — [scripts/OaksLab.asm:122](scripts/OaksLab.asm#L122). Add `call DelayFrame` before `PlayDefaultMusic`.
- [ ] **Hidden-item jingle cut off by fadeout** — [engine/events/hidden_items.asm:23-41](engine/events/hidden_items.asm#L23-L41). Save/clear/restore `wAudioFadeOutControl` around `SFX_GET_ITEM_2`.
- [ ] **Route 15 binocular Articuno cry distorted** — [engine/events/hidden_events/route_15_binoculars.asm:7-10](engine/events/hidden_events/route_15_binoculars.asm#L7-L10). Move the cry after `AnimateSendingOutMon` (the wiki fix assumes `DisplayMonFrontSpriteInBox` plays it; it currently does not here).
- [ ] **Slot machine loads 4 extra tiles** — [engine/slots/slot_machine.asm:854](engine/slots/slot_machine.asm#L854), [864](engine/slots/slot_machine.asm#L864). `$1c` should be `$18`.
- [ ] **Healing-machine PC copies 3 tiles** — [engine/overworld/healing_machine.asm:6](engine/overworld/healing_machine.asm#L6). `3` should be `2`.
- [ ] **Splash screen adds 2 extra invisible stars** — [engine/movie/splash.asm:127](engine/movie/splash.asm#L127). `add 6` should be `add 4`.
- [ ] **Trainer Card DMG transition** — [engine/menus/start_sub_menus.asm:453-471](engine/menus/start_sub_menus.asm#L453-L471). Wiki fix adds `Delay3`; **N/A at runtime** because the ROM is CGB-only and `RunDmgError` rejects DMG ([home.asm:11-23](home.asm#L11-L23)).
- [ ] **OAM/V-Blank corruption** — **N/A**: no `hSkipOAMUpdates` exists, but OAM is built in `DelayFrameHook` rather than V-Blank ([home.asm:167-205](home.asm#L167-L205), [home/vblank.asm:34-46](home/vblank.asm#L34-L46)). Residual theoretical risk only.
- [ ] **ED tile bank comment** — [engine/menus/naming_screen.asm:317-322](engine/menus/naming_screen.asm#L317-L322). Poor-emulator compatibility only; `BANK("Home")` vs `BANK(ED_Tile)`.

### Text / items

- [ ] **Move-learning sound wrong bank** — see battle list; `sound_get_item_1` outside battle plays Get-Item instead of Level-Up ([engine/pokemon/learn_move.asm:188](engine/pokemon/learn_move.asm#L188)).
- [ ] **Oak’s five Poké Balls speech** — see overworld list.
- [ ] **Raichu trade** — see overworld list.
- [ ] **Route 8 battle message** — see overworld list.
- [ ] **Status-cure stat reset** — see battle list.
- [ ] **18th-character ▼** — by design; fixed content is in BUG-17.

---

## Already fixed / do not chase

- Focus Energy crit penalty — [engine/battle/core.asm:4655-4676](engine/battle/core.asm#L4655-L4676) now doubles twice.
- Blaine AI potion HP check — [engine/battle/trainer_ai.asm:382-388](engine/battle/trainer_ai.asm#L382-L388).
- Transformed capture treated as Ditto — the `ld a,DITTO / ld [wEnemyMonSpecies2],a` store was removed from `ItemUseBall`.
- GetName’s TM/HM diversion for monsters — [home/names2.asm:24-38](home/names2.asm#L24-L38), with list-state save/restore in [home/names.asm:56-70](home/names.asm#L56-L70).
- Hidden 40-coin stash pays 40 — [engine/events/hidden_items.asm:80-92](engine/events/hidden_items.asm#L80-L92).
- Lt. Surge trash reroll — [engine/events/hidden_events/vermilion_gym_trash.asm:61-67](engine/events/hidden_events/vermilion_gym_trash.asm#L61-L67).
- NPC movement-byte carry — [engine/overworld/movement.asm:120-125](engine/overworld/movement.asm#L120-L125).
- Struggle PP-Up bits — [engine/battle/core.asm:2886-2887](engine/battle/core.asm#L2886-L2887).
- Trainer end-battle win pointer (observable) — [home/trainers.asm:107-113](home/trainers.asm#L107-L113); the lose pointer remains latent (BUG-22).
- Escape Rope spin — [engine/overworld/player_animations.asm:2](engine/overworld/player_animations.asm#L2), [94](engine/overworld/player_animations.asm#L94).
- Exp. All semantics — rewritten to the intended 50/50 fighters vs sat-out split (fainted excluded) in [engine/battle/core.asm:945-972](engine/battle/core.asm#L945-L972), [engine/battle/experience.asm:307-405](engine/battle/experience.asm#L307-L405). Arithmetic verified clean.
- Nidorino/Nidorina intro cry — the intro now uses Charizard and `sound_cry_charizard`.
- Pewter Museum fossil cries — already silent (no `PlayCry` in `DisplayMonFrontSpriteInBox`).
- 99-stack direct quantity-100 overflow — mitigated by the split, but see BUG-05 for the remaining last-slot edge.
- `%` glyph — the battle menu writes tile `$DF`, and the custom `gfx/gs/font.1bpp` tile $DF is a percent sign; the charmap name “っ” is vestigial. Not a bug.
- Options-menu Up-from-TEXT-SPEED cursor — verified correct; it lands on the Cancel cursor, not Exp Share.

---

## Verified clean

Area-by-area checks that found no defects (useful so you do not re-audit):

- **Species/dex:** 205 internal species, 202 dex entries; `PokedexOrder` = 202 unique dex values + three 0s for fossils/ghost; all species↔dex conversion sites consistent; `NUM_POKEMON=202`, `NUM_POKEMON_INDEXES=205`.
- **Base stats:** 202 include files in exact dex order; filename/`db DEX_*`/pic labels/bank bytes match; all stats/types/growth valid.
- **Evolutions/learnsets:** 205 pointer entries map 1:1 to 205 blocks; both terminators in every block; valid methods/levels/items/targets/moves; `EVOLUTION_MOVE` always last.
- **Wild encounters:** all 55 grass tables = 10 slots, valid species/levels; slot probabilities sum to 256; water/rod tables valid; `WildDataPointers` = 248 maps.
- **Trainers:** 58 classes aligned across names/pics/money/AI/move choices/parties; all parties terminate, 1–6 mons; all 334 map trainer references in range; special-move party/slot indices in range (only the duplicates in BUG-13).
- **Moves/items/TMs:** 182 moves aligned across constants/names/data/descriptions/sfx/animations; 85 items aligned across names/prices/key flags/use pointers/descriptions; 50 TMs + 5 HMs and machine prices consistent; TM machine list = 50 + `$ff`.
- **Names/icons/palettes:** monster/item/move/trainer name tables aligned; 202 dex icons; 39 icon files at 128 bytes each; `MonsterPalettes` 203 + `TrainerPalettes` 59; 256 SGB palettes.
- **Battle systems:** Exp Share divisor/rounding/fainted exclusion; wrap damage math; priority table polarity and values; `EVOLVE_STAT` parsing; `_CalcStats` move; trainer pic bank plumbing; repel rewrite; TM/HM machine name and price conversion.
- **Menus/options:** instant text (`TEXT_DELAY_INSTANT=7`), Exp Share bit 4 wiring, cursor positions, `PrintLetterDelay` masking.
- **Cut/Strength/Surf interactions:** `hTextID`/`hSpriteIndex` alias is intentional (HRAM UNION); `wTileInFrontOfPlayer` is set before the interactions; `CheckPartyMonHasMove` preserves the move ID; `wWhichPokemon` survives the prompt.

---

## Runtime checks wanted

These are static conclusions; reproduce them first if you plan to fix:

1. Link battle win/run → exit Cable Club → use each rod. Expect a glitch party/hang today.
2. Mewtwo: lose the fight, black out, return. Expect the sprite to be gone.
3. Ice Stone on Eevee in the party menu. Expect “NOT ABLE” today.
4. Open each elevator; watch the description box. Expect text fragments.
5. Naming screen after party menu / different tilesets; compare colors.
6. 99 Potions in the last bag slot, add one; check money/WRAM adjacent values before and after.

Reference for known bugs: <https://github.com/pret/pokered/wiki/%5BARCHIVED%5D-Bugs-and-Glitches>
