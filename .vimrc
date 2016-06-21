"Vim Configuration
"Lauri Makinen
""http://laurimakinen.net

set nocompatible
set nomodeline

let mapleader=","
let maplocalleader=","

call pathogen#infect()

"gvim
if has("gui_running")
    set guioptions=ac
    set guifont=Consolas:h10:cANSI
    winpos 1 1
    set lines=999
    set columns=999
	set cursorline
	set cursorcolumn
	color badwolf
	"color solarized
else
	"color darkblue
	color relaxedgreen
	"color koehler
	"color dante
	"color delek
    "color rootwater
	"color smyck
	"color solarized
endif

if has("win32") || has("win64")
	map <F5> :!build.bat<CR>
	map <F11> <Esc>:call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>
end

if has("unix")
	map <F5> :make<CR>:cs reset<CR><CR>
end

if has("cscope")
	set csto=0
	set cst
	set nocsverb
	if filereadable("cscope.out")
		cs add cscope.out
	elseif $CSCOPE_DB != ""
		cs add $CSCOPE_DB
	endif
	set csverb
endif

syntax on
set synmaxcol=2048
set background=dark

set noswapfile
set nobackup

filetype plugin on
filetype indent on

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

set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab
set shiftround
set autoindent

"Autocompletion stuff
let g:OmniCpp_MayCompleteScope=1
let g:OmniCpp_MayCompleteDot=1
let g:OmniCpp_MayCompleteArrow=1

"By default
let g:SuperTabDefaultCompletionType = "<c-p>"

"Common typos
cmap W w
cmap WQ wq
cmap wQ wq
cmap Q q

"ignores
set wildignore+=*.class,*.exe,*.log,*.tlog,*pdb,*.ilk,*obj,*/_site/*,*/.git/*,*/_gist_cache/*,*/node_modules/*,*.o,*.a,*.tmp,./html/

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

"Default positioning of { }Â is bit akward..
"noremap J }
"noremap K {
"
" Disabled because this is behaves differently on some vim installations.

"Make text editing easier
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

"tags
set tags=./tags;/;tags-static
set ofu=syntaxcomplete#Complete

"statusline
set stl=%f\ %m\ %r\ Line:\ %l/%L[%p%%]\ Col:\ %c\ Buf:\ #%n
set laststatus=2

let g:ctrlp_working_path_mode = 0

"custom functions

"Curl content of http and dump it into a new buffer
function! Gethttp()
    let url = input('url ~>')
    let html = system("curl -s ".url)
    split new
    call append(0,html)
endfunction

"Automatically add gates for .h files
function! s:insert_gates()
  let gatename = substitute(toupper(expand("%:t")), "\\.", "_", "g")
  execute "normal! i#ifndef " . gatename
  execute "normal! o#define " . gatename . " "
  execute "normal! Go#endif /* " . gatename . " */"
  normal! kkjo
endfunction
autocmd BufNewFile *.{h,hpp} call <SID>insert_gates()

"commands
:command Gethttp :call Gethttp()

map <F1> :copen<CR>
map <F3> :cclose<CR>
nmap <F2> :cn<CR>
nmap <S-F2> :cp<CR>
nmap <F4> :AsyncCommand ctags -R --c++-kinds=+p --fields=+iaS --extra=+q -R .<CR>
nmap <C-X> :FSHere<CR>

nmap <F6> :GundoToggle<CR>
nmap <F7> :NERDTreeToggle<cr>
nmap <silent><F8> :TlistToggle<CR>

set pastetoggle=<F9>

nmap <F12> :tab sball<CR>
nmap <C-Tab> :tabn<CR>
nmap <C-S-Tab> :tabp<CR>
nmap <C-n> :tab new<CR>

nmap § :tabn<CR>

"TODO: add split find
"TODO: Add ctags support to get windows stuff working.
"TODO: Automatically change the right tag system
nmap <C-T> :ts <C-R>=expand('<cword>')<CR><CR>
"nmap <C-T> :cs find g <C-R>=expand('<cword>')<CR><CR>

nnoremap <leader>p p
nnoremap <leader>P P
nnoremap p p'[v']=
nnoremap P P'[v']=

"Toggle fold or create fold with space
nnoremap <space> za
vnoremap <space> zf

"Vimwiki
let g:vimwiki_list = [{'path':'~/vimwiki','path_html':'~/vimwiki/html'}]

augroup filetype
  au! BufRead,BufNewFile *.proto setfiletype proto
augroup end

"Autocmd
function JavaSettings()
	"Mostly just eclim settings
	map <silent> <buffer> <C-T> :JavaSearchContext<cr>
	map <silent> <buffer> <C-G> :JavaDocSearch<cr>
	map <silent> <buffer> <C-I> :JavaImport<cr>
	let g:SuperTabDefaultCompletionType = "<c-x><c-u>"
	map <F1> :ProjectProblems<CR>
	map <F5> :ProjectBuild<CR>
endfunction

autocmd BufRead,BufNewFile *.java call JavaSettings()
au BufRead,BufNewFile *.ext        setf cpp
au BufRead,BufNewFile *.sqf,*.sqs  setf sqf

"Get rid of the useless whitespace!
autocmd BufWritePre * :%s/\s\+$//e
