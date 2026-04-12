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
  alias vim="mvim -v"
else
  # linux shims: pbcopy/pbpaste via xclip so `path` and friends keep working
  if command -v xclip &>/dev/null; then
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
alias rm='trash'
alias l='lsd -al'
alias ls='lsd'
alias lt='ls --tree --depth 2 --max-shown 6 -d'
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
