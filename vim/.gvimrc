set mouse=a
set hlsearch
set noincsearch
set nowrapscan
set nowrap

" replace tabs with spaces. 
au FileType c   set expandtab
au FileType cpp set expandtab
au FileType vim set expandtab
au FileType sh set expandtab
au FileType txt set expandtab
au FileType awk set expandtab
au FileType make set noexpandtab
au FileType python set expandtab

set encoding=utf-8


"           _               
"  __  ___ | | ___  _ _  ___
" / _|/ _ \| |/ _ \| '_|(_-<
" \__|\___/|_|\___/|_|  /__/
                          
"
" colorscheme peaksea
au FileType c colorscheme peaksea
au FileType cpp colorscheme peaksea
au FileType vim colorscheme peaksea
au FileType sh colorscheme peaksea
au FileType txt colorscheme peaksea
au FileType make colorscheme peaksea
au FileType awk colorscheme peaksea
au FileType xml colorscheme peaksea
au FileType python colorscheme peaksea

" if has("gui_running")
"   " GUI is running or is about to start.
"   " Maximize gvim window.
"   set lines=999 columns=999
" else
"   " This is console Vim.
"   if exists("+lines")
"     set lines=50
"   endif
"   if exists("+columns")
"     set columns=100
"   endif
" endif


"
"                 _  _  _             
"  ___ _ __  ___ | || |(_) _ _   __ _ 
" (_-<| '_ \/ -_)| || || || ' \ / _` |
" /__/| .__/\___||_||_||_||_||_|\__, |
"     |_|                       |___/ 
"
" CTRL-X s -  to find suggestions
" to turn off :set nospell
" click z= to see correction options for misspled work under cursor
"
" turn spelling on
setlocal spell spelllang=en_us
set nospell
" map CTRL-p to switch spelling on/off
map <C-p> :set spell!<cr>

" auto complete words using the files set in dictionary
" with the CTRL-X,CTRL-K 
" (not be confused with CTRL-p completes words from open buffers )
map <c-f6> :call Update_dict()<cr>
function! Update_dict ()
   !~/.vim/update_dictionary.sh
   source ~/.vim/.vimrc.dictionary
endfunc
" source ~/.vim/.vimrc.dictionary


let g:netrw_liststyle=3
let g:netrw_keepdir=0
set lcs=tab::\ ,eol:$,trail:. "
set nolist "
" set grepprg=grep\ -nHr\ --exclude=*svn*\ --include=*.cpp\ --include=*\.\[c,h\]\  
set grepprg=grep\ -nHr\ --exclude=tags\ --exclude=*svn*\  

map <S-s> :w<CR>
map <S-w> :tabedit 
map <S-w><S-w> :tabclose<CR> 
" map <S-h> :noh<CR> 
map <silent> <S-h> :let @/=""<CR>

" map <S-right> :tabnext<CR> 
" map <S-left> :tabprevious<CR> 
" map <C-l> :tabnext<CR> 
" map <C-k> :tabprevious<CR> 

" surround selected text with quotes.
" map <F2> c"<C-R>""<ESC>xx
map <F2> c"<esc>pi"<esc>

" map <C-q><C-a> :qa!<CR>
" map <C-a> :q!
" map <C-a><C-a> :qa!
map <C-w><C-w> :qa!
map <C-w><C-w><C-w> :wqa!

" redraw screen up/downward while keeping cursor in the middle of the screen
map <C-y> kzz
map <C-e> jzz

" CTRL-i will go into insert mode and press ENTER 
" same as 'o' but takes the rest of the line with it
" map <C-i>: setic!<cr>

" delete trailing spaces in the entire file
vmap <f12> :s/\s\+$//<CR>


" all files should have this tab setting 
" except text files 
au FileType c   set tabstop=4
au FileType c   set shiftwidth=4
au FileType cpp set tabstop=4
au FileType cpp set shiftwidth=4
au FileType txt set tabstop=3
au FileType txt set shiftwidth=3
au FileType sh  set tabstop=4
au FileType sh  set shiftwidth=4
au FileType make  set tabstop=4
au FileType make  set shiftwidth=4
au FileType python  set tabstop=4
au FileType python  set shiftwidth=4



" comment shortcut for different file types.
" add unrecognized file types definitions in 
" .vim/ftdetect/mine.vim
" 
" filetype plugin on
au FileType cpp vmap <S-c> :s/^/\/\/\ /g<CR>:nohl<CR> 
au FileType c vmap <S-c> :s/^/\/\/\ /g<CR>:nohl<CR> 
au FileType sh vmap <S-c> :s/^/#\ /g<CR>:nohl<CR>
au FileType make vmap <S-c> :s/^/#\ /g<CR>:nohl<CR>
au FileType conf vmap <S-c> :s/^/#\ /g<CR>:nohl<CR>
au FileType python vmap <S-c> :s/^/#\ /g<CR>:nohl<CR>
au FileType vim vmap <S-c> :s/^/"\ /g<CR>:nohl<CR>

" for some reason this does not work
" comment lines shortcut
" if &ft=='c' || &ft=='cpp'
" vmap <S-c> :s/^/\/\/\ /g<CR>:nohl<CR>
" else
" vmap <S-c> :s/^/#\ /g<CR>:nohl<CR>
" endif

" show/unshow hidded characters.
" map <A-k> :set list!<CR>

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
" "let g:mapleader = ","

" Fast saving
nmap <leader>w :w!<cr>

" show/hide line numbers
map <C-n> : set nu!<CR>

" Fast editing of the .vimrc
map <leader>m :source ~/.gvimrc<CR>
map <leader>e :tabedit ~/.vim/.gvimrc<CR>
map <leader>s :tabedit ~/docs/vim/vim_symbols.txt<CR>
" map <leader>f :!figlet -m0 -f small 
" vmap <leader>f y:!figlet -m0 -f small <C-R>"  > x <CR> :r x<CR> :!rm -f x<cr><cr>
vmap <F1> y:!figlet -m0 -f small <C-R>"  > x <CR> :r x<CR> :!rm -f x<cr><cr>
vmap <F1><F1> y:!figlet -m0  <C-R>"  > x <CR> :r x<CR> :!rm -f x<cr><cr>

function! Insert_indent_symbol (number)
   let v=a:number 
   let s="r! sed -n '".v."p' /home/yonic/.vim/vim_indent_symbols.txt"
   echom s
   exec s
endfunc

" usage - :I2 or and other number 
com! -nargs=1 I call Insert_indent_symbol(<f-args>)
map <leader>l :call Insert_indent_symbol(1)<CR>

vmap / y/<C-R>"<CR>

set smartindent
set cindent

set ic

"
"  for vimdiff
"
" set diffopt+=iwhite
if &diff 
	colorscheme peaksea
    map [p ]c
    map ]p [c
endif


function! Auto_comp_paren ()
   inoremap ( ()<esc>i
   inoremap < <><esc>i
   inoremap [ []<esc>i
   inoremap " ""<esc>i
   inoremap ' ''<esc>i
   inoremap { {<CR>}<esc><up>o 
endfunc


function! Auto_comp_paren_disable ()
   inoremap ( (
   inoremap < <
   inoremap [ [
   inoremap " "
   inoremap ' '
   inoremap { {
endfunc

com! -nargs=1 II call SetIndent(<f-args>)
function! SetIndent (indent) 
   let v=a:indent 
   execute 'set tabstop='.v
   execute 'set shiftwidth='.v
endfunc

set ruler
set wildmenu
set laststatus=2
set statusline=%<%F\ %h%m%r%=%-14.(\[%l:%L\]\[%c\]%)\ %P

set guifont=Monospace\ 9

"
" TABS
"
" setting this will cause :sb <buf number> to open buffers in new tabs
" set switchbuf=split,usetab,newtab
" open files with 'e' in new tabs
" au BufAdd,BufNewFile * nested tab sball

"
" TAGS
"
" open a tag under the cursor in a new tab
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
nnoremap gf <C-W>gf

function! Cpptags () 
	execute ':!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q --extra=+f'
endfunc	
map <C-c> :call Cpptags()<cr>

" help vim commands
" -------------
" vab - will visual select inner block including block limiters
" vib - will select the same but without the limiters 
"   the limiters for example of ( text ) are the brackets or in 
"   [ text ] are the square brackets
"
" :tab ba will open all buffers with tabs
"



" insert time date 
" the format is the same as the date command.

:nnoremap <F5> "=strftime("%A %d/%m/%Y")<CR>P
:inoremap <F5> <C-R>=strftime("%A %d/%m/%Y")<CR>
