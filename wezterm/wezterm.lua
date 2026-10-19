-- WezTerm config for Windows: same look as ghostty/config and, in native
-- mode, the same keys as .tmux.conf (WezTerm acts as the multiplexer).
--
-- DOTS_WSL_DISTRO set (WSL mode, done by install.ps1): open that distro and
-- leave C-a / C-hjkl to the real tmux running inside it.
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

local wsl_distro = os.getenv 'DOTS_WSL_DISTRO'
local is_windows = wezterm.target_triple:find 'windows' ~= nil

-- Look (ghostty/config) ---------------------------------------------------
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 11
config.window_decorations = 'RESIZE'
config.window_padding = { left = 6, right = 6, top = 6, bottom = 6 }
config.default_cursor_style = 'BlinkingBlock'
config.colors = {
  background = '#010409',
  foreground = '#e6edf3',
  selection_bg = '#264f78',
  selection_fg = '#e6edf3',
  cursor_bg = '#e6edf3',
  cursor_border = '#e6edf3',
  cursor_fg = '#010409',
  ansi = {
    '#484f58',
    '#ff7b72',
    '#3fb950',
    '#d29922',
    '#58a6ff',
    '#bc8cff',
    '#39c5cf',
    '#b1bac4',
  },
  brights = {
    '#6e7681',
    '#ffa198',
    '#56d364',
    '#e3b341',
    '#79c0ff',
    '#d2a8ff',
    '#56d4dd',
    '#ffffff',
  },
  -- Tab bar styled like the tmux status bar.
  tab_bar = {
    background = '#010409',
    active_tab = { bg_color = '#010409', fg_color = '#e6edf3', intensity = 'Bold' },
    inactive_tab = { bg_color = '#010409', fg_color = '#6e7681' },
    inactive_tab_hover = { bg_color = '#010409', fg_color = '#e6edf3' },
    new_tab = { bg_color = '#010409', fg_color = '#6e7681' },
    new_tab_hover = { bg_color = '#010409', fg_color = '#e6edf3' },
  },
}
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false

if wsl_distro then
  config.default_domain = 'WSL:' .. wsl_distro
  return config
end

if is_windows then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
end

-- Multiplexer (.tmux.conf) ------------------------------------------------
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

-- C-hjkl: inside Neovim send the key (vim-tmux-navigator moves between
-- Neovim windows), otherwise move between WezTerm panes.
local function is_vim(pane)
  return (pane:get_foreground_process_name() or ''):find 'n?vim' ~= nil
end

local function navigate(key, direction)
  return {
    key = key,
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      if is_vim(pane) then
        window:perform_action(act.SendKey { key = key, mods = 'CTRL' }, pane)
      else
        window:perform_action(act.ActivatePaneDirection(direction), pane)
      end
    end),
  }
end

-- Leader + hjkl resizes by 5 and, like `bind -r`, keeps repeating hjkl
-- until a short pause.
local function resize(key, direction)
  return {
    key = key,
    mods = 'LEADER',
    action = act.Multiple {
      act.AdjustPaneSize { direction, 5 },
      act.ActivateKeyTable { name = 'resize', one_shot = false, timeout_milliseconds = 500 },
    },
  }
end

config.keys = {
  { key = 'a', mods = 'LEADER|CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' } },
  { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  resize('h', 'Left'),
  resize('j', 'Down'),
  resize('k', 'Up'),
  resize('l', 'Right'),
  { key = 'm', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
  navigate('h', 'Left'),
  navigate('j', 'Down'),
  navigate('k', 'Up'),
  navigate('l', 'Right'),
}
for i = 1, 9 do
  table.insert(config.keys, { key = tostring(i), mods = 'LEADER', action = act.ActivateTab(i - 1) })
end

config.key_tables = {
  resize = {
    { key = 'h', action = act.AdjustPaneSize { 'Left', 5 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 5 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 5 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 5 } },
    { key = 'Escape', action = 'PopKeyTable' },
  },
}

return config
