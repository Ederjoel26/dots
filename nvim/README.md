# Neovim config

A minimal, performance-first Neovim configuration written in Lua.

The goal is an editor that opens instantly and never gets in the way while
you type. Almost every plugin is lazy-loaded (on a key, a command, a filetype
or after the UI is drawn), there is no heavy completion stack, and the plugin
list is kept short on purpose.

## Install

### One command

**Linux and macOS**

```bash
curl -fsSL https://raw.githubusercontent.com/Ederjoel26/dots/main/nvim/install.sh | bash
```

**Windows** (PowerShell, not as admin)

```powershell
irm https://raw.githubusercontent.com/Ederjoel26/dots/main/nvim/install.ps1 | iex
```

That's it. When it finishes, open a new terminal and run `nvim`.

Already cloned the repo? Run it from the checkout instead: `./nvim/install.sh`
or `.\nvim\install.ps1`.

Supported systems:

- **Linux**: anything with `apt` (Debian, Ubuntu, Mint, Pop!_OS), `dnf`
  (Fedora, RHEL), `pacman` (Arch, Manjaro) or `zypper` (openSUSE). Also WSL.
- **macOS**: Apple Silicon and Intel.
- **Windows**: 10 (1809+) and 11, either natively or through WSL (the script
  asks). tmux and Ghostty don't run natively on Windows, so WezTerm takes
  their place (see below).

Run it as your normal user. On Linux and macOS it asks for your password
(`sudo`) for system packages and the first Homebrew install.

### What `install.sh` does (Linux / macOS)

Distro package managers often ship outdated (or missing) versions of
Neovim, lazygit, yazi, etc. To avoid that, the script uses
[Homebrew](https://brew.sh) for everything except the few base packages
Homebrew itself needs.

1. **System prerequisites** (Linux only, via `apt`/`dnf`/`pacman`/`zypper`):
   compiler, `make`, `git`, `curl`, `file`, `unzip`, `tar`, `fontconfig`, and
   clipboard tools (`xclip`, `wl-clipboard`). On macOS the Homebrew installer
   sets up the Xcode Command Line Tools.
2. **Homebrew**: installed non-interactively if missing, and added to
   `~/.bashrc` / `~/.zshrc`.
3. **Tools from Homebrew**:
   - Required: `neovim`, `ripgrep`, `fd`, `fzf`, `lazygit`, `node`,
     `go`, `python` (Node, Go and Python are needed by Mason to build the
     language servers and formatters).
   - Optional: `yazi`, `tmux`, `opencode`, and Ghostty on macOS. If one
     fails, only its integration is affected and the install continues.
4. **JetBrainsMono Nerd Font**: into `~/.local/share/fonts` on Linux
   (skipped if already installed), via Homebrew on macOS.
5. **Config**: clones the repo to `~/dots` and symlinks `~/.config/nvim`,
   `~/.tmux.conf` and `~/.config/ghostty/config` to it. Anything already
   there is moved to `<path>.bak.<timestamp>`, never deleted. tmux plugins
   are installed through tpm.
6. **Headless bootstrap**, so the first launch is clean:
   - plugins installed at the exact versions in `lazy-lock.json`
   - Treesitter parsers compiled
   - LSP servers and formatters installed by Mason

### What `install.ps1` does (Windows)

Same idea with [Scoop](https://scoop.sh), the Windows equivalent of
Homebrew (per user, no admin needed). Ghostty and tmux don't exist on
Windows, so [WezTerm](https://wezterm.org) replaces them with the config in
`wezterm/wezterm.lua`: same font, colors, padding and cursor as the Ghostty
config.

First it asks which option you want (or set `DOTS_WINDOWS_MODE`):

**1) Native** (default): everything runs on Windows.

1. **Scoop**, plus the `extras` and `nerd-fonts` buckets.
2. **WezTerm** and **JetBrainsMono Nerd Font** (`JetBrainsMono-NF`).
3. **Tools**: `neovim`, `ripgrep`, `fd`, `fzf`, `lazygit`, `nodejs-lts`, `go`,
   `python`, `mingw` (C compiler), `make`, `7zip`, `unzip`, `pwsh`
   (WezTerm's shell). Optional: `yazi`, `opencode`.
4. **Config**: clones the repo to `~\dots`, links `%LOCALAPPDATA%\nvim` to
   `~\dots\nvim` (a junction, so no Developer Mode needed; an existing config
   is moved to `nvim.bak.<timestamp>`) and points WezTerm to its config
   through the `WEZTERM_CONFIG_FILE` user variable.
5. **Headless bootstrap**, same as above.

WezTerm works as the multiplexer here, with the tmux keys:

| Keys | Action |
| --- | --- |
| `C-a \|` / `C-a -` | Split side by side / top and bottom |
| `C-a h/j/k/l` | Resize pane by 5 (keep pressing `hjkl` to repeat) |
| `C-a m` | Zoom pane |
| `C-a [` | Copy mode (vi keys, `v` select, `y` copy) |
| `C-a c` / `C-a n` / `C-a p` / `C-a 1-9` | New / next / previous / go to tab |
| `C-a x` | Close pane |
| `C-a r` | Reload config |
| `C-h/j/k/l` | Move between Neovim windows and WezTerm panes |

Not replicated: session save/restore (tmux-resurrect + continuum), and
`C-h/j/k/l` doesn't jump from the edge Neovim window to the next WezTerm
pane (inside Neovim it moves between Neovim windows only). Use option 2 if
you need those.

**2) WSL**: Linux inside Windows, identical to the Linux setup.

1. Checks that a WSL distro exists (if not, it tells you to run
   `wsl --install -d Ubuntu` as admin and reboot, then re-run the script).
2. **Scoop**, **WezTerm** and the **Nerd Font** on the Windows side.
3. Points WezTerm to its config and sets `DOTS_WSL_DISTRO`, so WezTerm opens
   straight into that distro and leaves `C-a` / `C-hjkl` to tmux.
4. Runs `install.sh` inside the distro: Neovim, tmux with `.tmux.conf`,
   plugins, everything as on Linux.

Both scripts are idempotent: running them again updates the repo and
installs whatever is missing.

#### Options

Both scripts read the same environment variables:

| Variable          | Default                                 | Effect                          |
| ----------------- | --------------------------------------- | ------------------------------- |
| `DOTS_DIR`        | `~/dots`                                | Where the repo is cloned        |
| `REPO_URL`        | `https://github.com/Ederjoel26/dots.git` | Use your own fork               |
| `SKIP_FONT=1`     | off                                     | Don't install the Nerd Font     |
| `SKIP_OPTIONAL=1` | off                                     | Skip the optional tools         |
| `DOTS_WINDOWS_MODE` | asks                                  | Windows only: `native` or `wsl` |

```bash
curl -fsSL https://raw.githubusercontent.com/Ederjoel26/dots/main/nvim/install.sh | SKIP_FONT=1 bash
```

```powershell
$env:SKIP_FONT = '1'; irm https://raw.githubusercontent.com/Ederjoel26/dots/main/nvim/install.ps1 | iex
```

### After installing

- Set your terminal font to **JetBrainsMono Nerd Font**, otherwise icons
  show as boxes.
- `vim-wakatime` shows `API Key not found` until you set a
  [WakaTime](https://wakatime.com) key with `:WakaTimeApiKey`. Don't use
  WakaTime? Delete `lua/plugins/wakatime.lua`.

### Manual install

Linux / macOS:

```bash
brew install neovim ripgrep fd fzf lazygit node go python yazi tmux
git clone https://github.com/Ederjoel26/dots.git ~/dots
ln -s ~/dots/nvim ~/.config/nvim
nvim   # lazy.nvim installs everything on first launch
```

Windows:

```powershell
scoop bucket add extras
scoop install git neovim ripgrep fd fzf lazygit nodejs-lts go python mingw make 7zip unzip pwsh
git clone https://github.com/Ederjoel26/dots.git $HOME\dots
New-Item -ItemType Junction -Path $env:LOCALAPPDATA\nvim -Target $HOME\dots\nvim
nvim
```

### Uninstall

```bash
rm ~/.config/nvim                                   # the symlink
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

On Windows: remove `%LOCALAPPDATA%\nvim` (the junction),
`%LOCALAPPDATA%\nvim-data`, and the `WEZTERM_CONFIG_FILE` / `DOTS_WSL_DISTRO`
user environment variables.

## Structure

```
nvim/
├── init.lua              # entry point: options → keymaps → lazy.nvim
├── lazy-lock.json        # pinned plugin versions
├── .stylua.toml          # Lua formatting rules
├── install.sh            # one-command installer (Linux, macOS)
├── install.ps1           # one-command installer (Windows: native or WSL)
└── lua/
    ├── config/
    │   ├── options.lua   # editor options
    │   └── keymaps.lua   # global keymaps + yank highlight
    └── plugins/          # one file per plugin, auto-imported by lazy.nvim
```

Every file in `lua/plugins/` returns a [lazy.nvim](https://lazy.folke.io)
spec and is picked up automatically. To add a plugin, create a new file
there; to remove one, delete its file.

## Performance approach

- **Lazy loading everywhere.** Only the colorscheme and the LSP setup load at
  startup. Everything else loads on `VeryLazy` (after the first screen is
  drawn), on a keymap, a command, a filetype, or when entering insert mode.
- **No heavy completion stack.** No `nvim-cmp`, no LuaSnip, no long list of
  completion sources. The only completion plugin is `blink.cmp` (Rust fuzzy
  matcher), and it is not loaded until you first enter insert mode.
- **Few plugins doing a lot.** `mini.nvim` alone covers text objects,
  surround and color highlighting.
- **Built-ins first.** netrw is the default file explorer (`<leader>e`),
  the native diagnostic UI is used instead of a separate plugin.
- **Pinned versions.** `lazy-lock.json` means everyone gets the same,
  tested plugin versions.

Check startup time yourself with `:Lazy profile` or
`nvim --startuptime /tmp/startup.log`.

## Plugins

| Plugin | Purpose | Loads on |
| --- | --- | --- |
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager | startup |
| [github-nvim-theme](https://github.com/projekt0n/github-nvim-theme) | Colorscheme (`github_dark_high_contrast`) | startup |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) + [mason.nvim](https://github.com/mason-org/mason.nvim) | LSP servers, auto-installed | startup |
| [fidget.nvim](https://github.com/j-hui/fidget.nvim) | LSP progress spinner | with LSP |
| [lazydev.nvim](https://github.com/folke/lazydev.nvim) | Neovim Lua API types | `lua` files |
| [blink.cmp](https://github.com/saghen/blink.cmp) | Completion + signature help | `InsertEnter` |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto close brackets/quotes | `InsertEnter` |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Format on save | `BufWritePre` |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (+ textobjects) | Syntax highlighting, indent, text objects | `VeryLazy` |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (+ fzf-native, ui-select) | Fuzzy finder | `VeryLazy` |
| [harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2) | Quick file marks | keymap |
| [flash.nvim](https://github.com/folke/flash.nvim) | Jump anywhere on screen | `VeryLazy` |
| [mini.nvim](https://github.com/echasnovski/mini.nvim) | `ai` text objects, `surround`, hex color highlight | `VeryLazy` |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git signs in the gutter | file open |
| [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) | Lazygit in a float | keymap/command |
| [yazi.nvim](https://github.com/mikavilpas/yazi.nvim) | Yazi file manager | `VeryLazy` |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Floating terminal | keymap/command |
| [opencode.nvim](https://github.com/NickvanDyke/opencode.nvim) | OpenCode AI assistant | keymap |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keymap hints | `VeryLazy` |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline (global) | `VeryLazy` |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Rendered markdown in buffer | `markdown` files |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight TODO/FIX/NOTE | `VeryLazy` |
| [guess-indent.nvim](https://github.com/NMAC427/guess-indent.nvim) | Detect file indentation | file open |
| [smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim) | Cursor movement animation | `VeryLazy` |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Move between Neovim and tmux panes | keymap |
| [vim-tpipeline](https://github.com/vimpostor/vim-tpipeline) | Statusline inside tmux bar | `VeryLazy` |
| [vim-wakatime](https://github.com/wakatime/vim-wakatime) | Coding time tracking | `VeryLazy` |

## Languages

Installed automatically by Mason (see `lua/plugins/lsp.lua`):

| Language | LSP | Formatter |
| --- | --- | --- |
| Lua | `lua_ls` | `stylua` |
| TypeScript / JavaScript / React | `ts_ls` | `prettierd` → `prettier` |
| CSS / Tailwind | `cssls`, `tailwindcss` | `prettierd` → `prettier` |
| JSON | `jsonls` | `prettierd` → `prettier` |
| HTML | – | `prettierd` → `prettier` |
| Go | `gopls` | `goimports` |
| Python | `pyright` | `isort` + `black` |
| Bash | `bashls` | – |
| Markdown | `marksman` | `prettierd` → `prettier` |
| C | – | `clang-format` (manual only, `<leader>f`) |

Format on save is enabled for everything except C/C++. Falls back to the
LSP formatter if no formatter is configured.

Treesitter parsers listed in `lua/plugins/treesitter.lua` are installed
up front; any other language gets its parser on first open
(`auto_install`).

To add a language: add the server to `servers` and the formatter to `tools`
in `lua/plugins/lsp.lua`, then map the formatter in
`lua/plugins/formatting.lua`.

## Keymaps

Leader is `<Space>`. Press it and wait to see all mappings in which-key,
or search them with `<leader>sk`.

### General

| Keys | Action |
| --- | --- |
| `<Esc>` | Clear search highlight |
| `<leader>e` | File explorer (netrw) |
| `<leader>q` | Diagnostics to location list |
| `<leader>f` | Format buffer |
| `<C-h/j/k/l>` | Move between windows (and tmux panes) |
| `<C-\>` | Previous window / tmux pane |
| `<C-w>-` / `<C-w>\|` | Horizontal / vertical split |
| `<C-=>` / `<C-->` | Increase / decrease window height |
| `<C-t>` | Toggle floating terminal |
| `zk` | Flash jump |

Arrow keys are disabled in normal mode on purpose (use `hjkl`).

### Search (Telescope)

| Keys | Action |
| --- | --- |
| `<leader>sf` | Files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Word under cursor |
| `<leader><leader>` | Open buffers |
| `<leader>/` | Fuzzy find in current buffer |
| `<leader>s/` | Grep in open files |
| `<leader>s.` | Recent files |
| `<leader>sd` | Diagnostics |
| `<leader>sh` | Help tags |
| `<leader>sk` | Keymaps |
| `<leader>sn` | Neovim config files |
| `<leader>ss` | Telescope pickers |
| `<leader>sr` | Resume last search |

### LSP (when a server is attached)

| Keys | Action |
| --- | --- |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References |
| `gI` | Implementations |
| `<leader>D` | Type definition |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `<leader>th` | Toggle inlay hints |

### Completion (insert mode)

| Keys | Action |
| --- | --- |
| `<CR>` | Accept |
| `<C-n>` / `<C-p>` | Next / previous item |
| `<C-space>` | Open menu / docs |
| `<C-e>` | Close menu |

### Harpoon

| Keys | Action |
| --- | --- |
| `<leader>ma` | Add file |
| `<leader>ml` | Toggle menu |
| `<leader>h` / `<leader>j` / `<leader>k` | Jump to file 1 / 2 / 3 |
| `<C-p>` / `<C-n>` | Previous / next file in the list |

### Git and files

| Keys | Action |
| --- | --- |
| `<leader>lg` | LazyGit |
| `<leader>-` | Yazi at current file |
| `<leader>cw` | Yazi at working directory |
| `<C-Up>` | Resume last Yazi session |

### Text objects and motions

| Keys | Action |
| --- | --- |
| `af` / `if` | Around / inside function |
| `ac` / `ic` | Around / inside class |
| `as` | Language scope |
| `[f` / `]f` | Next / previous function start |
| `[F` | Previous function end |
| `va)`, `ci'`, `yinq`... | mini.ai text objects |
| `saiw)` / `sd'` / `sr)'` | Add / delete / replace surrounding |

### OpenCode

| Keys | Action |
| --- | --- |
| `<leader>aa` | Toggle OpenCode |
| `<leader>ai` | Ask |
| `<leader>aI` | Ask about selection/cursor |
| `<leader>ab` | Ask about buffer |
| `<leader>as` | Select action |
| `<leader>ap` | Prompt with context |
| `<leader>ape/apf/apd/apr/apt/apo` | Explain / fix / diagnose / review / test / optimize |

## Options worth knowing

From `lua/config/options.lua`:

- 2-space indentation, spaces instead of tabs (`guess-indent` adapts per file)
- Relative line numbers, cursor line, ruler at column 80
- Persistent undo (`undofile`)
- System clipboard (`unnamedplus`; on Linux needs `xclip` or `wl-clipboard`)
- Case-insensitive search unless you type a capital letter
- Live preview of `:s` substitutions
- Global statusline (`laststatus = 3`)

## Troubleshooting

**`nvim: command not found` after installing.** Open a new terminal, or run
`eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"` (Linux) or
`eval "$(/opt/homebrew/bin/brew shellenv)"` (macOS). Fish users must
add Homebrew to their config manually.

**Icons look like squares.** Your terminal isn't using a Nerd Font. Select
"JetBrainsMono Nerd Font" in its settings.

**A language server is missing.** Run `:Mason` to see its status, or
`:MasonToolsInstall` to retry.

**Treesitter errors after an update.** Run `:TSUpdate`.

**Plugins are in a broken state.** Restore the pinned versions with
`:Lazy restore`, or wipe and reinstall:

```bash
rm -rf ~/.local/share/nvim/lazy && nvim --headless '+Lazy! restore' +qa
```

**Health check.** `:checkhealth` reports anything missing on your system.

## Formatting this config

Lua files are formatted with `stylua` using `.stylua.toml` (80 columns,
2 spaces, single quotes, no call parentheses):

```bash
stylua lua/ init.lua
```
