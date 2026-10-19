#!/usr/bin/env bash
# One-command installer for these dotfiles (Neovim, tmux, Ghostty) on Linux
# and macOS. Windows: use install.ps1.
#
#   curl -fsSL https://raw.githubusercontent.com/Ederjoel26/dots/main/nvim/install.sh | bash
#
# Everything comes from Homebrew so versions are recent and identical on every
# system. On Linux, distro packages are only used for the few things Homebrew
# itself needs (compiler, git, curl...).
#
# Overridable env vars: REPO_URL, DOTS_DIR, SKIP_FONT=1, SKIP_OPTIONAL=1
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/Ederjoel26/dots.git}"
DOTS_DIR="${DOTS_DIR:-$HOME/dots}"
NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/JetBrainsMonoNerdFont"
OS="$(uname -s)"

# Required: Neovim + everything plugins and Mason need to work.
BREW_REQUIRED=(neovim ripgrep fd fzf lazygit node go python)
# Nice to have: missing ones only disable a single feature.
BREW_OPTIONAL=(yazi tmux opencode)

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

case "$OS" in
  Linux | Darwin) ;;
  *) die "Unsupported system: $OS. On Windows use install.ps1." ;;
esac
[ "$(id -u)" -ne 0 ] || die "Run as your normal user, not root (Homebrew refuses root). sudo is used when needed."

sudo_() { if command -v sudo >/dev/null; then sudo "$@"; else die "sudo is required to install: $*"; fi; }

# 1. System prerequisites (only what Homebrew needs to install itself) -------
install_system_deps() {
  # macOS: the Homebrew installer sets up the Xcode Command Line Tools itself.
  [ "$OS" = Linux ] || return 0
  info "Installing system prerequisites for Homebrew"
  local base clip=(xclip wl-clipboard)
  if command -v apt-get >/dev/null; then
    base=(build-essential procps curl file git unzip tar xz-utils fontconfig ca-certificates)
    sudo_ apt-get update -qq
    sudo_ env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${base[@]}" >/dev/null
    sudo_ env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${clip[@]}" >/dev/null || warn "Clipboard tools not installed"
  elif command -v dnf >/dev/null; then
    base=(gcc gcc-c++ make procps-ng curl file git unzip tar xz fontconfig)
    sudo_ dnf install -y -q "${base[@]}"
    sudo_ dnf install -y -q "${clip[@]}" || warn "Clipboard tools not installed"
  elif command -v pacman >/dev/null; then
    base=(base-devel procps-ng curl file git unzip tar xz fontconfig)
    sudo_ pacman -Sy --needed --noconfirm "${base[@]}"
    sudo_ pacman -S --needed --noconfirm "${clip[@]}" || warn "Clipboard tools not installed"
  elif command -v zypper >/dev/null; then
    base=(gcc gcc-c++ make procps curl file git unzip tar xz fontconfig)
    sudo_ zypper --non-interactive install "${base[@]}"
    sudo_ zypper --non-interactive install "${clip[@]}" || warn "Clipboard tools not installed"
  else
    warn "Unknown package manager. Make sure gcc, make, git, curl, file, unzip and tar are installed."
  fi
}

# 2. Homebrew ----------------------------------------------------------------
find_brew() {
  local b
  for b in "$(command -v brew || true)" /opt/homebrew/bin/brew /usr/local/bin/brew \
    /home/linuxbrew/.linuxbrew/bin/brew; do
    [ -n "$b" ] && [ -x "$b" ] && { echo "$b"; return; }
  done
}

install_brew() {
  if [ -z "$(find_brew)" ]; then
    info "Installing Homebrew"
    # Cache sudo now: the non-interactive Homebrew installer can't prompt.
    sudo_ -v
    NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  local brew_bin
  brew_bin="$(find_brew)"
  [ -n "$brew_bin" ] || die "Homebrew installation failed"
  eval "$("$brew_bin" shellenv)"

  # Make brew available in future shells (zsh is the macOS default).
  local line="eval \"\$($brew_bin shellenv)\"" rc
  local shell_rc="$HOME/.$(basename "${SHELL:-bash}")rc"
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] || [ "$rc" = "$shell_rc" ]; then
      grep -qsF "$line" "$rc" || printf '\n%s\n' "$line" >>"$rc"
    fi
  done
}

install_brew_packages() {
  export HOMEBREW_NO_ENV_HINTS=1 HOMEBREW_NO_INSTALL_CLEANUP=1
  info "Updating Homebrew"
  brew update --quiet || warn "brew update failed, continuing with current formulae"

  info "Installing: ${BREW_REQUIRED[*]}"
  brew install --quiet "${BREW_REQUIRED[@]}"

  [ "${SKIP_OPTIONAL:-0}" = 1 ] && return
  local pkg
  for pkg in "${BREW_OPTIONAL[@]}"; do
    info "Installing optional: $pkg"
    brew install --quiet "$pkg" || warn "Could not install $pkg (only its integration is affected)"
  done
  # Ghostty only has a Homebrew package on macOS.
  if [ "$OS" = Darwin ] && [ ! -d /Applications/Ghostty.app ]; then
    info "Installing optional: Ghostty"
    brew install --quiet --cask ghostty || warn "Could not install Ghostty"
  fi
}

# 3. Nerd Font ---------------------------------------------------------------
install_font() {
  [ "${SKIP_FONT:-0}" = 1 ] && return
  if [ "$OS" = Darwin ]; then
    info "Installing JetBrainsMono Nerd Font"
    brew install --quiet --cask font-jetbrains-mono-nerd-font || warn "Font install failed, install a Nerd Font manually"
    return 0
  fi
  if command -v fc-list >/dev/null && fc-list | grep -i "JetBrainsMono.*Nerd" >/dev/null; then
    info "JetBrainsMono Nerd Font already installed"
    return
  fi
  info "Installing JetBrainsMono Nerd Font"
  mkdir -p "$FONT_DIR"
  curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz |
    tar -xJ -C "$FONT_DIR" || { warn "Font download failed, install a Nerd Font manually"; return 0; }
  if command -v fc-cache >/dev/null; then fc-cache -f "$FONT_DIR" >/dev/null; fi
}

# 4. Config ------------------------------------------------------------------
# link SRC DEST: symlink DEST to SRC, backing up whatever was at DEST.
link() {
  local src="$1" dest="$2"
  if [ "$(readlink -f "$dest" 2>/dev/null)" = "$src" ]; then
    info "$dest already points to $src"
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup
    backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    warn "Existing $dest moved to $backup"
    mv "$dest" "$backup"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  info "Linked $dest -> $src"
}

install_config() {
  local dots
  # Running from a local checkout (./install.sh)? Use it. Piped from curl? Clone.
  if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ] &&
    [ -f "$(dirname "${BASH_SOURCE[0]}")/init.lua" ]; then
    dots="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
  else
    if [ -d "$DOTS_DIR/.git" ]; then
      info "Updating $DOTS_DIR"
      git -C "$DOTS_DIR" pull --ff-only || warn "Could not update $DOTS_DIR, using it as is"
    else
      info "Cloning $REPO_URL into $DOTS_DIR"
      git clone --depth 1 "$REPO_URL" "$DOTS_DIR"
    fi
    dots="$(cd "$DOTS_DIR" && pwd -P)"
  fi

  link "$dots/nvim" "$NVIM_DIR"
  link "$dots/.tmux.conf" "$HOME/.tmux.conf"
  # Ghostty reads ~/.config/ghostty/config on macOS too.
  link "$dots/ghostty/config" "${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
}

# tmux plugins (tpm). Without tpm, tmux shows an error on every start.
setup_tmux() {
  command -v tmux >/dev/null || return 0
  local tpm="$HOME/.tmux/plugins/tpm"
  if [ ! -d "$tpm" ]; then
    info "Installing tmux plugin manager (tpm)"
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm" ||
      { warn "Could not clone tpm"; return 0; }
  fi
  info "Installing tmux plugins"
  "$tpm/bin/install_plugins" >/dev/null || warn "tmux plugins not installed, press C-a I inside tmux"
}

# 5. Plugins, parsers, LSP servers (headless, so first launch is clean) -----
bootstrap_nvim() {
  info "Installing plugins (lazy.nvim, pinned to lazy-lock.json)"
  nvim --headless '+Lazy! restore' +qa

  info "Installing Treesitter parsers"
  nvim --headless '+Lazy! load nvim-treesitter' \
    "+lua require('nvim-treesitter.install').ensure_installed_sync(require('nvim-treesitter.configs').get_ensure_installed_parsers())" \
    +qa

  info "Installing LSP servers and formatters (Mason)"
  nvim --headless '+MasonToolsInstallSync' +qa
}

install_system_deps
install_brew
install_brew_packages
install_font
install_config
setup_tmux
bootstrap_nvim

echo
info "Done! Open a new terminal (or run: eval \"\$(brew shellenv)\") and start: nvim"
info "Set your terminal font to 'JetBrainsMono Nerd Font' for icons."
