# Driving the ROM in PyBoy

How to boot this hack headlessly, walk to a battle, poke menus, and read/write game
memory — so a testing session can be restarted without re-deriving any of it.
See also `POKEDEX_TODO.md` for the current feature gap list.

## Setup

```bash
# 1. always rebuild first: the .gbc files are gitignored and go stale
make -j"$(nproc)" red

# 2. stage a working copy in /tmp -- never run PyBoy against the repo copy.
#    PyBoy looks for and writes <rom>.ram (the cartridge battery) next to the
#    ROM, and .gitignore covers *.sav but not *.ram
mkdir -p /tmp/psp
cp pokered.gbc /tmp/psp/psp.gbc
cp pokered.sym /tmp/psp/psp.gbc.sym
cp pokered.sav /tmp/psp/psp.gbc.ram     # optional: a save to boot into

# 3. run. The venv path has spaces, so quote it; every run prints an SDL2 warning
"/mnt/e/Documents/My Projects/poke-sparkle-pink/pyboy-venv/bin/python" script.py 2>&1 | grep -v UserWarning
```

`pyboy-venv/` is PyBoy 2.7 with numpy and **no Pillow**, so `pb.screen.image.save()`
fails — use `save_png()` below.

`PyBoy(rom, symbols=rom + ".sym", window="null", sound_emulated=True,
log_level="CRITICAL")` enables `pb.symbol_lookup("Name")` and
`pb.hook_register(None, "Name", cb, pb)`. Keep `symbols=` pointed at the `.sym`
built alongside the ROM you are running, or symbol lookups resolve to the wrong
addresses.

## harness.py

```python
import struct, zlib, os
from pyboy import PyBoy

ROM = "/tmp/psp/psp.gbc"

def save_png(pb, path):
    """Write the 144x160 RGBA ndarray to a PNG (no Pillow in this venv)."""
    arr = pb.screen.ndarray
    h, w, _ = arr.shape
    raw = b""
    for y in range(h):
        raw += b"\x00"
        for x in range(w):
            r, g, b = arr[y, x, 0], arr[y, x, 1], arr[y, x, 2]
            raw += bytes((r, g, b))
    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data
                + struct.pack(">I", zlib.crc32(tag + data) & 0xffffffff))
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 6))
    png += chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)
    print("wrote", path, w, "x", h)

def decode_tile(b):
    if 0x80 <= b <= 0x99: return chr(ord('A') + b - 0x80)
    if 0x9A <= b <= 0xB3: return chr(ord('a') + b - 0x9A)
    if 0xB4 <= b <= 0xBD: return chr(ord('0') + b - 0xB4)
    if b == 0x7F: return ' '
    if b == 0xE8: return '.'
    if b == 0xE3: return '-'
    return '?'

def screen_text(pb, base=0x9800, rows=18, cols=20):
    out = []
    for r in range(rows):
        line = ''.join(decode_tile(pb.memory[base + r * 32 + c]) for c in range(cols))
        out.append(line.rstrip())
    return '\n'.join(out)

def save_state(pb, path):
    with open(path, "wb") as f:
        pb.save_state(f)

def load_state(pb, path):
    with open(path, "rb") as f:
        pb.load_state(f)

def new_pb(rom=None, **kw):
    rom = rom or ROM
    return PyBoy(rom, window="null", sound_emulated=True, log_level="CRITICAL",
                 symbols=rom + ".sym", **kw)

def press(pb, btn, delay=6, wait=0):
    pb.button(btn, delay=delay)
    if wait:
        pb.tick(wait)
```

`button()` presses and releases after `delay` ticks; `tick(n)` advances n frames.
Screenshots are worth an `Read` — visual checks caught two mistakes that memory
reads alone would have missed.

Prefer a **fresh boot from the `.sav`** over reusing a save state across builds:
states are emulator snapshots and are only trustworthy with the ROM that made them.
Within one ROM, `save_state`/`load_state` are the fast way to re-run a scenario.

## Recipes

### Boot into an existing save

```python
for i in range(40):
    pb.tick(60)
    if i % 4 == 0: press(pb, "start", delay=6, wait=10)   # skip the intro
press(pb, "a", delay=6, wait=120)                          # CONTINUE
pb.tick(180)
```
The main menu's first entry is CONTINUE. START spam is harmless once past the title.

### Walk into a wild battle

```python
import random
random.seed(1)
for i in range(300):
    if pb.memory[0xd066]: break                            # wIsInBattle
    pb.button(random.choice(["down","left","up","right"]), delay=14); pb.tick(10)
```
`wIsInBattle` is 1 for a wild battle, 2 for a trainer battle (`wBattleType` at
`$d069` is 0 for normal, 1 for the old man tutorial, 2 for Safari).

### Show a specific mon's sprite (party menu / status screen)

`pb.symbol_lookup` returns `(bank, addr)`, so index `[1]` for the address. The party lives in
WRAM bank 1, but **the species is stored twice** and the two copies feed different screens:

```python
ps  = pb.symbol_lookup("wPartySpecies")[1]   # $d173, the list the party menu draws from
pm1 = pb.symbol_lookup("wPartyMon1")[1]      # $d17a, whose first byte is the struct's species
pb.memory[1, ps]  = 0xC5                     # MIME_JR
pb.memory[1, pm1] = 0xC5
```

Poking only `wPartySpecies` changes the party-menu icon but the **status screen still shows the
old mon** — it takes the species, dex number and type from the party struct. Poke both.
The party struct's other fields (level, HP, stats, nickname) stay as they were, which is fine
for a sprite/palette check.

Navigation: START -> DOWN -> A is the party menu; A opens STATS/SWITCH/CANCEL; A takes STATS.
The status screen and the pokedex both route through `DeterminePaletteID` -> `MonsterPalettes`
(see [palettes.asm](data/pokemon/palettes.asm)), so the status screen is the cheap way to
verify a `PAL_*` entry without walking into a battle. The party menu itself does **not** — its
Gen 2 icons use their own palette, so a colour read there tells you nothing about the mon
palette.

To check palettes, sample the screenshot rather than eyeballing it: the CGB render of
`RGB r,g,b` is `(r<<3, g<<3, b<<3)`, so `RGB 31,20,24` must appear as exactly `#F8A0C0`.

### Battle menu -> bag -> item

```python
pb.tick(200)
for i in range(7):                       # clear "Wild X appeared!" / "Go! Y!"
    pb.button("a", delay=6); pb.tick(40)
pb.tick(60)
pb.button("down", delay=6); pb.tick(20)  # FIGHT -> ITEM
pb.button("a", delay=6); pb.tick(60)     # open the bag
for i in range(3):
    pb.button("down", delay=6); pb.tick(30)
pb.button("a", delay=6); pb.tick(240)    # use the selected item
```
The cursor remembers where you left it (`wBagSavedMenuItem`), so after leaving and
re-entering the bag it is usually on ITEM, not FIGHT — press `up` before `a` if you
want FIGHT.

### Overworld bag

START -> DOWN x2 -> A. `b` leaves the bag to the start menu with the cursor still on
ITEM, so `a` re-enters it.

### Debug menu, TestBattle, and an instant 6-mon party

`CheckForUserInterruption` (`home/overworld.asm`) watches `hJoy5` (*newly* pressed),
so holding SELECT from boot never triggers it — START does. `engine/movie/title.asm`
then reads `hJoyHeld` ~400 frames later, so SELECT must still be held at that read.

```python
press(pb, "select"); pb.tick(1200)        # title screen, SELECT held
pb.button("start", 6); pb.tick(400)       # interrupt + let title.asm read hJoyHeld
pb.button_release("select"); pb.tick(60)
pb.button("a", 6)                         # FIGHT -> TestBattle
```
Then answer the nickname prompt with DOWN+A and poll `wIsInBattle` until non-zero.
After the battle starts, use **A only** — DOWN+A moves the battle menu cursor.
`TestBattle` pre-selects the player's move via `wTestBattlePlayerSelectedMove`
(`$ccd9`) and re-runs itself forever, resetting the party after every battle, so read
state before the reset.

Choosing **DEBUG** instead of FIGHT runs `StartNewGameDebug`: no Oak speech, a fixed
party of six, and the "give a nickname?" prompt **six times** (A to advance, DOWN+A
for NO). This is only in the `blue_debug` target.

### Forcing a specific move

Poke `wTestBattlePlayerSelectedMove` (`$ccd9`) — `GetCurrentMove` uses it instead of
the menu selection while BIT_TEST_BATTLE is set. Take the move index from the built
ROM, not from a hand count of `constants/move_constants.asm`: the effect byte is at
`Moves + (i-1)*6 + 1`, and `const NO_MOVE ; 00` occupies slot 0, so `RECOVER` is $69.
`wPlayerMoveNum`/`wPlayerMoveEffect` are `$cfe1`/`$cfe2`.

## Reading and writing state

**Resolve addresses with `pb.symbol_lookup("wCurItem")` rather than hardcoding.**
WRAM0 is full and addresses move whenever anything is added, so a saved table goes
stale silently. The current values are handy for quick checks:

| what | addr | notes |
|---|---|---|
| `wCurItem` / `wCurListMenuItem` / `wCurPartySpecies` | `$cfa0` | one byte, three names |
| `wWhichPokemon` | `$cfa1` | |
| `wNameListType` / `wPredefBank` | `$d0c5` / `$d0c6` | 4 = ITEM_NAME, 2 = MOVE_NAME |
| `wIsInBattle` / `wBattleType` | `$d066` / `$d069` | |
| `wNumBagItems` / `wBagItems` | `$d33a` / `$d33b` | count, then (id, qty) pairs, `$FF`-terminated |
| `wPartyCount` / `wPartySpecies` | `$d172` / `$d173` | |
| `wBoxCount` | `$da5f` | |
| `wCurMap` / `wYCoord` / `wXCoord` | `$d37b` / `$d37e` / `$d37f` | also gives "has the overworld loaded yet" |
| `wBagSavedMenuItem` | `$cc2c` | cursor memory across bag opens |
| `wMenuItemToSwap` | `$cc35` | 0 = no swap pending |

**The WRAM bank trap.** `$C000-$CFFF` is fixed and always safe. `$D000-$DFFF` is
*switchable*: `pb.memory[addr]` reads whatever bank is currently selected and can
return 0 or another bank's data. Read those as `pb.memory[1, addr]` (bank 1 held the
bag and party during normal play), or scan banks 0-7 for the value you expect:

```python
for b in range(8):
    if pb.memory[b, 0xd33a] == 5: ...
```

Bag/item/party edits need the write to reach the same bank the game reads, so write
with an explicit bank too: `pb.memory[1, 0xd343] = 0xC4`.

Reading a *name* out of a tilemap is easiest on the charmap `$80-$99` = A-Z,
`$9A-$B3` = a-z, `$B4-$BD` = 0-9; keep the **first** mapping per byte value, since
later aliases (kana) overwrite letter entries. VRAM tilemaps are 32 bytes per row,
not 20 — using a 20-stride gives diagonal garbage.

## Instrumentation

```python
def cb(ctx):
    rf = ctx.register_file                      # A, B, C, D, E, F, HL, PC, SP
    print("hit: PC=%04x A=%02x HL=%04x" % (rf.PC, rf.A, rf.HL))
pb.hook_register(None, "UseItem_", cb, pb)      # by symbol, or (bank, addr, cb, pb)
```
There is **no combined `DE`** register — compute `(rf.D << 8) | rf.E`.

Hooks replace the instruction, so use them on real code, and expect the callback to
run on every hit. To find which function clobbers a variable, hook a bisecting set of
labels and print the value at each; local labels are in the `.sym` by their dotted
name (`DisplayListMenuIDLoop.storeChosenEntry`).

To bound the damage from a suspicious copy, snapshot WRAM either side of the call:

```python
snap = {}
def before(ctx): snap['a'] = bytes(pb.memory[0xc000:0xe000])
def after(ctx):
    b = bytes(pb.memory[0xc000:0xe000]); a = snap['a']
    for i in range(len(a)):
        if a[i] != b[i]: print("$%04x %02x -> %02x" % (0xc000+i, a[i], b[i]))
pb.hook_register(0, 0x2bf5, before, pb)   # the `call` instruction
pb.hook_register(0, 0x2bf8, after, pb)    # the instruction right after it returns
```
(Run this against a `git stash`ed build too — comparing fixed vs unfixed is the
cheapest way to prove a cause. Remember to rebuild both ways and restore your work;
save `git diff` to a patch first.)

Name lookups copy into fixed-size buffers and rely on an `'@'` (`$50`) terminator
coming along with the source, so a lookup pointed at the wrong table produces an
unterminated buffer. To catch that before it does damage, watch the copy and check
the source:

```python
bad = []
def watch_copy(ctx):
    rf = ctx.register_file
    de = (rf.D << 8) | rf.E
    src = bytes(pb.memory[de:de + 24])
    if src.find(b"\x50") < 0 or src.find(b"\x50") >= 20:
        bad.append((de, src))       # copy will run past the buffer
pb.hook_register(None, "CopyToStringBuffer", watch_copy, pb)
```
The bag is a good place to exercise this: open it, move the cursor so a TM/HM row is
the bottom one drawn, then use an item. `wNameListType` reads 4 (`ITEM_NAME`) when
the list is healthy and 2 (`MOVE_NAME`) when a TM name has leaked its list type —
that single byte is the precondition for the whole family of bag corruption bugs.

To search for a string in the built ROM, encode it with `charmap.asm` — but note that
charmap defines **two-character ligatures** (`"'s"`→$bd, `"'t"`→$be, `"'v"`→$bf) that
rgbasm matches before the single `"'"`, so a naive char-by-char encode of `"BROCK's"`
produces the wrong bytes. Encode ligatures first, or dump the bytes around a known
line.
