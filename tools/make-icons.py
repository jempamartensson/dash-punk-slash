#!/usr/bin/env python3
"""Generate the dash-punk isometric icon theme as SVG files.

All icons share one 2:1 isometric projection (horizontals rise 1 unit for
every 2 across), black outlines, three-tone shading (top light, left base,
right dark) and a flat base with a drop shadow. Circles are only used for
spheres.

  tools/make-icons.py [OUTDIR]     default OUTDIR: icons/dash-punk
  tools/make-icons.py --preview F  also write an HTML contact sheet to F
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
OUTLINE = "#0b0b0b"
SELECT = "#f2d33c"   # IRIX: icons turn yellow when selected
DROP = "#2f45c4"     # IRIX: royal blue when something is dropped on them


# ---------------------------------------------------------------- drawing --
def shade(hex_: str, f: float) -> str:
    """f > 0 lightens toward white, f < 0 darkens toward black."""
    r, g, b = (int(hex_[i:i + 2], 16) for i in (1, 3, 5))
    def ch(x: int) -> int:
        y = x + (255 - x) * f if f >= 0 else x * (1 + f)
        return max(0, min(255, round(y)))
    return "#{:02x}{:02x}{:02x}".format(ch(r), ch(g), ch(b))


class Iso:
    def __init__(self, s: float = 6.0):
        self.s = s
        self.parts: list[str] = []
        self.defs: list[str] = []

    def P(self, x: float, y: float, z: float) -> tuple[float, float]:
        s = self.s
        return ((x - y) * s, (x + y) * s / 2 - z * s)

    def pts(self, corners) -> str:
        return " ".join(f"{px:.2f},{py:.2f}" for px, py in (self.P(*c) for c in corners))

    def poly(self, corners, fill, stroke=OUTLINE, sw=1.1, extra="") -> None:
        st = f' stroke="{stroke}" stroke-width="{sw}" stroke-linejoin="round"' if stroke else ""
        self.parts.append(f'<polygon points="{self.pts(corners)}" fill="{fill}"{st}{extra}/>')

    def box(self, x, y, z, w, d, h, col, sw=1.1) -> None:
        x1, y1, z1 = x + w, y + d, z + h
        self.poly([(x, y1, z), (x1, y1, z), (x1, y1, z1), (x, y1, z1)], col, sw=sw)               # left (+y)
        self.poly([(x1, y, z), (x1, y1, z), (x1, y1, z1), (x1, y, z1)], shade(col, -.32), sw=sw)  # right (+x)
        self.poly([(x, y, z1), (x1, y, z1), (x1, y1, z1), (x, y1, z1)], shade(col, .32), sw=sw)   # top

    def face_y(self, x, y, z) -> str:
        """Transform mapping (u, v) = (+x, -z) onto the +y face plane."""
        e, f = self.P(x, y, z)
        s = self.s
        return f"matrix({s},{s / 2},0,{s},{e:.2f},{f:.2f})"

    def text_on_face(self, x, y, z, tx, ty, size, text, fill) -> None:
        self.parts.append(
            f'<g transform="{self.face_y(x, y, z)}"><text x="{tx}" y="{ty}" font-size="{size}" '
            f'font-family="Terminus, DejaVu Sans Mono, monospace" font-weight="bold" fill="{fill}">{text}</text></g>')

    def svg(self) -> str:
        defs = f"<defs>{''.join(self.defs)}</defs>" if self.defs else ""
        return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="-58 -60 116 116" width="128" height="128">'
                f"{defs}{''.join(self.parts)}</svg>\n")


def carpet(iso: Iso) -> None:
    c = [(-.6, -.6, 0), (8.6, -.6, 0), (8.6, 8.6, 0), (-.6, 8.6, 0)]
    iso.poly(c, "rgba(0,0,0,.38)", stroke=None, extra=' transform="translate(4,4)"')
    iso.box(-.6, -.6, -.5, 9.2, 9.2, .5, "#9aa0a6", sw=1)


# ------------------------------------------------------------------ icons --
def pick(state, normal):
    return {"sel": SELECT, "drop": DROP}.get(state, normal)


def usd(iso: Iso, st=None, zipped=False):
    cols = [pick(st, c) for c in ("#8e979f", "#3f9a96", "#e0863a")]
    for i, c in enumerate(cols):
        iso.box(1, 1, i * 2.3, 6, 6, 1.3, c)
    ink = "#00000055" if st else "#7a3a0a"
    for i in range(3):
        iso.poly([(2, 2.2 + i * 1.4, 5.92), (5.6 - i * .8, 2.2 + i * 1.4, 5.92),
                  (5.6 - i * .8, 2.7 + i * 1.4, 5.92), (2, 2.7 + i * 1.4, 5.92)], ink, stroke=None)
    if zipped:  # a strap around the stack = packaged usdz
        strap = pick(st, "#2a2f36")
        iso.poly([(1, 7, 0), (1.9, 7, 0), (1.9, 7, 5.9), (1, 7, 5.9)], strap, sw=.8)
        iso.poly([(1, 1, 5.9), (1.9, 1, 5.9), (1.9, 7, 5.9), (1, 7, 5.9)], shade(strap, .3), sw=.8)


def vdb(iso: Iso, st=None):
    vox = []
    for x in range(4):
        for y in range(4):
            for z in range(4):
                dx, dy, dz = x - 1.5, y - 1.5, z - 1.3
                if dx * dx + dy * dy + dz * dz * 1.1 < 4.2 and not (x == 3 and y == 0 and z == 3):
                    vox.append((x, y, z))
    vox.sort(key=lambda v: (v[0] + v[1] - v[2] * .01, v[2]))
    for x, y, z in vox:
        d = 1 - (abs(x - 1.5) + abs(y - 1.5) + abs(z - 1.5)) / 6
        iso.box(.6 + x * 1.75, .6 + y * 1.75, z * 1.75, 1.75, 1.75, 1.75,
                pick(st, shade("#7aa6d6", d * .45 - .05)), sw=.8)


def exr(iso: Iso, st=None):
    iso.box(2.2, 1, .4, 5.6, .5, 6.4, pick(st, "#3e7bd1"))
    iso.box(1.6, 3, .2, 5.6, .5, 6.4, pick(st, "#4aa860"))
    iso.box(1, 5, 0, 5.6, .5, 6.4, pick(st, "#d24a3c"))
    gid = f"exr{st or ''}"
    stops = ([("0", "#1d2a5c"), (".55", "#e0784a"), (".56", "#2d2a26"), ("1", "#4a3d2f")] if not st else
             [("0", pick(st, "")), (".55", shade(pick(st, ""), .4)), (".56", shade(pick(st, ""), -.2)), ("1", shade(pick(st, ""), -.3))])
    iso.defs.append(f'<linearGradient id="{gid}" x1="0" y1="0" x2="0" y2="1">'
                    + "".join(f'<stop offset="{o}" stop-color="{c}"/>' for o, c in stops) + "</linearGradient>")
    iso.poly([(1.5, 5.5, .6), (6.1, 5.5, .6), (6.1, 5.5, 5.8), (1.5, 5.5, 5.8)], f"url(#{gid})", sw=.9)
    iso.parts.append(f'<g transform="{iso.face_y(1.5, 5.5, 5.8)}"><ellipse cx="2.8" cy="2.5" rx=".8" ry=".8" '
                     f'fill="{"#ffffff88" if st else "#ffd36a"}"/></g>')


def rez(iso: Iso, st=None):
    c = pick(st, "#c79a5e")
    iso.box(1, 1, 0, 6, 6, 4.6, c)
    tape = shade(c, .5) if st else "#efe2b8"
    iso.poly([(3.4, 1, 4.6), (4.6, 1, 4.6), (4.6, 7, 4.6), (3.4, 7, 4.6)], tape, sw=.7)
    iso.poly([(3.4, 7, 4.6), (4.6, 7, 4.6), (4.6, 7, 2.8), (3.4, 7, 2.8)], shade(tape, -.1), sw=.7)
    iso.text_on_face(1, 7, 4.6, .5, 3.6, 1.25, "rez", "#2a1a08")


def shell(iso: Iso, st=None):
    c = pick(st, "#b8b8b4")
    iso.box(1, 3.6, 0, 6.4, 3.4, 5.6, c)
    iso.box(2.2, 1.2, 0, 4, 2.4, 3.4, shade(c, -.12))
    iso.poly([(1.6, 7, 1), (6.8, 7, 1), (6.8, 7, 5), (1.6, 7, 5)], "#0d1a3f" if st else "#0f1b16", sw=.9)
    iso.text_on_face(1.6, 7, 5, .5, 1.9, 1.5, "&gt;_", "#7fe08a")


def assistant(iso: Iso, st=None):
    iso.box(1.6, 1.6, 0, 4.8, 4.8, 1.8, pick(st, "#8e979f"))
    base = pick(st, "#8a5ad0")
    gid = f"orb{st or ''}"
    iso.defs.append(f'<radialGradient id="{gid}" cx=".36" cy=".32" r=".75">'
                    f'<stop offset="0" stop-color="{shade(base, .75)}"/><stop offset=".45" stop-color="{base}"/>'
                    f'<stop offset="1" stop-color="{shade(base, -.55)}"/></radialGradient>')
    px, py = iso.P(4, 4, 1.8)
    cx, cy = iso.P(4, 4, 5.2)
    iso.parts.append(f'<ellipse cx="{px:.2f}" cy="{py:.2f}" rx="14" ry="5" fill="rgba(0,0,0,.35)"/>')
    iso.parts.append(f'<circle cx="{cx:.2f}" cy="{cy:.2f}" r="17" fill="url(#{gid})" stroke="{OUTLINE}" stroke-width="1.1"/>')


def folder(iso: Iso, st=None, open_=False):
    c = pick(st, "#d9b65a")
    iso.box(.8, 1, 0, 6.4, 6, .6, shade(c, -.1))
    if open_:
        iso.box(.8, 1, .6, 6.4, .5, 4.6, c)                      # back wall
        iso.box(1.4, 2, .6, 5, 4, 2.6, "#e8e4d8")                 # sheets
        iso.poly([(.8, 7, .6), (7.2, 7, .6), (7.2, 5.4, 4), (.8, 5.4, 4)], shade(c, .15))  # flap tilted open
    else:
        iso.box(.8, 1, .6, 6.4, 6, 3.6, c)
        iso.poly([(.8, 1, 4.2), (3.2, 1, 4.2), (3.2, 1, 4.9), (.8, 1, 4.9)], shade(c, .2), sw=.8)  # tab


# name -> (context, draw function)
ICONS = {
    "model-x-usd": ("mimetypes", usd),
    "model-vnd.usdz+zip": ("mimetypes", lambda i, st=None: usd(i, st, zipped=True)),
    "application-x-openvdb": ("mimetypes", vdb),
    "image-x-exr": ("mimetypes", exr),
    "application-x-rez-package": ("mimetypes", rez),
    "utilities-terminal": ("apps", shell),
    "vfx-assistant": ("apps", assistant),
    "folder": ("places", folder),
    "folder-open": ("places", lambda i, st=None: folder(i, st, open_=True)),
}

INDEX_THEME = """[Icon Theme]
Name=dash-punk
Comment=Isometric icons in the spirit of the IRIX desktop
Inherits=Adwaita,hicolor
Directories=scalable/mimetypes,scalable/apps,scalable/places

[scalable/mimetypes]
Size=128
MinSize=16
MaxSize=512
Context=MimeTypes
Type=Scalable

[scalable/apps]
Size=128
MinSize=16
MaxSize=512
Context=Applications
Type=Scalable

[scalable/places]
Size=128
MinSize=16
MaxSize=512
Context=Places
Type=Scalable
"""


def draw(fn, state=None) -> str:
    iso = Iso()
    carpet(iso)
    fn(iso, state)
    return iso.svg()


def main(argv: list[str]) -> None:
    preview = None
    if "--preview" in argv:
        i = argv.index("--preview")
        preview = Path(argv[i + 1])
        argv = argv[:i] + argv[i + 2:]
    out = Path(argv[0]) if argv else REPO / "icons" / "dash-punk"
    for name, (ctx, fn) in ICONS.items():
        d = out / "scalable" / ctx
        d.mkdir(parents=True, exist_ok=True)
        (d / f"{name}.svg").write_text(draw(fn))
    (out / "index.theme").write_text(INDEX_THEME)
    print(f"wrote {len(ICONS)} icons to {out}")
    if preview:
        cells = []
        for name, (_, fn) in ICONS.items():
            row = "".join(f'<div>{draw(fn, st)}<small>{lbl}</small></div>'
                          for st, lbl in ((None, "normal"), ("sel", "selected"), ("drop", "drop")))
            cells.append(f"<section><h3>{name}</h3><div class=r>{row}</div></section>")
        preview.write_text(
            "<!doctype html><meta charset=utf-8><style>body{background:#4a5a6a;color:#eef;font:13px sans-serif;"
            "display:flex;flex-wrap:wrap;gap:16px;padding:16px}.r{display:flex;gap:8px}.r div{display:flex;"
            "flex-direction:column;align-items:center}svg{width:96px;height:96px}h3{margin:0 0 4px;font-size:12px}"
            "</style>" + "".join(cells))
        print(f"preview: {preview}")


if __name__ == "__main__":
    main(sys.argv[1:])
