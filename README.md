# dots

My personal dotfiles for Linux.

| Directory | What it is |
| --- | --- |
| [`nvim/`](nvim/) | Minimal, performance-first Neovim config. See [nvim/README.md](nvim/README.md). |
| [`ghostty/`](ghostty/) | [Ghostty](https://ghostty.org) terminal config: JetBrainsMono Nerd Font 11pt, GitHub dark palette (matches the Neovim theme), no window decorations. |
| [`.tmux.conf`](.tmux.conf) | tmux config: `C-a` prefix, `\|`/`-` splits, `hjkl` resize, vi copy mode to the system clipboard (`xclip`), seamless `C-hjkl` navigation with Neovim, sessions saved and restored with resurrect + continuum. |

## Install

Neovim (installs every dependency through Homebrew):

```bash
curl -fsSL https://raw.githubusercontent.com/Ederjoel26/dots/main/nvim/install.sh | bash
```

Ghostty (install Ghostty itself first, see https://ghostty.org/docs/install):

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dots/ghostty/config ~/.config/ghostty/config
```

tmux (the Neovim installer already installs `tmux` and `xclip`):

```bash
ln -sf ~/dots/.tmux.conf ~/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux   # then press C-a I to install the plugins
```

## License

MIT
