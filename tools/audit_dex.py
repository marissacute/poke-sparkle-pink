#!/usr/bin/env python3
"""Re-derive POKEDEX_TODO.md's obtainability and trainer-team lists.

These are the two lists in POKEDEX_TODO.md that go stale the moment someone
adds a wild slot, a gift, a trade or a party row:

    section 2  "Can't be obtained"                species with no source at all
    section 3  "Never appears on a trainer's team"

Both are derived here from the source tables, by the recipe the doc records
under "Verifying":

    * every `db <lvl>, <SPECIES>` pair under data/wild/ (grass, water, the rods)
    * the hardcoded Old Rod MAGIKARP in engine/items/item_effects.asm
    * every `call GivePokemon` site, the fossil table in engine/events/
      cinnabar_lab.asm, the Route 15 aide's list and the OaksLab starter
      constants
    * `npctrade` column 2, `prize_mon` rows, `OW_POKEMON` map objects
    * scripts that load a species into wCurOpponent (scripted wild battles)

...then closed forwards under `db EVOLVE_*`, so evolving into something counts
as obtaining it. The traps the doc lists are handled: `DEF` aliases are resolved
(`STARTER1/2/3`, `RESTLESS_SOUL`), the Old Man's unreachable WEEDLE demo is not
counted as a source, a team row naming something that isn't a species is dropped
rather than half-counted (the old `PAL_WOOPER` collision), and a giveaway whose
species can't be read off the site is reported as a warning instead of guessed.

Mew and Hoopa are called out separately - they are deliberately unobtainable.
The three internal MISSINGNO. slots (FOSSIL_KABUTOPS, FOSSIL_AERODACTYL,
MON_GHOST) have no dex entry and are left out of both lists entirely.

Not audited here: placeholder graphics, cries and learnsets - those are the
other rows of the doc's "Verifying" table.

Usage:
    tools/audit_dex.py                    # print both lists
    tools/audit_dex.py --why MAREEP       # where one species comes from
    tools/audit_dex.py --sources          # every source, species by species
    tools/audit_dex.py --json dex.json    # machine-readable dump
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import re
import sys
from collections import defaultdict

# The three internal slots, which have no dex entry (POKEDEX_TODO.md scope note).
INTERNAL_SLOTS = {"FOSSIL_KABUTOPS", "FOSSIL_AERODACTYL", "MON_GHOST"}

# Deliberately unobtainable, so never reported as a gap.
UNOBTAINABLE_BY_DESIGN = {"MEW", "HOOPA"}

# Legendaries and mythicals, excluded from the trainer-team list.
NOT_ON_TEAMS = {"ARTICUNO", "ZAPDOS", "MOLTRES", "MEWTWO", "MEW", "HOOPA"}

# scripts/ViridianCity.asm loads WEEDLE into wCurOpponent for the Old Man's
# catching demo, guarded by BATTLE_TYPE_OLD_MAN. That battle can't be kept, so
# it is not a source - POKEDEX_TODO.md's trap list calls this one out.
UNREACHABLE_BATTLES = {("scripts/ViridianCity.asm", "WEEDLE")}

# The Fighting Dojo hands out wCurPartySpecies, not a literal, so the two mons
# can't be read off the `call GivePokemon` site. Matched to that file's give
# sites in source order, so keep the list in the same order as the script.
GIFTS_FROM_WCURPARTYSPECIES = {
    "scripts/FightingDojo.asm": ["HITMONLEE", "HITMONCHAN"],
}

# These two also give a variable, but one filled from a table this script reads
# separately: the fossil room's wFossilMon, and the Route 15 aide's .StarterList.
# Listing them keeps the "could not resolve" warning meaningful.
GIFTS_DERIVED_ELSEWHERE = {
    "scripts/CinnabarLabFossilRoom.asm",
    "scripts/Route15Gate2F.asm",
}


class Repo:
    def __init__(self, root):
        self.root = root

    def read(self, rel):
        with open(os.path.join(self.root, rel), encoding="utf-8") as fh:
            return fh.read()

    def lines(self, rel):
        return self.read(rel).splitlines()

    def glob(self, pattern):
        files = glob.glob(os.path.join(self.root, pattern), recursive=True)
        return sorted(os.path.relpath(f, self.root).replace(os.sep, "/")
                      for f in files)


def strip_comment(line):
    return line.split(";")[0]


def db_args(line):
    """The comma-separated operands of a `db` line, or None."""
    body = strip_comment(line).strip()
    if not re.match(r"^db\s", body):
        return None
    return [t.strip() for t in re.sub(r"^db\s+", "", body).split(",") if t.strip()]


class Dex:
    """Species list, aliases and evolution edges."""

    def __init__(self, repo):
        self.repo = repo
        # all_species keeps the MISSINGNO. slots, because EvosMovesPointerTable is
        # indexed by species id; species is the 202 the dex actually shows.
        self.all_species, self.alias = self._parse_species()
        self.species = [s for s in self.all_species if s not in INTERNAL_SLOTS]
        self.species_set = set(self.species)
        self.evos = self._parse_evolutions()

    def _parse_species(self):
        species, alias = [], {}
        for line in self.repo.lines("constants/pokemon_constants.asm"):
            body = strip_comment(line).strip()
            m = re.match(r"const\s+(\w+)$", body)
            if m:
                species.append(m.group(1))
                continue
            m = re.match(r"const_skip(?:\s+(\d+))?$", body)
            if m:
                species += ["<skip>"] * int(m.group(1) or 1)
                continue
            m = re.match(r"DEF\s+(\w+)\s+EQU\s+(\w+)$", body)
            if m:
                alias[m.group(1)] = m.group(2)
        return species[1:], alias          # NO_MON occupies index 0

    def resolve(self, tok):
        """Follow DEF aliases (STARTER1 -> IGGLYBUFF, RESTLESS_SOUL -> MAROWAK)."""
        for _ in range(5):
            if tok not in self.alias:
                return tok
            tok = self.alias[tok]
        return tok

    def is_species(self, tok):
        return self.resolve(tok) in self.species_set

    def _parse_evolutions(self):
        """Struct per species; `EvosMovesPointerTable` is in species order."""
        src = self.repo.read("data/pokemon/evos_moves.asm")
        labels = re.findall(r"^\tdw (\w+EvosMoves)$", src, re.M)
        if len(labels) != len(self.all_species):
            raise SystemExit(f"evos_moves.asm has {len(labels)} structs for "
                             f"{len(self.all_species)} species ids")
        label_species = dict(zip(labels, self.all_species))

        evos = defaultdict(set)
        current = None
        for line in src.splitlines():
            m = re.match(r"(\w+EvosMoves):", line.strip())
            if m:
                current = m.group(1)
                continue
            m = re.match(r"\s*db\s+(EVOLVE_\w+),\s*(.+?)\s*$", strip_comment(line))
            if m and current:
                target = self.resolve(m.group(2).split(",")[-1].strip())
                if target in self.species_set:
                    evos[label_species[current]].add(target)
        return evos

    def close_forwards(self, owned):
        """Everything reachable from `owned` by evolving."""
        reached = set(owned)
        frontier = list(owned)
        while frontier:
            for target in self.evos.get(frontier.pop(), ()):
                if target not in reached:
                    reached.add(target)
                    frontier.append(target)
        return reached


def parse_trainer_mons(repo, dex):
    """Species on trainer teams, plus a row count to compare against the doc."""
    mons = set()
    rows = 0
    for line in repo.lines("data/trainers/parties.asm"):
        args = db_args(line)
        if not args:
            continue
        if args[0] == "$FF":
            rest = args[1:]
            pairs = [(rest[i], rest[i + 1]) for i in range(0, len(rest) - 1, 2)]
            found = [dex.resolve(s) for _, s in pairs if dex.is_species(s)]
        elif re.match(r"^\d+$", args[0]):
            found = [dex.resolve(t) for t in args[1:] if t != "0" and dex.is_species(t)]
            # a team row is all species; anything else is a different table
            if len(found) != len([t for t in args[1:] if t != "0"]):
                continue
        else:
            continue
        if not found:
            continue
        rows += 1
        mons.update(found)
    return mons, rows


class Sources:
    """species -> kind -> [where]."""

    def __init__(self):
        self.by_species = defaultdict(lambda: defaultdict(list))
        self.counts = defaultdict(int)

    def add(self, species, kind, where):
        self.counts[kind] += 1
        if where not in self.by_species[species][kind]:
            self.by_species[species][kind].append(where)

    def kinds(self, species):
        return self.by_species.get(species, {})


def find_wild(repo, dex, sources):
    files = repo.glob("data/wild/**/*.asm")
    for path in files:
        for i, line in enumerate(repo.lines(path), 1):
            args = db_args(line)
            if args and len(args) == 2 and re.match(r"^\d+$", args[0]) \
                    and dex.is_species(args[1]):
                sources.add(dex.resolve(args[1]), "wild", f"{path}:{i}")
    return len(files)


def find_scripted_battles(repo, dex, sources, warnings):
    """Species loaded into wCurOpponent, plus the sites that only name a trainer."""
    trainer_classes = 0
    for path in repo.glob("scripts/**/*.asm"):
        lines = repo.lines(path)
        for i, line in enumerate(lines):
            if "ld [wCurOpponent], a" not in line:
                continue
            value = None
            for j in range(i - 1, max(-1, i - 15), -1):
                if lines[j][:1] not in (" ", "\t"):     # a label ends the block
                    break
                m = re.match(r"\s*ld a,\s*(\w+)\s*$", strip_comment(lines[j]))
                if m:
                    value = m.group(1)
                    break
            if value is None:
                warnings.append(f"{path}:{i + 1}: no `ld a, <value>` found")
            elif not dex.is_species(value):
                trainer_classes += 1                      # OPP_*, set elsewhere
            elif (path, value) in UNREACHABLE_BATTLES:
                sources.counts["scripted (unreachable)"] += 1
            else:
                sources.add(dex.resolve(value), "scripted", f"{path}:{i + 1}")
    return trainer_classes


def find_grants(repo, dex, sources, warnings):
    """Gifts, fossils, starters - everything handed to the player."""
    call_sites = 0
    for path in repo.glob("scripts/**/*.asm"):
        lines = repo.lines(path)
        sites = [i for i, line in enumerate(lines) if "call GivePokemon" in line]
        manual = GIFTS_FROM_WCURPARTYSPECIES.get(path, [])
        for k, i in enumerate(sites):
            call_sites += 1
            found = []
            for j in range(i - 1, max(-1, i - 8), -1):
                if lines[j][:1] not in (" ", "\t"):
                    break
                m = re.match(r"\s*lb bc,\s*(\w+),\s*(\w+)", strip_comment(lines[j]))
                if m:
                    found += [t for t in m.groups() if dex.is_species(t)]
                    break
                m = re.match(r"\s*ld a,\s*(\w+)\s*$", strip_comment(lines[j]))
                if m and dex.is_species(m.group(1)):
                    found.append(m.group(1))
                    break
            if found:
                for name in found:
                    sources.add(dex.resolve(name), "gift", f"{path}:{i + 1}")
            elif k < len(manual):
                sources.add(dex.resolve(manual[k]), "gift", f"{path}:{i + 1}")
            elif path not in GIFTS_DERIVED_ELSEWHERE:
                warnings.append(f"{path}:{i + 1}: could not resolve the gift")

    # Fossil revives: the fossil -> species table.
    path = "engine/events/cinnabar_lab.asm"
    for i, line in enumerate(repo.lines(path), 1):
        m = re.match(r"\s*ld b,\s*(\w+)", strip_comment(line))
        if m and dex.is_species(m.group(1)):
            sources.add(dex.resolve(m.group(1)), "fossil", f"{path}:{i}")

    # The Route 15 aide's classic three.
    path = "scripts/Route15Gate2F.asm"
    lines = repo.lines(path)
    for i, line in enumerate(lines):
        if ".StarterList" not in line:
            continue
        for j in range(i + 1, len(lines)):
            args = db_args(lines[j])
            if not args or not dex.is_species(args[0]):
                break
            sources.add(dex.resolve(args[0]), "gift", f"{path}:{j + 1}")

    # The player's starter: OaksLab stops on one of the three STARTER constants.
    path = "scripts/OaksLab.asm"
    starters = set(re.findall(r"\b(STARTER\d)\b", repo.read(path)))
    for tok in sorted(starters):
        sources.add(dex.resolve(tok), "starter", path)

    # The Old Rod is hardcoded rather than a table.
    path = "engine/items/item_effects.asm"
    lines = repo.lines(path)
    for i, line in enumerate(lines):
        if not line.startswith("ItemUseOldRod:"):
            continue
        for j in range(i + 1, i + 6):
            m = re.search(r"lb bc,\s*\d+,\s*(\w+)", strip_comment(lines[j]))
            if m and dex.is_species(m.group(1)):
                sources.add(dex.resolve(m.group(1)), "old rod", f"{path}:{j + 1}")
                break
    return call_sites


def find_events(repo, dex, sources):
    """Trades, prize mons and overworld Pokemon objects."""
    for i, line in enumerate(repo.lines("data/events/trades.asm"), 1):
        m = re.match(r"\s*npctrade\s+(\w+),\s*(\w+)", strip_comment(line))
        if m and dex.is_species(m.group(2)):
            sources.add(dex.resolve(m.group(2)), "trade", f"trades.asm:{i}")

    for i, line in enumerate(repo.lines("data/events/prizes.asm"), 1):
        m = re.match(r"\s*prize_mon\s+(\w+)", strip_comment(line))
        if m and dex.is_species(m.group(1)):
            sources.add(dex.resolve(m.group(1)), "prize", f"prizes.asm:{i}")

    count = 0
    for path in repo.glob("data/maps/objects/*.asm"):
        for i, line in enumerate(repo.lines(path), 1):
            if "OW_POKEMON" not in line:
                continue
            args = [a.strip() for a in line.split(";")[0].split(",")]
            if len(args) >= 7 and dex.is_species(args[6]):
                count += 1
                sources.add(dex.resolve(args[6]), "overworld", f"{path}:{i}")
    return count


def audit(repo, warnings):
    dex = Dex(repo)
    sources = Sources()

    wild_files = find_wild(repo, dex, sources)
    trainer_classes = find_scripted_battles(repo, dex, sources, warnings)
    gift_sites = find_grants(repo, dex, sources, warnings)
    ow_objects = find_events(repo, dex, sources)

    team_mons, party_rows = parse_trainer_mons(repo, dex)

    directly_owned = set(sources.by_species)
    obtained = dex.close_forwards(directly_owned)

    missing = [s for s in dex.species
               if s not in obtained and s not in UNOBTAINABLE_BY_DESIGN]
    never_on_team = [s for s in dex.species
                     if s not in team_mons and s not in NOT_ON_TEAMS]

    return {
        "dex": dex,
        "sources": sources,
        "missing": missing,
        "never_on_team": never_on_team,
        "obtained": obtained,
        "directly_owned": directly_owned,
        "counts": {
            "species": len(dex.species),
            "obtainable": len(obtained),
            "unobtainable_by_design": len(UNOBTAINABLE_BY_DESIGN & dex.species_set),
            "on_team": len(team_mons),
            "party_rows": party_rows,
            "wild_files": wild_files,
            "gift_sites": gift_sites,
            "ow_objects": ow_objects,
            "trainer_class_opponents": trainer_classes,
        },
    }


def wrap(names, width=78):
    lines, line = [], ""
    for name in names:
        if line and len(line) + len(name) + 2 > width:
            lines.append(line)
            line = ""
        line = f"{line}, {name}" if line else name
    if line:
        lines.append(line)
    return lines


def report(result, show_sources):
    dex, sources, counts = result["dex"], result["sources"], result["counts"]
    print(f"{counts['species']} dex species "
          f"({counts['species'] + len(INTERNAL_SLOTS)} constants minus the "
          f"{len(INTERNAL_SLOTS)} internal MISSINGNO. slots)")

    print(f"Obtainable: {counts['obtainable']} of {counts['species']} "
          f"({counts['unobtainable_by_design']} deliberately out of reach)")

    missing = sorted(result["missing"])
    print(f"\nSection 2 - can't be obtained: {len(missing)}")
    for line in wrap(missing, width=70):
        print(f"    {line}")

    never = sorted(result["never_on_team"])
    print(f"\nSection 3 - never on a trainer's team: {len(never)} "
          f"({counts['on_team']} of {counts['species']} appear on at least one)")
    for line in wrap(never, width=70):
        print(f"    {line}")

    print("\nSources counted")
    for kind in sorted(sources.counts):
        print(f"    {kind:12s} {sources.counts[kind]}")
    print(f"    {'wild files':12s} {counts['wild_files']}")
    print(f"    {'party rows':12s} {counts['party_rows']}")
    if counts["trainer_class_opponents"]:
        print(f"    ({counts['trainer_class_opponents']} wCurOpponent sites load a "
              f"trainer class, not a species)")

    if show_sources:
        print("\nSources by species")
        for name in dex.species:
            kinds = sources.kinds(name)
            if not kinds:
                continue
            parts = []
            for kind in sorted(kinds):
                where = kinds[kind]
                shown = ", ".join(where[:4]) + (f" (+{len(where) - 4})"
                                                if len(where) > 4 else "")
                parts.append(f"{kind}: {shown}")
            print(f"    {name:12s} " + "; ".join(parts))


def why(result, name):
    dex, sources = result["dex"], result["sources"]
    name = dex.resolve(name.upper())
    if name not in dex.species_set:
        print(f"{name} is not a species")
        return 1
    print(f"{name}")
    kinds = sources.kinds(name)
    if not kinds:
        print("    no direct source - only reachable by evolving")
    for kind in sorted(kinds):
        for where in kinds[kind]:
            print(f"    {kind:9s} {where}")
    for source in sorted(s for s, targets in dex.evos.items() if name in targets):
        print(f"    evolves from {source}")
    evolves_into = sorted(dex.evos.get(name, ()))
    if evolves_into:
        print(f"    evolves into {', '.join(evolves_into)}")
    return 0


def main(argv=None):
    here = os.path.dirname(os.path.abspath(__file__))
    default_root = os.path.dirname(here)

    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", default=default_root,
                    help="repository root (default: the parent of this script)")
    ap.add_argument("--why", metavar="SPECIES",
                    help="show where one species comes from, then exit")
    ap.add_argument("--sources", action="store_true",
                    help="list every source, species by species")
    ap.add_argument("--json", metavar="PATH",
                    help="write the derived sets to a JSON file")
    args = ap.parse_args(argv)

    repo = Repo(args.root)
    warnings = []
    result = audit(repo, warnings)
    for warning in warnings:
        print(f"warning: {warning}", file=sys.stderr)

    if args.why:
        return why(result, args.why)

    report(result, args.sources)

    if args.json:
        dex, sources = result["dex"], result["sources"]
        dump = {
            "species": dex.species,
            "unobtainable": result["missing"],
            "never_on_trainer_team": result["never_on_team"],
            "directly_owned": sorted(result["directly_owned"]),
            "sources": {s: {k: v for k, v in sources.kinds(s).items()}
                        for s in dex.species if sources.kinds(s)},
            "evolutions": {s: sorted(t) for s, t in dex.evos.items()},
            "counts": result["counts"],
        }
        with open(args.json, "w", encoding="utf-8") as fh:
            json.dump(dump, fh, indent=1, sort_keys=True)
        print(f"\nwrote {args.json}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
