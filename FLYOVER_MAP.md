# Editing the Fly flyover map

The real-map Fly cutscene uses a build-time stitched map of all 36 outdoor
Kanto maps. It is stored as two ordinary `.blk` layers that can be edited in
Polished Map:

| File | Size | Tileset | Contents |
|---|---|---|---|
| `maps/Flyover.174x180.overworld.blk` | 174x180 | OVERWORLD | The whole world. Cities, routes, water and the wilderness gaps. |
| `maps/FlyoverPlateau.17x84.plateau.blk` | 17x84 | PLATEAU | Route 23, Indigo Plateau, and their edge ring. Its top-left is global block (0,1). |

The main map's 17x84 area at global block (0,1) is replaced by the plateau
overlay when the ROM data is built, so edit Route 23 / Indigo Plateau and the
plateau's edges in the plateau file, not in the main file.

## Edge tiles

Each map's object file starts with `db $XX ; border block`. That is the block
the game draws outside the map's dimensions. Stitching reads those values and
uses the nearest map's border block for the **3-block ring** around that map
(the same `MAP_BORDER` the engine uses). Where two maps meet, the map cells
already cover the ring, exactly as connections overwrite the border in-game.
Gaps deeper than 3 blocks are not defined by the game, so they use the neutral
grass/tree/flower wilderness fill.

All 36 maps are covered: the overworld layer uses the OVERWORLD borders, and
the plateau overlay uses the PLATEAU borders for Route 23 and Indigo Plateau.

## Opening the files

The filenames encode the map size and tileset
(`Name.WIDTHxHEIGHT.TILESET.blk`), so the bundled Polished Map can open them
without adding entries to `constants/map_constants.asm`:

```bat
tools\polishedmap.exe maps\Flyover.174x180.overworld.blk
tools\polishedmap.exe maps\FlyoverPlateau.17x84.plateau.blk
```

Polished Map may warn that the map is larger than the game's 1300-byte
overworld buffer. That warning is expected: this map is not loaded as a normal
map; it is expanded a few blocks at a time by the cutscene's custom view
builder.

The main map uses block IDs 0-127 (the OVERWORLD blockset). The plateau overlay
uses block IDs 0-72 (the PLATEAU blockset). Hand-editing the border rings and
the wilderness gaps is supported.

## Building

- `make` automatically rebuilds `gfx/flyover/kanto_blocks_1.bin` and
  `gfx/flyover/kanto_blocks_2.bin` when either `.blk` file changes.
- `make flyover-build` forces that conversion.
- `make flyover-stitch` recreates both `.blk` files from the real map headers,
  connections and `.blk` data. **This overwrites artist edits.** Only run it
  after changing the real Kanto maps.
