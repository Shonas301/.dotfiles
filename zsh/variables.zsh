# paths
export PATH="${HOME}/.local/bin:${PATH}"

# hub
export HUB_PROTOCOL=ssh

# go
export GOPATH="$HOME/go"

# java — mac has a helper, linux does not
if [[ "$OSTYPE" == darwin* ]] && [[ -x /usr/libexec/java_home ]]; then
  export JAVA_HOME="$(/usr/libexec/java_home 2>/dev/null)"
fi

# orbstack
if [[ -d "$HOME/.orbstack/bin" ]]; then
  export PATH="$PATH:$HOME/.orbstack/bin"
  fpath+=/Applications/OrbStack.app/Contents/Resources/completions/zsh
fi

# ls colors via vivid — cached to avoid subprocess on every shell open
if command -v vivid &>/dev/null; then
  local vivid_cache="${XDG_CACHE_HOME:-$HOME/.cache}/vivid-ls-colors"
  if [[ ! -f "$vivid_cache" ]] || [[ "$(which vivid)" -nt "$vivid_cache" ]]; then
    mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}"
    vivid generate catppuccin-mocha > "$vivid_cache"
  fi
  export LS_COLORS="$(cat "$vivid_cache")"
fi
