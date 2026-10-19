# dots

My personal dotfiles for Linux.

| Directory | What it is |
| --- | --- |
| [`nvim/`](nvim/) | Minimal, performance-first Neovim config. See [nvim/README.md](nvim/README.md). |
| [`ghostty/`](ghostty/) | [Ghostty](https://ghostty.org) terminal config: JetBrainsMono Nerd Font 11pt, dark palette, 92% opacity, no window decorations. |

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

## License

MIT
