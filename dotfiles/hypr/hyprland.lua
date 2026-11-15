-- vfx-linux Hyprland config (Hyprland 0.57+ reads Lua, not hyprland.conf).
-- IRIX-inspired: flat, square, no animation, terminal-first.
-- Colours come from the active scheme (vfx-theme), rules from rules.lua.
-- Check after editing: Hyprland -c ~/.config/hypr/hyprland.lua --verify-config

local HOME      = os.getenv("HOME")
local THEME_DIR = HOME .. "/.config/vfx-theme"
local HYPR_DIR  = HOME .. "/.config/hypr"

-- Active scheme; fall back to Slate if vfx-theme hasn't run yet.
local ok, theme = pcall(dofile, THEME_DIR .. "/hyprland.lua")
if not ok or type(theme) ~= "table" then
    theme = { desktop = "rgb(4a5a6a)", active = "rgb(d4a84a)", inactive = "rgb(8a949e)" }
end

-- Running in a VM? Hardware cursors are often invisible there.
local function in_vm()
    local f = io.open("/sys/class/dmi/id/sys_vendor", "r")
    if not f then return false end
    local v = f:read("*l") or ""
    f:close()
    return v:find("QEMU") ~= nil or v:find("VMware") ~= nil or v:find("innotek") ~= nil
end

----------------
--- MONITORS ---
----------------
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-------------------
--- MY PROGRAMS ---
-------------------
local terminal = "foot"
local launcher = "fuzzel --config " .. THEME_DIR .. "/fuzzel.ini"
local lock     = "hyprlock -c " .. THEME_DIR .. "/hyprlock.conf"

-----------------
--- AUTOSTART ---
-----------------
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar -s " .. THEME_DIR .. "/waybar.css")
    hl.exec_cmd("mako -c " .. THEME_DIR .. "/mako.conf")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd(terminal)
end)

-----------------------------
--- ENVIRONMENT VARIABLES ---
-----------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- Qt: prefer Wayland, fall back to X11 for apps with bundled Qt (Maya, Nuke,
-- Houdini). Per-app overrides go in the rez wrappers (step 3).
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

---------------------
--- LOOK AND FEEL ---
---------------------
hl.config({
    general = {
        gaps_in          = 2,
        gaps_out         = 4,
        border_size      = 3,
        col = {
            active_border   = theme.active,
            inactive_border = theme.inactive,
        },
        layout           = "dwindle",
        resize_on_border = true,
    },
    decoration = {
        rounding = 0,
        shadow   = { enabled = false },
        blur     = { enabled = false },
    },
    animations = { enabled = false },
    dwindle = { preserve_split = true },
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        background_color         = theme.desktop,
    },
    -- Keeps XWayland apps (most VFX apps) sharp on HiDPI.
    xwayland = { force_zero_scaling = true },
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
    },
})

if in_vm() then
    hl.config({ cursor = { no_hardware_cursors = true } })
end

------------
--- KEYS ---
------------
local mod = "SUPER"

hl.bind(mod .. " + Return",      hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + D",           hl.dsp.exec_cmd(launcher))
hl.bind(mod .. " + Q",           hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + E",   hl.dsp.exit())
hl.bind(mod .. " + F",           hl.dsp.window.fullscreen())
hl.bind(mod .. " + V",           hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P",           hl.dsp.window.pseudo())
hl.bind(mod .. " + S",           hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + L",           hl.dsp.exec_cmd(lock))
hl.bind(mod .. " + SHIFT + T",   hl.dsp.exec_cmd("vfx-theme next"))

for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mod .. " + " .. dir,           hl.dsp.focus({ direction = dir }))
    hl.bind(mod .. " + SHIFT + " .. dir,   hl.dsp.window.move({ direction = dir }))
end

for i = 1, 9 do
    hl.bind(mod .. " + " .. i,             hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i,     hl.dsp.window.move({ workspace = i }))
end

hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })

-------------
--- RULES ---
-------------
dofile(HYPR_DIR .. "/rules.lua")
