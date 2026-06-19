# general
alias python="python3"
alias py="python"
alias agrep="alias | grep"
alias back="cd -"
alias show="declare -f"
alias m="make"

# os-specific — mac has pbcopy/pbpaste/mvim/open natively
if [[ "$OSTYPE" == darwin* ]]; then
  alias chrome="open -a \"Google Chrome\""
  alias vim="nvim"
else
  # linux shims: pbcopy/pbpaste so `path` and friends keep working
  if [[ -n "$WSL_DISTRO_NAME" ]] || grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
    # wsl: bridge to the windows clipboard — xclip would hit the (headless) linux side
    if command -v win32yank.exe &>/dev/null; then
      alias pbcopy="win32yank.exe -i --crlf"
      alias pbpaste="win32yank.exe -o --lf"
    else
      alias pbcopy="clip.exe"
      alias pbpaste="powershell.exe -NoProfile -Command Get-Clipboard"
    fi
  elif command -v xclip &>/dev/null; then
    alias pbcopy="xclip -selection clipboard"
    alias pbpaste="xclip -selection clipboard -o"
  elif command -v wl-copy &>/dev/null; then
    alias pbcopy="wl-copy"
    alias pbpaste="wl-paste"
  fi
  command -v xdg-open &>/dev/null && alias chrome="xdg-open"
fi
alias path="pwd | pbcopy"
alias maket="make -qp | awk -F':' '/^[a-zA-Z0-9][^\$#\/\t=]*:([^=]|$)/ {split(\$1,A,/ /);for(i in A)print A[i]}' | sort -u"
alias npm="pnpm"
alias rm='/usr/local/opt/trash-cli/bin/trash-put'  # trash-cli swallows -rf for rm-compat; full path avoids brew link/shadow issues with /usr/bin/trash
alias l='lsd -al'
alias ls='lsd'
alias lt='ls --tree --depth 2 --max-shown -1 -d --tree-columns'
alias lr='ls -R --depth 3'

# git
alias gcaf="gca --fixup"
alias gitn="git --no-pager"
alias gpf="gp -f"
alias glum="git pull upstream main"
alias gcm="git checkout main"

# hub
alias git="hub"
alias pr="g pull-request --no-edit"
alias ci="g ci-status"
alias show-pr="g pr show"

# navigation
alias personal="vim ~/code/personal_env"
alias docs='cd ~/code/personal/docs'
alias ccwd='cd ~/code'
alias fr='cd ~/code/friends'
alias tools='cd ~/code/personal/tooling'
alias dme='cd ~/code/personal'

# shell — exec zsh replaces the process (fast), source re-inits p10k (slow)
alias zsource="exec zsh"
alias resource="exec zsh"

# claude
alias fgc='fg %claude'
alias cc='claude'
alias ccs='claude --dangerously-skip-permissions'
