# dots

My personal dotfiles for Linux, macOS and Windows.

| Directory | What it is |
| --- | --- |
| [`nvim/`](nvim/) | Minimal, performance-first Neovim config. See [nvim/README.md](nvim/README.md). |
| [`ghostty/`](ghostty/) | [Ghostty](https://ghostty.org) terminal config: JetBrainsMono Nerd Font 11pt, GitHub dark palette (matches the Neovim theme), no window decorations. |
| [`.tmux.conf`](.tmux.conf) | tmux config: `C-a` prefix, `\|`/`-` splits, `hjkl` resize, vi copy mode to the system clipboard (`xclip` on Linux, `pbcopy` on macOS), seamless `C-hjkl` navigation with Neovim, sessions saved and restored with resurrect + continuum. |
| [`wezterm/`](wezterm/) | Windows terminal: same look as the Ghostty config and, in native mode, the same keys as `.tmux.conf`. |

## Install

**Linux and macOS**

```bash
curl -fsSL https://raw.githubusercontent.com/Ederjoel26/dots/main/nvim/install.sh | bash
```

Installs every dependency through Homebrew, clones the repo to `~/dots` and
symlinks all three configs (existing files are backed up as `*.bak.<timestamp>`):

| Link | Points to |
| --- | --- |
| `~/.config/nvim` | `~/dots/nvim` |
| `~/.tmux.conf` | `~/dots/.tmux.conf` |
| `~/.config/ghostty/config` | `~/dots/ghostty/config` |

It also installs tmux plugins through [tpm](https://github.com/tmux-plugins/tpm).
On macOS it installs Ghostty too; on Linux, Ghostty has no Homebrew package,
see https://ghostty.org/docs/install.

**Windows** (PowerShell, not as admin)

```powershell
irm https://raw.githubusercontent.com/Ederjoel26/dots/main/nvim/install.ps1 | iex
```

Ghostty and tmux don't run natively on Windows, so the script installs
[WezTerm](https://wezterm.org) with the same look as the Ghostty config and
asks how you want to work:

| | 1) Native (default) | 2) WSL |
| --- | --- | --- |
| Neovim | Windows, via [Scoop](https://scoop.sh) | inside WSL, via `install.sh` |
| Terminal | WezTerm (PowerShell) | WezTerm, opens straight into WSL |
| tmux | WezTerm is the multiplexer, same keys as `.tmux.conf` | the real tmux and `.tmux.conf` |
| Best for | Windows projects and tools | Linux-first workflows, identical to Linux/macOS |

The WSL option needs a distro first: `wsl --install -d Ubuntu` in an admin
PowerShell, reboot, then run the script. Skip the question with
`$env:DOTS_WINDOWS_MODE = 'native'` (or `'wsl'`).

See [nvim/README.md](nvim/README.md). |
| [`ghostty/`](ghostty/) | [Ghostty](https://ghostty.org) terminal config: JetBrainsMono Nerd Font 11pt, GitHub dark palette (matches the Neovim theme), no window decorations. |
| [`.tmux.conf`](.tmux.conf) | tmux config: `C-a` prefix, `\|`/`-` splits, `hjkl` resize, vi copy mode to the system clipboard (`xclip` on Linux, `pbcopy` on macOS), seamless `C-hjkl` navigation with Neovim, sessions saved and restored with resurrect + continuum. |
| [`wezterm/`](wezterm/) | Windows terminal: same look as the Ghostty config and, in native mode, the same keys as `.tmux.conf`. |

## Install

**Linux and macOS**

```bash
curl -fsSL https://raw.githubusercontent.com/Ederjoel26/dots/main/nvim/install.sh | bash
```

Installs every dependency through Homebrew, clones the repo to `~/dots` and
symlinks all three configs (existing files are backed up as `*.bak.<timestamp>`):

| Link | Points to |
| --- | --- |
| `~/.config/nvim` | `~/dots/nvim` |
| `~/.tmux.conf` | `~/dots/.tmux.conf` |
| `~/.config/ghostty/config` | `~/dots/ghostty/config` |

It also installs tmux plugins through [tpm](https://github.com/tmux-plugins/tpm).
On macOS it installs Ghostty too; on Linux, Ghostty has no Homebrew package,
see https://ghostty.org/docs/install.

**Windows** (PowerShell, not as admin)

```powershell
irm https://raw.githubusercontent.com/Ederjoel26/dots/main/nvim/install.ps1 | iex
```

Installs dependencies through [Scoop](https://scoop.sh) and links
`%LOCALAPPDATA%\nvim` to `~\dots\nvim`. Neovim only: tmux and Ghostty
don't run natively on Windows (use WSL and the Linux command for those).

See [nvim/README.md](nvim/README.md#install) for details and options.

## License

MIT
