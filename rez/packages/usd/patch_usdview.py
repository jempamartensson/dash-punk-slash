"""Patch usdview so its colours follow the active vfx-theme scheme.

usdview sets prim tree and attribute colours in code (usdviewq/common.py),
tuned for its dark stock look, so on a light scheme most prim names are
white on white. This appends a block to common.py that reads
$VFX_USDVIEW_COLORS (rendered by vfx-theme from templates/usdview-colors.ini)
and overrides those colours. Colours the file leaves out are darkened when
the scheme is light. Without the file usdview looks stock.

Usage: python3 patch_usdview.py path/to/usdviewq/common.py   (idempotent)
"""
import sys

MARK = "# --- vfx-theme colours ---"
BLOCK = MARK + '''
def _vfxApplyThemeColors():
    import configparser, os
    path = os.environ.get("VFX_USDVIEW_COLORS", "")
    if not os.path.isfile(path):
        return
    cfg = configparser.ConfigParser(interpolation=None)
    cfg.optionxform = str
    try:
        cfg.read(path)
    except configparser.Error:
        return
    dark = cfg.get("scheme", "dark", fallback="true").lower() == "true"
    alpha = {"ANCESTOR_OF_SELECTED": 60, "ANCESTOR_OF_SELECTED_HOVER": 110}
    for group in (UIBaseColors, UIPrimTypeColors, UIPrimTreeColors,
                  UIPropertyValueSourceColors):
        section = cfg[group.__name__] if cfg.has_section(group.__name__) else {}
        for name in dir(group):
            stock = getattr(group, name)
            if name.startswith("_") or not isinstance(stock, QtGui.QBrush):
                continue
            if name in section:
                color = QtGui.QColor(section[name])
                if not color.isValid():
                    continue
                color.setAlpha(alpha.get(name, 255))
            elif not dark:
                color = QtGui.QColor(stock.color()).darker(220)
            else:
                continue
            # ConstantsGroup blocks normal assignment.
            type.__setattr__(group, name, QtGui.QBrush(color))

_vfxApplyThemeColors()
'''


def main(path):
    text = open(path).read()
    if MARK in text:
        print("usdview colours already patched:", path)
        return
    for cls in ("class UIBaseColors", "class UIPrimTypeColors", "class UIPrimTreeColors",
                "class UIPropertyValueSourceColors"):
        if cls not in text:
            sys.exit(f"{cls} not found in {path}; update patch_usdview.py for this USD version")
    with open(path, "a") as f:
        f.write("\n\n" + BLOCK)
    print("patched usdview colours:", path)


if __name__ == "__main__":
    main(sys.argv[1])
