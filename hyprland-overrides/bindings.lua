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

-- Раскладка workspace: стоковые Super+L / Super+Alt+L заняты vim-навигацией и группами, перенесены на Super+;
-- (code:47 — клавиша справа от L, в ru «ж»)
hl.unbind("SUPER + ALT + L")
o.bind("SUPER + code:47", "Cycle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
o.bind("SUPER + SHIFT + code:47", "Cycle workspace layout back", "omarchy-hyprland-workspace-layout-toggle back")

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

------ Universal clipboard в любой раскладке
-- Стоковые Super+C/V/X/A (default/hypr/bindings/clipboard.lua) передают send_key_state имя клавиши ("C"), и Hyprland
-- ищет его в текущей раскладке: в ru латинских букв нет, вызов падает с "send_key_state: key not found".
-- Здесь те же бинды передают скан-код физической клавиши, он от раскладки не зависит.
do
	local KEY_C = "code:54"
	local KEY_V = "code:55"
	local KEY_X = "code:53"
	local KEY_A = "code:38"

	-- Нажатие и отпускание разнесены таймером, как в стоковом clipboard.lua
	-- (обход залипания синтетических клавиш: https://github.com/hyprwm/Hyprland/discussions/14099).
	local function send_shortcut_once(mods, key)
		return function()
			hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))

			hl.timer(function()
				hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
			end, { timeout = 50, type = "oneshot" })
		end
	end

	-- Терминал определяется по тегу terminal из default/hypr/apps/terminals.lua; у динамических тегов в конце "*".
	local function active_window_is_terminal()
		local window = hl.get_active_window()
		if not window then
			return false
		end

		for _, tag in ipairs(window.tags or {}) do
			if tag:gsub("%*$", "") == "terminal" then
				return true
			end
		end

		return false
	end

	local function universal_clipboard_shortcut(default_mods, default_key, terminal_mods, terminal_key)
		return function()
			if active_window_is_terminal() then
				send_shortcut_once(terminal_mods, terminal_key)()
			else
				send_shortcut_once(default_mods, default_key)()
			end
		end
	end

	o.rebind("SUPER + C", "Universal copy", universal_clipboard_shortcut("CTRL", KEY_C, "CTRL SHIFT", KEY_C))
	o.rebind("SUPER + V", "Universal paste", universal_clipboard_shortcut("CTRL", KEY_V, "CTRL SHIFT", KEY_V))
	o.rebind("SUPER + X", "Universal cut", send_shortcut_once("CTRL", KEY_X))
	o.rebind("SUPER + A", "Select all", send_shortcut_once("CTRL", KEY_A))
end

------ Ctrl+hjkl / Ctrl+n,p в меню omarchy-shell
-- Пока открыт слой одного из меню из LAYERS, включён submap omarchy-vim-nav: Ctrl+H/J/K/L и Ctrl+N/P
-- шлют в меню стрелки. В карусели выбора темы и фона Ctrl+J/N листают вперёд, Ctrl+K/P назад.
-- Клавиши заданы скан-кодами, поэтому работают в любой раскладке. Остальные клавиши, в том числе
-- набор текста в поиск, submap пропускает в меню.
-- Если бинд сработал, а открытого меню нет (событие закрытия потерялось), submap выключается,
-- а нажатие уходит окну как обычный Ctrl+клавиша.
do
	local SUBMAP = "omarchy-vim-nav"

	local LIST = { left = "Left", down = "Down", up = "Up", right = "Right" }
	local CAROUSEL = { left = "Left", down = "Right", up = "Left", right = "Right" }

	local LAYERS = {
		["omarchy-menu"] = LIST, -- меню Omarchy, Super+Space
		["omarchy-clipboard"] = LIST, -- история буфера обмена
		["omarchy-emojis"] = LIST, -- эмодзи, Super+Ctrl+E
		["omarchy-dock-apps"] = LIST, -- сетка приложений, Super+Alt+Space
		["omarchy-image-selector"] = CAROUSEL, -- выбор темы и фона
	}

	-- Открытое меню: слой из LAYERS, который держит фокус клавиатуры. skip исключает закрывающийся слой.
	local function open_menu(skip)
		for _, layer in ipairs(hl.get_layers()) do
			if
				LAYERS[layer.namespace]
				and layer.mapped
				and layer.interactivity ~= 0
				and (not skip or layer.address ~= skip.address)
			then
				return layer
			end
		end
	end

	local function send_key(mods, key)
		hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))

		hl.timer(function()
			hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
		end, { timeout = 50, type = "oneshot" })
	end

	local function navigate(direction, key)
		return function()
			local menu = open_menu()
			if menu then
				send_key("", LAYERS[menu.namespace][direction])
			else
				hl.dispatch(hl.dsp.submap("reset"))
				send_key("CTRL", key)
			end
		end
	end

	local KEYS = {
		{ key = "code:43", direction = "left" }, -- H
		{ key = "code:44", direction = "down" }, -- J
		{ key = "code:45", direction = "up" }, -- K
		{ key = "code:46", direction = "right" }, -- L
		{ key = "code:57", direction = "down" }, -- N
		{ key = "code:33", direction = "up" }, -- P
	}

	hl.define_submap(SUBMAP, function()
		for _, k in ipairs(KEYS) do
			hl.bind("CTRL + " .. k.key, navigate(k.direction, k.key))
		end
	end)

	hl.on("layer.opened", function(layer)
		if layer and LAYERS[layer.namespace] then
			hl.dispatch(hl.dsp.submap(SUBMAP))
		end
	end)

	hl.on("layer.closed", function(layer)
		if layer and LAYERS[layer.namespace] and hl.get_current_submap() == SUBMAP and not open_menu(layer) then
			hl.dispatch(hl.dsp.submap("reset"))
		end
	end)
end
