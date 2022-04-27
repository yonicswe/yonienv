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
