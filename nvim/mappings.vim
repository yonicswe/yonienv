map <C-w><C-w> :qa!
"
" Fast editing of the .vimrc
map <leader>m :source ~/.config/nvim/init.vim<cr>:edit<cr>
map <leader>e :tabedit ~/.config/nvim/init.vim<cr>
map <leader>ss :tabedit ~/.vim/vim_symbols.txt<cr>
" map <leader>f :!figlet -m0 -f small
" vmap <leader>f y:!figlet -m0 -f small <C-R>"  > x <CR> :r x<CR> :!rm -f x<cr><cr>
vmap <F1> y:!figlet -m0 -f small <C-R>"  > x <CR> :r x<CR> :!rm -f x<cr><cr>
vmap <F1><F1> y:!figlet -m0 <C-R>"  > x <CR> :r x<CR> :!rm -f x<cr><cr>
map <S-s> :w<CR>
noremap <S-l> :set nohlsearch!<CR>

" click '/' on visualy selected text to search for it
vmap / y/<C-R>"<CR>

" select text and move it up/down with ctrl-up/down
vnoremap <C-Down> :m '>+1<CR>gv=gv
vnoremap <C-Up>   :m '<-2<CR>gv=gv
map <S-w> :tabedit 

" open help in vertical split window on the right
nnoremap <C-H> :vert bo help 

" ------------------------
"  cscope mappings
"  -------------------------
source ~/.vim/cscope.vim

nnoremap <S-F6> :ts<cr>
map <F11> :cp<cr>
map <F12> :cn<cr>
map <S-F9> :colder<cr>
map <S-F10> :cnewer<cr>
map <F3> :set spell!<cr>


function! ToggleQuickFix()
  if exists("g:qwindow")
"     lclose
    ccl
    unlet g:qwindow
  else
    copen
    let g:qwindow = 1
"     try
"       lopen 10
"       let g:qwindow = 1
"     catch
"       echo "No Errors found!"
"     endtry
  endif
endfunction
nmap <script> <silent> <F6> :call ToggleQuickFix()<CR>

" file buffers
nnoremap <A-down> :bnext<CR>
nnoremap <A-up> :bprevious<CR>
nnoremap <S-F8> :Buffers<cr>

" tag browsing
nnoremap <C-S-Up> :pop<CR>
nnoremap <C-S-Down> :tag<CR>
nnoremap <S-F6> :ts<cr>

" redraw screen up/downward while keeping cursor in the middle of the screen
map <C-y> kzz
map <C-e> jzz

" erase trailing white space
vmap <f12> :s/\s\+$//<CR>

" move cursor in insert mode
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-k> <Up>
inoremap <C-j> <Down>

" save in insert mode
inoremap <c-s><c-s> <c-\><c-o>:w<cr>

map cdf :cd %:h<cr>
