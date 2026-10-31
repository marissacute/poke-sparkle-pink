#!/usr/bin/env python3
"""Build the stitched Kanto map used by the Fly cutscene.

There are two layers, both stored as ordinary editable .blk files:

    maps/Flyover.174x180.overworld.blk      whole world, OVERWORLD blocks
    maps/FlyoverPlateau.17x84.plateau.blk   plateau maps + edge ring, PLATEAU

Polished Map reads the size and tileset from the filename, so these files can
be opened directly (File > Open, drag-and-drop, or polishedmap.exe <file>).
The main map's 17x84 area at global block (0,1) is replaced by the plateau
overlay when the ROM data is built.

Each map's object file specifies a border block for tiles outside its
dimensions.  Stitching uses those blocks for the 3-block edge ring around
each map; gaps beyond that use a neutral wilderness fill.

`stitch` recreates both .blk files from the real map headers/connections/.blk
data, which OVERWRITES artist edits.  Run it only when the real maps change.
`build` combines the two .blk files into the two ROM banks:

    gfx/flyover/kanto_blocks_1.bin   rows 0..89   (174 * 90 bytes)
    gfx/flyover/kanto_blocks_2.bin   rows 90..179 (174 * 90 bytes)

Block IDs use bit 7 to mark PLATEAU blocks in the combined data.  Empty cells
are filled with a deterministic mix of grass, tree and flower blocks so the
large holes between the real routes read as wilderness.

    python3 tools/gen_flyover_map.py stitch   # re-stitch from the real maps
    python3 tools/gen_flyover_map.py build    # .blk edits -> ROM data
"""

import glob
import os
import re
import sys
from collections import Counter, deque

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

OUT_GFX = "gfx/flyover"
OUT_DATA = "data/flyover"
GFX1 = os.path.join(OUT_GFX, "kanto_blocks_1.bin")
GFX2 = os.path.join(OUT_GFX, "kanto_blocks_2.bin")
TABLES = os.path.join(OUT_DATA, "tables.asm")
BLK_MAIN = "maps/Flyover.174x180.overworld.blk"
BLK_PLATEAU = "maps/FlyoverPlateau.17x84.plateau.blk"

MAP_WIDTH = 174
MAP_HEIGHT = 180
BORDER_MARGIN = 3  # MAP_BORDER: the game draws this many blocks outside a map
# The plateau layer covers Route 23/Indigo plus the surrounding edge ring.
# Its south side is the Route 22 connection, so it is not expanded downward.
PLATEAU_BOX = (0, 1, 17, 84)  # x, y, width, height in global blocks

CELL_VOID = 0x100  # internal marker, replaced below
TILESET_BIT = 0x80

# Blocks used to fill the holes between maps.  These are ordinary OVERWORLD
# blocks (checked below): 0x0A is plain grass, 0x0F a dense tree block and
# 0x74 grass with flowers.  Scattering them keeps the large gaps between the
# real routes from looking like a flat green field.
VOID_GRASS_BLOCK = None   # chosen automatically (most common GREEN block)
VOID_TREE_BLOCK = 0x0F
VOID_FLOWER_BLOCK = 0x74


def fail(msg):
    raise SystemExit("gen_flyover_map: " + msg)


def parse_map_constants():
    """Return {name: (id, width, height)} in declaration order."""
    consts = {}
    order = []
    path = "constants/map_constants.asm"
    with open(path) as f:
        for line in f:
            m = re.match(r"\s*map_const\s+(\w+)\s*,\s*(\d+)\s*,\s*(\d+)", line)
            if m:
                name = m.group(1)
                consts[name] = (len(order), int(m.group(2)), int(m.group(3)))
                order.append(name)
    if "PALLET_TOWN" not in consts:
        fail("could not parse map_const entries")
    return consts, order


def parse_headers(consts):
    """Return {map_const_name: {label, tileset, connections}} for outdoor maps."""
    maps = {}
    for path in sorted(glob.glob("data/maps/headers/*.asm")):
        label = map_id = tileset = None
        conns = []
        with open(path) as f:
            for line in f:
                m = re.match(r"\s*map_header\s+(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*,\s*(.*)", line)
                if m:
                    label = m.group(1)
                    map_id = m.group(2)
                    tileset = m.group(3)
                    continue
                m = re.match(r"\s*connection\s+(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*,\s*(-?\d+)", line)
                if m and label is not None:
                    conns.append((m.group(1), m.group(2), m.group(3), int(m.group(4))))
        if label is not None and map_id in consts:
            maps[map_id] = {
                "label": label,
                "tileset": tileset,
                "connections": conns,
            }
    if not maps:
        fail("could not parse map headers")
    return maps


def place_maps(maps, consts):
    """BFS the connection graph; return {map_const: (x, y)} in blocks."""
    origins = {"PALLET_TOWN": (0, 0)}
    todo = deque(["PALLET_TOWN"])
    while todo:
        src = todo.popleft()
        sx, sy = origins[src]
        _, sw, sh = consts[src]
        for direction, _label, target, offset in maps[src]["connections"]:
            if target not in consts:
                fail("connection from %s names unknown map %s" % (src, target))
            _, tw, th = consts[target]
            if direction == "north":
                pos = (sx + offset, sy - th)
            elif direction == "south":
                pos = (sx + offset, sy + sh)
            elif direction == "west":
                pos = (sx - tw, sy + offset)
            elif direction == "east":
                pos = (sx + sw, sy + offset)
            else:
                fail("bad connection direction %r" % direction)
            if target in origins:
                if origins[target] != pos:
                    fail(
                        "%s -> %s (%s) lands at %s, already placed at %s"
                        % (src, target, direction, pos, origins[target])
                    )
            else:
                origins[target] = pos
                todo.append(target)
    return origins


def normalize(origins, consts):
    min_x = min(origins[m][0] for m in origins)
    min_y = min(origins[m][1] for m in origins)
    max_x = max(origins[m][0] + consts[m][1] for m in origins)
    max_y = max(origins[m][1] + consts[m][2] for m in origins)
    norm = {m: (x - min_x, y - min_y) for m, (x, y) in origins.items()}
    return norm, max_x - min_x, max_y - min_y


def read_blk(label, width, height):
    path = "maps/%s.blk" % label
    with open(path, "rb") as f:
        data = f.read()
    if len(data) != width * height:
        fail("%s is %d bytes, expected %d" % (path, len(data), width * height))
    return data


def read_border_block(label):
    """Read the map's border block from data/maps/objects/<Label>.asm."""
    path = "data/maps/objects/%s.asm" % label
    with open(path) as f:
        text = f.read()
    m = re.search(r"^\s*db\s+\$([0-9A-Fa-f]+)\s*;\s*border block", text, re.M)
    if m:
        return int(m.group(1), 16)
    m = re.search(r"^\s*db\s+(\d+)\s*;\s*border block", text, re.M)
    if m:
        return int(m.group(1), 10)
    fail("could not find border block in %s" % path)


def rect_distance(x, y, ox, oy, w, h):
    """Chebyshev distance from a cell to a map rectangle (0 inside)."""
    if x < ox:
        dx = ox - x
    elif x >= ox + w:
        dx = x - (ox + w - 1)
    else:
        dx = 0
    if y < oy:
        dy = oy - y
    elif y >= oy + h:
        dy = y - (oy + h - 1)
    else:
        dy = 0
    return max(dx, dy)


def nearest_map(x, y, entries):
    """entries: (map_const, ox, oy, w, h, border).  Ties keep map-ID order."""
    best = None
    for entry in entries:
        _, ox, oy, w, h, _border = entry
        d = rect_distance(x, y, ox, oy, w, h)
        if best is None or d < best[0]:
            best = (d, entry)
    return best


def parse_tilepals(path):
    names = ["GRAY", "RED", "GREEN", "WATER", "YELLOW", "BROWN", "ROOF", "TEXT"]
    values = []
    with open(path) as f:
        for line in f:
            if "tilepal" not in line:
                continue
            body = line.split(",", 1)[1]
            for token in body.split(","):
                token = token.strip()
                if token in names:
                    values.append(names.index(token))
                elif re.match(r"PRIORITY", token):
                    pass
                elif token:
                    fail("unknown tilepal token %r in %s" % (token, path))
    return values


def choose_void_block(grid, origins, consts, maps, blocksets, palettes):
    """Pick the most common GREEN-dominant overworld block as generic land."""
    yellow = Counter()
    green = Counter()
    for map_const, (mx, my) in origins.items():
        if maps[map_const]["tileset"] != "OVERWORLD":
            continue
        _, w, h = consts[map_const]
        blk = read_blk(maps[map_const]["label"], w, h)
        blockset = blocksets["OVERWORLD"]
        pal = palettes["OVERWORLD"]
        for block_id in blk:
            tiles = blockset[block_id]
            counts = Counter(pal[t] for t in tiles if t < len(pal))
            if not counts:
                continue
            dominant = max(counts.items(), key=lambda kv: (kv[1], kv[0]))[0]
            if dominant == 2:  # GREEN
                green[block_id] += 1
            if dominant == 4:  # YELLOW
                yellow[block_id] += 1
    if green:
        return green.most_common(1)[0][0], green.most_common(5)
    if yellow:
        return yellow.most_common(1)[0][0], yellow.most_common(5)
    return 0, []


def compute_plateau_box(origins, consts, maps):
    """Return (x, y, w, h) of the smallest rectangle holding all PLATEAU maps."""
    xs = []
    ys = []
    for name, (ox, oy) in origins.items():
        if maps[name]["tileset"] != "PLATEAU":
            continue
        _, w, h = consts[name]
        xs.extend((ox, ox + w))
        ys.extend((oy, oy + h))
    if not xs:
        fail("no PLATEAU maps found")
    x0, y0 = min(xs), min(ys)
    return x0, y0, max(xs) - x0, max(ys) - y0


def expand_plateau_box(exact, origins, consts, maps):
    """Grow the plateau layer by the game's edge margin, without covering maps.

    The southern side of Route 23 is the Route 22 connection, so expanding
    across it would overwrite a real outdoor map; that edge stays put.
    """
    ex, ey, ew, eh = exact
    x0 = max(0, ex - BORDER_MARGIN)
    y0 = max(0, ey - BORDER_MARGIN)
    x1 = min(MAP_WIDTH, ex + ew + BORDER_MARGIN)
    y1 = min(MAP_HEIGHT, ey + eh + BORDER_MARGIN)

    def overlaps_non_plateau():
        for name, (ox, oy) in origins.items():
            if maps[name]["tileset"] == "PLATEAU":
                continue
            _, w, h = consts[name]
            if ox < x1 and ox + w > x0 and oy < y1 and oy + h > y0:
                return True
        return False

    if overlaps_non_plateau():
        y1 = ey + eh
        if overlaps_non_plateau():
            fail("cannot expand the plateau overlay without covering another map")
    return x0, y0, x1 - x0, y1 - y0


def choose_plateau_fill(origins, consts, maps):
    """Pick the most common PLATEAU block as the overlay's generic land."""
    counts = Counter()
    for name, (ox, oy) in origins.items():
        if maps[name]["tileset"] != "PLATEAU":
            continue
        _, w, h = consts[name]
        counts.update(read_blk(maps[name]["label"], w, h))
    if not counts:
        fail("no PLATEAU blocks found")
    return counts.most_common(1)[0][0]


def read_fly_destinations(consts, origins):
    """Return {city_map_const: (x_pixels, y_pixels)}."""
    city_names = [
        "PALLET_TOWN", "VIRIDIAN_CITY", "PEWTER_CITY", "CERULEAN_CITY",
        "LAVENDER_TOWN", "VERMILION_CITY", "CELADON_CITY", "FUCHSIA_CITY",
        "CINNABAR_ISLAND", "INDIGO_PLATEAU", "SAFFRON_CITY",
    ]
    found = {}
    path = "data/maps/special_warps.asm"
    with open(path) as f:
        for line in f:
            m = re.match(r"\s*\.\w+:\s*fly_warp\s+(\w+)\s*,\s*(\d+)\s*,\s*(\d+)", line)
            if not m:
                continue
            map_const, x, y = m.group(1), int(m.group(2)), int(m.group(3))
            if map_const not in city_names:
                continue
            if map_const not in origins:
                fail("fly destination %s is not in the stitched layout" % map_const)
            ox, oy = origins[map_const]
            found[map_const] = (ox * 32 + x * 16 + 8, oy * 32 + y * 16 + 8)
    missing = [c for c in city_names if c not in found]
    if missing:
        fail("missing fly_warp entries for: %s" % ", ".join(missing))
    return [found[c] for c in city_names]


def emit_tables(origins, consts, width, height, dest_coords, plateau_palettes,
                void_block, plateau_box, plateau_fill):
    lines = []
    lines.append("; Generated by tools/gen_flyover_map.py -- do not edit by hand.")
    lines.append("")
    lines.append("DEF FLYOVER_VOID_BLOCK EQU $%02X" % void_block)
    lines.append("DEF FLYOVER_VOID_TREE_BLOCK EQU $%02X" % VOID_TREE_BLOCK)
    lines.append("DEF FLYOVER_VOID_FLOWER_BLOCK EQU $%02X" % VOID_FLOWER_BLOCK)
    lines.append("DEF FLYOVER_MAP_WIDTH_BLOCKS EQU %d" % width)
    lines.append("DEF FLYOVER_MAP_HEIGHT_BLOCKS EQU %d" % height)
    lines.append("DEF FLYOVER_MAP_WIDTH_PX EQU %d" % (width * 32))
    lines.append("DEF FLYOVER_MAP_HEIGHT_PX EQU %d" % (height * 32))
    lines.append("DEF FLYOVER_SPLIT_ROW EQU 90")
    lines.append("DEF FLYOVER_BORDER_MARGIN EQU %d" % BORDER_MARGIN)
    lines.append("DEF FLYOVER_PLATEAU_X EQU %d" % plateau_box[0])
    lines.append("DEF FLYOVER_PLATEAU_Y EQU %d" % plateau_box[1])
    lines.append("DEF FLYOVER_PLATEAU_WIDTH EQU %d" % plateau_box[2])
    lines.append("DEF FLYOVER_PLATEAU_HEIGHT EQU %d" % plateau_box[3])
    lines.append("DEF FLYOVER_PLATEAU_VOID_BLOCK EQU $%02X" % plateau_fill)
    lines.append("")
    lines.append("FlyoverMapOrigins:")
    lines.append("\ttable_width 5")
    lines.append("\t; valid, pixel x, pixel y, indexed by map ID ($00-$24)")
    for map_id in range(0x25):
        entry = None
        for name, (const_id, _w, _h) in consts.items():
            if const_id == map_id:
                entry = name
                break
        if entry is None or entry not in origins:
            lines.append("\tdb 0\n\tdw 0\n\tdw 0")
            continue
        ox, oy = origins[entry]
        lines.append("\tdb 1")
        lines.append("\tdw %d" % (ox * 32))
        lines.append("\tdw %d" % (oy * 32))
    lines.append("\tassert_table_length $25")
    lines.append("")
    lines.append("FlyoverDestCoords:")
    lines.append("\ttable_width 4")
    lines.append("\t; pixel x, pixel y, indexed by city map ID")
    for x, y in dest_coords:
        lines.append("\tdw %d" % x)
        lines.append("\tdw %d" % y)
    lines.append("\tassert_table_length NUM_CITY_MAPS")
    lines.append("")
    lines.append("FlyoverPlateauPalettes:")
    for i in range(0, len(plateau_palettes), 16):
        chunk = plateau_palettes[i:i + 16]
        lines.append("\tdb " + ", ".join(str(v) for v in chunk))
    lines.append("\tassert @ - FlyoverPlateauPalettes == 70")
    lines.append("")
    with open(TABLES, "w") as f:
        f.write("\n".join(lines))


def stitch():
    """Recreate both editable .blk layers from the real map data."""
    consts, _const_order = parse_map_constants()
    maps = parse_headers(consts)
    origins = place_maps(maps, consts)

    # Check that every placed map is an outdoor map and vice versa.
    outdoor = {
        name for name, (const_id, _w, _h) in consts.items()
        if const_id < 0x25 and name != "UNUSED_MAP_0B"
    }
    if set(origins) != outdoor:
        fail(
            "placed %d maps, expected %d outdoor maps; missing=%s extra=%s"
            % (len(origins), len(outdoor), sorted(outdoor - set(origins)), sorted(set(origins) - outdoor))
        )

    origins, width, height = normalize(origins, consts)
    if (width, height) != (MAP_WIDTH, MAP_HEIGHT):
        fail("unexpected layout size %dx%d" % (width, height))

    # Overlap check.
    owner = {}
    for name, (ox, oy) in origins.items():
        _, w, h = consts[name]
        for yy in range(h):
            for xx in range(w):
                cell = (ox + xx, oy + yy)
                if cell in owner:
                    fail("overlap at %s: %s and %s" % (cell, owner[cell], name))
                owner[cell] = name
    if len(owner) != 10881:
        fail("occupied block count %d, expected 10881" % len(owner))

    # Blocksets and palettes used to pick a plain land block for the holes.
    with open("gfx/blocksets/overworld.bst", "rb") as f:
        bst_over = list(f.read())
    with open("gfx/blocksets/plateau.bst", "rb") as f:
        bst_plat = list(f.read())
    blocksets = {
        "OVERWORLD": [bst_over[i * 16:(i + 1) * 16] for i in range(len(bst_over) // 16)],
        "PLATEAU": [bst_plat[i * 16:(i + 1) * 16] for i in range(len(bst_plat) // 16)],
    }
    palettes = {
        "OVERWORLD": parse_tilepals("color/tilesets/overworld.asm"),
        "PLATEAU": parse_tilepals("color/tilesets/plateau.asm"),
    }
    if len(palettes["OVERWORLD"]) != 94 or len(palettes["PLATEAU"]) != 70:
        fail("unexpected tilepal counts: %s" % {k: len(v) for k, v in palettes.items()})

    void_block, candidates = choose_void_block(
        None, origins, consts, maps, blocksets, palettes
    )
    if void_block & TILESET_BIT:
        fail("void block has bit 7 set")

    # Validate the decorative fill blocks against the OVERWORLD tileset.
    for block in (VOID_TREE_BLOCK, VOID_FLOWER_BLOCK):
        if block >= len(blocksets["OVERWORLD"]):
            fail("void fill block $%02x is outside the overworld blockset" % block)
        for tile in blocksets["OVERWORLD"][block]:
            if tile >= len(palettes["OVERWORLD"]):
                fail("void fill block $%02x uses tile $%02x outside the tileset" % (block, tile))

    # Border blocks are what the game draws outside each map.  Read them from
    # data/maps/objects/<Label>.asm and validate against the map's tileset.
    border = {}
    for name in origins:
        tileset = maps[name]["tileset"]
        block = read_border_block(maps[name]["label"])
        limit = len(blocksets["PLATEAU" if tileset == "PLATEAU" else "OVERWORLD"])
        if block >= limit:
            fail("%s border block $%02x is outside the %s blockset"
                 % (maps[name]["label"], block, tileset))
        border[name] = block

    # Main editable layer.  The plateau area is filled with the same
    # wilderness as the rest; the plateau overlay replaces it in build().
    grid = bytearray(width * height)
    for y in range(height):
        for x in range(width):
            h = ((x * 37) ^ (y * 91)) & 15
            if h == 0:
                grid[y * width + x] = VOID_TREE_BLOCK
            elif h == 1:
                grid[y * width + x] = VOID_FLOWER_BLOCK
            else:
                grid[y * width + x] = void_block
    plateau_count = 0
    for map_const, (ox, oy) in origins.items():
        _, w, h = consts[map_const]
        data = read_blk(maps[map_const]["label"], w, h)
        plateau = maps[map_const]["tileset"] == "PLATEAU"
        for y in range(h):
            for x in range(w):
                block = data[y * w + x]
                if block & TILESET_BIT:
                    fail("%s block $%02x has bit 7 set" % (maps[map_const]["label"], block))
                if plateau:
                    if block >= len(blocksets["PLATEAU"]):
                        fail("%s block $%02x is outside the plateau blockset"
                             % (maps[map_const]["label"], block))
                    plateau_count += 1
                else:
                    grid[(oy + y) * width + ox + x] = block

    if plateau_count == 0:
        fail("no PLATEAU blocks found")

    # Give every overworld map its own 3-block edge ring, using the border
    # block that map specifies for tiles outside its dimensions.  Deeper gaps
    # keep the neutral wilderness fill: the game never defines those cells.
    main_entries = []
    for name, (ox, oy) in sorted(origins.items(), key=lambda kv: consts[kv[0]][0]):
        if maps[name]["tileset"] == "PLATEAU":
            continue
        _, w, h = consts[name]
        main_entries.append((name, ox, oy, w, h, border[name]))
    for y in range(height):
        for x in range(width):
            if (x, y) in owner:
                continue
            best = nearest_map(x, y, main_entries)
            if best is not None and best[0] <= BORDER_MARGIN:
                grid[y * width + x] = best[1][5]

    # Second editable layer: Route 23 / Indigo Plateau plus their edge ring.
    exact = compute_plateau_box(origins, consts, maps)
    box = expand_plateau_box(exact, origins, consts, maps)
    if box != PLATEAU_BOX:
        fail("expanded plateau box changed from %s to %s" % (PLATEAU_BOX, box))
    bx, by, bw, bh = box
    plateau_fill = choose_plateau_fill(origins, consts, maps)
    if plateau_fill >= len(blocksets["PLATEAU"]):
        fail("plateau fill block $%02x is outside the plateau blockset" % plateau_fill)
    plat_entries = []
    for name, (ox, oy) in sorted(origins.items(), key=lambda kv: consts[kv[0]][0]):
        if maps[name]["tileset"] != "PLATEAU":
            continue
        _, w, h = consts[name]
        plat_entries.append((name, ox, oy, w, h, border[name]))
    plat = bytearray([plateau_fill]) * (bw * bh)
    for map_const, (ox, oy) in origins.items():
        if maps[map_const]["tileset"] != "PLATEAU":
            continue
        _, w, h = consts[map_const]
        data = read_blk(maps[map_const]["label"], w, h)
        for y in range(h):
            for x in range(w):
                plat[(oy - by + y) * bw + (ox - bx + x)] = data[y * w + x]
    for y in range(by, by + bh):
        for x in range(bx, bx + bw):
            if (x, y) in owner:
                if maps[owner[(x, y)]]["tileset"] != "PLATEAU":
                    fail("plateau overlay covers %s at (%d,%d)"
                         % (owner[(x, y)], x, y))
                continue
            best = nearest_map(x, y, plat_entries)
            if best is None:
                fail("no plateau map near (%d,%d)" % (x, y))
            plat[(y - by) * bw + (x - bx)] = best[1][5]

    dest_coords = read_fly_destinations(consts, origins)

    os.makedirs(OUT_GFX, exist_ok=True)
    os.makedirs(OUT_DATA, exist_ok=True)
    with open(BLK_MAIN, "wb") as f:
        f.write(grid)
    with open(BLK_PLATEAU, "wb") as f:
        f.write(plat)
    emit_tables(origins, consts, width, height, dest_coords, palettes["PLATEAU"],
                void_block, box, plateau_fill)

    print("layout: %d x %d blocks, %d occupied, %d plateau blocks"
          % (width, height, len(owner), plateau_count))
    print("void block: $%02X (candidates %s)" % (void_block, candidates))
    print("plateau overlay: %dx%d at (%d,%d), fill $%02X"
          % (bw, bh, bx, by, plateau_fill))
    print("wrote %s (%d bytes) and %s (%d bytes)"
          % (BLK_MAIN, os.path.getsize(BLK_MAIN), BLK_PLATEAU, os.path.getsize(BLK_PLATEAU)))
    print("wrote %s" % TABLES)
    build()


def build():
    """Combine the editable .blk layers into the two ROM banks."""
    for path in (BLK_MAIN, BLK_PLATEAU):
        if not os.path.exists(path):
            fail("%s is missing; run 'python3 tools/gen_flyover_map.py stitch' first" % path)

    with open(BLK_MAIN, "rb") as f:
        main = f.read()
    with open(BLK_PLATEAU, "rb") as f:
        plat = f.read()

    if len(main) != MAP_WIDTH * MAP_HEIGHT:
        fail("%s is %d bytes, expected %d"
             % (BLK_MAIN, len(main), MAP_WIDTH * MAP_HEIGHT))
    bx, by, bw, bh = PLATEAU_BOX
    if len(plat) != bw * bh:
        fail("%s is %d bytes, expected %d" % (BLK_PLATEAU, len(plat), bw * bh))

    for i, block in enumerate(main):
        if block & TILESET_BIT:
            fail("%s: block %d ($%02x) has bit 7 set"
                 % (BLK_MAIN, i, block))

    with open("gfx/blocksets/plateau.bst", "rb") as f:
        plateau_blocks = len(f.read()) // 16
    for i, block in enumerate(plat):
        if block >= plateau_blocks:
            fail("%s: block %d ($%02x) is outside the plateau blockset"
                 % (BLK_PLATEAU, i, block))

    grid = bytearray(main)
    for y in range(bh):
        for x in range(bw):
            grid[(by + y) * MAP_WIDTH + bx + x] = TILESET_BIT | plat[y * bw + x]

    os.makedirs(OUT_GFX, exist_ok=True)
    with open(GFX1, "wb") as f:
        f.write(grid[:MAP_WIDTH * 90])
    with open(GFX2, "wb") as f:
        f.write(grid[MAP_WIDTH * 90:])
    print("built %s (%d bytes) and %s (%d bytes)"
          % (GFX1, os.path.getsize(GFX1), GFX2, os.path.getsize(GFX2)))


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "stitch"
    if mode == "stitch":
        stitch()
    elif mode == "build":
        build()
    else:
        fail("usage: python3 tools/gen_flyover_map.py [stitch|build]")


if __name__ == "__main__":
    main()
