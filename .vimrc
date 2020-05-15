"Vim Configuration
"Lauri Mäkinen
""http://laurimakinen.net

set nocompatible
set nomodeline

" ###################
" Generic vim options
" ###################
syntax on
set synmaxcol=2048
set background=dark
let mapleader=","
let maplocalleader=","

set noswapfile
set nobackup

filetype plugin on
filetype indent on

set path+=**

set wildmenu

set showmatch
set showmode
set number
set novisualbell
set autoread
set mousehide
set guicursor=a:blinkon0

set ignorecase
set smartcase
set hlsearch
set incsearch
set autoindent

set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab

" #############################
" Platform/gui specific options
" #############################

if has("gui_running")
  set guioptions=ac
  set guifont=Consolas:h10:cANSI
  winpos 1 1
  set lines=999
  set columns=999
  "color solarized
else
  "color solarized
endif

" ################
" General keybinds
" ################

"Common typos
cmap W w
cmap WQ wq
cmap wQ wq
cmap Q q
"Hide hilights with return
:nnoremap <CR> :nohlsearch<CR>/<BS>

"disable arrows
inoremap  <Up>     <NOP>
inoremap  <Down>   <NOP>
inoremap  <Left>   <NOP>
inoremap  <Right>  <NOP>
noremap   <Up>     <NOP>
noremap   <Down>   <NOP>
noremap   <Left>   <NOP>
noremap   <Right>  <NOP>

nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk


nnoremap <leader>p p
nnoremap <leader>P P
nnoremap p p'[v']=
nnoremap P P'[v']=

nnoremap <space> za
vnoremap <space> zf

" ###################
" Rest of the options
" ###################

"tags
set tags=./tags;/;tags-static

"statusline
set stl=%f\ %m\ %r\ Line:\ %l/%L[%p%%]\ Col:\ %c\ Buf:\ #%n
set laststatus=2

"ignores
set wildignore+=*.class,*.exe,*.log,*.tlog,*pdb,*.ilk,*obj,*/_site/*,*/.git/*,*/_gist_cache/*,*/node_modules/*,*.o,*.a,*.tmp,./html/,._*,*.pp,target

" ####################
" Load local additions
" ####################
"
if filereadable(glob("~/.vimrc_local"))
  source ~/.vimrc_local
end

