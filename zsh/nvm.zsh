# nvm — lazy loaded to avoid ~500ms startup penalty
export NVM_DIR="$HOME/.nvm"

# put default node on PATH immediately (no nvm overhead)
if [[ -d "$NVM_DIR/versions/node" ]]; then
  local default_node
  default_node=$(ls "$NVM_DIR/versions/node" 2>/dev/null | sort -V | tail -1)
  if [[ -n "$default_node" ]]; then
    export PATH="$NVM_DIR/versions/node/$default_node/bin:$PATH"
  fi
fi

# lazy-load full nvm only when explicitly called
nvm() {
  unset -f nvm
  # prefer native install (~/.nvm) — used on linux and by nvm curl installer
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    . "$NVM_DIR/nvm.sh"
    . "$NVM_DIR/bash_completion" 2>/dev/null
  elif [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
    . "/opt/homebrew/opt/nvm/nvm.sh"
    . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" 2>/dev/null
  fi
  nvm "$@"
}
