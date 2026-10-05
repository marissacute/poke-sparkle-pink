#!/usr/bin/env python3
"""Generate a GitHub wiki reference for Pokemon Sparkling Pink.

Reads the disassembly (base stats, learnsets, move data, TM/HM lists) and emits
two GitHub-flavoured Markdown files:

    POKEDEX.md   every Pokemon: typing, base-stat meters, full move table
    MOVES.md     every move: stats, in-game effect text, who learns it

They are split because github.com stops rendering Markdown past 512 KiB; a
single combined document is ~660 KiB and would show as raw text.

Usage:
    tools/gen_wiki.py                     # write POKEDEX.md + MOVES.md
    tools/gen_wiki.py --outdir wiki       # write them elsewhere
    tools/gen_wiki.py --check-only        # parse + validate, write nothing
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from collections import defaultdict

# ---------------------------------------------------------------- constants

TYPE_NAMES = {
    "NORMAL": "Normal", "FIGHTING": "Fighting", "FLYING": "Flying",
    "POISON": "Poison", "GROUND": "Ground", "ROCK": "Rock", "BUG": "Bug",
    "GHOST": "Ghost", "STEEL": "Steel", "FIRE": "Fire", "WATER": "Water",
    "GRASS": "Grass", "ELECTRIC": "Electric", "PSYCHIC_TYPE": "Psychic",
    "ICE": "Ice", "DRAGON": "Dragon", "DARK": "Dark", "FAIRY": "Fairy",
    "BIRD": "Bird",
}

# The stored name for Paldean Wooper is `db "WOOPER",220,221,222,"@"`, using
# custom PALDEA glyphs that don't survive extraction.
DISPLAY_OVERRIDES = {"PALDEAN_WOOPER": "PALDEAN WOOPER"}

# `power` is a placeholder byte, not a real base power, for these effects.
PLACEHOLDER_POWER = {"OHKO_EFFECT", "SUPER_FANG_EFFECT", "SPECIAL_DAMAGE_EFFECT"}

BAR_CELLS = 20          # width of a base-stat meter
BAR_SCALE = 255         # Gen 1 base stats top out at 255
EIGHTHS = "▏▎▍▌▋▊▉█"    # partial-block ramp for the fractional cell
GROWTH_LABELS = {
    "GROWTH_MEDIUM_FAST": "Medium Fast", "GROWTH_MEDIUM_SLOW": "Medium Slow",
    "GROWTH_FAST": "Fast", "GROWTH_SLOW": "Slow",
}

STAT_REQUIREMENTS = {
    "ATK_GT_DEF": "Attack > Defense",
    "ATK_EQ_DEF": "Attack = Defense",
    "ATK_LT_DEF": "Attack < Defense",
}

POKEDEX_FILE = "POKEDEX.md"
MOVES_FILE = "MOVES.md"


# ---------------------------------------------------------------- helpers

def slug(text):
    """Reproduce GitHub's heading anchor slugger (it drops symbols like the
    gender signs in Nidoran), which is why Pokemon headings carry their dex
    number -- otherwise #34 Nidoran and #37 Nidoran would collide."""
    s = re.sub(r"[^\w\s-]", "", text.lower())
    return re.sub(r"\s+", "-", s).strip("-")


def titlecase(raw):
    """'NIDORAN' -> 'Nidoran', \"FARFETCH'D\" -> \"Farfetch'd\", 'MIME JR.' -> 'Mime Jr.'"""
    out, cap = [], True
    for ch in raw.lower():
        if cap and ch.isalpha():
            out.append(ch.upper())
            cap = False
        else:
            out.append(ch)
        if ch in " -.":
            cap = True
    s = "".join(out)
    return {"Mr.Mime": "Mr. Mime"}.get(s, s)


def camel(const):
    return "".join(w.capitalize() for w in const.split("_"))


def stat_bar(value):
    filled = value / BAR_SCALE * BAR_CELLS
    whole = min(int(filled), BAR_CELLS)
    bar = "█" * whole
    part = filled - whole
    if part > 0 and whole < BAR_CELLS:
        bar += EIGHTHS[min(7, int(part * 8))]
    return bar + "░" * max(0, BAR_CELLS - len(bar))


# ---------------------------------------------------------------- parsing

class Repo:
    """Parses the disassembly into plain Python data."""

    def __init__(self, root):
        self.root = root
        self.dex = self._pokedex_constants()
        self.species = self._species_list()
        self.raw_names = self._mon_names()
        self.mons = self._base_stats()
        self.learnsets = self._learnsets()
        self.moves = self._moves()
        self.tmhm_slots = self._tmhm_slots()
        self.item_names = self._item_names()
        self._crosslink()

    # -- file access
    def read(self, rel):
        # descriptions.asm is CRLF, everything else is LF
        with open(os.path.join(self.root, rel), newline="") as fh:
            return fh.read().replace("\r\n", "\n")

    # -- constants/pokedex_constants.asm : DEX_X -> dex number
    def _pokedex_constants(self):
        out, n = {}, 0
        for m in re.finditer(r"^\s*const\s+(DEX_\w+)",
                             self.read("constants/pokedex_constants.asm"), re.M):
            n += 1
            out[m.group(1)[4:]] = n
        return out

    # -- constants/pokemon_constants.asm : species ids; index == species id
    def _species_list(self):
        return re.findall(r"^\s*const\s+(\w+)",
                          self.read("constants/pokemon_constants.asm"), re.M)

    # -- data/pokemon/names.asm : MonsterNames, species-indexed
    def _mon_names(self):
        out = []
        for line in self.read("data/pokemon/names.asm").splitlines():
            m = re.match(r'\s*dname\s+"([^"]*)"', line)
            if m:
                out.append(m.group(1))
                continue
            m = re.match(r'\s*db\s+"([^"]*)"', line)
            if m and "PALDEA" in line:
                out.append(m.group(1))
        return out

    # -- data/pokemon/base_stats.asm : included in dex order
    def _base_stats(self):
        order = re.findall(r'INCLUDE "data/pokemon/base_stats/(\w+)\.asm"',
                           self.read("data/pokemon/base_stats.asm"))
        mons = []
        for slug_name in order:
            src = self.read(f"data/pokemon/base_stats/{slug_name}.asm")
            stats = re.search(r"^\s*db\s+(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+)",
                              src, re.M)
            mons.append({
                "slug": slug_name,
                "dex_const": re.search(r"db (DEX_\w+)", src).group(1)[4:],
                # stored order is hp, atk, def, spd, spc
                "stats": [int(x) for x in stats.groups()],
                "types": [t.strip() for t in
                          re.search(r"^\s*db (\w+), (\w+) ; type", src, re.M).groups()],
                "catch_rate": int(re.search(r"db (\d+) ; catch rate", src).group(1)),
                "base_exp": int(re.search(r"db (\d+) ; base exp", src).group(1)),
                "growth": re.search(r"db (GROWTH_\w+)", src).group(1),
                "pic": re.search(r"dw (\w+)PicFront", src).group(1),
                "start_moves": [m.strip() for m in re.search(
                    r"^\s*db ([\w, ]+); level 1 learnset", src, re.M).group(1).split(",")],
                "tmhm": self._tmhm_block(src),
            })
            mons[-1]["start_moves"] = [m for m in mons[-1]["start_moves"]
                                       if m and m != "NO_MOVE"]
        return mons

    @staticmethod
    def _tmhm_block(src):
        """The `tmhm ... ; end` list.  Continuations are backslash-joined and
        every cell but the last keeps its trailing comma, so splitting on
        commas is exact."""
        m = re.search(r"tmhm(.*?)\n\t; end", src, re.S)
        if not m:
            return []
        body = re.sub(r"\\\s*\n\s*", " ", m.group(1))
        body = re.sub(r";.*", "", body)
        return [x.strip() for x in body.split(",") if x.strip()]

    # -- data/pokemon/evos_moves.asm : species-indexed evolutions + learnsets
    #
    #   db EVOLVE_LEVEL, level, species
    #   db EVOLVE_ITEM,  item, min level (1), species
    #   db EVOLVE_TRADE, min level (1), species
    #   db EVOLVE_STAT,  level, ATK_*_DEF, species
    #   db 0                              ; end of evolutions
    #   db level, move                    ; learnset, ascending
    #   db 0                              ; end of learnset
    def _learnsets(self):
        src = self.read("data/pokemon/evos_moves.asm")
        out = {}
        for m in re.finditer(r"^(\w+)EvosMoves:\n(.*?)(?=\n\w|\Z)", src, re.M | re.S):
            body = re.sub(r";.*", "", m.group(2))
            evolutions, moves, in_moves = [], [], False
            for line in (ln.strip() for ln in body.splitlines() if ln.strip()):
                if line == "db 0":
                    in_moves = True
                    continue
                fields = [f.strip() for f in re.sub(r"^db\s+", "", line).split(",")]
                if in_moves:
                    if len(fields) == 2:
                        moves.append((fields[0], fields[1]))
                else:
                    evolutions.append(self._evolution(fields))
            out[m.group(1)] = {"moves": moves, "evolutions": evolutions}
        return out

    @staticmethod
    def _evolution(fields):
        kind = fields[0]
        if kind == "EVOLVE_ITEM":
            return {"kind": "item", "item": fields[1], "species": fields[3]}
        if kind == "EVOLVE_TRADE":
            return {"kind": "trade", "species": fields[2]}
        if kind == "EVOLVE_STAT":
            return {"kind": "stat", "level": fields[1], "stat": fields[2],
                    "species": fields[3]}
        return {"kind": "level", "level": fields[1], "species": fields[2]}

    # -- data/items/names.asm : item display names
    def _item_names(self):
        """ItemNames has no entry for NO_ITEM, so names[i] is item id i+1."""
        src = self.read("constants/item_constants.asm")
        consts = re.findall(r"^\tconst (\w+)", src, re.M)
        consts = consts[:consts.index("FLOOR_B2F")]
        head = self.read("data/items/names.asm").split("assert_list_length NUM_ITEMS")[0]
        names = re.findall(r'^\tli "([^"]*)"', head, re.M)
        if len(names) != len(consts) - 1:
            raise SystemExit(f"item names misaligned: {len(consts)} item ids, "
                             f"{len(names)} names")
        # ItemNames stores in-game ALL CAPS ("MOON STONE", "KING'S ROCK")
        return {const: titlecase(names[i - 1])
                for i, const in enumerate(consts) if i > 0}

    # -- data/moves/*.asm : the three tables are index-aligned by move id
    def _moves(self):
        rows = re.findall(r"^\tmove (\w+),\s*(\w+),\s*(\d+),\s*(\w+),\s*(\d+),\s*(\d+)",
                          self.read("data/moves/moves.asm"), re.M)
        names = re.findall(r'^\tli "(.*)"', self.read("data/moves/names.asm"), re.M)
        descs = re.findall(r"^\s+text_far _(\w+)Description",
                           self.read("data/moves/descriptions.asm"), re.M)
        texts = self._move_texts()
        if not (len(rows) == len(names) == len(descs)):
            raise SystemExit(f"move tables are misaligned: "
                             f"{len(rows)} moves, {len(names)} names, {len(descs)} descriptions")
        out = []
        for i, (const, effect, power, mtype, acc, pp) in enumerate(rows):
            out.append({
                "const": const, "name": titlecase(names[i]), "effect": effect,
                "power": int(power), "type": mtype, "acc": int(acc), "pp": int(pp),
                "text": texts.get(descs[i], ""),
            })
        return out

    def _move_texts(self):
        """_PoundDescription -> 'Pounds the foe to deal damage.'"""
        src = self.read("data/moves/descriptions.asm")
        out = {}
        for m in re.finditer(r"^_(\w+)Description::\n(.*?)(?=\n\S|\Z)", src, re.M | re.S):
            chunks = re.findall(r'^\s*(?:text|line|cont|para)\s+"([^"]*)"', m.group(2), re.M)
            out[m.group(1)] = " ".join(chunks).strip()
        return out

    # -- constants/item_constants.asm : MOVE -> 'TM32' / 'HM03'
    def _tmhm_slots(self):
        src = self.read("constants/item_constants.asm")
        out, tm, hm = {}, 0, 0
        for m in re.finditer(r"^\s*add_(tm|hm) (\w+)", src, re.M):
            if m.group(1) == "tm":
                tm += 1
                out[m.group(2)] = f"TM{tm:02d}"
            else:
                hm += 1
                out[m.group(2)] = f"HM{hm:02d}"
        return out

    # -- link the per-dex tables to the per-species tables
    def _crosslink(self):
        species_idx = {name: i for i, name in enumerate(self.species)}
        by_const = {m["const"]: m for m in self.moves}
        self.move_of = by_const

        by_species = {camel(mon["dex_const"]): mon for mon in self.mons}
        for mon in self.mons:
            mon["dex_no"] = self.dex[mon["dex_const"]]
            raw = DISPLAY_OVERRIDES.get(mon["dex_const"],
                                        self.raw_names[species_idx[mon["dex_const"]] - 1])
            mon["display"] = titlecase(raw)
            mon["anchor"] = f'{mon["dex_no"]}-{slug(mon["display"])}'
            # the learnset is keyed by the evos_moves label, which is the pic
            # label for every mon except Paldean Wooper (PalWooper)
            learn = (self.learnsets.get(camel(mon["dex_const"]))
                     or self.learnsets.get(mon["pic"])
                     or {"moves": [], "evolutions": []})
            mon["learnset"] = learn["moves"]
            mon["evolutions"] = [(by_species.get(camel(e["species"])), e)
                                 for e in learn["evolutions"]]

        # whom each Pokemon evolves from (the inverse of the table above),
        # keyed by anchor because a mon dict is not hashable
        self.evolves_from = defaultdict(list)
        for mon in self.mons:
            for target, evo in mon["evolutions"]:
                if target is not None:
                    self.evolves_from[target["anchor"]].append((mon, evo))

        # every (label, move) a Pokemon has, start moveset first.  Pineco,
        # Forretress and Politoed list a start move again at learnset level 1,
        # so identical pairs are dropped.
        self.learned_by = defaultdict(list)
        for mon in self.mons:
            rows, seen = [], set()
            for move in mon["start_moves"]:
                rows.append(("1", move))
            for level, move in mon["learnset"]:
                rows.append(("Evo" if level == "EVOLUTION_MOVE" else level, move))
            for move in mon["tmhm"]:
                rows.append((self.tmhm_slots.get(move, "TM"), move))
            mon["learn_rows"] = [row for row in rows
                                 if not (row in seen or seen.add(row))]
            for label, move in mon["learn_rows"]:
                self.learned_by[move].append((mon, label))


# ---------------------------------------------------------------- rendering

def fmt_power(move):
    if move["power"] == 0 or move["effect"] in PLACEHOLDER_POWER:
        return "—"
    return str(move["power"])


def fmt_acc(acc):
    return f"{acc}%" if acc else "—"


class Wiki:
    """Renders the parsed repo into the two Markdown documents."""

    def __init__(self, repo):
        self.r = repo

    # -- links (cross-file, since the output is split in two)
    def mon_link(self, mon, local=False):
        target = f'#{mon["anchor"]}' if local else f'{POKEDEX_FILE}#{mon["anchor"]}'
        return f'[{mon["display"]}]({target})'

    def move_link(self, move, local=False):
        target = f'#{slug(move["name"])}' if local else f'{MOVES_FILE}#{slug(move["name"])}'
        return f'[{move["name"]}]({target})'

    # -- POKEDEX.md
    def pokedex(self):
        o = ["# Pokémon Sparkling Pink — Pokédex\n"]
        o.append(f'<sub>{len(self.r.mons)} Pokémon · base stats, typing and moves · '
                 f'the move list is in [{MOVES_FILE}]({MOVES_FILE})</sub>\n')
        o.append("**STAB** moves are in **bold**. Stat meters run 0–255, the Gen 1 "
                 "base-stat scale. Rows marked `1` are the starting moveset, `Evo` is "
                 "learned on evolution.\n")
        o.append("## Contents\n")
        o.append(self._contents())
        o.append("\n## Pokémon\n")
        for mon in self.r.mons:
            o.append("---\n")
            o.append(self._mon_section(mon))
        return "\n".join(o)

    def _contents(self, cols=3):
        o = ["| " + " | ".join(["#", "Pokémon"] * cols) + " |",
             "|" + "---:|:--|" * cols]
        for chunk in (self.r.mons[i:i + cols] for i in range(0, len(self.r.mons), cols)):
            row = []
            for mon in chunk:
                row += [str(mon["dex_no"]), self.mon_link(mon, local=True)]
            row += ["", ""] * (cols - len(chunk))
            o.append("| " + " | ".join(row) + " |")
        return "\n".join(o)

    def _mon_section(self, mon):
        o = [f'### #{mon["dex_no"]} {mon["display"]}\n']
        o.append(f'**Type:** {" / ".join(dict.fromkeys(TYPE_NAMES[t] for t in mon["types"]))}  ')
        o.append(f'**Catch rate:** {mon["catch_rate"]} · **Base EXP:** {mon["base_exp"]} · '
                 f'**Growth:** {GROWTH_LABELS.get(mon["growth"], mon["growth"])}  ')
        for line in self._evolution_lines(mon):
            o.append(line)
        o.append("")

        o.append("#### Base stats\n")
        o.append("| Stat | Base | |")
        o.append("|:---|---:|:--|")
        for label, value in zip(("HP", "Attack", "Defense", "Speed", "Special"), mon["stats"]):
            o.append(f"| {label} | {value} | `{stat_bar(value)}` |")
        o.append(f'| **Total** | **{sum(mon["stats"])}** | |\n')

        o.append("#### Moves\n")
        stab = set(mon["types"])
        o.append("| Lv | Move | Type | Power | Acc | PP |")
        o.append("|---:|:--|:--|---:|---:|---:|")
        for label, move in mon["learn_rows"]:
            if label[:2] not in ("TM", "HM"):
                o.append(self._move_row(label, move, stab))
        o.append("")
        o.append(self._tmhm_grid(mon))
        return "\n".join(o)

    def _evolution_lines(self, mon):
        """'Evolves into X — level 16', plus the inverse for pre-evolutions."""
        out = []
        origins = self.r.evolves_from.get(mon["anchor"], [])
        if origins:
            links = " · ".join(f"{self.mon_link(src, local=True)} — "
                               f"{self._evolution_method(evo)}"
                               for src, evo in origins)
            out.append(f"**Evolves from:** {links}  ")
        targets = [(tgt, evo) for tgt, evo in mon["evolutions"] if tgt is not None]
        if targets:
            links = " · ".join(f"{self.mon_link(tgt, local=True)} — "
                               f"{self._evolution_method(evo)}"
                               for tgt, evo in targets)
            out.append(f"**Evolves into:** {links}  ")
        return out

    def _evolution_method(self, evo):
        if evo["kind"] == "item":
            return self.r.item_names.get(evo["item"], titlecase(evo["item"]))
        if evo["kind"] == "trade":
            return "trade"
        if evo["kind"] == "stat":
            return (f'level {evo["level"]}, '
                    f'{STAT_REQUIREMENTS.get(evo["stat"], evo["stat"])}')
        return f'level {evo["level"]}'

    def _move_row(self, label, const, stab):
        move = self.r.move_of.get(const)
        if move is None:
            return f"| {label} | {const} | ? | ? | ? | ? |"
        name = self.move_link(move)
        if move["type"] in stab:
            name = f"**{name}**"
        return (f'| {label} | {name} | {TYPE_NAMES[move["type"]]} | '
                f'{fmt_power(move)} | {fmt_acc(move["acc"])} | {move["pp"]} |')

    def _tmhm_grid(self, mon, cols=3):
        """TM/HM moves as a compact grid -- their type/power/accuracy/PP are
        already in the move list, and repeating them costs ~90 KiB."""
        if not mon["tmhm"]:
            return ""
        cells = []
        for const in mon["tmhm"]:
            move = self.r.move_of.get(const)
            name = self.move_link(move) if move else const
            cells.append((self.r.tmhm_slots.get(const, "TM"), name))
        o = ["**TM/HM moves**\n",
             "| " + " | ".join(["TM/HM", "Move"] * cols) + " |",
             "|" + "---:|:--|" * cols]
        for chunk in (cells[i:i + cols] for i in range(0, len(cells), cols)):
            row = []
            for cell in chunk:
                row += list(cell)
            row += ["", ""] * (cols - len(chunk))
            o.append("| " + " | ".join(row) + " |")
        return "\n".join(o)

    # -- MOVES.md
    def moves(self):
        o = ["# Pokémon Sparkling Pink — Move list\n"]
        o.append(f'<sub>{len(self.r.moves)} moves · who learns what · '
                 f'Pokémon stat pages are in [{POKEDEX_FILE}]({POKEDEX_FILE})</sub>\n')
        o.append("| Move | Type | Power | Acc | PP | Effect |")
        o.append("|:--|:--|---:|---:|---:|:--|")
        for move in self.r.moves:
            o.append(f'| {self.move_link(move, local=True)} | {TYPE_NAMES[move["type"]]} | '
                     f'{fmt_power(move)} | {fmt_acc(move["acc"])} | {move["pp"]} | '
                     f'{move["text"]} |')
        o.append("")
        for move in self.r.moves:
            o.append("---\n")
            o.append(self._move_section(move))
        return "\n".join(o)

    def _move_section(self, move):
        o = [f'### {move["name"]}\n']
        o.append(f'**Type:** {TYPE_NAMES[move["type"]]} · **Power:** {fmt_power(move)} · '
                 f'**Accuracy:** {fmt_acc(move["acc"])} · **PP:** {move["pp"]}\n')
        if move["text"]:
            o.append(f'> {move["text"]}\n')
        learners = self.r.learned_by.get(move["const"], [])
        level_up = [(mon, lv) for mon, lv in learners if not lv[:2] in ("TM", "HM")]
        tmhm = [(mon, lv) for mon, lv in learners if lv[:2] in ("TM", "HM")]
        if level_up:
            o.append("**Learned by level-up**\n")
            o.append("| Pokémon | Lv |")
            o.append("|:--|---:|")
            for mon, level in level_up:
                o.append(f'| {self.mon_link(mon)} | {level} |')
            o.append("")
        if tmhm:
            links = ", ".join(self.mon_link(mon) for mon, _ in tmhm)
            o.append(f"**{tmhm[0][1]}:** {links}\n")
        if not level_up and not tmhm:
            o.append("_Not learned by any Pokémon._\n")
        return "\n".join(o)


# ---------------------------------------------------------------- validation

def validate(pokedex, moves):
    """Catch the failure modes that would silently break the wiki on GitHub:
    anchors that collide, and links that point nowhere."""
    problems = []
    for name, text in ((POKEDEX_FILE, pokedex), (MOVES_FILE, moves)):
        headings = re.findall(r"^#{2,3} (.+)$", text, re.M)
        seen = {}
        for heading in headings:
            s = slug(heading)
            if s in seen:
                problems.append(f"{name}: duplicate anchor #{s} "
                                f"({seen[s]!r} and {heading!r})")
            seen[s] = heading
    # every link must resolve, in this file or across the pair
    local = {
        POKEDEX_FILE: {slug(h) for h in re.findall(r"^#{2,3} (.+)$", pokedex, re.M)},
        MOVES_FILE: {slug(h) for h in re.findall(r"^#{2,3} (.+)$", moves, re.M)},
    }
    for name, text in ((POKEDEX_FILE, pokedex), (MOVES_FILE, moves)):
        for target in re.findall(r"\]\((?!https?:)([^)]+)\)", text):
            if target.startswith("#"):
                if target[1:] not in local[name]:
                    problems.append(f"{name}: dead anchor {target}")
            else:
                fname, _, anchor = target.partition("#")
                if fname not in local:
                    problems.append(f"{name}: link to unknown file {fname}")
                elif anchor and anchor not in local[fname]:
                    problems.append(f"{name}: dead cross-file anchor {target}")
    return problems


# ---------------------------------------------------------------- entry point

def main(argv=None):
    here = os.path.dirname(os.path.abspath(__file__))
    default_root = os.path.dirname(here)

    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", default=default_root,
                    help="repository root (default: the parent of this script)")
    ap.add_argument("--outdir", default=default_root,
                    help="where to write the .md files")
    ap.add_argument("--check-only", action="store_true",
                    help="parse and validate, but write nothing")
    args = ap.parse_args(argv)

    repo = Repo(args.root)
    wiki = Wiki(repo)
    pokedex, moves = wiki.pokedex(), wiki.moves()

    problems = validate(pokedex, moves)
    for problem in problems:
        print(f"warning: {problem}", file=sys.stderr)

    print(f'{len(repo.mons)} Pokémon, {len(repo.moves)} moves, '
          f'{len(repo.learned_by)} moves with a learner')
    if args.check_only:
        return 1 if problems else 0

    os.makedirs(args.outdir, exist_ok=True)
    for name, text in ((POKEDEX_FILE, pokedex), (MOVES_FILE, moves)):
        path = os.path.join(args.outdir, name)
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(text)
        size = os.path.getsize(path)
        print(f'wrote {path} ({size:,} B, {size / 1024:.1f} KiB)')
        if size > 512 * 1024:
            print(f'warning: {name} is over GitHub\'s 512 KiB render limit',
                  file=sys.stderr)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
