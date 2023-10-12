" place this file in ~/.config/nvim
" install vim-plug for neovim: https://github.com/junegunn/vim-plug

"*******************
"*** General Vim ***
"*******************

"files
set hidden "hide rather than close buffers when navigating away
set autoread "update buffer when a file is changed from the outside

"yank to system clipboard
set clipboard+=unnamedplus

"numbers
set number

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

" set new splits below by default
set splitbelow

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
"Plug 'doums/darcula'
Plug 'sainnhe/sonokai'

" sidebar file browser (plus icons)
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'

" fuzzy finder for files, file content, buffers
Plug 'ibhagwan/fzf-lua', {'branch': 'main'}

" go specific tools
"Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" intellisense
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" neovim native syntax highlighting (faster than vim regex or CoC)
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" neovim native lang server for things like 'go to definiton', etc
" note: use LspInstall command to download the lang-specific servers when
" setting up!
" visit nvim-lsp-installer on github for more info
"Plug 'williamboman/nvim-lsp-installer'
"Plug 'neovim/nvim-lspconfig'

" improved bottom status bar
Plug 'nvim-lualine/lualine.nvim'

" better git commands
Plug 'tpope/vim-fugitive'

" fancy git UI menu
" tip: (darcula vim theme) set lazygit config yaml lightTheme=true
Plug 'kdheepak/lazygit.nvim'
call plug#end()

let g:sonokai_style = 'andromeda'
let g:sonokai_better_performance = 1
colorscheme sonokai 

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

--[[ language server installer/manager for other IDE like features
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
local nvim_lsp = require('lspconfig')

local servers = {'gopls', 'golangci_lint_ls', 'eslint', 'tsserver', 'jsonls', 'solargraph'}
for _, lsp in pairs(servers) do
	nvim_lsp[lsp].setup {
      on_attach = on_attach,
    }
end
--]]
EOF

"************
"** Vim-Go **
"************

" disable all linters as that is taken care of by coc.nvim
"let g:go_diagnostics_enabled = 0
"let g:go_metalinter_enabled = []
"
"" don't jump to errors after metalinter is invoked
"let g:go_jump_to_error = 0
"
"" run go imports on file save
"let g:go_fmt_command = "goimports"
"
"" automatically highlight variable your cursor is on
"let g:go_auto_sameids = 0

"**********************
"** CoC Intellisense **
"**********************

let g:coc_global_extensions = ['coc-pairs', 'coc-git', 'coc-go', 'coc-json', 'coc-tsserver', 'coc-eslint', 'coc-prettier', 'coc-solargraph','coc-clangd', 'coc-svelte', 'coc-docker']

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
  " Recently vim can merge signcolumn and number column into one
set signcolumn=number

"****************
"*** Commands ***
"****************

let mapleader=" "

" -- standard vim
nnoremap <leader>sv :source $MYVIMRC<CR>| "source vimrc

" -- FZF (fuzzy finder for files, file content, buffers)
nnoremap <leader>ff <cmd>lua require('fzf-lua').git_files()<cr> 
nnoremap <leader>fa <cmd>lua require('fzf-lua').files()<cr>
nnoremap <leader>fg <cmd>lua require('fzf-lua').live_grep_native()<cr>
nnoremap <leader>fb <cmd>lua require('fzf-lua').buffers()<cr>

" -- nerdtree
nnoremap <C-n> :NERDTreeToggle<CR>|" Open tree with ctrl + n
nnoremap ` :NERDTreeFind<CR>|" Open tree at current file loc with <backtick>

" -- Coc
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
"set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
" nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" lazygit
nnoremap <leader>lg :LazyGit<CR>|" Open lazygit popover window
