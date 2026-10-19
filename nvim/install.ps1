# One-command installer for these dotfiles on Windows (PowerShell 5.1+).
#
#   irm https://raw.githubusercontent.com/Ederjoel26/dots/main/nvim/install.ps1 | iex
#
# Ghostty and tmux don't run natively on Windows, so it asks for one of:
#   native  Neovim on Windows. WezTerm is the terminal and replaces tmux
#           (same keys as .tmux.conf).
#   wsl     WezTerm opens WSL; install.sh sets up Neovim + tmux inside Linux.
# Both use WezTerm with the same look as ghostty/config.
#
# Uses Scoop (the Windows equivalent of Homebrew): recent versions, per user,
# no admin needed.
#
# Overridable env vars: DOTS_WINDOWS_MODE=native|wsl, REPO_URL, DOTS_DIR,
# SKIP_FONT=1, SKIP_OPTIONAL=1
$ErrorActionPreference = 'Stop'

$RepoUrl = if ($env:REPO_URL) { $env:REPO_URL } else { 'https://github.com/Ederjoel26/dots.git' }
$DotsDir = if ($env:DOTS_DIR) { $env:DOTS_DIR } else { Join-Path $HOME 'dots' }
$InstallSh = 'https://raw.githubusercontent.com/Ederjoel26/dots/main/nvim/install.sh'
$NvimDir = Join-Path $env:LOCALAPPDATA 'nvim'

# Native mode, required: Neovim + everything plugins and Mason need to work
# (gcc/make build Treesitter parsers and telescope-fzf-native, pwsh is the
# shell, 7zip/unzip are used by Mason).
$Required = @('neovim', 'ripgrep', 'fd', 'fzf', 'lazygit', 'nodejs-lts', 'go', 'python',
  'mingw', 'make', '7zip', 'unzip', 'pwsh')
# Nice to have: missing ones only disable a single feature.
$Optional = @('yazi', 'opencode')

function Info($msg) { Write-Host "==> $msg" -ForegroundColor Blue }
function Warn($msg) { Write-Host "warn: $msg" -ForegroundColor Yellow }

function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' +
    [Environment]::GetEnvironmentVariable('Path', 'Machine')
}

# Run a native command and stop if it fails.
function Exec([scriptblock]$cmd) {
  & $cmd
  if ($LASTEXITCODE) { throw "Command failed ($LASTEXITCODE): $cmd" }
}

function Set-UserEnv($name, $value) {
  [Environment]::SetEnvironmentVariable($name, $value, 'User')
}

# 0. Mode --------------------------------------------------------------------
$Mode = $env:DOTS_WINDOWS_MODE
if (-not $Mode) {
  Write-Host ''
  Write-Host 'How do you want to run the dotfiles?'
  Write-Host '  1) Native  Neovim on Windows, WezTerm as terminal + tmux replacement (default)'
  Write-Host '  2) WSL     WezTerm opens WSL, Neovim + tmux run inside Linux'
  $Mode = if ((Read-Host 'Choose 1 or 2') -eq '2') { 'wsl' } else { 'native' }
}
if ($Mode -notin 'native', 'wsl') { throw "DOTS_WINDOWS_MODE must be 'native' or 'wsl', got '$Mode'" }
Info "Mode: $Mode"

# WSL mode needs a working distro first; check before installing anything.
if ($Mode -eq 'wsl') {
  # Name of the default distro, or nothing if WSL or a distro is missing.
  $Distro = ''
  if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
    try {
      $out = & { $ErrorActionPreference = 'Continue'; wsl.exe -- bash -c 'echo $WSL_DISTRO_NAME' 2>$null }
      if (-not $LASTEXITCODE) { $Distro = ($out | Out-String).Trim() }
    } catch {}
  }
  if (-not $Distro) {
    Write-Host ''
    Warn 'No WSL distro found. Set it up first, then run this script again:'
    Write-Host '  1. In an admin PowerShell:  wsl --install -d Ubuntu'
    Write-Host '  2. Reboot, open "Ubuntu" from the Start menu and create your user.'
    return
  }
  Info "WSL distro: $Distro"
}

# 1. Scoop -------------------------------------------------------------------
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Info 'Installing Scoop'
  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
  Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
  Refresh-Path
}

Info 'Installing git and Scoop buckets'
scoop install git
foreach ($bucket in 'extras', 'nerd-fonts') {
  if (-not (scoop bucket list | Where-Object { $_.Name -eq $bucket })) { scoop bucket add $bucket }
}
scoop update

# 2. Terminal + font (both modes) -------------------------------------------
Info 'Installing WezTerm'
scoop install wezterm
Refresh-Path
if (-not (Get-Command wezterm -ErrorAction SilentlyContinue)) { throw 'WezTerm was not installed, re-run the script' }

if ($env:SKIP_FONT -ne '1') {
  Info 'Installing JetBrainsMono Nerd Font'
  scoop install nerd-fonts/JetBrainsMono-NF
  if ($LASTEXITCODE) { Warn 'Font install failed, install a Nerd Font manually' }
}

# 3. Repo --------------------------------------------------------------------
# Running from a local checkout (.\nvim\install.ps1)? Use it. Piped from irm? Clone.
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot 'init.lua'))) {
  $Dots = Split-Path $PSScriptRoot -Parent
} else {
  if (Test-Path (Join-Path $DotsDir '.git')) {
    Info "Updating $DotsDir"
    git -C $DotsDir pull --ff-only
    if ($LASTEXITCODE) { Warn "Could not update $DotsDir, using it as is" }
  } else {
    Info "Cloning $RepoUrl into $DotsDir"
    Exec { git clone --depth 1 $RepoUrl $DotsDir }
  }
  $Dots = $DotsDir
}
$Dots = (Resolve-Path $Dots).Path

# WezTerm reads its config from WEZTERM_CONFIG_FILE: no symlink (and no admin
# or Developer Mode) needed, and edits in the repo apply right away.
Set-UserEnv 'WEZTERM_CONFIG_FILE' (Join-Path $Dots 'wezterm\wezterm.lua')
Info "WezTerm config: $Dots\wezterm\wezterm.lua"

# 4a. WSL mode: everything else happens inside Linux -------------------------
if ($Mode -eq 'wsl') {
  Set-UserEnv 'DOTS_WSL_DISTRO' $Distro
  Info "Running install.sh inside $Distro (it may ask for your Linux password)"
  # The font lives on the Windows side, WezTerm renders it.
  Exec { wsl.exe -d $Distro -- bash -c "curl -fsSL $InstallSh | SKIP_FONT=1 bash" }

  Write-Host ''
  Info 'Done! Open WezTerm: it starts in WSL with tmux and nvim ready.'
  return
}

# 4b. Native mode -----------------------------------------------------------
Set-UserEnv 'DOTS_WSL_DISTRO' $null

Info "Installing: $($Required -join ' ')"
scoop install @Required
Refresh-Path
foreach ($exe in 'nvim', 'rg', 'fd', 'fzf', 'lazygit', 'node', 'go', 'python', 'gcc', 'make', 'git', 'pwsh') {
  if (-not (Get-Command $exe -ErrorAction SilentlyContinue)) { throw "$exe was not installed, re-run the script" }
}

if ($env:SKIP_OPTIONAL -ne '1') {
  foreach ($pkg in $Optional) {
    Info "Installing optional: $pkg"
    scoop install $pkg
    if ($LASTEXITCODE) { Warn "Could not install $pkg (only its integration is affected)" }
  }
}

$Src = Join-Path $Dots 'nvim'
$existing = Get-Item $NvimDir -Force -ErrorAction SilentlyContinue
if ($existing -and "$($existing.Target)" -eq $Src) {
  Info "$NvimDir already points to $Src"
} else {
  if ($existing) {
    $backup = "$NvimDir.bak.$(Get-Date -Format yyyyMMddHHmmss)"
    Warn "Existing config moved to $backup"
    Move-Item $NvimDir $backup
  }
  # A junction needs no admin rights or Developer Mode, unlike a symlink.
  New-Item -ItemType Junction -Path $NvimDir -Target $Src | Out-Null
  Info "Linked $NvimDir -> $Src"
}

# Plugins, parsers, LSP servers (headless, so first launch is clean).
Info 'Installing plugins (lazy.nvim, pinned to lazy-lock.json)'
Exec { nvim --headless '+Lazy! restore' +qa }

Info 'Installing Treesitter parsers'
Exec { nvim --headless '+Lazy! load nvim-treesitter' "+lua require('nvim-treesitter.install').ensure_installed_sync(require('nvim-treesitter.configs').get_ensure_installed_parsers())" +qa }

Info 'Installing LSP servers and formatters (Mason)'
Exec { nvim --headless '+MasonToolsInstallSync' +qa }

Write-Host ''
Info 'Done! Open WezTerm and start: nvim'
