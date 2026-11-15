-- Window rules. Hyprland validates these: run
--   Hyprland -c ~/.config/hypr/hyprland.lua --verify-config
-- after editing. Per-app rules for Houdini, Nuke, Maya etc. come in step 3,
-- once each app's real window classes are known (hyprctl clients).

-- Splash screens float.
hl.window_rule({
    name  = "float-splash",
    match = { title = "^(.*[Ss]plash.*)$" },
    float = true,
})

-- Render progress windows must not steal focus.
hl.window_rule({
    name     = "render-progress-no-focus",
    match    = { title = "^(.*[Rr]ender [Pp]rogress.*)$" },
    no_focus = true,
})

-- The volume mixer floats.
hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "^(org.pulseaudio.pavucontrol)$" },
    float = true,
})

-- Fix dragging issues with XWayland (most VFX apps run under XWayland).
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})
