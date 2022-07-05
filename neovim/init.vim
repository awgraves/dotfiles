" place this file in ~/.config/nvim
" install vim-plug for neovim: https://github.com/junegunn/vim-plug

"*******************
"*** General Vim ***
"*******************

"files
set hidden "hide rather than close buffers when navigating away
set autoread "update buffer when a file is changed from the outside

"numbers
set number
set relativenumber

"indents
set smartindent
set tabstop=4
set shiftwidth=4
set softtabstop=4

"line breaks
set wrap
set linebreak
set breakindent

syntax on "even with treesitter, seems to add a little extra

"search
set incsearch
set nohlsearch

"sound
set noerrorbells

"layout
set signcolumn=yes
set scrolloff=8 

"gui
set guicursor=
set termguicolors

" Switch between splits
nmap <silent> <C-k> :wincmd k<CR>
nmap <silent> <C-j> :wincmd j<CR>
nmap <silent> <C-h> :wincmd h<CR>
nmap <silent> <C-l> :wincmd l<CR>

" jk = esc in insert & visual modes
inoremap jk <esc>
vnoremap jk <esc> 

" W / Q = write / quit in normal and visual modes
nnoremap W :w<CR>
nnoremap Q :q<CR>
vnoremap W :w<CR>
vnoremap Q :q<CR>

"***************
"*** Plugins ***
"***************

call plug#begin()
" jetbrains IDE inspired colorscheme
Plug 'doums/darcula'

" sidebar file browser (plus icons)
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'

" fuzzy finder for files, file content, buffers
Plug 'ibhagwan/fzf-lua', {'branch': 'main'}

" neovim native syntax highlighting (faster than vim regex)
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" neovim native lang server for things like 'go to definiton', etc
" note: use LspInstall command to download the lang-specific servers when
" setting up!
" visit nvim-lsp-installer on github for more info
Plug 'williamboman/nvim-lsp-installer'
Plug 'neovim/nvim-lspconfig'

" improved bottom status bar
Plug 'nvim-lualine/lualine.nvim'

" fancy git UI menu
" tip: (darcula vim theme) set lazygit config yaml lightTheme=true
Plug 'kdheepak/lazygit.nvim'
call plug#end()

colorscheme darcula 

" NERDTree setting defaults to work around http://github.com/scrooloose/nerdtree/issues/489
let NERDTreeShowHidden = 1
let g:NERDTreeDirArrows = 1
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let g:NERDTreeGlyphReadOnly = "RO"
" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

"******************
"*** Lua Setups ***
"******************
lua << EOF
-- lualine for bottom status bar
require('lualine').setup{
	options = {theme = 'auto'}
}

-- treesitter for syntax highlighting 
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = {"c", "cpp", "css", "dockerfile", "go", "gomod", 
  "graphql", "html", "javascript", "json", "lua", "make", "markdown", 
  "python", "ruby", "rust", "svelte", "typescript", "toml", "tsx", "vim", "yaml"},
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = false --neovim's autoindent does better i think
  }
}

-- language server installer/manager for other IDE like features
require("nvim-lsp-installer").setup {
	automatic_installation = true, -- automatically detect which servers to install (based on which servers are set up via lspconfig)
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    }
}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end

-- Individual language servers
require'lspconfig'.gopls.setup{
	on_attach = on_attach
}

require'lspconfig'.golangci_lint_ls.setup{
	on_attach = on_attach
}

require'lspconfig'.eslint.setup{
	on_attach = on_attach
}

require'lspconfig'.tsserver.setup{
	on_attach = on_attach
}

require'lspconfig'.jsonls.setup{
	on_attach = on_attach
}

require'lspconfig'.solargraph.setup{
	on_attach = on_attach
}

EOF


"****************
"*** Commands ***
"****************

let mapleader=" "

" standard vim
nnoremap <leader>sv :source $MYVIMRC<CR>| "source vimrc

" FZF (fuzzy finder for files, file content, buffers)
nnoremap <leader>ff <cmd>lua require('fzf-lua').git_files()<cr> 
nnoremap <leader>fa <cmd>lua require('fzf-lua').files()<cr>
nnoremap <leader>fg <cmd>lua require('fzf-lua').live_grep_native()<cr>
nnoremap <leader>fb <cmd>lua require('fzf-lua').buffers()<cr>

" nerdtree
nnoremap <C-n> :NERDTreeToggle<CR>|" Open tree with ctrl + n
nnoremap ` :NERDTreeFind<CR>|" Open tree at current file loc with <backtick>

" lazygit
nnoremap <leader>lg :LazyGit<CR>|" Open lazygit popover window
