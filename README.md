# .dotfiles

personal dev environment — zsh, vim, vscode. mac + ubuntu/debian.

## install

```sh
git clone git@github.com:Shonas301/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` detects the OS and dispatches to `install-macos.sh` or
`install-linux.sh`. both are idempotent — safe to re-run.

## layout

```
~/.dotfiles/
├── install.sh            # dispatcher (OS detection)
├── install-macos.sh      # brew + nvm + oh-my-zsh + p10k + vim-plug + claude
├── install-linux.sh      # apt + curl installers (size-conscious, no linuxbrew)
├── zsh/
│   ├── zshrc             # symlinked to ~/.zshrc
│   ├── aliases.zsh
│   ├── variables.zsh
│   ├── nvm.zsh           # lazy-loaded
│   ├── pyenv.zsh         # lazy-loaded
│   ├── usr_functions.zsh
│   └── p10k.zsh
├── vim/
│   └── vimrc             # symlinked to ~/.vimrc (coc.nvim, fzf, ALE, polyglot)
└── vscode/              # symlinked into VSCode user dir (OS-specific)
    ├── settings.json     # mac: ~/Library/Application Support/Code/User/
    └── keybindings.json  # linux: ~/.config/Code/User/
```

## what gets installed

**mac (brew):** macvim, lsd, vivid, pyenv, nvm, hub, trash, fzf, ripgrep,
cowsay, pnpm, go

**linux (apt + curl):** zsh, git, curl, build-essential, vim-gtk3, lsd, hub,
trash-cli, fzf, ripgrep, cowsay, xclip, golang-go, pyenv build deps; pyenv,
nvm, pnpm via curl installers; vivid from github release .deb

**both:** oh-my-zsh, powerlevel10k, vim-plug + vim plugins, node LTS (via
nvm), claude code (via npm)

## after install

- `exec zsh` (or restart terminal)
- `p10k configure` to set up the prompt (skip if the bundled `p10k.zsh` is
  what you want)
- in vim: `:CocInstall coc-json coc-pyright coc-go coc-tsserver
  coc-rust-analyzer`
- linux only: `chsh -s $(command -v zsh)` if zsh isn't default
