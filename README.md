# 🚀 Eder's Development Environment Setup

A comprehensive dotfiles repository containing my personal development environment configuration. This setup includes a highly optimized Neovim configuration, i3 window manager, terminal multiplexer, and various productivity tools.

## 📋 Table of Contents

- [🎯 Overview](#-overview)
- [🛠️ Technologies Included](#️-technologies-included)
- [📦 Prerequisites](#-prerequisites)
- [🚀 Installation](#-installation)
- [⚙️ Configuration Details](#️-configuration-details)
- [🎨 Theme & Appearance](#-theme--appearance)
- [🔧 Key Features](#-key-features)
- [📝 Usage Tips](#-usage-tips)
- [🐛 Troubleshooting](#-bug-troubleshooting)

## 🎯 Overview

This dotfiles collection is designed for developers who want a fast, efficient, and visually appealing development environment on Linux. The configuration focuses on:

- **Minimalism**: Only essential tools and configurations
- **Performance**: Optimized for speed and responsiveness
- **Consistency**: Unified theme across all applications
- **Productivity**: Keyboard-driven workflow with minimal mouse usage

## 🛠️ Technologies Included

### Core Environment
- **i3wm** - Tiling window manager for efficient workspace management
- **Ghostty** - Modern, fast terminal emulator
- **Tmux** - Terminal multiplexer for session management
- **Picom** - Compositor for visual effects and transparency
- **Rofi** - Application launcher and menu system

### Development Tools
- **Neovim** - Highly configured Lua-based text editor
- **Lazy.nvim** - Modern plugin manager for Neovim
- **Blink.cmp** - Fast completion engine
- **LSP** - Language Server Protocol support
- **Treesitter** - Syntax highlighting and code understanding
- **Lazygit** - Terminal UI for git operations (integrated with Neovim)

### Additional Tools
- **OpenCode** - AI-powered development assistant
- **Stylua** - Lua code formatter
- **Various CLI tools** - Modern replacements for traditional Unix tools

## 📦 Prerequisites

### System Requirements
- **Linux Distribution**: Ubuntu 22.04+, Arch Linux, or similar
- **Display Server**: X11 (Wayland support in progress)
- **Hardware**: Any modern computer with at least 4GB RAM

### Required Dependencies

#### Core System Packages
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y \
    i3-wm i3status i3lock \
    rofi picom feh \
    tmux xclip \
    maim peek simplescreenrecorder \
    nm-applet \
    brightnessctl \
    wpctl \
    git curl wget \
    build-essential \
    fonts-jetbrains-mono

# Arch Linux
sudo pacman -S \
    i3-wm i3status i3lock \
    rofi picom feh \
    tmux xclip \
    maim peek simplescreenrecorder \
    networkmanager \
    brightnessctl \
    wireplumber \
    git curl wget \
    base-devel \
    ttf-jetbrains-mono-nerd
```

#### Neovim Dependencies
```bash
# Ubuntu/Debian
sudo apt install -y \
    neovim \
    python3-pip \
    nodejs npm \
    ripgrep fd-find \
    bat eza sd \
    lazygit

# Arch Linux
sudo pacman -S \
    neovim \
    python-pip \
    nodejs npm \
    ripgrep fd \
    bat eza sd \
    lazygit
```

#### Modern CLI Tools (Highly Recommended)
```bash
# Install via Homebrew (if available)
brew install bat ripgrep fd sd eza lazygit

# Or via package managers
# Ubuntu/Debian
sudo apt install -y bat ripgrep fd-find sd eza
# Lazygit needs to be installed separately
curl -s https://packagecloud.io/install/repositories/jesseduffield/lazygit/script.deb.sh | sudo bash
sudo apt-get install lazygit

# Arch Linux
sudo pacman -S bat ripgrep fd sd eza lazygit
```

#### Lazygit (Git GUI - Required for Neovim Integration)
```bash
# Method 1: Direct download (recommended)
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz lazygit

# Method 2: Package manager (Ubuntu/Debian)
curl -s https://packagecloud.io/install/repositories/jesseduffield/lazygit/script.deb.sh | sudo bash
sudo apt-get install lazygit

# Method 3: Package manager (Arch Linux)
sudo pacman -S lazygit

# Method 4: Via Homebrew
brew install lazygit

# Verify installation
lazygit --version
```

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/Ederjoel26/dots.git ~/dots
cd ~/dots
```

### 2. Create Symbolic Links
```bash
# Create config directories if they don't exist
mkdir -p ~/.config ~/.config/i3 ~/.config/nvim ~/.config/picom ~/.config/ghostty

# Create symbolic links
ln -sf ~/dots/i3/config ~/.config/i3/config
ln -sf ~/dots/i3/monitor_detect.sh ~/.config/i3/monitor_detect.sh
ln -sf ~/dots/nvim ~/.config/nvim
ln -sf ~/dots/picom/picom.conf ~/.config/picom/picom.conf
ln -sf ~/dots/ghostty/config ~/.config/ghostty/config
ln -sf ~/dots/.tmux.conf ~/.tmux.conf
ln -sf ~/dots/opencode ~/.config/opencode
```

### 3. Install Neovim Plugins
```bash
# Neovim will automatically install plugins on first launch
nvim
```

### 4. Install Tmux Plugins
```bash
# Install TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install plugins (start tmux and press prefix + I)
tmux
# Then press: Ctrl-a + I
```

### 5. Install Ghostty
```bash
# Ubuntu/Debian
wget -qO- https://github.com/ghostty-org/ghostty/releases/latest/download/ghostty_amd64.deb | sudo dpkg -i -

# Arch Linux (via AUR)
yay -S ghostty-bin

# Or build from source
git clone https://github.com/ghostty-org/ghostty.git
cd ghostty
make install
```

### 6. Install OpenCode (Optional)
```bash
# Install OpenCode CLI tool
npm install -g @opencode/cli

# Or download from releases
wget https://github.com/opencode-org/opencode/releases/latest/download/opencode-linux-amd64
chmod +x opencode-linux-amd64
sudo mv opencode-linux-amd64 /usr/local/bin/opencode
```

## ⚙️ Configuration Details

### i3 Window Manager
- **Mod Key**: Super (Windows key)
- **Terminal**: Ghostty
- **Application Launcher**: Rofi
- **Workspaces**: 9 numbered workspaces
- **Gaps**: 10px inner, 5px outer, 30px top
- **Theme**: Custom dark theme with purple accents

#### Key Bindings
- `Mod + Enter`: Open terminal
- `Mod + d`: Open application launcher
- `Mod + Shift + q`: Close focused window
- `Mod + h/j/k/l`: Navigate windows
- `Mod + Shift + h/j/k/l`: Move windows
- `Mod + f`: Toggle fullscreen
- `Mod + 1-9`: Switch to workspace
- `Mod + Shift + 1-9`: Move to workspace

### Neovim Configuration
- **Plugin Manager**: Lazy.nvim
- **Completion**: Blink.cmp with LSP integration
- **Theme**: Vague theme (dark, minimalist)
- **Features**:
  - LSP with auto-completion
  - Treesitter for syntax highlighting
  - Git integration (Gitsigns)
  - File explorer (Telescope)
  - Terminal integration
  - Auto-formatting
  - Todo comments highlighting

#### Key Features
- **Modern Lua Configuration**: Modular and maintainable
- **Fast Startup**: Optimized loading times
- **Rich Ecosystem**: Extensive plugin collection
- **AI Integration**: OpenCode for intelligent assistance

### Tmux Configuration
- **Prefix**: Ctrl-a (instead of Ctrl-b)
- **Plugins**:
  - vim-tmux-navigator: Seamless navigation between Vim/Tmux panes
  - tmux-themepack: Powerline theme
  - tmux-resurrect: Session persistence
  - tmux-continuum: Automatic session saving

#### Key Bindings
- `Ctrl-a + |`: Split horizontal
- `Ctrl-a + -`: Split vertical
- `Ctrl-a + h/j/k/l`: Resize panes
- `Ctrl-a + r`: Reload configuration
- `Ctrl-a + I`: Install plugins

### Ghostty Terminal
- **Font**: JetBrainsMono Nerd Font (11pt)
- **Theme**: Custom Vague color scheme
- **Features**:
  - Font ligatures enabled
  - Background opacity (92%)
  - Rounded corners
  - Custom color palette

## 🎨 Theme & Appearance

### Color Scheme
The entire setup uses a consistent dark theme called "Vague" with:
- **Background**: Deep dark blue (#14141d)
- **Foreground**: Light gray (#cdcecf)
- **Accent**: Purple (#D07EF2) for focused elements
- **Palette**: Carefully selected colors for syntax highlighting

### Visual Effects
- **Rounded Corners**: 12px radius (excluded from polybar/i3bar)
- **Shadows**: Subtle shadows for depth
- **Transparency**: 92% opacity for terminal
- **Gaps**: Consistent spacing throughout

## 🔧 Key Features

### Productivity Enhancements
- **Keyboard-Driven Workflow**: Minimal mouse usage required
- **Session Management**: Tmux sessions persist across reboots
- **Smart Completion**: Context-aware code completion
- **Git Integration**: Built-in git status and operations
- **Screenshot Tools**: Multiple screenshot options
- **Audio/Brightness Controls**: Media key support

### Development Features
- **LSP Support**: Full language server protocol integration
- **Syntax Highlighting**: Treesitter-powered highlighting
- **Code Formatting**: Automatic formatting on save
- **IntelliSense**: Rich code intelligence
- **Debugging**: Integrated debugging capabilities
- **File Navigation**: Fast file search and navigation

## 📝 Usage Tips

### Daily Workflow
1. **Start i3**: Login to your system with i3 selected
2. **Open Terminal**: `Mod + Enter` opens Ghostty
3. **Launch Applications**: `Mod + d` opens Rofi launcher
4. **Manage Windows**: Use hjkl for navigation
5. **Development Work**: Open Neovim and start coding

### Neovim Tips
- Use `:Lazy` to manage plugins
- Use `:Telescope` for file navigation
- Use `gd` to go to definition
- Use `gr` to find references
- Use `:TodoTrouble` to see all todos
- Use `:LazyGit` to open git interface (requires lazygit)

### Tmux Tips
- Use `Ctrl-a + I` to install plugins
- Use `Ctrl-a + s` to save sessions
- Use `Ctrl-a + r` to restore sessions
- Use `Ctrl-a + c` to create new windows

## 🐛 Troubleshooting

### Common Issues

#### Lazygit Not Found
```bash
# Check if lazygit is installed
which lazygit
# If not found, install using one of the methods above
# Then restart Neovim to enable the integration
```

#### Neovim Plugins Not Installing
```bash
# Remove lazy-lock.json and restart Neovim
rm ~/.config/nvim/lazy-lock.json
nvim
```

#### Tmux Plugins Not Working
```bash
# Reinstall TPM
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux
# Press Ctrl-a + I to install plugins
```

#### Ghostty Not Found
```bash
# Check if Ghostty is installed
which ghostty
# If not found, reinstall following the installation steps
```

#### Font Issues
```bash
# Install Nerd Fonts
sudo apt install fonts-jetbrains-mono-nerd
# Or download from https://www.nerdfonts.com/
```

#### i3 Gaps Not Working
```bash
# Check if i3-gaps is installed (for older systems)
# Modern i3 includes gaps by default
i3-msg gaps inner all set 10
```

### Getting Help
- **i3**: Check `~/.config/i3/config` for keybindings
- **Neovim**: Use `:help` inside Neovim
- **Tmux**: Use `man tmux` or `Ctrl-a + ?`
- **Ghostty**: Check `ghostty --help`

## 🤝 Contributing

Feel free to fork this repository and adapt it to your needs. If you find any issues or have suggestions, please open an issue or submit a pull request.

## 📄 License

This repository is licensed under the MIT License. Feel free to use and modify it as you see fit.

---

**Happy Coding! 🚀**

Built with ❤️ by [Eder Joel](https://github.com/Ederjoel26)