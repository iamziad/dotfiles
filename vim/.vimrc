call plug#begin()
  Plug 'kien/ctrlp.vim'
  Plug 'tpope/vim-commentary'
  Plug 'jiangmiao/auto-pairs'
  Plug 'morhetz/gruvbox'
  Plug 'mhinz/vim-signify', { 'tag': 'legacy' }
  Plug 'itchyny/lightline.vim'
call plug#end()


" ====================================================================
" Options
" ====================================================================

" set visualbell
set termguicolors
colorscheme habamax
colorscheme gruvbox

" lighline
set laststatus=2
set showmode!
let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ }

" Misc
"set cursorline
syntax on
set number
set relativenumber
set mouse=a
set clipboard=unnamedplus
set guicursor=n-v-c:block,i:block-blinkon0
set equalalways
set colorcolumn=80
set timeoutlen=300
set ttimeoutlen=10
set nowrap
set scrolloff=8
set signcolumn=yes
set updatetime=300
set splitbelow
set splitright
set virtualedit=block
set backspace=start,eol,indent

" Indenting
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smartindent

" Searching
set nohlsearch
set incsearch
set ignorecase
set smartcase

" Netrw settings
let g:netrw_banner = 0
let g:netrw_browse_split = 4
let g:netrw_altv = 0
let g:netrw_liststyle = 3

" Completion
set completeopt=menu,menuone,noselect
set pumheight=10

