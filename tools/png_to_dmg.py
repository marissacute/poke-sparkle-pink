#!/usr/bin/env python3
"""Convert a colour drawing from drawings/ into the repo's DMG sprite format.

`rgbgfx --colors dmg` refuses any image whose palette holds a non-grey colour,
and the 2bpp value it gives a pixel comes from that colour's *luminance*. So the
conversion is: leave the pixel samples alone, and rewrite the palette so each
entry becomes the DMG grey matching its luminance rank (lightest -> #FFFFFF,
darkest -> #000000). Samples, IDAT and every other chunk are copied verbatim,
so the result differs from the source in the PLTE bytes only.

It also prints the palette to paste into data/sgb/sgb_palettes.asm: the two mid
tones, 8-bit to 5-bit by `>>3` (truncation), lighter tone first.

Usage:
    tools/png_to_dmg.py drawings/glaceon.png gfx/pokemon/gsfront/glaceon.png
    tools/png_to_dmg.py --check gfx/pokemon/gsfront/glaceon.png
"""

from __future__ import annotations

import argparse
import struct
import sys
import zlib

DMG_GREYS = [(0xFF, 0xFF, 0xFF), (0xAA, 0xAA, 0xAA), (0x55, 0x55, 0x55), (0x00, 0x00, 0x00)]


def luminance(rgb: tuple[int, int, int]) -> float:
    r, g, b = rgb
    return 0.299 * r + 0.587 * g + 0.114 * b


def read_chunks(data: bytes) -> list[tuple[bytes, bytes]]:
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("not a PNG")
    chunks = []
    i = 8
    while i < len(data):
        length = struct.unpack(">I", data[i : i + 4])[0]
        kind = data[i + 4 : i + 8]
        chunks.append((kind, data[i + 8 : i + 8 + length]))
        i += 12 + length
    return chunks


def write_chunk(kind: bytes, payload: bytes) -> bytes:
    crc = zlib.crc32(kind + payload) & 0xFFFFFFFF
    return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", crc)


def ihdr_info(chunks) -> tuple[int, int, int, int]:
    for kind, payload in chunks:
        if kind == b"IHDR":
            w, h, depth, colour_type = struct.unpack(">IIBB", payload[:10])
            return w, h, depth, colour_type
    raise ValueError("no IHDR")


def palette_of(chunks) -> list[tuple[int, int, int]]:
    for kind, payload in chunks:
        if kind == b"PLTE":
            if len(payload) % 3 or not payload:
                raise ValueError("malformed PLTE")
            return [tuple(payload[i : i + 3]) for i in range(0, len(payload), 3)]
    raise ValueError("no PLTE - image is not indexed; re-export it as 2-bit indexed")


def grey_by_rank(colours: list[tuple[int, int, int]]) -> list[tuple[int, int, int]]:
    """Each entry becomes the DMG grey of its luminance rank, lightest first."""
    order = sorted(range(len(colours)), key=lambda i: -luminance(colours[i]))
    if len(colours) != len(DMG_GREYS):
        raise ValueError(f"expected {len(DMG_GREYS)} palette entries, found {len(colours)}")
    out: list[tuple[int, int, int]] = [(0, 0, 0)] * len(colours)
    for rank, index in enumerate(order):
        out[index] = DMG_GREYS[rank]
    return out


def five_bit(rgb: tuple[int, int, int]) -> tuple[int, int, int]:
    return tuple(channel >> 3 for channel in rgb)  # truncation, not rounding


def render_palette(colours: list[tuple[int, int, int]]) -> str:
    order = sorted(range(len(colours)), key=lambda i: -luminance(colours[i]))
    darker, lighter = colours[order[2]], colours[order[1]]
    light5, dark5 = five_bit(lighter), five_bit(darker)
    return (
        f"; light {lighter} -> {light5}, dark {darker} -> {dark5}\n"
        f"\tRGB 31,31,31, "
        + ", ".join(f"{c:02d}" for c in light5)
        + ", "
        + ", ".join(f"{c:02d}" for c in dark5)
        + ", 00,00,00"
    )


def convert(src: str, dst: str) -> None:
    data = open(src, "rb").read()
    chunks = read_chunks(data)
    w, h, depth, colour_type = ihdr_info(chunks)
    if colour_type != 3:
        raise ValueError(f"colour type {colour_type}, expected 3 (indexed)")
    before = palette_of(chunks)
    after = grey_by_rank(before)

    out = [data[:8]]
    for kind, payload in chunks:
        if kind == b"PLTE":
            payload = b"".join(bytes(rgb) for rgb in after)
        out.append(write_chunk(kind, payload))
    with open(dst, "wb") as f:
        f.write(b"".join(out))

    print(f"{src} -> {dst}  ({w}x{h}, {depth}-bit indexed)")
    for index, (was, now) in enumerate(zip(before, after)):
        print(f"  [{index}] #{was[0]:02X}{was[1]:02X}{was[2]:02X} -> #{now[0]:02X}{now[1]:02X}{now[2]:02X}")
    print(render_palette(before))


def check(path: str) -> int:
    """Confirm a committed sprite is already in DMG form."""
    chunks = read_chunks(open(path, "rb").read())
    w, h, depth, colour_type = ihdr_info(chunks)
    colours = palette_of(chunks) if colour_type == 3 else []
    if colour_type == 0:
        print(f"{path}: {w}x{h}, {depth}-bit greyscale - ok for rgbgfx --colors dmg")
        return 0
    if colour_type == 3 and all(c in DMG_GREYS for c in colours):
        print(f"{path}: {w}x{h}, indexed with DMG greys only - ok")
        return 0
    print(f"{path}: {w}x{h}, colour type {colour_type} - would fail rgbgfx --colors dmg")
    for index, rgb in enumerate(colours):
        print(f"  [{index}] #{rgb[0]:02X}{rgb[1]:02X}{rgb[2]:02X}")
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("src", nargs="?", help="source PNG (colour drawing)")
    parser.add_argument("dst", nargs="?", help="destination PNG to write")
    parser.add_argument("--check", metavar="PNG", help="only report whether a PNG is DMG-safe")
    args = parser.parse_args()

    if args.check:
        return check(args.check)
    if not args.src or not args.dst:
        parser.error("need SRC and DST (or --check PNG)")
    try:
        convert(args.src, args.dst)
    except (ValueError, OSError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
