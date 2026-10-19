#!/usr/bin/env bash
# One-command installer for this Neovim config on Linux.
#
#   curl -fsSL https://raw.githubusercontent.com/Ederjoel26/dots/main/nvim/install.sh | bash
#
# Distro packages are only used for the few things Homebrew itself needs
# (compiler, git, curl...). Everything else comes from Homebrew so versions
# are recent and identical on every distro.
#
# Overridable env vars: REPO_URL, DOTS_DIR, SKIP_FONT=1, SKIP_OPTIONAL=1
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/Ederjoel26/dots.git}"
DOTS_DIR="${DOTS_DIR:-$HOME/dots}"
NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/JetBrainsMonoNerdFont"
BREW_PREFIX=/home/linuxbrew/.linuxbrew

# Required: Neovim + everything plugins and Mason need to work.
BREW_REQUIRED=(neovim ripgrep fd fzf lazygit node go python)
# Nice to have: missing ones only disable a single feature.
BREW_OPTIONAL=(yazi tmux opencode)

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = Linux ] || die "This installer only supports Linux."
[ "$(id -u)" -ne 0 ] || die "Run as your normal user, not root (Homebrew refuses root). sudo is used when needed."

sudo_() { if command -v sudo >/dev/null; then sudo "$@"; else die "sudo is required to install: $*"; fi; }

# 1. System prerequisites (only what Homebrew needs to install itself) -------
install_system_deps() {
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
install_brew() {
  if ! command -v brew >/dev/null && [ ! -x "$BREW_PREFIX/bin/brew" ]; then
    info "Installing Homebrew"
    NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  local brew_bin
  brew_bin="$(command -v brew || echo "$BREW_PREFIX/bin/brew")"
  eval "$("$brew_bin" shellenv)"

  # Make brew available in future shells.
  local line="eval \"\$($brew_bin shellenv)\"" rc
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] || [ "$rc" = "$HOME/.bashrc" ]; then
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
}

# 3. Nerd Font ---------------------------------------------------------------
install_font() {
  [ "${SKIP_FONT:-0}" = 1 ] && return
  if command -v fc-list >/dev/null && fc-list | grep -i "JetBrainsMono.*Nerd" >/dev/null; then
    info "JetBrainsMono Nerd Font already installed"
    return
  fi
  info "Installing JetBrainsMono Nerd Font"
  mkdir -p "$FONT_DIR"
  curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz |
    tar -xJ -C "$FONT_DIR" || { warn "Font download failed, install a Nerd Font manually"; return; }
  command -v fc-cache >/dev/null && fc-cache -f "$FONT_DIR" >/dev/null
}

# 4. Config ------------------------------------------------------------------
install_config() {
  local src
  # Running from a local checkout (./install.sh)? Use it. Piped from curl? Clone.
  if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ] &&
    [ -f "$(dirname "${BASH_SOURCE[0]}")/init.lua" ]; then
    src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    if [ -d "$DOTS_DIR/.git" ]; then
      info "Updating $DOTS_DIR"
      git -C "$DOTS_DIR" pull --ff-only || warn "Could not update $DOTS_DIR, using it as is"
    else
      info "Cloning $REPO_URL into $DOTS_DIR"
      git clone --depth 1 "$REPO_URL" "$DOTS_DIR"
    fi
    src="$DOTS_DIR/nvim"
  fi

  if [ "$(readlink -f "$NVIM_DIR" 2>/dev/null)" = "$src" ]; then
    info "$NVIM_DIR already points to $src"
    return
  fi
  if [ -e "$NVIM_DIR" ] || [ -L "$NVIM_DIR" ]; then
    local backup
    backup="$NVIM_DIR.bak.$(date +%Y%m%d%H%M%S)"
    warn "Existing config moved to $backup"
    mv "$NVIM_DIR" "$backup"
  fi
  mkdir -p "$(dirname "$NVIM_DIR")"
  ln -s "$src" "$NVIM_DIR"
  info "Linked $NVIM_DIR -> $src"
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
bootstrap_nvim

echo
info "Done! Open a new terminal (or run: eval \"\$(brew shellenv)\") and start: nvim"
info "Set your terminal font to 'JetBrainsMono Nerd Font' for icons."
