#!/usr/bin/env python3
"""Merge the four outdoor Safari Zone maps into the Fly flyover world map.

The Safari Zone areas are ordinary outdoor maps, but they use the FOREST
tileset, so they are not part of the stitched OVERWORLD/PLATEAU flyover map.
This tool overlays them onto the existing editable flyover layer:

    maps/Flyover.174x180.overworld.blk

It deliberately does NOT run the stitcher.  The current .blk is read as-is,
the four Safari Zone rectangles are replaced, and every other cell is kept
byte-for-byte.  maps/FlyoverPlateau.17x84.plateau.blk and
maps/Flyover.174x180.overworld.edited.blk are never touched.

FOREST -> OVERWORLD block substitution
--------------------------------------
The two tilesets do not share art, and the Safari Zone's art has no exact
OVERWORLD equivalent.  Blocks are mapped by what they depict, using the
OVERWORLD art that reads the same at flyover scale:

  plain grass / walkable grass textures -> $0A plain grass
  tall grass (FOREST tile $20)          -> $0B tall grass (OVERWORLD tile $52)
  trees (FOREST tiles $54-$57)          -> $0F tree block
  grass with a red flower               -> $74 grass with flowers
  brown dirt path                       -> $2C mottled brown ground
  dirt path checker edge (right/bottom) -> $29 / $57, corner -> $2B
  water                                 -> $43, with brown shores on the
                                           matching side ($1D/$1E/$1F/$64/$65)
  wooden fences / fence posts           -> $0F (hedge / tree line)
  rest house (tile $01 windows)         -> $02 gate + $12 house
  small signposts                       -> $79 sign on ground

The Safari Zone areas are connected by edge warps, not map connections, so
placement is free.  The layout below puts Center directly north of Fuchsia
City's Safari Zone Gate (its south opening at Center block 7,12 lands on the
gate), West/East beside it and North above it.  The Center rectangle is
currently untouched by the artist's edits; the surrounding water and forest
are preserved everywhere outside the four rectangles.

Usage:
    python3 tools/merge_safari_zone.py            # apply the merge
    python3 tools/merge_safari_zone.py --dry-run  # report only
"""

import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

MAIN = "maps/Flyover.174x180.overworld.blk"
MAP_WIDTH = 174
MAP_HEIGHT = 180

# The four outdoor areas, in world-block coordinates.
#   name: (file label, x, y, width, height)
SAFARI_MAPS = [
    ("SafariZoneWest",   "SafariZoneWest",   71, 122, 15, 13),
    ("SafariZoneCenter", "SafariZoneCenter", 86, 122, 15, 13),
    ("SafariZoneEast",   "SafariZoneEast",  101, 122, 15, 13),
    ("SafariZoneNorth",  "SafariZoneNorth",  83, 104, 20, 18),
]

# FOREST block -> OVERWORLD block.  Every block used by the four maps must
# appear here; the tool refuses to run otherwise.
CONVERT = {
    # Tall grass: FOREST tile $20.  Full and edge blocks become full grass.
    0x01: 0x0B,
    0x22: 0x0B,
    0x23: 0x0B,
    0x24: 0x0B,
    0x25: 0x0B,

    # Trees: the round-bush blocks (FOREST tiles $54-$57) and the pink
    # flowering tree (ROOF palette) all read as trees in the OVERWORLD set.
    0x02: 0x0F,
    0x7C: 0x0F,
    0x7D: 0x0F,
    0x7E: 0x0F,
    0x7F: 0x0F,

    # Wooden fences, fence posts and rails become hedge/tree lines.
    0x04: 0x0F,
    0x05: 0x0F,
    0x06: 0x0F,
    0x07: 0x0F,
    0x15: 0x0F,
    0x17: 0x0F,
    0x1D: 0x0F,
    0x21: 0x0F,
    0x26: 0x0F,
    0x27: 0x0F,
    0x33: 0x0F,
    0x35: 0x0F,
    0x39: 0x0F,
    0x48: 0x0F,
    0x49: 0x0F,
    0x4C: 0x0F,
    0x4D: 0x0F,

    # Plain and decorative grass (including the walkable FOREST grass
    # textures $34/$5E and the small tuft tiles).
    0x1B: 0x0A,
    0x20: 0x0A,
    0x28: 0x0A,
    0x2C: 0x0A,
    0x56: 0x0A,
    0x57: 0x0A,
    0x58: 0x0A,
    0x59: 0x0A,

    # Grass with the red flower tile.
    0x29: 0x74,
    0x2E: 0x74,

    # Brown dirt paths.  The interior is mottled brown; the checker border
    # becomes the OVERWORLD's brown path edging on the matching side.
    0x3C: 0x2C,
    0x3D: 0x2C,
    0x3E: 0x29,  # right edge
    0x3F: 0x57,  # bottom edge
    0x40: 0x2C,
    0x41: 0x2C,
    0x42: 0x29,  # right edge
    0x43: 0x2B,  # bottom-right corner
    0x44: 0x57,  # bottom edge
    0x45: 0x57,  # bottom edge
    0x46: 0x2B,  # bottom-right corner
    0x47: 0x57,  # bottom edge
    0x4A: 0x2C,
    0x4B: 0x2C,
    0x53: 0x2B,  # bottom-right corner

    # Water.  FOREST tile $14 is water; $48-$4E are the brown timber edging.
    0x2D: 0x43,  # all water
    0x4F: 0x1D,  # brown top-left corner
    0x50: 0x65,  # grass/water with a left shore
    0x51: 0x1F,  # brown top edge
    0x52: 0x1E,  # brown top + right corner
    0x54: 0x65,  # grass/water with a left shore
    0x55: 0x1D,  # brown top-left corner
    0x5A: 0x65,  # brown left edge
    0x5B: 0x64,  # brown right edge
    0x5C: 0x1D,  # brown top-left corner
    0x5D: 0x64,  # brown right edge
    0x5E: 0x1E,  # brown top-right corner

    # Rest house: F19 is the left/roof half, F1C the windowed half.
    0x19: 0x02,  # gate with a door
    0x1C: 0x12,  # house wall with windows

    # Small wooden signposts.
    0x2A: 0x79,
    0x2B: 0x79,
}


def fail(msg):
    raise SystemExit("merge_safari_zone: " + msg)


def read_blk(label, width, height):
    path = "maps/%s.blk" % label
    with open(path, "rb") as f:
        data = f.read()
    if len(data) != width * height:
        fail("%s is %d bytes, expected %d" % (path, len(data), width * height))
    return data


def used_blocks():
    used = set()
    for _name, label, _x, _y, w, h in SAFARI_MAPS:
        used.update(read_blk(label, w, h))
    return used


def validate():
    used = used_blocks()
    missing = sorted(used - set(CONVERT))
    if missing:
        fail("no OVERWORLD mapping for FOREST block(s): %s"
             % ", ".join("$%02X" % b for b in missing))

    # Every target must be a plain OVERWORLD block id.
    for src, dst in sorted(CONVERT.items()):
        if not 0 <= dst < 0x80:
            fail("FOREST $%02X maps to invalid OVERWORLD block $%02X" % (src, dst))

    # Rectangles must be in bounds and disjoint.
    seen = {}
    for name, _label, x, y, w, h in SAFARI_MAPS:
        if x < 0 or y < 0 or x + w > MAP_WIDTH or y + h > MAP_HEIGHT:
            fail("%s rectangle is outside the flyover map" % name)
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                if (xx, yy) in seen:
                    fail("%s overlaps %s at (%d,%d)" % (name, seen[(xx, yy)], xx, yy))
                seen[(xx, yy)] = name
    return used


def main(argv):
    dry_run = "--dry-run" in argv
    for arg in argv:
        if arg not in ("--dry-run",):
            fail("usage: python3 tools/merge_safari_zone.py [--dry-run]")

    used = validate()

    with open(MAIN, "rb") as f:
        base = bytearray(f.read())
    if len(base) != MAP_WIDTH * MAP_HEIGHT:
        fail("%s is %d bytes, expected %d"
             % (MAIN, len(base), MAP_WIDTH * MAP_HEIGHT))

    before = bytes(base)
    changed = 0
    per_map = []
    for name, label, x, y, w, h in SAFARI_MAPS:
        src = read_blk(label, w, h)
        cells = 0
        for yy in range(h):
            for xx in range(w):
                i = (y + yy) * MAP_WIDTH + x + xx
                out = CONVERT[src[yy * w + xx]]
                if base[i] != out:
                    base[i] = out
                    cells += 1
        per_map.append((name, x, y, w, h, cells))

    changed = sum(1 for a, b in zip(before, base) if a != b)
    counts = {}
    for b in used:
        counts[CONVERT[b]] = counts.get(CONVERT[b], 0) + 1

    print("Safari Zone merge")
    print("  source tileset: FOREST, %d distinct blocks mapped" % len(used))
    print("  target: %s" % MAIN)
    targets = ", ".join("$%02X" % t for t in sorted(counts))
    print("  OVERWORLD blocks used: %s" % targets)
    for name, x, y, w, h, cells in per_map:
        print("  %-17s %2dx%-2d at (%3d,%3d): %d cell%s changed"
              % (name, w, h, x, y, cells, "" if cells == 1 else "s"))
    print("  total cells changed: %d" % changed)

    if dry_run:
        print("dry run: no files written")
        return

    # Write atomically so a failed run cannot leave a half-merged map.
    tmp = MAIN + ".tmp"
    with open(tmp, "wb") as f:
        f.write(base)
    os.replace(tmp, MAIN)
    print("wrote %s (%d bytes)" % (MAIN, len(base)))


if __name__ == "__main__":
    main(sys.argv[1:])
