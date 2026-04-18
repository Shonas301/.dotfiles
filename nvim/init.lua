-- neovim config — faithful port of vim/vimrc using lazy.nvim
-- keep in sync with vim/vimrc where possible

-- ############################ bootstrap lazy.nvim ############################
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- set leader before lazy loads anything that reads it
vim.g.mapleader = ","

-- dedicated python for neovim remote plugins (molten, etc)
-- venv created by install scripts with pynvim + jupyter_client
vim.g.python3_host_prog = vim.fn.expand("~/.local/share/nvim/python-venv/bin/python")

-- ############################ plugins ############################
require("lazy").setup({
  -- core editing
  "tpope/vim-surround",
  "tpope/vim-endwise",
  "tpope/vim-ragtag",
  "tomtom/tcomment_vim",
  "Raimondi/delimitMate",
  "mg979/vim-visual-multi",

  -- navigation + search
  { "junegunn/fzf", build = ":call fzf#install()" },
  "junegunn/fzf.vim",
  "christoomey/vim-tmux-navigator",
  "roman/golden-ratio",
  -- flash: labeled jumps, treesitter-aware. overrides s/S (cl still substitutes)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,             desc = "flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end,       desc = "flash treesitter" },
      { "r", mode = "o",               function() require("flash").remote() end,           desc = "remote flash" },
      { "R", mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "treesitter search" },
    },
  },

  -- display
  "jeffkreeftmeijer/vim-numbertoggle",
  "nathanaelkane/vim-indent-guides",
  { "nanotech/jellybeans.vim", lazy = false, priority = 1000 },

  -- linting + completion
  "dense-analysis/ale",
  { "neoclide/coc.nvim", branch = "release" },

  -- language support
  -- treesitter replaces vim-polyglot: real parse trees instead of regex syntax
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "lua", "python", "go", "javascript", "typescript", "tsx",
        "ruby", "html", "css", "json", "yaml", "toml",
        "markdown", "markdown_inline", "bash", "vim", "vimdoc", "query",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
  { "fatih/vim-go", build = ":GoUpdateBinaries" },

  -- utilities
  "godlygeek/tabular",
  "dhruvasagar/vim-table-mode",
  "aserebryakov/vim-todo-lists",

  -- jupyter / notebooks
  -- jupytext: transparently edit .ipynb as .py/.md
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },
  -- molten: run code in jupyter kernels with inline output
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_wrap_output = true
      vim.g.molten_image_provider = "none"
    end,
  },
})

-- ############################ options ############################
vim.opt.number = true
vim.cmd("syntax enable")

vim.opt.autoindent = true
vim.opt.autoread = true
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.clipboard = "unnamed"
vim.opt.directory:remove(".")                   -- no swapfiles in cwd
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.laststatus = 2
vim.opt.ruler = true
vim.opt.scrolloff = 3
vim.opt.shiftwidth = 4
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 8
vim.opt.wildmode = "longest:full"
vim.opt.wildmenu = true
vim.opt.colorcolumn = "80"
vim.opt.mouse = "a"

-- neovim cursor shape — replaces vim's t_SI/t_EI dance
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- ############################ colorscheme ############################
vim.cmd("colorscheme jellybeans")

-- ############################ plugin settings ############################
vim.g.VimTodoListsMoveItems = 0
vim.g.go_version_warning = 0
vim.g.ale_fix_on_save = 1
vim.g.ale_sign_error = "E"
vim.g.ale_sign_warning = "W"

-- coc.nvim completion behavior
vim.opt.completeopt = { "menuone", "noinsert", "noselect" }
vim.opt.shortmess:append("c")

-- ############################ keybindings ############################
-- insert-mode escapes
vim.keymap.set("i", ";;", "<ESC>")
vim.keymap.set("i", "jj", "<ESC>")

-- split navigation
vim.keymap.set("n", "<C-J>", "<C-W><C-J>")
vim.keymap.set("n", "<C-K>", "<C-W><C-K>")
vim.keymap.set("n", "<C-L>", "<C-W><C-L>")
vim.keymap.set("n", "<C-H>", "<C-W><C-H>")

-- :W / :Q / :Wq typo corrections
vim.cmd([[
  cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
  cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
  cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
]])

-- strip trailing whitespace
vim.keymap.set("n", "<leader>W", [[:%s/\s\+$//<cr>:let @/=''<CR>]])

-- fzf
vim.keymap.set("n", "<leader>f", ":Files<CR>")
vim.keymap.set("n", "<leader>b", ":Buffers<CR>")
vim.keymap.set("n", "<leader>r", ":Rg<CR>")
vim.keymap.set("n", "<leader>l", ":Lines<CR>")

-- %% in cmdline expands to current buffer dir
vim.keymap.set("c", "%%", "<C-R>=expand('%:h').'/'<cr>")

-- ############################ filetype autocmds ############################
local augroup = vim.api.nvim_create_augroup("dotfiles", { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup, pattern = "*.json.jbuilder",
  callback = function() vim.bo.filetype = "ruby" end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup, pattern = "*.ejs",
  callback = function() vim.bo.filetype = "html" end,
})

-- prose: wrap at 80 and spell-check
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup, pattern = { "*.txt", "*.md" },
  callback = function()
    vim.opt_local.textwidth = 80
    vim.opt_local.spell = true
  end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup, pattern = "*.tex",
  callback = function() vim.opt_local.textwidth = 80 end,
})

-- folding for python/todo
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup, pattern = { "*.py", "*.todo" },
  callback = function() vim.opt_local.foldmethod = "indent" end,
})

-- yaml — 2 space indent + indent folds
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup, pattern = "*.yml",
  callback = function()
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.foldmethod = "indent"
  end,
})

-- git commits — spell + 72 cols
vim.api.nvim_create_autocmd("FileType", {
  group = augroup, pattern = "gitcommit",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 72
  end,
})

-- auto-reload on focus, auto-save on leave
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = augroup, command = "silent! !",
})
vim.api.nvim_create_autocmd({ "FocusLost", "WinLeave" }, {
  group = augroup, command = "silent! w",
})

-- ############################ coc.nvim bindings ############################
-- tab / s-tab navigate completion, cr confirms
vim.cmd([[
  inoremap <silent><expr> <TAB>
        \ coc#pum#visible() ? coc#pum#next(1) :
        \ CheckBackspace() ? "\<Tab>" :
        \ coc#refresh()
  inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

  inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                                \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

  function! CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  function! ShowDocumentation()
    if CocAction('hasProvider', 'hover')
      call CocActionAsync('doHover')
    else
      call feedkeys('K', 'in')
    endif
  endfunction
]])

vim.keymap.set("n", "gd", "<Plug>(coc-definition)", { silent = true })
vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", { silent = true })
vim.keymap.set("n", "gr", "<Plug>(coc-references)", { silent = true })
vim.keymap.set("n", "K", ":call ShowDocumentation()<CR>", { silent = true })
vim.keymap.set("n", "<leader>rn", "<Plug>(coc-rename)")

-- ############################ molten (jupyter) ############################
-- all under <leader>m* to avoid clashing with fzf <leader>r etc
vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>",             { silent = true, desc = "molten: init kernel" })
vim.keymap.set("n", "<leader>me", ":MoltenEvaluateOperator<CR>", { silent = true, desc = "molten: eval operator" })
vim.keymap.set("n", "<leader>ml", ":MoltenEvaluateLine<CR>",     { silent = true, desc = "molten: eval line" })
vim.keymap.set("n", "<leader>mr", ":MoltenReevaluateCell<CR>",   { silent = true, desc = "molten: re-eval cell" })
vim.keymap.set("v", "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>gv", { silent = true, desc = "molten: eval visual" })
vim.keymap.set("n", "<leader>mo", ":noautocmd MoltenEnterOutput<CR>", { silent = true, desc = "molten: enter output" })
vim.keymap.set("n", "<leader>mh", ":MoltenHideOutput<CR>",       { silent = true, desc = "molten: hide output" })
vim.keymap.set("n", "<leader>md", ":MoltenDelete<CR>",           { silent = true, desc = "molten: delete cell" })

-- ############################ snakecase helper ############################
vim.cmd([[
  function! s:snakeize(range) abort
    if a:range == 0
      s#\C\(\<\u[a-z0-9]\+\|[a-z0-9]\+\)\(\u\)#\l\1_\l\2#g
    else
      s#\%V\C\(\<\u[a-z0-9]\+\|[a-z0-9]\+\)\(\u\)\%V#\l\1_\l\2#g
    endif
  endfunction
  command! -range Snake silent! call <SID>snakeize(<range>)
]])
