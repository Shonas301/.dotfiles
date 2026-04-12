#!/usr/bin/env bash
# bootstrap a new mac with ~/.dotfiles
# idempotent — safe to re-run
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_DIR="$REPO_DIR/zsh"
VIM_DIR="$REPO_DIR/vim"
CLAUDE_DIR="$REPO_DIR/claude"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[ok]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!!]${NC} $1"; }
fail()  { echo -e "${RED}[err]${NC} $1"; exit 1; }
step()  { echo -e "\n${GREEN}==> $1${NC}"; }

# ── homebrew ──────────────────────────────────────────────────────────
step "homebrew"
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # add brew to current session PATH
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    info "homebrew installed"
else
    info "homebrew already installed"
fi

# ── brew packages ─────────────────────────────────────────────────────
step "brew packages"
PACKAGES=(
    macvim
    lsd
    vivid
    pyenv
    nvm
    hub
    trash
    fzf
    ripgrep
    cowsay
    pnpm
    go
)

for pkg in "${PACKAGES[@]}"; do
    if brew list "$pkg" &>/dev/null 2>&1; then
        info "$pkg already installed"
    else
        brew install "$pkg" && info "$pkg installed" || warn "$pkg failed to install, skipping"
    fi
done

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

# ── claude code configs ───────────────────────────────────────────────
step "claude configs"
mkdir -p "$HOME/.claude"
for f in settings.json keybindings.json; do
    if [[ -f "$HOME/.claude/$f" ]] && [[ ! -L "$HOME/.claude/$f" ]]; then
        mv "$HOME/.claude/$f" "$HOME/.claude/$f.backup.$(date +%s)"
        warn "backed up existing ~/.claude/$f"
    fi
    ln -sf "$CLAUDE_DIR/$f" "$HOME/.claude/$f"
    info "~/.claude/$f -> $CLAUDE_DIR/$f"
done

# ── vim setup ─────────────────────────────────────────────────────────
step "vim"

# symlink vimrc
if [[ -f "$HOME/.vimrc" ]] && [[ ! -L "$HOME/.vimrc" ]]; then
    mv "$HOME/.vimrc" "$HOME/.vimrc.backup.$(date +%s)"
    warn "backed up existing ~/.vimrc"
fi
ln -sf "$VIM_DIR/vimrc" "$HOME/.vimrc"
info "~/.vimrc -> $VIM_DIR/vimrc"

# install vim-plug
if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    info "vim-plug installed"
else
    info "vim-plug already installed"
fi

# install vim plugins (headless)
info "installing vim plugins..."
if command -v mvim &>/dev/null; then
    mvim -v -es -u "$HOME/.vimrc" -i NONE -c "PlugInstall" -c "qa" 2>/dev/null || true
else
    vim -es -u "$HOME/.vimrc" -i NONE -c "PlugInstall" -c "qa" 2>/dev/null || true
fi
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

# ── nvm + node ────────────────────────────────────────────────────────
step "nvm + node"
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

# source nvm from homebrew
if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
    . "/opt/homebrew/opt/nvm/nvm.sh"
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
    . "$NVM_DIR/nvm.sh"
fi

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
    warn "go not on PATH after install — trying brew install go"
    brew install go && info "go installed: $(go version)" || warn "go install failed"
fi

# ── claude code verify ────────────────────────────────────────────────
step "claude code"
if command -v claude &>/dev/null; then
    info "claude: $(claude --version 2>/dev/null || echo installed)"
else
    if command -v npm &>/dev/null; then
        npm install -g @anthropic-ai/claude-code && info "claude installed: $(claude --version 2>/dev/null || echo ok)" || warn "claude install failed"
    else
        warn "npm not available — skipping claude install (install node via nvm first)"
    fi
fi

# ── done ──────────────────────────────────────────────────────────────
step "setup complete"
echo ""
echo "next steps:"
echo "  1. restart your terminal or run: exec zsh"
echo "  2. run 'p10k configure' to set up the prompt (if needed)"
echo "  3. install coc.nvim language servers in vim:"
echo "     :CocInstall coc-json coc-pyright coc-go coc-tsserver coc-rust-analyzer"
echo ""
