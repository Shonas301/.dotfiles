# dotfiles

## what this is

personal environment config — zsh (powerlevel10k, nvm, pyenv), vim (vim-plug, coc.nvim, ALE, fzf.vim, polyglot), vscode settings/keybindings. dual-purpose: (1) fresh-machine bootstrap via `./install.sh` on a brand-new mac or ubuntu box, (2) sync between personal and work laptops — edits to files in this repo propagate live because everything in `$HOME` is a symlink back into the repo.

guiding principle: "this machine just spawned, make it comfortable" — minimum viable comfort, not kitchen-sink.

## architecture

bootstrap flow is a two-stage dispatch:

```
./install.sh
  └─ dispatches on $OSTYPE
     ├─ darwin*  → install-macos.sh  (brew + native nvm/pyenv shims)
     └─ linux*   → install-linux.sh  (apt + curl installers for pyenv/nvm/vivid/pnpm)
         │
         └─ both then:
            1. install package manager + packages
            2. install oh-my-zsh + powerlevel10k
            3. backup + symlink zsh/zshrc → ~/.zshrc
            4. backup + symlink vscode/{settings,keybindings}.json → vscode user dir
            5. backup + symlink vim/vimrc → ~/.vimrc; headless :PlugInstall
            6. cache vivid ls-colors, install node LTS, verify go, install claude cli
```

runtime flow (shell startup): `~/.zshrc` is a symlink to `zsh/zshrc`. zshrc resolves its own dir via `DIR="${${(%):-%x}:A:h}"` (follows the symlink to `zsh/`), then sources siblings in order: `variables.zsh`, `aliases.zsh`, `usr_functions.zsh`, `nvm.zsh`, `pyenv.zsh`. p10k instant-prompt must be first; `p10k.zsh` sourced last so user config overrides defaults.

## active decisions

- **apt + curl over linuxbrew on linux** — linuxbrew bootstrap is ~300 MB before any package, ~1–1.5 GB for the full list; apt equivalents total ~150–300 MB. footprint matters, so we maintain two install paths instead of sharing linuxbrew.
- **modular zsh** — each concern (aliases, variables, functions, nvm, pyenv) lives in its own `zsh/*.zsh` file so it can be reasoned about independently. zshrc is the composition layer.
- **symlinks, never copies** — install scripts `ln -sf` the repo files into `$HOME`. editing the repo edits the live config; no reinstall round-trip for sync-between-laptops flow.
- **idempotent bootstrap** — every install step guards with `command -v` / `[[ -d ]]` / `brew list` / `nvm ls default`. safe to re-run on an already-configured sync target.
- **OS branch at call site, not dispatch layer** — `aliases.zsh`, `variables.zsh`, `zshrc` all check `$OSTYPE` where the difference is narrow (e.g., mvim vs vim, pbcopy vs xclip) rather than maintaining separate zsh modules per OS.

## patterns

- **lazy-load nvm and pyenv** — `nvm.zsh` prepends the newest installed node to PATH directly and defines a shim `nvm()` that self-removes and sources the real nvm on first call. same pattern in `pyenv.zsh`. this is the single biggest shell-startup win (~600ms saved).
- **single compinit with 24h cache** — `zshrc` guards `compinit` on a mtime check against `.zcompdump`. avoids the repeated-cost compinit trap.
- **typeset -U PATH** — deduplicates PATH across nested shells; without this PATH accumulated to 800+ entries in the predecessor repo.
- **`exec zsh`, not `source ~/.zshrc`** — `zsource` / `resource` aliases use `exec zsh` because re-sourcing inside an existing shell triggers p10k/gitstatus reinit (~10s). `exec zsh` replaces the process and hits the fresh-shell fast path (~0.37s).
- **vivid ls-colors cached** — `$XDG_CACHE_HOME/vivid-ls-colors` regenerated only when the `vivid` binary is newer than the cache. install scripts also seed the cache.
- **backup-on-symlink** — if a symlink target exists as a real file, rename to `<target>.backup.<unix-seconds>` before `ln -sf`. `.gitignore` excludes `*.backup.*`.
- **headless vim plugin install** — `vim -es -u ~/.vimrc -c PlugInstall -c qa` (or `mvim -v -es ...` on mac) during bootstrap. coc language extensions (`coc-pyright`, `coc-go`, etc.) still require manual `:CocInstall` on first open — documented in install script footer.

## research

[none yet — research findings are promoted from .thinking/research/]

---

*context established: 2026-04-12*
*last updated: 2026-04-12*
