"Vim Configuration
"Lauri Mäkinen
""http://laurimakinen.net

set nocompatible
set nomodeline

call pathogen#infect()

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
  "set cursorline
  "set cursorcolumn
  color badwolf
  "color solarized
else
  "color darkblue
  "color relaxedgreen
  "color koehler
  "color dante
  color delek
  "color rootwater
  "color smyck
  "color solarized
endif

if has("win32") || has("win64")
  map <F11> <Esc>:call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>
end

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

nmap <C-X> :FSHere<CR>
nmap <F7> :NERDTreeToggle<cr>
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode
map <C-t> :split<CR>:exec("tag ".expand("<cword>"))<CR>
map <C-y> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>

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
set ofu=syntaxcomplete#Complete

"statusline
set stl=%f\ %m\ %r\ Line:\ %l/%L[%p%%]\ Col:\ %c\ Buf:\ #%n
set laststatus=2

"ignores
set wildignore+=*.class,*.exe,*.log,*.tlog,*pdb,*.ilk,*obj,*/_site/*,*/.git/*,*/_gist_cache/*,*/node_modules/*,*.o,*.a,*.tmp,./html/,._*,*.pp,target

let g:ctrlp_working_path_mode = 0

"By default
let g:SuperTabDefaultCompletionType = "<c-p>"

let g:startify_custom_header = ['','   Vim']

" ############
" Autocommands
" ############

"Automatically add gates for .h files
function! s:insert_gates()
  let gatename = substitute(toupper(expand("%:t")), "\\.", "_", "g")
  execute "normal! i#ifndef " . gatename
  execute "normal! o#define " . gatename . " "
  execute "normal! Go#endif /* " . gatename . " */"
  normal! kkjo
endfunction
autocmd BufNewFile *.{h,hpp} call <SID>insert_gates()

augroup filetype
  au! BufRead,BufNewFile *.proto setfiletype proto
augroup end

au BufRead,BufNewFile *.sqf,*.sqs  setf sqf

au BufRead,BufNewFile *.go map <F5> :GoBuild<CR>

" ####################
" Load local additions
" ####################
"
if filereadable(glob("~/.vimrc_local"))
  source ~/.vimrc_local
end

