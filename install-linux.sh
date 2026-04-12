#!/usr/bin/env bash
# bootstrap a debian/ubuntu box with ~/.dotfiles
# idempotent — safe to re-run
# size-conscious: apt where possible, curl installers for the rest
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_DIR="$REPO_DIR/zsh"
VIM_DIR="$REPO_DIR/vim"
VSCODE_DIR="$REPO_DIR/vscode"
VSCODE_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[ok]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!!]${NC} $1"; }
fail()  { echo -e "${RED}[err]${NC} $1"; exit 1; }
step()  { echo -e "\n${GREEN}==> $1${NC}"; }

# sanity — debian/ubuntu only
if ! command -v apt-get &>/dev/null; then
    fail "apt-get not found — this script is for debian/ubuntu. use setup.sh on macOS."
fi

# ── apt packages ──────────────────────────────────────────────────────
step "apt packages"
APT_PACKAGES=(
    zsh
    git
    curl
    build-essential
    vim-gtk3      # vim with +clipboard (no macvim on linux)
    lsd
    hub
    trash-cli     # provides trash-put (wrapped below)
    fzf
    ripgrep
    cowsay
    xclip         # pbcopy/pbpaste shim
    golang-go     # go toolchain (apt version may lag upstream)
    # pyenv build deps — needed if user later installs python versions
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
)

sudo apt-get update
sudo apt-get install -y "${APT_PACKAGES[@]}" || warn "some apt packages failed — continuing"

# trash-cli ships `trash-put`; aliases.zsh aliases `rm` to `trash`
# create a /usr/local/bin/trash shim pointing at trash-put
if command -v trash-put &>/dev/null && ! command -v trash &>/dev/null; then
    sudo ln -sf "$(command -v trash-put)" /usr/local/bin/trash
    info "trash -> trash-put shim installed"
fi

# ── vivid (not in apt — grab prebuilt .deb) ───────────────────────────
step "vivid"
if ! command -v vivid &>/dev/null; then
    VIVID_VERSION="0.10.1"
    ARCH="$(dpkg --print-architecture)"
    TMP_DEB="$(mktemp --suffix=.deb)"
    if curl -fsSL "https://github.com/sharkdp/vivid/releases/download/v${VIVID_VERSION}/vivid_${VIVID_VERSION}_${ARCH}.deb" -o "$TMP_DEB"; then
        sudo dpkg -i "$TMP_DEB" && info "vivid installed" || warn "vivid dpkg install failed"
        rm -f "$TMP_DEB"
    else
        warn "vivid download failed, skipping"
    fi
else
    info "vivid already installed"
fi

# ── pyenv (curl installer) ────────────────────────────────────────────
step "pyenv"
if [[ ! -d "$HOME/.pyenv" ]]; then
    curl -fsSL https://pyenv.run | bash
    info "pyenv installed"
else
    info "pyenv already installed"
fi

# ── nvm (curl installer) ──────────────────────────────────────────────
step "nvm"
if [[ ! -d "$HOME/.nvm" ]]; then
    # latest install script — pinned version avoids surprise changes
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    info "nvm installed"
else
    info "nvm already installed"
fi

# ── pnpm (standalone installer) ───────────────────────────────────────
step "pnpm"
if ! command -v pnpm &>/dev/null; then
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    info "pnpm installed"
else
    info "pnpm already installed"
fi

# ── oh-my-zsh ─────────────────────────────────────────────────────────
step "oh-my-zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    info "oh-my-zsh installed"
else
    info "oh-my-zsh already installed"
fi

# ── powerlevel10k ─────────────────────────────────────────────────────
step "powerlevel10k"
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    info "powerlevel10k installed"
else
    info "powerlevel10k already installed"
fi

# ── zshrc symlink ─────────────────────────────────────────────────────
step "zshrc"
if [[ -f "$HOME/.zshrc" ]] && [[ ! -L "$HOME/.zshrc" ]]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"
    warn "backed up existing ~/.zshrc"
fi
ln -sf "$ZSH_DIR/zshrc" "$HOME/.zshrc"
info "~/.zshrc -> $ZSH_DIR/zshrc"

# ── p10k config ───────────────────────────────────────────────────────
if [[ -f "$ZSH_DIR/p10k.zsh" ]]; then
    info "p10k config will be sourced from $ZSH_DIR/p10k.zsh"
else
    warn "no p10k.zsh found — run 'p10k configure' after setup"
fi

# ── vscode configs ────────────────────────────────────────────────────
step "vscode configs"
mkdir -p "$VSCODE_USER_DIR"
for f in settings.json keybindings.json; do
    target="$VSCODE_USER_DIR/$f"
    if [[ -f "$target" ]] && [[ ! -L "$target" ]]; then
        mv "$target" "$target.backup.$(date +%s)"
        warn "backed up existing $target"
    fi
    ln -sf "$VSCODE_DIR/$f" "$target"
    info "$target -> $VSCODE_DIR/$f"
done

# ── vim setup ─────────────────────────────────────────────────────────
step "vim"
if [[ -f "$HOME/.vimrc" ]] && [[ ! -L "$HOME/.vimrc" ]]; then
    mv "$HOME/.vimrc" "$HOME/.vimrc.backup.$(date +%s)"
    warn "backed up existing ~/.vimrc"
fi
ln -sf "$VIM_DIR/vimrc" "$HOME/.vimrc"
info "~/.vimrc -> $VIM_DIR/vimrc"

if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    info "vim-plug installed"
else
    info "vim-plug already installed"
fi

info "installing vim plugins..."
vim -es -u "$HOME/.vimrc" -i NONE -c "PlugInstall" -c "qa" 2>/dev/null || true
info "vim plugins installed"

# ── vivid color cache ─────────────────────────────────────────────────
step "vivid cache"
if command -v vivid &>/dev/null; then
    mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}"
    vivid generate catppuccin-mocha > "${XDG_CACHE_HOME:-$HOME/.cache}/vivid-ls-colors"
    info "vivid ls-colors cached"
else
    warn "vivid not found, skipping color cache"
fi

# ── node via nvm ──────────────────────────────────────────────────────
step "node (via nvm)"
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"

if command -v nvm &>/dev/null; then
    if ! nvm ls default &>/dev/null 2>&1; then
        nvm install --lts
        nvm alias default node
        info "node LTS installed as default"
    else
        info "nvm default already set: $(nvm current)"
    fi
else
    warn "nvm not available, skipping node install"
fi

# ── go verify ─────────────────────────────────────────────────────────
step "go"
if command -v go &>/dev/null; then
    info "go: $(go version)"
else
    warn "go not on PATH after install — retrying apt"
    sudo apt-get install -y golang-go && info "go installed: $(go version)" || warn "go install failed"
fi

# ── claude code verify ────────────────────────────────────────────────
step "claude code"
if command -v claude &>/dev/null; then
    info "claude: $(claude --version 2>/dev/null || echo installed)"
else
    if command -v npm &>/dev/null; then
        npm install -g @anthropic-ai/claude-code && info "claude installed: $(claude --version 2>/dev/null || echo ok)" || warn "claude install failed"
    else
        warn "npm not available — skipping claude install (nvm install failed earlier?)"
    fi
fi

# ── default shell ─────────────────────────────────────────────────────
step "default shell"
if [[ "$SHELL" != *"zsh"* ]]; then
    if command -v zsh &>/dev/null; then
        warn "run: chsh -s $(command -v zsh)  # to make zsh default"
    fi
else
    info "zsh already default shell"
fi

# ── done ──────────────────────────────────────────────────────────────
step "setup complete"
echo ""
echo "next steps:"
echo "  1. restart your terminal or run: exec zsh"
echo "  2. run 'p10k configure' to set up the prompt (if needed)"
echo "  3. install coc.nvim language servers (open vim, then run)"
echo "     :CocInstall coc-json coc-pyright coc-go coc-tsserver coc-rust-analyzer"
echo "  4. if zsh isn't default yet: chsh -s \$(command -v zsh)"
echo ""
