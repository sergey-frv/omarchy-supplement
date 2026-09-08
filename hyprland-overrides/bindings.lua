-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
-- Hyprland configuration overrides
-- Add your custom settings here

------ Apps keybindings
-- Browser
hl.unbind("SUPER + B")
o.bind("SUPER + B", "Browser", "exec google-chrome-stable --force-device-scale-factor=0.9")

-- Password manager
hl.unbind("SUPER + SHIFT + SLASH")
o.bind("SUPER + SHIFT + SLASH", "Passwords", "exec uwsm-app -- keepassxc")

-- Music
hl.unbind("SUPER + SHIFT + M")
o.bind("SUPER + SHIFT + M", "Music", 'exec omarchy-launch-or-focus-webapp "Music" "https://music.yandex.ru"')

-- Telegram
o.bind("SUPER + SHIFT + CTRL + T", "Telegram", 'exec omarchy-launch-or-focus ^telegram$ "uwsm-app -- Telegram"')

-- Time
o.bind(
	"SUPER + SHIFT + CTRL + ALT + T",
	"Time Desktop",
	'exec omarchy-launch-or-focus ^time$ "uwsm-app -- Time Desktop"'
)

------ Vim navigation
-- Unbind vim hjkl
hl.unbind("SUPER + h")
hl.unbind("SUPER + j")
hl.unbind("SUPER + J")
hl.unbind("SUPER + k")
hl.unbind("SUPER + K")
hl.unbind("SUPER + l")

hl.unbind("SUPER + L")
o.bind("SUPER + A", "Toggle workspace layout", "exec omarchy-hyprland-workspace-layout-toggle")

-- Control tiling
hl.unbind("SUPER + code:48")
o.bind("SUPER + code:48", "Toggle window split", "layoutmsg togglesplit") -- dwindle, code:48="

-- Show key bindings
hl.unbind("SUPER + ALT + SLASH")
o.bind("SUPER + ALT + SLASH", "Show key bindings", "exec omarchy-menu-keybindings")

-- Move focus with SUPER + vim arrow keys
o.bind("SUPER + h", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + l", "Focus on right window", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + k", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + j", "Focus on below window", hl.dsp.focus({ direction = "d" }))

-- Move workspaces to other monitors
o.bind("SUPER + SHIFT + ALT + h", "Move workspace to left monitor", hl.dsp.workspace.move({ monitor = "l" }))
o.bind("SUPER + SHIFT + ALT + l", "Move workspace to right monitor", hl.dsp.workspace.move({ monitor = "r" }))
o.bind("SUPER + SHIFT + ALT + k ", "Move workspace to up monitor", hl.dsp.workspace.move({ monitor = "u" }))
o.bind("SUPER + SHIFT + ALT + j", "Move workspace to down monitor", hl.dsp.workspace.move({ monitor = "d" }))

-- Swap active window with the one next to it with SUPER + SHIFT + vim arrow keys
o.bind("SUPER + SHIFT + h", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + l", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + SHIFT + k", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + j", "Swap window down", hl.dsp.window.swap({ direction = "d" }))

-- Join groups
hl.unbind("SUPER + ALT + k")
o.bind("SUPER + ALT + h", "Move window to group on left", hl.dsp.window.move({ into_group = "l" }))
o.bind("SUPER + ALT + l", "Move window to group on right", hl.dsp.window.move({ into_group = "r" }))
o.bind("SUPER + ALT + k", "Move window to group on top", hl.dsp.window.move({ into_group = "u" }))
o.bind("SUPER + ALT + j", "Move window to group on bottom", hl.dsp.window.move({ into_group = "d" }))

-- Window navigation for grouped windows - no need for this binding, defaults are hardware and lock
-- o.bind("SUPER + CTRL + h", "Move grouped window focus left", hl.dsp.group.prev())
-- o.bind("SUPER + CTRL + l", "Move grouped window focus right", hl.dsp.group.next())
